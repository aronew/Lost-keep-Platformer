"""Export image-generated source art as exact, integer-grid game atlases."""
from pathlib import Path
import json, math, shutil, zipfile
import numpy as np
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parent
for sub in ('sheets','native','pieces','previews'): (ROOT/sub).mkdir(exist_ok=True)
NN=Image.Resampling.NEAREST
def rgb(s): return tuple(bytes.fromhex(s.lstrip('#')))
EARTH=list(map(rgb,['583640','764837','915937','A37043','BF8951']))
STONE=list(map(rgb,['484247','635853','8C877F','A49C8A','C3B89F']))
LEAF=list(map(rgb,['1D5C51','24717D','399483','6C8F5E','A4BC63']))
BARK=list(map(rgb,['382C35','583640','6B3A2E','96503B','B87A4A']))
GOLD=list(map(rgb,['583640','B8742A','F2B04A','FFE59A']))
RED=list(map(rgb,['583640','8E1E3A','C2385A','D66C55']))
ICE=list(map(rgb,['275773','3A7FB0','9FE6F5','D8F5EC']))
WHITE=list(map(rgb,['A49C8A','E8DCC0','FFF5D4']))
WATER=list(map(rgb,['246A7C','337F9E','3F86C6','66AFD7','8FCDEB']))
SKY=list(map(rgb,['62ADCF','7CC5DD','9BD9E0','B8E6DF','D6F2E8']))
FAR=list(map(rgb,['6FB0A0','84C9AF','99D2B7','B0DDC4','C7E8D3']))
MID=list(map(rgb,['24717D','398B83','399483','65AB95','88C3AC']))

def blank(w,h): return Image.new('RGBA',(w,h))
def src(name):
 im=Image.open(ROOT/'sources'/f'{name}.png').convert('RGBA')
 a=np.array(im);a[:,:,3]=np.where(a[:,:,3]>=235,255,0);a[a[:,:,3]==0]=0
 return Image.fromarray(a)
def normcrop(im,box):
 w,h=im.size
 return im.crop(tuple(round(n*s) for n,s in zip(box,(w,h,w,h))))
def trim(im):
 b=im.getchannel('A').getbbox()
 return im.crop(b) if b else im
def piece(name,box,size): return trim(normcrop(src(name),box)).resize(size,NN)
def nearest(vals,colors):
 colors=np.array(colors,dtype=np.int32); v=vals.astype(np.int32)
 return colors[((v[:,None,:]-colors[None,:,:])**2).sum(2).argmin(1)].astype(np.uint8)
def palette(im,kind='general'):
 a=np.array(im); flat=a[:,:,:3].reshape(-1,3); alpha=a[:,:,3].reshape(-1)
 u,inv=np.unique(flat,axis=0,return_inverse=True)
 if kind in ('water','sky','far','mid','foreground','earth','letters'):
  c={'water':WATER,'sky':SKY,'far':FAR,'mid':MID,'foreground':LEAF+STONE[:2], 'earth':EARTH+STONE,'letters':GOLD+ICE+[(62,46,74),(94,76,104),(140,121,146)]}[kind]
  out=nearest(u,c)
 else:
  out=np.zeros_like(u)
  for i,(r,g,b) in enumerate(u.astype(int)):
   if (r,g,b)==(40,62,64): out[i]=(40,62,64);continue
   if (r,g,b)==(63,224,200): out[i]=(63,224,200);continue
   if g>r*1.06 and g>b*.91: ramp=LEAF
   elif b>r*1.18 and b>g*1.03: ramp=ICE
   elif g>r*1.15 and b>r*1.14: ramp=LEAF
   elif r>125 and g<85 and r>g*1.6 and b>g*.8: ramp=RED
   elif r>180 and g>110 and b<g*.8: ramp=GOLD
   elif r>205 and g>175 and b>135: ramp=WHITE if b>g*.78 else GOLD
   elif abs(r-g)<27 and abs(g-b)<33: ramp=STONE
   else: ramp=BARK if kind=='bark' else EARTH
   out[i]=nearest(np.array([[r,g,b]],dtype=np.uint8),ramp)[0]
 a[:,:,:3]=out[inv].reshape(a.shape[:2]+(3,)); a[:,:,3]=np.where(a[:,:,3]>=128,255,0);a[a[:,:,3]==0]=0
 return Image.fromarray(a)
