import json
from google.cloud import pubsub_v1, firestore
from normalize_json import normalize_event

# Configure Pub/Sub
project_id = "tum-cdtm25mun-8743"
subscription_id = "incoming-events-sub"
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(project_id, subscription_id)

# Configure Firestore
db = firestore.Client(project=project_id)


def callback(message: pubsub_v1.subscriber.message.Message) -> None:
    try:
        raw = json.loads(message.data.decode("utf-8"))
        doc = normalize_event(raw)

        print(f"📥 Received: {raw}")
        print(f"✅ Normalized: {doc}")

        db.collection("news").add(doc)
        print("📝 Written to Firestore.")

        message.ack()
    except Exception as e:
        print(f"❌ Error: {e}")
        message.nack()


# Start subscriber
streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
print(f"🚀 Listening for messages on {subscription_path}...")

try:
    streaming_pull_future.result()
except KeyboardInterrupt:
    streaming_pull_future.cancel()
