#!/usr/bin/env python3
"""check-banner.py: mechanical gate for a YouTube banner upload file (brand-identity B5).

usage: check-banner.py BANNER.(jpg|png) [--palette RUN/palette/palette.json] [--keep x,y,w,h ...] [--sheet OUT.jpg]
  --keep   boxes (in 2560x1440 px) that must sit inside the safe band: logo, hero face
  --sheet  writes a TV / desktop / mobile crop sheet for the reviewers
Checks (fix message on every failure):
  size 16:9, >= 2048x1152 (2560x1440 recommended), file <= 6 MB   [V YouTube Help 10456525, read 2026-11-06]
  every --keep box inside the safe band 1546x423 centred (at 2560x1440 scale)
  palette share: pixels near the locked palette tokens (report; warn under 60%)
Stdlib + ffprobe/ffmpeg only. Exit 1 on any FAIL.
"""
import argparse, json, os, subprocess, sys

def probe(p):
    o = subprocess.run(['ffprobe', '-v', 'error', '-select_streams', 'v', '-show_entries', 'stream=width,height',
                        '-of', 'csv=p=0', p], capture_output=True, text=True, check=True).stdout.strip()
    w, h = o.split(',')[:2]
    return int(w), int(h)

def pixels(p, w=128, h=72):
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', p, '-vf', f'scale={w}:{h}', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'],
                         capture_output=True, check=True).stdout
    return [tuple(raw[i:i + 3]) for i in range(0, len(raw), 3)]

def main():
    a = argparse.ArgumentParser(); a.add_argument('img'); a.add_argument('--palette'); a.add_argument('--keep', nargs='*', default=[])
    a.add_argument('--sheet'); args = a.parse_args()
    fails, notes = [], []
    w, h = probe(args.img); mb = os.path.getsize(args.img) / 1e6
    if abs(w / h - 16 / 9) > 0.01: fails.append(f'ratio {w}x{h} is not 16:9 → export the 21:9 master inside a 2560x1440 canvas')
    if w < 2048 or h < 1152: fails.append(f'{w}x{h} below 2048x1152 → export at 2560x1440')
    if mb > 6: fails.append(f'{mb:.1f} MB > 6 MB → export JPG q≈2-4')
    notes.append(f'{w}x{h}, {mb:.2f} MB')
    sx, sy = w / 2560, h / 1440
    S = (507 * sx, 508.5 * sy, 2053 * sx, 931.5 * sy)
    for k in args.keep:
        x, y, bw, bh = [float(v) for v in k.split(',')]
        x, y, bw, bh = x * sx, y * sy, bw * sx, bh * sy
        if x < S[0] or y < S[1] or x + bw > S[2] or y + bh > S[3]:
            fails.append(f'box {k} leaves the safe band (x {S[0]:.0f}-{S[2]:.0f}, y {S[1]:.0f}-{S[3]:.0f}) → move it inward')
    if args.palette:
        toks = [tuple(int(c.lstrip('#')[i:i + 2], 16) for i in (0, 2, 4)) for c in json.load(open(args.palette))['tokens'].values()]
        px = pixels(args.img)
        near = sum(1 for p in px if min(sum((p[i] - t[i]) ** 2 for i in range(3)) for t in toks) < 45 ** 2)
        share = near / len(px)
        notes.append(f'palette share {share:.0%}')
        if share < 0.6: notes.append('WARN palette share < 60%: off-palette colour or heavy shading; check the route card allows it')
    if args.sheet:
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', args.img, '-filter_complex',
                        f'[0]scale=1200:-1[tv];[0]crop={w}:{int(423*sy)}:0:{int(508*sy)},scale=1200:-1[dt];'
                        f'[0]crop={int(1546*sx)}:{int(423*sy)}:{int(507*sx)}:{int(508*sy)},scale=725:-1,pad=1200:ih:(ow-iw)/2:0:color=0x181818[mb];'
                        '[tv][dt][mb]vstack=inputs=3', args.sheet], check=True)
        notes.append(f'sheet {args.sheet}')
    for n in notes: print('INFO', n)
    for f in fails: print('FAIL', f)
    print('PASS' if not fails else f'{len(fails)} FAIL')
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