def seam(im,axis='x',collar=4):
 a=np.array(im)
 if axis=='x': a[:,-collar:]=a[:,:collar][:,::-1]
 else: a[-collar:]=a[:collar][::-1]
 return Image.fromarray(a)
def solid(im,box,color):
 a=np.array(im);x,y,w,h=box
 region=a[y:y+h,x:x+w]; missing=region[:,:,3]==0
 region[missing]=(*color,255)
 return Image.fromarray(a)

SHEETS={}; MAN=[]
def save(name,im,scale=8,kind='general',opaque=False,seams=()):
 im=palette(im,kind)
 if opaque:
  a=np.array(im);a[:,:,3]=255;im=Image.fromarray(a)
 for axis in seams: im=seam(im,axis)
 SHEETS[name]=im
 im.save(ROOT/'native'/f'{name}.png')
 im.resize((im.width*scale,im.height*scale),NN).save(ROOT/'sheets'/f'{name}.png')
 entry={'name':name,'native_size':list(im.size),'scale':scale,'output_size':[im.width*scale,im.height*scale],'opaque':opaque,'repeat_axes':list(seams),'pieces':[]}
 MAN.append(entry)
 return im
def record(sheet,name,rect,**extra):
 e=next(x for x in MAN if x['name']==sheet);e['pieces'].append({'name':name,'rect_native':list(rect),**extra})
 x,y,w,h=rect;im=SHEETS[sheet].crop((x,y,x+w,y+h));sc=e['scale']
 im.resize((w*sc,h*sc),NN).save(ROOT/'pieces'/f'{name}.png')
def add(im,p,x,y): im.alpha_composite(p,(x,y));return im

# Ground bands: resample flora and structural body independently to lock y16.
s=src('01-ground-bands');w,h=s.size
im=blank(384,128)
add(im,s.crop((0,round(h*.065),w,round(h*.183))).resize((384,8),NN),0,8)
add(im,s.crop((0,round(h*.183),w,round(h*.5))).resize((384,40),NN),0,16)
im=solid(im,(0,16,384,40),EARTH[2]); d=ImageDraw.Draw(im);d.rectangle((0,52,383,55),fill=(*EARTH[2],255));d.rectangle((0,72,383,87),fill=(*EARTH[2],255))
add(im,s.crop((0,round(h*.70),w,round(h*.96))).resize((384,32),NN),0,88)
im=save('01-ground-bands',im,seams=('x',))
record('01-ground-bands','walkable-ground-band',(0,8,384,48),walking_y=16,walking_span=[0,384],repeat_axes=['x'],fill_join_y=56)
record('01-ground-bands','ground-underside-band',(0,72,384,48),repeat_axes=['x'],fill_join_y=72)

# Calm seamless interior fill.
fill=src('03-earth-fill').resize((128,128),NN)
save('03-earth-fill',fill,kind='earth',opaque=True,seams=('x','y'))
record('03-earth-fill','earth-fill',(0,0,128,128),repeat_axes=['x','y'])

# Vertical face: no top vegetation in the repeated wall band.
wall=piece('02-ground-wall-corners',(0,.095,.156,1),(44,256))
wall=solid(wall,(0,0,40,256),EARTH[2]);wall=seam(wall,'y')
im=blank(256,256);add(im,wall,0,0)
texture=SHEETS['03-earth-fill']
top=SHEETS['01-ground-bands'].crop((0,8,64,56))
under=SHEETS['01-ground-bands'].crop((64,72,128,120))
for name,x,y,mode in [('outer-top',128,0,'ot'),('outer-under',192,0,'ou'),('inner-top',128,64,'it'),('inner-under',192,64,'iu')]:
 c=blank(64,64);yy,xx=np.mgrid[:64,:64]
 mask={'ot':(xx<32)&(yy>=32),'ou':(xx<32)&(yy<32),'it':(xx<32)|(yy>=32),'iu':(xx<32)|(yy<32)}[mode]
 a=np.array(texture.crop((0,0,64,64)));a[~mask]=0;c=Image.fromarray(a)
 # inset right face, using generated stone wall texture, without void interiors.
 face=wall.crop((24,0,40,64))
 if mode=='ot': add(c,face.crop((0,32,16,64)),16,32)
 elif mode=='ou': add(c,face.crop((0,0,16,32)),16,0)
 elif mode=='it': add(c,face.crop((0,0,16,32)),16,0)
 else: add(c,face.crop((0,32,16,64)),16,32)
 if mode in ('ot','it'):
  span=(0,32) if mode=='ot' else (32,64)
  # The same generated grass lip wraps into this junction.
  strip=top.crop((0,0,span[1]-span[0],14));add(c,strip,span[0],24)
 else:
  span=(0,32) if mode=='ou' else (32,64)
  strip=under.crop((0,16,span[1]-span[0],40));add(c,strip,span[0],24)
 add(im,c,x,y)
