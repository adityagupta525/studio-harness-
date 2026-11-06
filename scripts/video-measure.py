#!/usr/bin/env python3
"""video-measure.py: measured numbers for one video, so nobody describes a reference or a take from a guess.

usage: video-measure.py VIDEO OUT_DIR [--thresholds 0.3,0.08] [--sheet-fps 1]

Needs ffmpeg and ffprobe on PATH (exit 2 if missing). Standard library only.
Writes OUT_DIR/measure.json, OUT_DIR/measure.md and OUT_DIR/contact-sheet.jpg:
  - duration, fps, resolution, aspect (display rotation applied)
  - scene changes per threshold: ffmpeg select='gt(scene,T)',showinfo, pts_time parsed from the log.
    The highest threshold is read as hard cuts; the lowest also counts panel flips, whip pans and fast
    3D moves, so its raw changes are clustered (changes closer than 0.25 s merge into one).
  - shots, average shot length (ASL), shots per 10 s and cuts in the first 3 s, per threshold
  - integrated loudness (EBU R128: LUFS, LRA, true peak) when the file has audio
  - a contact sheet (ffmpeg fps + tile); cell i shows the frame at about i / sheet_fps seconds
  - words per second over the speech span, if VIDEO_STEM*.vtt or VIDEO_STEM*.srt sits beside the video
Thresholds are reading aids, not proof: dissolves and morphs hide cuts, flashes invent them. Say which
threshold an ASL came from, and check a doubtful window frame by frame.
"""
import argparse, glob, json, math, os, re, shutil, subprocess, sys

CLUSTER_GAP = 0.25   # seconds; low-threshold changes closer than this are one transition
HOOK_WINDOW = 3.0    # seconds counted as the opening
MAX_SHEET_CELLS = 60


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, errors='replace')


def ratio(s):
    try:
        a, b = s.split('/')
        return float(a) / float(b) if float(b) else None
    except (ValueError, AttributeError):
        return None


def probe(path):
    p = run(['ffprobe', '-v', 'error', '-show_entries',
             'format=duration:stream=codec_type,width,height,avg_frame_rate,r_frame_rate:stream_tags=rotate:stream_side_data=rotation',
             '-of', 'json', path])
    if p.returncode != 0:
        sys.exit(f'ffprobe could not read {path}: {p.stderr.strip()[:300]}')
    d = json.loads(p.stdout or '{}')
    v = next((s for s in d.get('streams', []) if s.get('codec_type') == 'video'), None)
    if not v:
        sys.exit(f'no video stream in {path}')
    has_audio = any(s.get('codec_type') == 'audio' for s in d.get('streams', []))
    w, h = v.get('width'), v.get('height')
    rot = 0
    try:
        rot = int(float((v.get('tags') or {}).get('rotate', 0)))
    except ValueError:
        pass
    for sd in v.get('side_data_list') or []:
        if 'rotation' in sd:
            rot = int(sd['rotation'])
    if abs(rot) % 180 == 90:
        w, h = h, w
    fps = ratio(v.get('avg_frame_rate')) or ratio(v.get('r_frame_rate'))
    dur = float((d.get('format') or {}).get('duration') or 0)
    g = math.gcd(w, h) if w and h else 1
    return {'duration_s': round(dur, 3), 'fps': round(fps, 3) if fps else None, 'width': w, 'height': h,
            'aspect': f'{w // g}:{h // g}' if w and h else None, 'aspect_decimal': round(w / h, 4) if w and h else None,
            'orientation': 'vertical' if h > w else 'horizontal' if w > h else 'square', 'has_audio': has_audio}


def scene_times(path, t):
    p = run(['ffmpeg', '-hide_banner', '-nostats', '-i', path, '-an', '-sn',
             '-vf', f"select='gt(scene,{t})',showinfo", '-f', 'null', '-'])
    return [round(float(m), 3) for m in re.findall(r'Parsed_showinfo.*?pts_time:\s*([0-9.]+)', p.stderr)]


def cluster(times, gap=CLUSTER_GAP):
    out, last = [], None
    for x in sorted(times):
        if last is None or x - last > gap:
            out.append(x)
        last = x
    return out


def shot_stats(cuts, dur):
    shots = len(cuts) + 1
    edges = [0.0] + cuts + [dur]
    lengths = [b - a for a, b in zip(edges, edges[1:]) if b - a > 0]
    return {'cuts': len(cuts), 'shots': shots, 'asl_s': round(dur / shots, 2) if dur else None,
            'shortest_s': round(min(lengths), 2) if lengths else None, 'longest_s': round(max(lengths), 2) if lengths else None,
            'shots_per_10s': round(shots / dur * 10, 2) if dur else None,
            'cuts_first_3s': sum(1 for c in cuts if c < HOOK_WINDOW), 'cut_times_s': cuts}


