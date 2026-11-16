"""Technical atlas assembly for generated artwork: integer grids, masks and export.

Source art is generated with ImageGen. This script constructs requested canvases,
places isolated pieces, snaps to the native grid, and validates exported PNGs.
"""
from pathlib import Path
import json, math, shutil
import numpy as np
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parent
SRC=json.loads((ROOT/'source-map.json').read_text())
N=Image.Resampling.NEAREST
MAN={'project':'Lost Keep: Platformer','version':1,'sheets':[],'assets':[],
     'notes':['Art pixels are exported as exact solid 8x8 squares; backdrop pixels are 4x4.',
     'Overhead crate guides are on a separate sheet; attach offsets can be negative relative to the character cell.']}
COL={
 'stone':['2E2438','3E2E4A','4E3E5E','6E5A7E','8E7A9A'],
 'shadow':['0B0812','1A1424'],
 'green':['13282B','1F4A4A','2E6A50','4F8A3A','8DC24E'],
 'bark':['3A2420','4A3028','5C3A2C','6A4430','8A5A3C'],
 'gold':['6E4A28','9A6E34','D99A4A','F2B04A','FFE59A'],
 'silk':['5E4C68','8C7A92','B8A58A','DDD0AC','FFE59A'],
 'violet':['3E2E4A','5E426E','734D8F','8A5AB0','B49AC6'],
 'teal':['13282B','1F4A4A','2E6A70','3FE0C8','9FE6F5'],
 'hair':['171C32','263354','33466D','465A88','6278A0'],
 'skin':['75523F','AD795B','D7A17C','F0C39B','FFE0B6']}
def rgb(h): return tuple(bytes.fromhex(h))
PALETTE=list(dict.fromkeys(rgb(h) for ramp in COL.values() for h in ramp))
def blank(w,h): return Image.new('RGBA',(w,h),(0,0,0,0))
def load(key):
 path=Path(SRC[key]);path=path if path.is_absolute() else ROOT/path
 im=Image.open(path).convert('RGBA');a=np.array(im)
 a[:,:,3]=np.where(a[:,:,3]>=235,255,0).astype('uint8');a[a[:,:,3]==0,:3]=0
 return Image.fromarray(a)
def trim(im):
 b=im.getchannel('A').getbbox()
 return im.crop(b) if b else blank(1,1)
def quant(im,pal=None):
 a=np.array(im);col=np.array(pal or PALETTE,dtype=np.int32)
 live=a[:,:,3]>0;pixels=a[live,:3].astype(np.int32)
 if len(pixels):
  unique,inv=np.unique(pixels,axis=0,return_inverse=True)
  nearest=np.argmin(((unique[:,None,:]-col[None,:,:])**2).sum(2),axis=1)
  a[live,:3]=col[nearest][inv].astype('uint8')
 a[:,:,3]=np.where(live,255,0).astype('uint8');a[~live,:3]=0
 return Image.fromarray(a)
def fit(im,w,h): return quant(trim(im).resize((w,h),N))
def part(key,box):
 im=load(key);w,h=im.size
 return trim(im.crop(tuple(round(v*(w if i%2==0 else h)) for i,v in enumerate(box))))
def paste(out,piece,x,y): out.alpha_composite(piece,(int(x),int(y)))
def rect(out,b,c): ImageDraw.Draw(out).rectangle(b,fill=(*rgb(c),255))
def save(name,im,scale=8,repeat=None):
 im=quant(im) if name[:2] not in ('14','15') else im
 if repeat=='x':
  a=np.array(im);a[:,-1]=a[:,0];im=Image.fromarray(a)
 if repeat=='y':
  a=np.array(im);a[-1]=a[0];im=Image.fromarray(a)
 im.save(ROOT/'native'/f'{name}.png')
 im.resize((im.width*scale,im.height*scale),N).save(ROOT/'sheets'/f'{name}.png')
 MAN['sheets'].append({'name':name,'file':f'sheets/{name}.png','native_file':f'native/{name}.png','size':[im.width*scale,im.height*scale],'native_size':list(im.size),'pixel_scale':scale,'repeat':repeat})
 return im
