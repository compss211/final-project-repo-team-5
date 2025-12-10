#!/usr/bin/env python3
import os
import json
import time
from datetime import datetime, timedelta, timezone
from atproto import Client
from atproto.exceptions import AtProtocolError

# ============================
# CONFIGURATION
# ============================
QUERY = "chatgpt"
START_DATE = datetime(2022, 11, 30, tzinfo=timezone.utc)
END_DATE = datetime.now(timezone.utc) + timedelta(days=30)
STEP_DAYS = 30                        # Monthly chunks; reduce for high volume
SAVE_FILE = f"{QUERY}_historical.json"
RATE_LIMIT_CALLS = 60                 # Bluesky per 5 min window
WINDOW_SECONDS = 300
# ============================

# Load credentials
handle = os.getenv("BLUESKY_HANDLE") # replace this with your bluesky handle
password = os.getenv("BLUESKY_APP_PASSWORD") # replace this with your APP password, you can get one here: https://bsky.app/settings/app-passwords 
if not handle or not password:
    raise RuntimeError("❌ Please set BLUESKY_HANDLE and BLUESKY_APP_PASSWORD")

# Initialize client
client = Client()
client.login(handle, password)

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
# Load existing data if available
# ============================
if os.path.exists(SAVE_FILE):
    with open(SAVE_FILE, "r", encoding="utf-8") as f:
        all_posts = json.load(f)
    all_posts = deduplicate(all_posts)
    print(f"📂 Resuming from existing file with {len(all_posts)} unique posts")

    if all_posts:
        dates = [p["created_at"] for p in all_posts if p.get("created_at")]
        if dates:
            last_date = max(dates)
            last_dt = datetime.fromisoformat(last_date.replace("Z", "+00:00"))
            current = last_dt + timedelta(seconds=1)
            print(f"⏩ Resuming from {current.isoformat()} (last collected post)")
        else:
            current = START_DATE
    else:
        current = START_DATE
else:
    all_posts = []
    current = START_DATE
    print(f"🆕 Starting fresh from {START_DATE}")

# Track rate limiting
calls_in_window = 0
window_start = time.time()

# ============================
# Scraping loop
# ============================
try:
    while current < END_DATE:
        since = fmt(current)
        until = fmt(current + timedelta(days=STEP_DAYS))
        print(f"\n📅 Fetching {since} → {until}")

        cursor = None
        total_for_range = 0

        while True:
            # Rate limit check
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

            params = {
                "q": QUERY,
                "limit": 100,
                "since": since,
                "until": until,
            }
            if cursor:
                params["cursor"] = cursor

            try:
                res = client.app.bsky.feed.search_posts(params)
            except AtProtocolError as e:
                print(f"⚠️ Rate limit or API error: {e}. Waiting 5 minutes before retry...")
                save_checkpoint(all_posts)
                time.sleep(300)
                continue
            except Exception as e:
                print(f"❌ Error: {e}")
                save_checkpoint(all_posts)
                raise

            calls_in_window += 1

            if not res.posts:
                break

            for post in res.posts:
                all_posts.append({
                    "author": post.author.handle,
                    "text": getattr(post.record, "text", ""),
                    "created_at": post.indexed_at,
                    "uri": post.uri,
                    # Add engagement metrics
                    "like_count": getattr(post, "like_count", 0),
                    "repost_count": getattr(post, "repost_count", 0),
                    "reply_count": getattr(post, "reply_count", 0),
                    "quote_count": getattr(post, "quote_count", 0),  # Quote posts
                    # Additional useful fields
                    "author_display_name": getattr(post.author, "display_name", ""),
                    "author_avatar": getattr(post.author, "avatar", ""),
                    "has_embedded_media": bool(getattr(post.record, "embed", None)),
                    "languages": getattr(post.record, "langs", []),
                    # URLs and references
                    "cid": post.cid,  # Content identifier
                })

            total_for_range += len(res.posts)
            cursor = getattr(res, "cursor", None)
            if not cursor:
                break

            # Polite short delay
            time.sleep(0.5)

        print(f"  → Collected {total_for_range} posts for this window")
        current += timedelta(days=STEP_DAYS)

except KeyboardInterrupt:
    print("\n🛑 Interrupted by user")
    save_checkpoint(all_posts)

except Exception as e:
    print(f"\n❌ Fatal error: {e}")
    save_checkpoint(all_posts)
    raise

print(f"\n✅ Finished or hit rate limit — total collected: {len(deduplicate(all_posts))} unique posts")
save_checkpoint(all_posts)