save('02-ground-wall-corners',im)
record('02-ground-wall-corners','right-facing-wall',(0,0,44,256),face_x=40,repeat_axes=['y'],inward_side='left')
for name,x,y in [('outer-top',128,0),('outer-under',192,0),('inner-top',128,64),('inner-under',192,64)]: record('02-ground-wall-corners',name,(x,y,64,64),junction=[x+32,y+32])

# Ruin architectural sprites. Opening normalized at native resolution.
im=blank(256,128)
specs=[('ruined-wall',(0,0,.47,.59),(0,0,96,64)),('arched-doorway',(.49,0,.80,.59),(112,0,64,80)),('broken-pillar',(.82,0,1,.60),(192,0,24,56)),('stone-steps',(0,.60,.32,1),(0,80,64,48)),('low-stone-ledge',(.37,.75,.64,1),(80,112,48,16))]
for name,box,(x,y,pw,ph) in specs:
 p=piece('04-ruin-pieces',box,(pw,ph))
 if name=='arched-doorway':
  # Exact 32x56 arch opening, flat floor; unlit glass remapped locally.
  dr=ImageDraw.Draw(p);dr.rectangle((16,40,47,79),fill=(*rgb('283E40'),255));dr.pieslice((16,24,47,55),180,360,fill=(*rgb('283E40'),255))
  a=np.array(p);glass=(a[:,:,0]>170)&(a[:,:,1]>95)&(np.indices((ph,pw))[1]>49)&(np.indices((ph,pw))[0]<34);a[glass]=(*STONE[2],255);p=Image.fromarray(a)
 if name=='stone-steps':
  # Three exact16-deep treads and16-high rises in the64x48 sprite.
  # The remaining16pixels are transparent placement padding on the left.
  p=p.resize((48,48),NN).transpose(Image.Transpose.FLIP_LEFT_RIGHT)
  a=np.array(p);Y,X=np.mgrid[:48,:48];mask=(Y>=np.where(X<16,32,np.where(X<32,16,0)));a[~mask]=0;p=Image.fromarray(a)
  p=solid(p,(0,32,16,16),STONE[2]);p=solid(p,(16,16,16,32),STONE[2]);p=solid(p,(32,0,16,48),STONE[2])
  q=blank(64,48);add(q,p,16,0);p=q
 if name=='low-stone-ledge': p=solid(p,(0,0,pw,3),LEAF[3])
 add(im,p,x,y)
save('04-ruin-pieces',im)
for name,box,rect in specs: record('04-ruin-pieces',name,rect,**({'opening_size':[32,56],'opening_floor_y':79} if name=='arched-doorway' else {'walking_y':rect[1]} if name=='low-stone-ledge' else {'step_treads':[[16,112,16],[32,96,16],[48,80,16]],'rise':16,'left_padding':16} if name=='stone-steps' else {}))

# Grass/earth islands. Generated flora and lower mass resampled separately.
def island(source,box,width,height,source_walk):
 p=trim(normcrop(src(source),box));sy=round(p.height*source_walk)
 q=blank(width,height);add(q,p.crop((0,0,p.width,sy)).resize((width,16),NN),0,0);add(q,p.crop((0,sy,p.width,p.height)).resize((width,height-16),NN),0,16)
 q=solid(q,(0,16,width,3),LEAF[3]);return q
im=blank(384,128)
ispec=[('island-a',(0,0,.20,1),8,16,48,40,.43),('island-b',(.22,0,.51,1),88,16,64,56,.18),('island-c',(.54,0,1,1),184,16,96,72,.15)]
for name,box,x,y,pw,ph,walk in ispec: add(im,island('05-islands-abc',box,pw,ph,walk),x,y)
save('05-islands-abc',im)
for name,box,x,y,pw,ph,walk in ispec: record('05-islands-abc',name,(x,y,pw,ph),walking_y=y+16,walking_span=[x,x+pw])
im=blank(384,128);add(im,island('06-island-d',(0,0,1,1),160,96,.27),112,16);save('06-island-d',im);record('06-island-d','island-d',(112,16,160,96),walking_y=32,walking_span=[112,272])