def asset(name,sheet,box,**kw):MAN['assets'].append({'name':name,'sheet':sheet,'rect_native':list(box),**kw})
def solid_top(im,y,left=0,right=None):
 right=im.width if right is None else right
 a=np.array(im)
 # Fill isolated alpha holes on the structural support line and the next row.
 for x in range(left,right):
  for yy in (y,y+1):
   if yy<im.height and a[yy,x,3]==0:a[yy,x]=(*rgb('4E3E5E'),255)
 return Image.fromarray(a)

# 01: two precise bands, full-width and repeatable.
src=load('01-stone-bands');out=blank(384,128)
# Map the generated flat masonry lip onto the exact collision line.
lip=round(src.height*.174)
flora=fit(src.crop((0,0,src.width,lip)),384,8)
stone=fit(src.crop((0,lip,src.width,round(src.height*.45))),384,40)
paste(out,flora,0,8);paste(out,stone,0,16);out=solid_top(out,16)
under=fit(src.crop((0,round(src.height*.54),src.width,src.height)),384,48)
paste(out,under,0,72)
rect(out,(0,72,383,87),'0B0812')
# Solid core must remain opaque, preserve generated block silhouettes on outside.
rect(out,(0,48,383,55),'0B0812')
save('01-ruin-top-and-underside',out,repeat='x')
asset('ruin_top','01-ruin-top-and-underside',(0,8,384,48),walk_y=16)
asset('ruin_underside','01-ruin-top-and-underside',(0,72,384,48))