def loudness(path):
    p = run(['ffmpeg', '-hide_banner', '-nostats', '-i', path, '-vn', '-af', 'ebur128=peak=true', '-f', 'null', '-'])
    s = p.stderr[p.stderr.rfind('Summary:'):] if 'Summary:' in p.stderr else ''
    if not s:
        return {'note': 'ebur128 gave no summary'}
    f = lambda rx: (lambda m: float(m.group(1)) if m else None)(re.search(rx, s, re.S))
    return {'integrated_lufs': f(r'I:\s*(-?[0-9.]+|-inf)\s*LUFS'), 'lra_lu': f(r'LRA:\s*(-?[0-9.]+)\s*LU'),
            'true_peak_dbtp': f(r'True peak:.*?Peak:\s*(-?[0-9.]+)')}


def contact_sheet(path, info, out, fps):
    dur = info['duration_s'] or 1
    fps = min(fps, MAX_SHEET_CELLS / dur)
    n = max(1, int(dur * fps))
    cols = 6 if info['orientation'] == 'vertical' else 4
    rows = math.ceil(n / cols)
    width = 200 if info['orientation'] == 'vertical' else 320
    p = run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-i', path, '-an', '-vf',
             f'fps={fps:.4f},scale={width}:-2,tile={cols}x{rows}:padding=4:margin=4', '-frames:v', '1', '-q:v', '3', out])
    if p.returncode != 0 or not os.path.exists(out):
        return {'error': p.stderr.strip()[:300]}
    return {'file': os.path.basename(out), 'cells': n, 'grid': f'{cols}x{rows}', 'seconds_per_cell': round(1 / fps, 3)}


def ts(s):
    m = re.match(r'(?:(\d+):)?(\d+):(\d+)[.,](\d+)', s.strip())
    if not m:
        return None
    h, mi, se, ms = m.groups()
    return int(h or 0) * 3600 + int(mi) * 60 + int(se) + int(ms.ljust(3, '0')[:3]) / 1000


def speech_rate(video):
    stem = os.path.splitext(video)[0]
    subs = sorted(glob.glob(glob.escape(stem) + '*.vtt') + glob.glob(glob.escape(stem) + '*.srt'))
    if not subs:
        return None
    path = subs[0]
    text = open(path, encoding='utf-8', errors='replace').read().replace('\r', '')
    starts, ends, lines, recent = [], [], [], []
    for block in re.split(r'\n\s*\n', text):
        rows = block.strip().split('\n')
        i = next((k for k, r in enumerate(rows) if '-->' in r), None)
        if i is None:
            continue
        a, b = rows[i].split('-->')[:2]
        a, b = ts(a), ts(b.split()[0] if b.split() else '')
        if a is None or b is None:
            continue
        cue_has_words = False
        for r in rows[i + 1:]:
            r = re.sub(r'<[^>]+>', '', r)
            r = re.sub(r'\[[^\]]*\]', '', r).strip()   # [Music], [Applause]
            if r and r not in recent:                  # auto-captions repeat the last line or two
                lines.append(r); recent = (recent + [r])[-3:]; cue_has_words = True
        if cue_has_words:
            starts.append(a); ends.append(b)
    words = sum(len(re.findall(r"[\w'’-]+", l)) for l in lines)
    if not starts:
        return {'file': os.path.basename(path), 'words': 0, 'note': 'no speech cues'}
    span = max(ends) - min(starts)
    return {'file': os.path.basename(path), 'words': words, 'speech_start_s': round(min(starts), 2),
            'speech_end_s': round(max(ends), 2), 'speech_span_s': round(span, 2),
            'words_per_second': round(words / span, 2) if span > 0 else None,
            'note': 'auto-captions are approximate; deduplicated rolling lines'}


