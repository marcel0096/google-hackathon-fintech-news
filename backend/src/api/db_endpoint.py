from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from google.cloud import firestore
from datetime import datetime, timezone
from dateutil import parser


project_id = "tum-cdtm25mun-8743"
app = FastAPI()
db = firestore.Client(project=project_id)


class NewsItem(BaseModel):
    id: str
    title: str
    summary: str
    source: str
    created_at: str
    sentiment: str


def humanize_time(ts_str: str) -> str:
    try:
        # Try parsing as ISO string
        dt = parser.parse(ts_str)
    except Exception:
        return ts_str  # fallback if parsing fails

    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)

    now = datetime.now(timezone.utc)
    delta = now - dt

    minutes = int(delta.total_seconds() // 60)
    hours = minutes // 60
    days = hours // 24

    if minutes < 60:
        return f"{minutes}min ago"
    elif hours < 24:
        return f"{hours}h ago"
    else:
        return f"{days}d ago"


@app.get("/news", response_model=List[NewsItem])
async def get_news():
    docs = db.collection("news").stream()
    news_list = []
    for doc in docs:
        data = doc.to_dict()

        # Ensure sentiment is always a string
        sentiment = data.get("sentiment")
        if sentiment is None:
            sentiment = "-"

        news_list.append(
            NewsItem(
                id=doc.id,
                title=data.get("title", "-"),
                summary=data.get("summary", "-"),
                source=data.get("source", "-"),
                created_at=humanize_time(str(data.get("created_at", "-"))),
                sentiment=str(sentiment),
            )
        )
    return news_list