# Bridges, preserve each native width.
im=blank(384,128)
for name,box,rect,wy,span in [('fallen-log',(0,0,.425,1),(8,24,160,32),30,[8,168]),('root-bridge',(.435,0,1,1),(184,16,192,64),24,[192,368])]:
 x,y,pw,ph=rect;p=trim(normcrop(src('07-log-root-bridge'),box));line=wy-y
 sy=round(p.height*(.42 if name=='fallen-log' else .16));q=blank(pw,ph)
 add(q,p.crop((0,0,p.width,sy)).resize((pw,line),NN),0,0)
 add(q,p.crop((0,sy,p.width,p.height)).resize((pw,ph-line),NN),0,line);p=q
 p=solid(p,(span[0]-x,line,span[1]-span[0],3),BARK[2]);add(im,p,x,y)
save('07-log-root-bridge',im,kind='bark')
record('07-log-root-bridge','fallen-log',(8,24,160,32),walking_y=30,walking_span=[8,168]);record('07-log-root-bridge','root-bridge',(184,16,192,64),walking_y=24,walking_span=[192,368])

im=blank(256,64)
for i,(box,x,pw) in enumerate([((0,0,.24,1),24,32),((.27,0,.58,1),104,40),((.62,0,1,1),192,48)]):
 p=piece('07b-stepping-stones',box,(pw,24));p=solid(p,(0,0,pw,2),LEAF[3]);d=ImageDraw.Draw(p);d.line((1,12,pw-2,12),fill=(*WATER[4],255));add(im,p,x,20)
save('07b-stepping-stones',im)
for i,(x,pw) in enumerate([(24,32),(104,40),(192,48)]): record('07b-stepping-stones',f'stepping-stone-{i+1}',(x,20,pw,24),walking_y=20,waterline_y=32)

# Complete decorative trees.
im=blank(384,256)
for i,(box,x) in enumerate([((0,0,.5,1),8),((.5,0,1,1),200)]):
 p=piece('08-great-trees',box,(176,256));a=np.array(p)
 # Unlit glass, no light halo. Source alpha threshold removes generated ambient haze.
 Y,X=np.mgrid[:256,:176];m=(a[:,:,0]>160)&(a[:,:,1]>110)&(a[:,:,2]<150)&(Y>130)&(Y<180)&((X>130) if i==0 else (X<60));a[m]=(*STONE[2],255);p=Image.fromarray(a);add(im,p,x,0)
save('08-great-trees',im,kind='bark')
for i,x in enumerate([8,200]): record('08-great-trees',f'great-tree-{i+1}',(x,0,176,256),decorative=True)

def crown(source,box,width):
 p=trim(normcrop(src(source),box));w,h=p.size
 # Hold the walking boundary at y12; retain end clumps only above it.
 sy=round(h*.20);crown_end=round(h*.54);q=blank(width,120)
 add(q,p.crop((0,0,w,sy)).resize((width,12),NN),0,0)
 add(q,p.crop((0,sy,w,crown_end)).resize((width,68),NN),0,12)
 add(q,p.crop((0,crown_end,w,h)).resize((width,40),NN),0,80)
 a=np.array(q);left=width//8;right=width-left
 a[:12,left:right]=0
 q=Image.fromarray(a);q=solid(q,(left,12,right-left,4),LEAF[3]);return q
im=blank(384,128);add(im,crown('09-crowns-ab',(0,0,.425,1),112),16,4);add(im,crown('09-crowns-ab',(.44,0,1,1),128),176,4);save('09-crowns-ab',im,kind='bark')
record('09-crowns-ab','tree-crown-a',(16,4,112,120),walking_y=16,walking_span=[30,114]);record('09-crowns-ab','tree-crown-b',(176,4,128,120),walking_y=16,walking_span=[192,288])
im=blank(384,128);add(im,crown('10-crown-c',(0,0,1,1),160),112,4);save('10-crown-c',im,kind='bark');record('10-crown-c','tree-crown-c',(112,4,160,120),walking_y=16,walking_span=[132,252])

