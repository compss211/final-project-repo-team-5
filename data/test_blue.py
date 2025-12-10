#!/usr/bin/env python3
import os
import json
import time
from datetime import datetime, timedelta, timezone
from atproto import Client
from atproto.exceptions import AtProtocolError
from dotenv import load_dotenv
load_dotenv()

# ============================
# CONFIGURATION
# ============================
QUERIES = ["chatgpt", "openai", "llm", "ai", "gemini", "deepseek"]  # multiple keywords
START_DATE = datetime(2022, 11, 30, tzinfo=timezone.utc)
END_DATE = datetime.now(timezone.utc) + timedelta(days=30)
STEP_DAYS = 30                        # Monthly chunks; reduce for high volume
RATE_LIMIT_CALLS = 60                 # Bluesky per 5 min window
WINDOW_SECONDS = 300
SAVE_FILE = "test_ai_posts_historical.json"  # single file for all keywords
# ============================

# Load credentials
handle = os.getenv("BLUESKY_HANDLE")
password = os.getenv("BLUESKY_APP_PASSWORD")
if not handle or not password:
    raise RuntimeError("❌ Please set BLUESKY_HANDLE and BLUESKY_APP_PASSWORD")

# Initialize client
client = Client()
client.login(handle, password)

# --- PATCH: Fix Bluesky image aspectRatio schema bug ---
def safe_search_posts(params):
    """Wrapper for client.app.bsky.feed.search_posts that fixes schema mismatches."""
    try:
        return client.app.bsky.feed.search_posts(params)
    except Exception as e:
        if "literal_error" in str(e) or "aspectRatio" in str(e):
            print("⚙️  Detected schema mismatch — fetching raw JSON to patch...")
            try:
                # Get raw response JSON directly from the endpoint
                raw = client.com.atproto.repo.list_records(params)
                if isinstance(raw, dict):
                    def fix_aspect_ratio(obj):
                        if isinstance(obj, dict):
                            for k, v in obj.items():
                                if k == "$type" and v == "app.bsky.embed.images#aspectRatio":
                                    obj[k] = "app.bsky.embed.defs#aspectRatio"
                                else:
                                    fix_aspect_ratio(v)
                        elif isinstance(obj, list):
                            for item in obj:
                                fix_aspect_ratio(item)
                    fix_aspect_ratio(raw)
                    # Attempt to revalidate
                    return client.app.bsky.feed.search_posts._model_validate(raw)
            except Exception as inner_e:
                print(f"⚠️  Retrying after patch failed: {inner_e}")
                return None
        # rethrow any other error
        raise


# Helper: date → ISO string
def fmt(dt):
    return dt.strftime("%Y-%m-%dT%H:%M:%S.000Z")

# Helper: deduplicate by URI
def deduplicate(posts):
    seen = {}
    for p in posts:
        if p.get("uri"):
            seen[p["uri"]] = p
    return list(seen.values())

# Helper: save intermediate progress
def save_checkpoint(posts):
    unique_posts = deduplicate(posts)
    with open(SAVE_FILE, "w", encoding="utf-8") as f:
        json.dump(unique_posts, f, ensure_ascii=False, indent=2)
    print(f"💾 Checkpoint saved — total {len(unique_posts)} unique posts")

# ============================
# MAIN SCRAPING LOOP
# ============================

all_posts = []
current = START_DATE
calls_in_window = 0
window_start = time.time()

try:
    for query in QUERIES:
        print(f"\n🔎 Searching for '{query}'...")
        current = START_DATE
        while current < END_DATE:
            since = fmt(current)
            until = fmt(current + timedelta(days=STEP_DAYS))
            cursor = None

            while True:
                # Rate limiting
                now = time.time()
                if calls_in_window >= RATE_LIMIT_CALLS:
                    elapsed = now - window_start
                    if elapsed < WINDOW_SECONDS:
                        wait_time = WINDOW_SECONDS - elapsed
                        print(f"⏸️  Rate limit hit — waiting {wait_time/60:.1f} minutes...")
                        save_checkpoint(all_posts)
                        time.sleep(wait_time)
                    calls_in_window = 0
                    window_start = time.time()

                params = {"q": query, "limit": 100, "since": since, "until": until}
                if cursor:
                    params["cursor"] = cursor

                try:
                    res = safe_search_posts(params)
                except AtProtocolError as e:
                    print(f"⚠️ API error: {e}. Waiting 5 minutes...")
                    save_checkpoint(all_posts)
                    time.sleep(300)
                    continue
                except Exception as e:
                    print(f"❌ Unexpected error: {e}")
                    save_checkpoint(all_posts)
                    raise

                calls_in_window += 1

                if not getattr(res, "posts", []):
                    break

                for post in res.posts:
                    all_posts.append({
                        "keyword": query,
                        "author": post.author.handle,
                        "text": getattr(post.record, "text", ""),
                        "created_at": post.indexed_at,
                        "uri": post.uri,
                        "like_count": getattr(post, "like_count", 0),
                        "repost_count": getattr(post, "repost_count", 0),
                        "reply_count": getattr(post, "reply_count", 0),
                        "author_display_name": getattr(post.author, "display_name", ""),
                        "has_embedded_media": bool(getattr(post.record, "embed", None)),
                    })

                cursor = getattr(res, "cursor", None)
                if not cursor:
                    break

                time.sleep(0.5)

            current += timedelta(days=STEP_DAYS)
            save_checkpoint(all_posts)

except KeyboardInterrupt:
    print("\n🛑 Interrupted by user")
    save_checkpoint(all_posts)

print(f"\n🎉 Finished — total unique posts: {len(deduplicate(all_posts))}")
save_checkpoint(all_posts)
