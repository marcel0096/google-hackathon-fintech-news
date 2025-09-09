from google.cloud import firestore
from vertexai.preview.generative_models import GenerativeModel
from datetime import datetime, timedelta

# --- CONFIG ---
PROJECT_ID = "tum-cdtm25mun-8743"
COLLECTION = "news"
NUM_ENTRIES = 20
GEMINI_MODEL_NAME = "gemini-1.5-pro-preview-0514"  # update if newer model

# --- INIT CLIENTS ---
db = firestore.Client(project=PROJECT_ID)
model = GenerativeModel(GEMINI_MODEL_NAME, project=PROJECT_ID)


# --- FETCH LATEST ENTRIES ---
def fetch_latest_entries():
    query = (
        db.collection(COLLECTION)
        .order_by("created_at", direction=firestore.Query.DESCENDING)
        .limit(NUM_ENTRIES)
    )
    return [doc.to_dict() for doc in query.stream()]


# --- COMBINE TEXTS ---
def combine_summaries(entries):
    combined_text = ""
    for e in entries:
        ts = e.get("created_at", "")
        source = e.get("source", "unknown")
        summary = e.get("summary", "")
        combined_text += f"[{ts}] ({source}) {summary}\n\n"
    return combined_text


# --- GENERATE DIGEST USING GEMINI ---
def generate_digest(text):
    prompt = (
        "You are an expert at creating concise fintech news digests. "
        "Summarize the following updates into a short, actionable summary:\n\n"
        f"{text}"
    )
    response = model.predict(prompt)
    return response.text


# --- MAIN ---
if __name__ == "__main__":
    entries = fetch_latest_entries()
    if not entries:
        print("No entries found.")
    else:
        combined_text = combine_summaries(entries)
        print("📝 Combined text:\n", combined_text[:1000], "...\n")
        digest = generate_digest(combined_text)
        print("💡 Gemini Digest:\n", digest)
