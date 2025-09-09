import asyncio
import json
import re
from datetime import datetime, timezone

from google.adk.agents import LlmAgent
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types
from google.adk.tools import agent_tool

# ✅ Use the ADK Google Search tool (instantiate it!)
from google.adk.tools import google_search
from multi_tool_agent.bluesky import fetch_bluesky_posts
# -------- Constants --------
APP_NAME_GSEARCH   = "google_search_app"
USER_ID_GSEARCH    = "user_gsearch_1"
SESSION_ID_GSEARCH = "session_gsearch_1"
AGENT_NAME_GSEARCH = "doc_qa_agent_google_search"
GEMINI_2_FLASH     = "gemini-2.5-pro"  # or another available model

# -------- Tool Instantiation --------
#google_search_tool = google_search()   # <-- instantiate the tool

# -------- Agent Definition --------


def fetch_X_tool(name: str) -> dict:

    return fetch_bluesky_posts(name, 10, sort_by_popularity=True)





google_agent = LlmAgent(
    name="google_agent",
    model=GEMINI_2_FLASH,
    tools=[google_search],  # <-- pass the tool instance, not the class
    instruction=(
        "You are a financial news analyst.\n"
        "Given a TICKER or topical headline (optionally with a candidate link), use the Google Search tool "
        "to read the most relevant coverage from the PAST 7 DAYS and return EXACTLY the following JSON array:\n"
        "[\n"
        "  {\n"
        "    \"title\": string,\n"
        "    \"extensive_summary\": string,\n"
        "    \"sentiment\": \"bullish\" | \"bearish\" | \"neutral\",\n"
        "    \"source\": string,  // publisher name only, NO URL\n"
        "    \"publication_date\": \"YYYY-MM-DD\"\n"
        "  }, ... up to 10 items, most recent first\n"
        "]\n"
        "Rules:\n"
        "- Base claims on sources you fetch via Google Search.\n"
        "- Prefer the past 7 days; if fewer items exist, return fewer.\n"
        "- Do NOT include URLs.\n"
        "- Use strict JSON with double quotes; no trailing commas; no extra commentary.\n"
        "- If an item is rumor/speculation, say so in the summary.\n"
        "- Output MUST be ONLY valid JSON (no prose before/after).\n"
        "- Dont include citations of numbers.\n"
    ),
    description="Answers questions using live Google Search grounding and returns strict JSON."
)

google_tool = agent_tool.AgentTool(agent=google_agent)


twitter_agent = LlmAgent(
    name="twitter_agent",
    model=GEMINI_2_FLASH,
    tools=[fetch_X_tool],  # <-- pass the tool instance, not the class
    instruction=(
        "You are a financial news analyst.\n"
        "Given a TICKER or topical headline, use the fetch_X_tool"
        "return the output as it is, just make sure its a good json structure"

    ),
    description="Answers questions using live twitter Search grounding and returns strict JSON."
)
twitter_tool = agent_tool.AgentTool(agent=twitter_agent)


root_agent = LlmAgent(
    name=AGENT_NAME_GSEARCH,
    model=GEMINI_2_FLASH,
    tools=[google_tool,twitter_tool],  # <-- pass the tool instance, not the class
    instruction=(
        "You are a financial news analyst.\n"
        "Given a TICKER or topical headline, use the google_tool"
        "Given a TICKER or topical headline, use the twitter_tool"
        "return the output as it is from both tools, just make sure its a good json structure"

    ),
    description="Answers questions using live google and twitter Search grounding depending on the given tools and returns strict JSON."
)

# -------- Session + Runner --------
session_service = InMemorySessionService()
runner = Runner(agent=root_agent, app_name=APP_NAME_GSEARCH, session_service=session_service)
session_service.create_session(
    app_name=APP_NAME_GSEARCH, user_id=USER_ID_GSEARCH, session_id=SESSION_ID_GSEARCH
)

# import asyncio
# asyncio.run(session_service.create_session(
#     app_name=APP_NAME_GSEARCH,
#     user_id=USER_ID_GSEARCH,
#     session_id=SESSION_ID_GSEARCH,
# ))

# -------- Helpers --------
def _today_iso():
    return datetime.now(timezone.utc).date().isoformat()

def _sanitize_filename(s: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", s).strip("_")

async def call_gsearch_agent_async(query: str) -> list:
    print("\n--- Running Google Search Grounded Agent ---")
    print(f"Query: {query}")

    content = types.Content(role="user", parts=[types.Part(text=query)])
    final_response_text = None
    grounding_attributions = 0

    try:
        async for event in runner.run_async(
            user_id=USER_ID_GSEARCH,
            session_id=SESSION_ID_GSEARCH,
            new_message=content
        ):
            if event.is_final_response() and event.content and event.content.parts:
                final_response_text = event.content.parts[0].text.strip()
            if getattr(event, "grounding_metadata", None):
                atts = getattr(event.grounding_metadata, "grounding_attributions", []) or []
                grounding_attributions += len(atts)

    except Exception as e:
        print(f"An error occurred: {e}")
        return []

    print(f"(Google Search grounding attributions seen: {grounding_attributions})")

    if not final_response_text:
        print("No response text received from agent.")
        return []

    # The agent is instructed to return strict JSON only.
    # Parse it; if parsing fails, try a common fallback (find the first JSON array).
    try:
        data = json.loads(final_response_text)
    except json.JSONDecodeError:
        # Fallback: extract first [...] block
        match = re.search(r"\[\s*{.*}\s*\]", final_response_text, re.DOTALL)
        if not match:
            print("Failed to parse JSON from the agent output.")
            return []
        try:
            data = json.loads(match.group(0))
        except Exception as e:
            print(f"Failed to parse extracted JSON block: {e}")
            return []

    if not isinstance(data, list):
        print("Parsed data is not a JSON array; returning empty list.")
        return []

    # Basic schema check + trim to 10
    required_keys = {"title", "extensive_summary", "sentiment", "source", "publication_date"}
    cleaned = []
    for item in data[:10]:
        if not isinstance(item, dict):
            continue
        if not required_keys.issubset(item.keys()):
            continue
        cleaned.append(item)
    # Save to file
    fname = f"{_sanitize_filename(query)}_{_today_iso()}.json"
    with open(fname, "w", encoding="utf-8") as f:
        json.dump(cleaned, f, ensure_ascii=False, indent=2)
    print(f"Saved {len(cleaned)} items to {fname}")
    return cleaned

# -------- Example run --------
async def run_gsearch_example():
    # Ask the agent to produce EXACT JSON for the ticker you want.
    # Make the intent explicit to help the model follow format:
    queries = [
        "AAPL"
    ]
    for q in queries:
        _ = await call_gsearch_agent_async(q)
        print(q)

if __name__ == "__main__":
    try:
        asyncio.run(run_gsearch_example())
    except RuntimeError as e:
        if "cannot be called from a running event loop" in str(e):
            print("Skipping execution in a running event loop (e.g., Colab/Jupyter). Run locally.")
        else:
            raise


