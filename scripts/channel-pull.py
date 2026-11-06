#!/usr/bin/env python3
"""channel-pull.py: public data pull for a Channel Dossier (channel-analyst, P3). Free: yt-dlp only, no login.

usage: channel-pull.py <@handle | channel URL> OUT_DIR [--max N] [--detail-long N] [--detail-shorts N]
Writes OUT_DIR/channel.json (name, id, handle, subscribers, description, tab counts, pulled_at) and
OUT_DIR/videos.csv: one row per upload from the Videos and Shorts tabs (flat: id, format, rank, title,
duration, views), plus full metadata for the newest N of each format (upload_date, likes, comments, tags,
chapters, description links, sponsor/affiliate markers). Rank 0 = newest. Numbers are what YouTube shows
publicly at pull time (rounded on the page for big counts); nothing is estimated here.
Optional: YOUTUBE_API_KEY (or CLAUDE_PLUGIN_OPTION_YOUTUBE_API_KEY) adds exact channel statistics and the
channel creation date. Stdlib + yt-dlp on PATH.
"""
import csv, datetime, json, os, re, subprocess, sys, urllib.parse, urllib.request

SPONSOR = re.compile(r'\b(sponsor(ed)?|paid promotion|#ad\b|use code|promo code|discount code|affiliate|partnered with)\b', re.I)
LINK = re.compile(r'https?://[^\s)>\]]+')

def ytdlp(args):
    r = subprocess.run(['yt-dlp', '--ignore-errors', '--no-warnings', '--sleep-requests', '0.5'] + args, capture_output=True, text=True)
    return r.stdout

def flat(url, n):
    out = ytdlp(['--flat-playlist', '-J', '--playlist-end', str(n), url])
    try:
        return json.loads(out) or {}  # yt-dlp prints null for a missing tab (Shorts-only channel) or a bad handle
    except ValueError:
        return {}

def detail(vid):
    out = ytdlp(['--skip-download', '-j', f'https://www.youtube.com/watch?v={vid}'])
    try:
        return json.loads(out.splitlines()[0])
    except (ValueError, IndexError):
        return {}

def api_stats(cid):
    key = os.environ.get('YOUTUBE_API_KEY') or os.environ.get('CLAUDE_PLUGIN_OPTION_YOUTUBE_API_KEY')
    if not key or not cid:
        return {}
    q = urllib.parse.urlencode({'part': 'snippet,statistics', 'id': cid, 'key': key})
    try:
        d = json.load(urllib.request.urlopen(f'https://www.googleapis.com/youtube/v3/channels?{q}', timeout=20))
        it = d['items'][0]
        return {'api_published_at': it['snippet'].get('publishedAt'), 'api_country': it['snippet'].get('country'),
                'api_subscribers': it['statistics'].get('subscriberCount'), 'api_total_views': it['statistics'].get('viewCount'),
                'api_video_count': it['statistics'].get('videoCount')}
    except Exception as e:
        return {'api_error': str(e)[:200]}

def main():
    a = sys.argv[1:]
    if len(a) < 2:
        print(__doc__); sys.exit(2)
    src, out = a[0], a[1]
    opt = lambda k, d: int(a[a.index(k) + 1]) if k in a else d
    nmax, dl, ds = opt('--max', 1000), opt('--detail-long', 25), opt('--detail-shorts', 40)
    base = src if src.startswith('http') else f'https://www.youtube.com/{src if src.startswith("@") else "@" + src}'
    base = base.rstrip('/')
    os.makedirs(out, exist_ok=True)
    rows, ch = [], {}
    for fmt, tab in (('long', 'videos'), ('short', 'shorts')):
        d = flat(f'{base}/{tab}', nmax)
        if not ch and d:
            ch = {k: d.get(k) for k in ('channel', 'channel_id', 'uploader_id', 'channel_follower_count', 'description', 'channel_url')}
        ents = d.get('entries') or []
        ch[f'{tab}_pulled'] = len(ents)
        for i, e in enumerate(ents):
            rows.append({'id': e.get('id'), 'format': fmt, 'rank': i, 'title': e.get('title'), 'duration': e.get('duration'),
                         'views': e.get('view_count'), 'url': f"https://www.youtube.com/watch?v={e.get('id')}"})
    if not rows:
        print('FAIL: nothing pulled (blocked, wrong handle or rate-limited). Name it in "could not examine".'); sys.exit(1)
    want = {r['id'] for r in rows if (r['format'] == 'long' and r['rank'] < dl) or (r['format'] == 'short' and r['rank'] < ds)}
    for r in rows:
        if r['id'] not in want:
            continue
        m = detail(r['id'])
        if not m:
            r['detail'] = 'failed'; continue
        desc = m.get('description') or ''
        links = LINK.findall(desc)
        r.update({'detail': 'ok', 'upload_date': m.get('upload_date'), 'likes': m.get('like_count'), 'comments': m.get('comment_count'),
                  'views': m.get('view_count') or r['views'], 'duration': m.get('duration') or r['duration'], 'tags': len(m.get('tags') or []), 'chapters': len(m.get('chapters') or []),
                  'link_domains': ' '.join(sorted({urllib.parse.urlparse(u).netloc.replace('www.', '') for u in links})),
                  'sponsor_marker': (SPONSOR.search(desc).group(0) if SPONSOR.search(desc) else ''),
                  'language': m.get('language') or ''})
    ch.update(api_stats(ch.get('channel_id')))
    ch['source'] = base
    ch['pulled_at'] = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds')
    ch['method'] = 'yt-dlp public pages' + (' + YouTube Data API' if any(k.startswith('api_') for k in ch) else '')
    json.dump(ch, open(os.path.join(out, 'channel.json'), 'w'), indent=1, ensure_ascii=False)
    cols = ['id', 'format', 'rank', 'title', 'duration', 'views', 'upload_date', 'likes', 'comments', 'tags', 'chapters', 'link_domains', 'sponsor_marker', 'language', 'detail', 'url']
    with open(os.path.join(out, 'videos.csv'), 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction='ignore'); w.writeheader(); w.writerows(rows)
    nd = sum(1 for r in rows if r.get('detail') == 'ok'); nf = sum(1 for r in rows if r.get('detail') == 'failed')
    print(f"pulled {ch.get('channel')}: {ch.get('videos_pulled', 0)} long, {ch.get('shorts_pulled', 0)} shorts; detail ok {nd}, failed {nf} -> {out}")

if __name__ == '__main__':
    main()
