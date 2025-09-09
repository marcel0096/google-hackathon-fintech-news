def normalize_event(event: dict) -> dict:
    """Normalize different schemas into a unified format."""

    # Twitter-like schema
    if "text" in event and "author" in event:
        return {
            "title": "Social Media Post",
            "source": event["author"],
            "summary": event["text"],
            "followers_count": event.get("followers_count", None),
            "sentiment": None,
            "created_at": event["created_at"],
        }

    # google news like schema
    elif "title" in event and "extensive_summary" in event:
        return {
            "title": event.get("title"),
            "source": event.get("source"),
            "summary": event["extensive_summary"],
            "followers_count": None,
            "sentiment": event.get("sentiment"),
            "created_at": event["publication_date"] + "T00:00:00Z",
        }

    # Fallback for unknown schemas
    return {
        "source": event.get("author") or event.get("source"),
        "summary": event.get("text") or event.get("extensive_summary"),
        "followers_count": event.get("followers_count"),
        "sentiment": event.get("sentiment"),
        "created_at": event.get("created_at") or event.get("publication_date"),
    }
