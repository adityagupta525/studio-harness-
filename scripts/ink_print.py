#!/usr/bin/env python3
"""ink_print.py: map an image onto the locked brand inks (ink / red / bone) with an ordered-dither halftone,
so generated art obeys the palette lock and reads as a real 3-ink print. Needs cv2 (run with the video-analyzer venv).
usage: ink_print.py IN OUT [--width 2560] [--cell 2] [--mode dither|flat] [--thresh 0.42] [--palette RUN/palette/palette.json]
"""
import argparse, json, cv2, numpy as np
a=argparse.ArgumentParser(); a.add_argument('src'); a.add_argument('out'); a.add_argument('--width',type=int,default=2560)
a.add_argument('--cell',type=int,default=2); a.add_argument('--palette')
a.add_argument('--mode',choices=['dither','flat'],default='dither'); a.add_argument('--thresh',type=float,default=0.42); args=a.parse_args()
tok={'ink':'#0B0A09','red':'#CF1C24','bone':'#F0E4D3'}
if args.palette: tok.update({k:v for k,v in json.load(open(args.palette))['tokens'].items() if k in tok})
hx=lambda h:np.array([int(h[5:7],16),int(h[3:5],16),int(h[1:3],16)],np.float32)  # BGR
INK,RED,BONE=hx(tok['ink']),hx(tok['red']),hx(tok['bone'])
im=cv2.imread(args.src); h,w=im.shape[:2]; im=cv2.resize(im,(args.width,int(h*args.width/w)),interpolation=cv2.INTER_AREA).astype(np.float32)
b,g,r=im[...,0],im[...,1],im[...,2]
lum=(0.299*r+0.587*g+0.114*b)/255.0
redness=np.clip((r-np.maximum(g,b))/255.0,0,1)
B8=np.array([[0,32,8,40,2,34,10,42],[48,16,56,24,50,18,58,26],[12,44,4,36,14,46,6,38],[60,28,52,20,62,30,54,22],
            [3,35,11,43,1,33,9,41],[51,19,59,27,49,17,57,25],[15,47,7,39,13,45,5,37],[63,31,55,23,61,29,53,21]],np.float32)/64
c=max(1,args.cell); T=np.kron(B8,np.ones((c,c),np.float32)); H,W=lum.shape
T=np.tile(T,(H//T.shape[0]+1,W//T.shape[1]+1))[:H,:W]
out=np.empty_like(im)
if args.mode=='flat':   # brush-ink look: solid shapes, no dots (critics 6 Nov: one stipple everywhere reads as an AI filter)
    lum_s=cv2.medianBlur((lum*255).astype(np.uint8),5)/255.0
    red_s=cv2.medianBlur((redness*255).astype(np.uint8),5)/255.0
    out[:]=BONE; out[lum_s<args.thresh]=INK; out[(red_s>0.22)&(lum_s>0.12)]=RED
    cv2.imwrite(args.out,out.astype(np.uint8),[cv2.IMWRITE_JPEG_QUALITY,95]); raise SystemExit
is_red=redness>(0.18+0.25*T)            # strong reds print red; weak tints dither
ink_mask=(~is_red)&(lum<T*0.92+0.04)      # darker than threshold → ink
out[:]=BONE; out[ink_mask]=INK; out[is_red]=RED
# keep solid reds solid even in shadows
out[(redness>0.35)&(lum>0.12)]=RED
cv2.imwrite(args.out,out.astype(np.uint8),[cv2.IMWRITE_JPEG_QUALITY,95])
