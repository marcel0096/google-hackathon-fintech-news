import json
from typing import Any, Dict, List


def parse_agent_run_response(raw_response: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Parses the raw /run response from your agent and returns structured JSON
    with google_news and twitter_news.
    """
    parsed_result = {"google_news": [], "twitter_news": []}

    for event in raw_response:
        if "content" not in event:
            continue

        for part in event["content"].get("parts", []):
            func_resp = part.get("functionResponse")
            if not func_resp:
                continue

            result_str = func_resp.get("response", {}).get("result")
            if not result_str:
                continue

            try:
                # Clean possible markdown fences
                cleaned = result_str.strip()
                if cleaned.startswith("```"):
                    cleaned = (
                        cleaned.removeprefix("```json")
                        .removeprefix("```")
                        .removesuffix("```")
                        .strip()
                    )

                data = json.loads(cleaned)

                # ✅ Case: Google
                if "google_news" in data:
                    parsed_result["google_news"].extend(data["google_news"])

                # ✅ Case: Twitter direct
                if "twitter_news" in data:
                    parsed_result["twitter_news"].extend(data["twitter_news"])

                # ✅ Case: Twitter wrapped in fetch_X_tool_response
                if "fetch_X_tool_response" in data:
                    parsed_result["twitter_news"].extend(
                        data["fetch_X_tool_response"].get("result", [])
                    )

            except Exception as e:
                print(f"Failed to parse {func_resp.get('name', '?')} result:", e)

    return parsed_result