water=src('11-pond-water').resize((384,64),NN)
# Put the generated surface ripple row at y0, retaining a full opaque depth band.
water=src('11-pond-water').crop((0,48,2172,724)).resize((384,64),NN)
a=np.array(water);bright=(a[:8,:,0]>120)&(a[:8,:,1]>165);row=int(bright.sum(1).argmax())
if row: a=np.concatenate((a[row:],np.repeat(a[-1:],row,axis=0)),axis=0)
water=Image.fromarray(a)
save('11-pond-water',water,kind='water',opaque=True,seams=('x',));record('11-pond-water','pond-water',(0,0,384,64),surface_y=0,repeat_axes=['x'])

im=blank(256,128)
plants=[('lily-pads-a',24,10),('lily-pads-b',32,12),('lily-pads-flower',40,20),('reeds-a',24,40),('cattails-a',32,48),('cattails-b',24,32),('bank-grass-a',32,28),('bank-grass-b',32,28)]
for i,(name,pw,ph) in enumerate(plants):
 col=i%4;row=i//4;p=piece('12-pond-plants',(col/4,row/2,(col+1)/4,(row+1)/2),(pw,ph));x=col*64+(64-pw)//2;y=row*64+56-ph
 if i>=6:
  a=np.array(p);m=(a[:,:,2].astype(float)>a[:,:,0].astype(float)*1.15)&(np.indices((ph,pw))[0]>ph-5);a[m]=0;p=Image.fromarray(a)
 add(im,p,x,y)
