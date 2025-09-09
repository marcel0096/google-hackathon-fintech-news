from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import uuid
import logging
from utils.response_parser import parse_agent_run_response

app = FastAPI()
logging.basicConfig(level=logging.INFO)

ADK_BASE = "http://127.0.0.1:8000"


class UserPrompt(BaseModel):
    prompt: str


@app.post("/ask_agent")
async def ask_agent(req: UserPrompt):
    user_id = f"u_{uuid.uuid4().hex[:6]}"
    session_id = f"s_{uuid.uuid4().hex[:6]}"
    app_name = "multi_tool_agent"

    async with httpx.AsyncClient(timeout=120.0) as client:
        try:
            # 1️⃣ Create session
            session_payload = {"state": {}}
            session_resp = await client.post(
                f"{ADK_BASE}/apps/{app_name}/users/{user_id}/sessions/{session_id}",
                json=session_payload,
            )
            session_resp.raise_for_status()
            logging.info(f"Created session {session_id} for user {user_id}")

            # 2️⃣ Run the user prompt
            run_payload = {
                "app_name": app_name,
                "user_id": user_id,
                "session_id": session_id,
                "new_message": {"role": "user", "parts": [{"text": req.prompt}]},
            }
            run_resp = await client.post(f"{ADK_BASE}/run", json=run_payload)
            run_resp.raise_for_status()

            # 3️⃣ Return the raw events list exactly as received
            raw_response = run_resp.json()
            # parsed_json = parse_agent_run_response(raw_response)
            return raw_response

        except httpx.HTTPStatusError as e:
            logging.error(f"HTTP error: {e}")
            raise HTTPException(status_code=500, detail=str(e))
        except Exception as e:
            logging.exception("Unexpected error")
            raise HTTPException(status_code=500, detail=str(e))
