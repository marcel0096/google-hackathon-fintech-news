from atproto import Client
import os
import json


# ----------------------------
# 1. Connect to Bluesky API
# ----------------------------
BSKY_USERNAME = "azizbenali.bsky.social"
BSKY_PASSWORD = "7894561230"

client = Client()
client.login(BSKY_USERNAME, BSKY_PASSWORD)

# ----------------------------
# 2. Search for Crypto/Stock Posts
# ----------------------------
def fetch_bluesky_posts(query="crypto", limit=10, sort_by_popularity=False):
    posts = []
    cursor = None

    while len(posts) < limit:
        params = {"q": query}
        if cursor:
            params["cursor"] = cursor

        feed = client.app.bsky.feed.search_posts(params)

        for item in feed.posts:
            # Fetch author info and post stats
            try:
                author_info = client.app.bsky.actor.get_profile({"actor": item.author.handle})
            except Exception:
                author_info = None

            try:
                post_stats = client.app.bsky.feed.get_post_thread({"uri": item.uri})
                thread = post_stats.thread

                likes = getattr(thread.post, "like_count", 0)
                reposts = getattr(thread.post, "repost_count", 0)
                replies = getattr(thread.post, "reply_count", 0)
            except Exception:
                likes = reposts = replies = 0

            # Convert URI to URL
            post_id = item.uri.split("/")[-1]
            post_url = f"https://bsky.app/profile/{item.author.handle}/post/{post_id}"

            posts.append({
                "author": item.author.handle,
                "text": item.record.text,
                "url": post_url,  # <-- clickable URL
                "followers_count": getattr(author_info, "followers_count", 0),
                "likes": likes,
                "reposts": reposts,
                "replies": replies,
                "engagement_score": likes + reposts + replies,
                "created_at": item.record.created_at
            })

            if len(posts) >= limit:
                break

        cursor = getattr(feed, "cursor", None)
        if not cursor:  # No more posts available
            break

    if sort_by_popularity:
        posts.sort(key=lambda x: x["engagement_score"], reverse=True)

    return posts[:limit]

# ----------------------------
# 3. Run the Fetcher
# ----------------------------
if __name__ == "_main_":
    posts = fetch_bluesky_posts(query="BTC OR ETH OR crypto", limit=300)
    with open("bluesky_crypto_posts.json", "w", encoding="utf-8") as f:
        json.dump(posts, f, ensure_ascii=False, indent=4)