def write_md(m, path):
    i = m['video']
    L = [f"# Video measure: {os.path.basename(m['source'])}", '',
         f"Measured {m['measured_on']} with ffmpeg/ffprobe (`scripts/video-measure.py`).", '',
         '| Item | Value |', '|---|---|',
         f"| Duration | {i['duration_s']} s |", f"| Frame rate | {i['fps']} fps |",
         f"| Resolution | {i['width']}x{i['height']} ({i['orientation']}) |", f"| Aspect | {i['aspect']} ({i['aspect_decimal']}) |", '',
         '## Cuts by threshold', '',
         '| Threshold | Changes | Cuts used | Shots | ASL s | Shots / 10 s | Cuts in first 3 s | Shortest / longest s |',
         '|---|---|---|---|---|---|---|---|']
    for t in m['cuts']:
        s = t['stats']
        L.append(f"| {t['threshold']}{' (clustered ' + str(CLUSTER_GAP) + ' s)' if t['clustered'] else ''} | {t['raw_changes']} | "
                 f"{s['cuts']} | {s['shots']} | {s['asl_s']} | {s['shots_per_10s']} | {s['cuts_first_3s']} | {s['shortest_s']} / {s['longest_s']} |")
    L += ['', 'Cut times (s):'] + [f"- {t['threshold']}: {', '.join(str(x) for x in t['stats']['cut_times_s']) or 'none'}" for t in m['cuts']]
    lo = m['loudness']
    L += ['', '## Audio', '', ('No audio stream.' if lo is None else
          f"Integrated {lo.get('integrated_lufs')} LUFS · LRA {lo.get('lra_lu')} LU · true peak {lo.get('true_peak_dbtp')} dBTP")]
    sp = m['speech']
    L += ['', '## Speech', '', ('No .vtt/.srt beside the video: words per second not measured.' if sp is None else
          f"{sp.get('words')} words over {sp.get('speech_span_s')} s ({sp.get('speech_start_s')}–{sp.get('speech_end_s')} s) = "
          f"**{sp.get('words_per_second')} words/s** from `{sp.get('file')}`. {sp.get('note', '')}")]
    cs = m['contact_sheet']
    L += ['', '## Contact sheet', '', (f"`{cs['file']}`: {cs['cells']} cells, grid {cs['grid']}, one every {cs['seconds_per_cell']} s "
          '(read left to right, top to bottom). Read it before writing any description.' if 'file' in cs else f"failed: {cs.get('error')}")]
    L += ['', '## Limits', '', '- Thresholds are reading aids: dissolves, whip pans and morphs can hide or invent cuts; check a doubtful window frame by frame.',
          '- Camera moves are not measured here; infer them only from consecutive frames and label them estimates.']
    open(path, 'w').write('\n'.join(L) + '\n')


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('video'); ap.add_argument('out_dir')
    ap.add_argument('--thresholds', default='0.3,0.08', help='comma list of scene thresholds (default 0.3,0.08)')
    ap.add_argument('--sheet-fps', type=float, default=1.0, help='contact-sheet frames per second (default 1, capped at 60 cells)')
    a = ap.parse_args()
    missing = [t for t in ('ffmpeg', 'ffprobe') if not shutil.which(t)]
    if missing:
        print(f"video-measure: {' and '.join(missing)} not found on PATH. Install ffmpeg (it ships ffprobe), e.g. "
              "'brew install ffmpeg' on macOS or 'apt install ffmpeg' on Debian/Ubuntu, then re-run.", file=sys.stderr)
        sys.exit(2)
    if not os.path.isfile(a.video):
        sys.exit(f'video not found: {a.video}')
    try:
        ths = sorted({float(x) for x in a.thresholds.split(',') if x.strip()}, reverse=True)
    except ValueError:
        sys.exit('--thresholds must be numbers, e.g. 0.3,0.08')
    os.makedirs(a.out_dir, exist_ok=True)
    info = probe(a.video)
    dur = info['duration_s']
    cuts = []
    for t in ths:
        raw = [x for x in scene_times(a.video, t) if 0 < x < dur]
        clustered = len(ths) > 1 and t == ths[-1]
        used = cluster(raw) if clustered else raw
        cuts.append({'threshold': t, 'clustered': clustered, 'raw_changes': len(raw), 'stats': shot_stats(used, dur)})
    from datetime import date
    m = {'source': os.path.abspath(a.video), 'measured_on': date.today().isoformat(), 'tool': 'scripts/video-measure.py',
         'video': info, 'cluster_gap_s': CLUSTER_GAP, 'cuts': cuts,
         'loudness': loudness(a.video) if info['has_audio'] else None,
         'contact_sheet': contact_sheet(a.video, info, os.path.join(a.out_dir, 'contact-sheet.jpg'), a.sheet_fps),
         'speech': speech_rate(a.video)}
    json.dump(m, open(os.path.join(a.out_dir, 'measure.json'), 'w'), indent=1)
    write_md(m, os.path.join(a.out_dir, 'measure.md'))
    print(f"{os.path.basename(a.video)}: {dur} s, {info['width']}x{info['height']} ({info['aspect']}), {info['fps']} fps")
    for c in cuts:
        s = c['stats']
        print(f"  scene>{c['threshold']}{' clustered' if c['clustered'] else ''}: {s['shots']} shots, ASL {s['asl_s']} s, "
              f"{s['shots_per_10s']} shots/10 s, {s['cuts_first_3s']} cuts in first 3 s (raw changes {c['raw_changes']})")
    lo = m['loudness']
    print(f"  loudness: {lo.get('integrated_lufs')} LUFS, true peak {lo.get('true_peak_dbtp')} dBTP" if lo else '  loudness: no audio')
    sp = m['speech']
    if sp:
        print(f"  speech: {sp.get('words')} words / {sp.get('speech_span_s')} s = {sp.get('words_per_second')} words/s")
    print(f"  wrote {a.out_dir}/measure.json, measure.md, contact-sheet.jpg")


if __name__ == '__main__':
    main()
