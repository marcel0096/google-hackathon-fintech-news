import json
from google.cloud import pubsub_v1

project_id = "tum-cdtm25mun-8743"
topic_id = "incoming-events"

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, topic_id)


def publish_message(data: dict):
    """Publish a dict as JSON message to Pub/Sub."""
    payload = json.dumps(data).encode("utf-8")
    future = publisher.publish(topic_path, payload)
    message_id = future.result()
    print(f"📤 Published message ID: {message_id}")


if __name__ == "__main__":
    with open(
        "src/pub_sub_service/publish/adk_outputs.json", "r", encoding="utf-8"
    ) as f:
        events = json.load(f)

    # 1. Publish Google News articles
    for article in events.get("google_news", []):
        print("📤 Publishing Google News article...")
        publish_message(article)

    # 2. Publish Twitter feed items
    twitter_results = (
        events.get("twitter_feed", {})
        .get("fetch_X_tool_response", {})
        .get("result", [])
    )
    for tweet in twitter_results:
        print("📤 Publishing Twitter/X post...")
        publish_message(tweet)