# 02: continuous wall and four 64x64 corner cells.
out=blank(256,256);wall=part('02-wall-corners',(0,0,.19,1))
wall=fit(wall,40,256)
a=np.array(wall);a[-1]=a[0];wall=Image.fromarray(a)
# Face exactly x40; void inward to left.
paste(out,wall,0,0);rect(out,(0,0,8,255),'0B0812')
for y in range(256):out.putpixel((39,y),(*rgb('4E3E5E'),255))
corners=[(.21,.09,.57,.47),(.59,.09,1,.49),(.21,.5,.57,.88),(.59,.5,1,.88)]
for i,b in enumerate(corners):
 x=80+(i%2)*88;y=32+(i//2)*112
 texture=np.array(Image.open(ROOT/'native'/'01-ruin-top-and-underside.png').convert('RGBA'))
 a=np.zeros((64,64,4),dtype=np.uint8)
 for yy in range(64):
  for xx in range(64):
   solid=[xx<32 and yy>=32,xx<32 and yy<32,not(xx>=32 and yy<32),not(xx>=32 and yy>=32)][i]
   if not solid:continue
   if i==0:depth=min(yy-32,31-xx)
   elif i==1:depth=min(31-yy,31-xx)
   elif i==2:depth=(31-xx if yy<32 else yy-32 if xx>=32 else min(31-xx,yy-32)+12)
   else:depth=(31-xx if yy>=32 else 31-yy if xx>=32 else min(31-xx,31-yy)+12)
   if depth>24:a[yy,xx]=(*rgb('0B0812'),255)
   else:
    pix=texture[16+(yy%32),(xx+i*73)%384].copy()
    if pix[3]==0:pix=(*rgb('4E3E5E'),255)
    a[yy,xx]=pix
 p=Image.fromarray(a);paste(out,p,x,y)
 asset(['outer_top','outer_under','inner_top','inner_under'][i],'02-wall-and-corners',(x,y,64,64),corner_anchor=[32,32])
save('02-wall-and-corners',out)
asset('wall_face','02-wall-and-corners',(0,0,40,256),wall_x=40,repeat='y')

# 03: stall above exact structural slab and piers. Arch alpha is rebuilt to spec.
src=load('03-market-stall');out=blank(288,192)
stall=fit(src.crop((0,0,src.width,round(src.height*.535))),288,96)
paste(out,stall,0,0)
base=fit(src.crop((0,round(src.height*.53),src.width,src.height)),288,96)
paste(out,base,0,96)
out=solid_top(out,96)
for x0 in (0,128,256):
 for y in range(128,192):
  for x in range(x0,x0+32):
   if out.getpixel((x,y))[3]==0:out.putpixel((x,y),(*rgb('4E3E5E'),255))
# Lower arch apertures; keep stone springing above ellipse, remove all residual glow.
for x0,x1 in [(32,128),(160,256)]:
 cx=(x0+x1)/2;rx=(x1-x0)/2
 for x in range(x0,x1):
  boundary=160-32*math.sqrt(max(0,1-((x-cx)/rx)**2))
  for y in range(math.ceil(boundary),192):out.putpixel((x,y),(0,0,0,0))
 # Restore source lamp, isolated from each original arch crown.
 lamp=part('03-market-stall',(.25 if x0==32 else .66,.66,.33 if x0==32 else .74,.81))
 paste(out,fit(lamp,12,22),int(cx)-6,132)
save('03-market-stall',out)
asset('market_stall','03-market-stall',(0,0,288,192),walk_y=96,slab_bottom=128,piers=[[0,128,32,64],[128,128,32,64],[256,128,32,64]])

# 04: five precisely sized islands split into two original-size canvases.
src=load('04-islands-source');w,h=src.size
widths=[96,80,80,80,64];tops=[32,48,16,64,32]
# Each object is in its own fifth. Native mushroom height retained with root base
# hidden behind the platform lip for the 40px mushroom above the 32px walk line.
for group,inds in enumerate(([0,1,2],[3,4])):
 out=blank(384,128);x=16
 for i in inds:
  bounds=[(0,.225),(.235,.417),(.426,.62),(.63,.82),(.83,1)]
  l,rr=bounds[i];p=trim(src.crop((round(w*l),0,round(w*rr),h)))
  ratio=[.37,.39,.10,.55,.32][i]
  split=round(p.height*ratio)
  body=fit(p.crop((0,split,p.width,p.height)),widths[i],128-tops[i])
  flora=fit(p.crop((0,0,p.width,max(1,split))),widths[i],max(1,tops[i]))
  if i==0:
   # The40px mushroom cannot fit above y32 without clipping. Keep it whole on
   # a companion original-size atlas and expose a negative placement offset.
   fern=part('04-islands-source',(.83,0,1,.30))
   flora=fit(fern,widths[i],tops[i])
  paste(out,body,x,tops[i]);paste(out,flora,x,0)
  out=solid_top(out,tops[i],x,x+widths[i])
  # Fill straight foundation to sheet bottom.
  for yy in range(tops[i]+2,128):
   for xx in range(x,x+widths[i]):
    if out.getpixel((xx,yy))[3]==0:out.putpixel((xx,yy),(*rgb('2E2438'),255))
  # Naturally darken submerged base using palette-only steps.
  a=np.array(out)
  for yy in range(101,128):
   factor=1-(yy-100)/45
   a[yy,x:x+widths[i],:3]=(a[yy,x:x+widths[i],:3]*factor).astype('uint8')
  out=quant(Image.fromarray(a))
  asset(f'island_{i+1}',f'04-islands-{group+1}',(x,0,widths[i],128),walk_y=tops[i])
  x+=widths[i]+24
 save(f'04-islands-{group+1}',out)

out=blank(384,128)
for name,b,sz,xy,offset in [
 ('mushroom_large',(.025,.06,.16,.39),(52,40),(16,32),(8,-8)),
 ('mushroom_small',(.12,.15,.21,.39),(36,26),(96,46),(60,6))]:
 p=fit(part('04-islands-source',b),*sz);paste(out,p,*xy)
 asset(name,'04-island-mushrooms',(*xy,*sz),island='island_1',placement_relative_to_island=list(offset))
save('04-island-mushrooms',out)

# 05: two original canvases preserve the long bridge widths.
for i,(key,width,walk) in enumerate([('fallen-trunk',224,40),('root-arch',192,24)]):
 p=part('05-trunk-root-source',(i*.5,0,(i+1)*.5,1))
 # Locate source flat moss line then remap above/below independently.
 p=fit(p,width,80 if i==0 else 96);out=blank(384,128)
 split=round(p.height*(.32 if i==0 else .22))
 paste(out,fit(p.crop((0,0,width,split)),width,walk),0,0)
 paste(out,fit(p.crop((0,split,width,p.height)),width,min(128-walk,p.height-split)),0,walk)
 out=solid_top(out,walk,0,width)
 save(f'05-{key}',out)
 asset(key,f'05-{key}',(0,0,width,128),walk_y=walk,embed_ends=16 if i==0 else 0)

# 06: one column/two rows on each original canvas allows 128px branches and gutters.
for page in range(2):
 out=blank(256,128)
 for j in range(2):
  idx=page*2+j;r=idx//2;c=idx%2
  p=part('06-branches-source',(c*.5,r*.5,(c+1)*.5,(r+1)*.5))
  p=trim(p);split=max(1,round(p.height*.20))
  q=blank(128,40)
  paste(q,fit(p.crop((0,0,p.width,split)),128,4),0,0)
  paste(q,fit(p.crop((0,split,p.width,p.height)),128,36),0,4)
  x=16;y=12+j*56
  paste(out,q,x,y);out=solid_top(out,y+4,x,x+128)
  asset(['lantern_branch','nest_branch','fork_branch','morvath_branch'][idx],f'06-branches-{page+1}',(x,y,128,40),walk_y=y+4)
 save(f'06-branches-{page+1}',out)

# 07: one tree per original canvas, original crown widths and height.
src=load('07-trees-source');w,h=src.size
for i,width in enumerate([224,176,160]):
 bounds=[(0,.39),(.39,.705),(.705,1)]
 l,rr=bounds[i];p=trim(src.crop((round(w*l),0,round(w*rr),h)))
 out=blank(384,256);x=(384-width)//2
 # Scale to requested width and complete tree height of216 below crown line40.
 split=max(1,round(p.height*.04));q=blank(width,224)
 paste(q,fit(p.crop((0,0,p.width,split)),width,8),0,0)
 paste(q,fit(p.crop((0,split,p.width,p.height)),width,216),0,8)
 paste(out,q,x,32)
 out=solid_top(out,40,x+8,x+width-8)
 save(f'07-canopy-tree-{i+1}',out)
 asset(f'canopy_tree_{i+1}',f'07-canopy-tree-{i+1}',(x,32,width,224),walk_y=40,walk_x=[x+8,x+width-8])

# 08: consistent three chest boxes, anchored base y56.
src=load('08-chest-frames');w,h=src.size;out=blank(192,64)
closed_body=None
for i,height in enumerate([24,30,36]):
 p=trim(src.crop((round(i*w/3),0,round((i+1)*w/3),h)))
 q=fit(p,32,height);paste(out,q,i*64+16,56-height)
 if i==0:closed_body=q.crop((0,10,32,24))
 else:paste(out,closed_body,i*64+16,42)
 asset(['chest_closed','chest_opening','chest_open'][i],'08-chest-animation',(i*64,0,64,64),anchor=[32,56],nominal_body_size=[32,24])
save('08-chest-animation',out)

# 09: breakable wall objects and eight distinct rubble chunks.
out=blank(128,128)
for i,(box,sz,xy) in enumerate([((0,0,.48,.64),(32,32),(8,8)),((.49,0,1,.64),(32,48),(72,8))]):
 paste(out,fit(part('09-breakable-stone',box),*sz),*xy)
 asset(f'cracked_wall_{i+1}','09-breakable-stone',(*xy,*sz))
for i,sz in enumerate([(7,8),(10,9),(7,6),(4,5),(5,6),(7,5),(9,9),(8,5)]):
 r=i//4;c=i%4;x=12+c*28;y=80+r*24
 p=part('09-breakable-stone',(c*.25,.65+r*.18,(c+1)*.25,.83+r*.17))
 paste(out,fit(p,*sz),x,y);asset(f'rubble_{i+1}','09-breakable-stone',(x,y,*sz))
save('09-breakable-stone',out)

# 10: repeatable128px bramble and two24px end caps.
out=blank(256,64)
for key,b,wh,xy in [('bramble',(.13,.25,.87,.75),(128,16),(16,24)),('left_cap',(0,.25,.13,.75),(24,12),(168,28)),('right_cap',(.87,.25,1,.75),(24,12),(208,28))]:
 p=fit(part('10-brambles',b),*wh)
 if key=='bramble':
  a=np.array(p);a[:,-1]=a[:,0];p=Image.fromarray(a)
 paste(out,p,*xy);asset(key,'10-brambles',(*xy,*wh),base_y=40,repeat='x' if key=='bramble' else None)
save('10-brambles',out)

# 11: six mushrooms + six plants, exact cell arrangement and32px max height.
out=blank(256,128)
for i in range(12):
 r=i//6;c=i%6
 p=part('11-flora',(c/6,r*.5,(c+1)/6,(r+1)*.5))
 height=[28,24,32,22,20,30,24,20,24,24,16,28][i]
 width=max(8,min(34,round(p.width*height/p.height)))
 x=4+c*42+(34-width)//2;y=(r+1)*60-height
 paste(out,fit(p,width,height),x,y)
 asset(f'flora_{i+1}','11-flora',(x,y,width,height),base_y=(r+1)*60)
save('11-flora',out)

# 12: 11 icons on one row. Source lantern converted to a wick/flame icon crop.
src=load('12-hud-icons');w,h=src.size;out=blank(128,64);x=1
for i in range(11):
 p=trim(src.crop((round(i*w/11),0,round((i+1)*w/11),h)))
 if i<3:
  # Extract lit glass/flame from housing; no hanging handle in tiny HUD symbol.
  p=p.crop((round(p.width*.31),round(p.height*.43),round(p.width*.69),round(p.height*.78)))
  width=11;height=15 if i==2 else 14
 elif i<9:width=height=9
 else:width,height=9,12
 paste(out,fit(p,width,height),x,24-height)
 asset(f'icon_{i+1}','12-hud-icons',(x,24-height,width,height));x+=width+1
save('12-hud-icons',out)

# 13: exact48px animation cells, consistent physical scale, separate full-size box guides.
src=load('13-kleo-interact');w,h=src.size
frames=[]
for i in range(12):
 c=i%4;r=i//4;p=src.crop((round(c*w/4),round(r*h/3),round((c+1)*w/4),round((r+1)*h/3)))
 a=np.array(p);green=(a[:,:,1]>130)&(a[:,:,1]>a[:,:,0]*1.8)&(a[:,:,1]>a[:,:,2]*1.8)
 a[green]=(0,0,0,0);p=trim(Image.fromarray(a));frames.append(p)
ratio=28/frames[1].height
out=blank(192,144);guides=blank(192,144)
offsets=[(6,-20),(8,-30),(-12,-49),(-12,-47),(-13,-48),(-12,-47),(-11,-48),(-12,-47),(-26,-40),(12,-44),None,(7,-20)]
for i,p in enumerate(frames):
 c=i%4;r=i//4;ww=max(1,round(p.width*ratio));hh=max(1,round(p.height*ratio))
 # fit only to preserve cell-edge safety, avoid clipping source pose.
 if ww>46 or hh>42:
  fact=min(46/ww,42/hh);ww=round(ww*fact);hh=round(hh*fact)
 q=fit(p,ww,hh);x=c*48+24-ww//2;y=r*48+43-hh
 paste(out,q,x,y)
 asset(f'kleo_{i+1:02}','13-kleo-interact',(c*48,r*48,48,48),anchor=[24,43],crate_offset=offsets[i])
 if offsets[i] is not None:
  rect(guides,(c*48+12,r*48+14,c*48+35,r*48+33),'00FF00')
  asset(f'crate_guide_{i+1:02}','13-crate-guides',(c*48+12,r*48+14,24,20),attach_offset_from_feet=offsets[i])
save('13-kleo-interact',out)
# Green is an exact functional key and must bypass ordinary artwork palette.
guides.save(ROOT/'native'/'13-crate-guides.png')
guides.resize((1536,1152),N).save(ROOT/'sheets'/'13-crate-guides.png')
MAN['sheets'].append({'name':'13-crate-guides','file':'sheets/13-crate-guides.png','native_file':'native/13-crate-guides.png','size':[1536,1152],'native_size':[192,144],'pixel_scale':8,'repeat':None})

# 14: lowcontrast repeatable backdrop with binary alpha and solid bottom60px.
mistpal=[rgb(x) for x in ['2E5A5C','3C7472','4C7D7D','5F8A8C','79A0A1']]
src=load('14-distant-aqueduct');out=blank(768,360)
q=quant(trim(src).resize((768,200),N),mistpal);paste(out,q,0,100)
# Converge to the solid mist color using opaque ordered pixel clusters, avoiding
# a crisp horizontal cutoff that could be mistaken for a playable platform.
a=np.array(out);bayer=np.array([[0,8,2,10],[12,4,14,6],[3,11,1,9],[15,7,13,5]])
for yy in range(260,300):
 for xx in range(768):
  if bayer[yy%4,xx%4] < (yy-260)*16/39:a[yy,xx]=(*rgb('5F8A8C'),255)
out=Image.fromarray(a)
rect(out,(0,300,767,359),'5F8A8C')
a=np.array(out);a[:,-1]=a[:,0];out=Image.fromarray(a)
save('14-distant-aqueduct',out,4,'x')
asset('distant_aqueduct','14-distant-aqueduct',(0,0,768,360),repeat='x',bottom_mist_start=300)

# 15: opaque repeatable sky; preserve cloud art, explicitly size/location moons.
sky=load('15-triad-sky').resize((768,360),N)
skypal=[rgb(x) for x in ['2A2238','3E344A','55435D','745370','916580','A97B92','2E5A5C','3C7472','5F8A8C','8CABA0','BDA574','D0B983','EBD6A0','F6E7B7']]
sky=quant(sky,skypal);a=np.array(sky);a[:,:,3]=255
# Remove original generated moon group from top region with matching sky source strip.
for y in range(0,100):a[y,300:480]=a[y,70:250]
sky=Image.fromarray(a);draw=ImageDraw.Draw(sky)
# Exact40px full moon, side crescent silhouettes. Palette-only clustered craters.
draw.ellipse((280,40,319,79),fill=(*rgb('EBD6A0'),255))
for b in [(288,47,293,51),(303,45,309,50),(297,60,304,66),(287,66,291,70),(310,65,314,69)]:draw.rectangle(b,fill=(*rgb('D0B983'),255))
draw.ellipse((240,44,267,73),fill=(*rgb('EBD6A0'),255));draw.ellipse((248,41,275,71),fill=(*rgb('2A2238'),255))
draw.ellipse((332,44,359,73),fill=(*rgb('EBD6A0'),255));draw.ellipse((324,41,351,71),fill=(*rgb('2A2238'),255))
a=np.array(sky);a[:,-1]=a[:,0];sky=Image.fromarray(a)
save('15-triad-sky',sky,4,'x')
asset('triad_sky','15-triad-sky',(0,0,768,360),moon_center=[300,60],moon_diameter=40,repeat='x')

(ROOT/'manifest.json').write_text(json.dumps(MAN,indent=2))
(ROOT/'palette.json').write_text(json.dumps({'ramps':COL,'reserved_blightexcluded':['8E1E3A','C2385A'],'key_green':'00FF00'},indent=2))
print('Exported',len(MAN['sheets']),'sheets,',len(MAN['assets']),'atlas regions')