save('12-pond-plants',im)
for i,(name,pw,ph) in enumerate(plants): record('12-pond-plants',name,(i%4*64+(64-pw)//2,i//4*64+56-ph,pw,ph),baseline_y=i//4*64+56)

im=blank(128,64);s=src('13-collectibles')
# Source rows have different widths; crop glyphs individually.
letter_boxes=[(.085,0,.27,.40),(.30,0,.48,.40),(.50,0,.685,.40),(.70,0,.90,.40)]
for i,box in enumerate(letter_boxes): add(im,trim(normcrop(s,box)).resize((16,18),NN),8+i*32,0)
coin_boxes=[(.10,.42,.26,.71),(.31,.42,.45,.71),(.54,.42,.64,.71),(.73,.42,.87,.71)]
for i,box in enumerate(coin_boxes):
 p=trim(normcrop(s,box));pw=[16,13,5,13][i];q=blank(16,16);add(q,p.resize((pw,16),NN),(16-pw)//2,0);add(im,q,8+i*32,24)
for i in range(8):
 p=trim(normcrop(s,(.04+i*.115,.74,.155+i*.115,1))).resize((9,11),NN);add(im,p,4+i*15,50)
save('13-collectibles',im,kind='letters')
for i,ch in enumerate('KLEO'): record('13-collectibles',f'collectible-{ch}',(8+i*32,0,16,18))
for i in range(4): record('13-collectibles',f'bonus-token-frame-{i}',(8+i*32,24,16,16))
for i,ch in enumerate('KLEOKLEO'): record('13-collectibles',f'hud-{ch}-{("dim" if i<4 else "found")}',(4+i*15,50,9,11))

im=blank(128,64)
for name,box,x in [('root-hollow',(0,0,.49,1),8),('ruin-hollow',(.51,0,1,1),72)]:
 p=piece('14-bonus-hollows',box,(48,48));d=ImageDraw.Draw(p)
 # Consistent entrance opening20x28, including arch, flat floor at bottom.
 d.rectangle((14,30,33,47),fill=(*rgb('283E40'),255));d.pieslice((14,20,33,39),180,360,fill=(*rgb('283E40'),255))
 for px,py in [(20,31),(26,36),(24,41)]: d.point((px,py),fill=(*rgb('3FE0C8'),255))
 add(im,p,x,8)
save('14-bonus-hollows',im)
for name,x in [('root-hollow',8),('ruin-hollow',72)]: record('14-bonus-hollows',name,(x,8,48,48),opening_size=[20,28],floor_y=55)

im=blank(256,64)
for name,box,rect in [('bramble-repeat',(0,0,.68,1),(8,24,128,24)),('bramble-left-cap',(.69,0,.84,1),(160,24,24,24)),('bramble-right-cap',(.845,0,1,1),(208,24,24,24))]:
 x,y,pw,ph=rect;p=piece('15-bramble-hazard',box,(pw,ph));p=seam(p) if name=='bramble-repeat' else p;add(im,p,x,y)
save('15-bramble-hazard',im)
record('15-bramble-hazard','bramble-repeat',(8,24,128,24),repeat_axes=['x'])
record('15-bramble-hazard','bramble-left-cap',(160,24,24,24));record('15-bramble-hazard','bramble-right-cap',(208,24,24,24))

im=blank(256,128)
props=[('unlit-lantern-post',26,40),('lit-lantern-post',26,40),('wooden-bench',32,18),('red-banner-pole',26,40),('wooden-crate',24,20),('barrel',20,24),('clay-pot',24,20),('blank-signpost',28,32),('red-mushrooms',28,20),('flower-cluster',28,24)]
for i,(name,pw,ph) in enumerate(props):
 col=i%5;row=i//5;p=piece('16-props',(col/5,0 if row==0 else .56,(col+1)/5,.54 if row==0 else 1),(pw,ph));x=8+col*49+(40-pw)//2;y=row*64+56-ph
 if name=='lit-lantern-post':
  dr=ImageDraw.Draw(p);dr.point((7,13),fill=(*rgb('FFE59A'),255));dr.point((7,14),fill=(*rgb('F2B04A'),255))
 add(im,p,x,y)
save('16-props',im,kind='bark')
for i,(name,pw,ph) in enumerate(props): record('16-props',name,(8+i%5*49+(40-pw)//2,i//5*64+56-ph,pw,ph),baseline_y=i//5*64+56)

# Parallax sheets at x4: native height positions, palette steps only.
sky=src('17-daytime-sky').resize((768,360),NN);save('17-daytime-sky',sky,4,'sky',True,('x',));record('17-daytime-sky','daytime-sky',(0,0,768,360),repeat_axes=['x'])
for name,kind,top,minsolid,color in [('18-far-forest','far',60,280,FAR[3]),('19-mid-forest','mid',30,320,MID[3])]:
 p=trim(src(name)).resize((768,360-top),NN);im=blank(768,360);add(im,p,0,top)
 a=np.array(im)
 # Bottom haze is opaque, using the same limited palette as its forest.
 for py in range(minsolid-24,minsolid):
  # A stepped, ordered pixel transition into the solid mist, no semitransparency.
  for px in range(768):
   if ((px*3+py*5)%24)<py-(minsolid-24): a[py,px]=(*color,255)
 a[minsolid:,:,3]=255
 a[minsolid:,:,:3]=color
 im=Image.fromarray(a);save(name,im,4,kind,False,('x',));record(name,name[3:],(0,0,768,360),repeat_axes=['x'],solid_bottom_from_y=minsolid,decorative=True)
fg=trim(src('20-foreground')).resize((768,90),NN);im=blank(768,96);add(im,fg,0,6)
im=solid(im,(0,84,768,12),LEAF[0]);save('20-foreground',im,4,'foreground',False,('x',));record('20-foreground','foreground-foliage',(0,0,768,96),repeat_axes=['x'],solid_bottom_from_y=84,decorative=True)

# Metadata and review-only contact sheet. Production images contain no text.
(ROOT/'atlas.json').write_text(json.dumps({'project':'Lost Keep: Platformer','coordinates':'native logical pixels; multiply by sheet scale for exported coordinates','sheets':MAN},indent=2))
(ROOT/'palette.json').write_text(json.dumps({k:['#'+bytes(v).hex().upper() for v in c] for k,c in {'earth':EARTH,'stone':STONE,'leaf':LEAF,'bark':BARK,'gold':GOLD,'red':RED,'ice':ICE,'water':WATER,'sky':SKY,'far':FAR,'mid':MID}.items()},indent=2))
cols=3;cw=520;ch=235;out=Image.new('RGB',(cols*cw,math.ceil(len(MAN)/cols)*ch),(213,230,222));dr=ImageDraw.Draw(out)
for i,e in enumerate(MAN):
 im=SHEETS[e['name']].copy();im.thumbnail((500,200),NN);x=i%cols*cw;y=i//cols*ch;out.paste(im,(x+10,y+25),im);dr.text((x+10,y+5),e['name']+' | '+str(e['output_size'][0])+' x '+str(e['output_size'][1]),fill=(30,60,50))
out.save(ROOT/'previews'/'asset-kit-overview.jpg',quality=95)
print('Exported',len(MAN),'sheets and',sum(len(x['pieces']) for x in MAN),'pieces')
