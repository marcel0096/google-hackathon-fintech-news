from google.cloud import firestore
from datetime import datetime

# Initialize Firestore
PROJECT_ID = "tum-cdtm25mun-8743"
db = firestore.Client(project=PROJECT_ID)

# Define assets
assets = [
    {"symbol": "BTC", "full_name": "Bitcoin", "last_scrape": None},
    {"symbol": "ETH", "full_name": "Ethereum", "last_scrape": None},
    {"symbol": "SLM", "full_name": "Selenium", "last_scrape": None},
    {"symbol": "AAPL", "full_name": "Apple Inc.", "last_scrape": None},
    {"symbol": "MSFT", "full_name": "Microsoft Corp.", "last_scrape": None},
]

# Add documents
for asset in assets:
    doc_ref = db.collection("active_assets").document(asset["symbol"])
    doc_ref.set(asset)
    print(f"Created document for {asset['symbol']}")
