from pathlib import Path
import json
import numpy as np
from PIL import Image

R=Path(__file__).resolve().parent
meta=json.loads((R/'atlas.json').read_text())
checks=[]
def check(name,condition):
 checks.append({'check':name,'passed':bool(condition)})
for s in meta['sheets']:
 name=s['name'];n=np.array(Image.open(R/'native'/f'{name}.png').convert('RGBA'));im=Image.open(R/'sheets'/f'{name}.png').convert('RGBA');a=np.array(im);scale=s['scale']
 check(name+': canvas',list(im.size)==s['output_size'])
 check(name+': exact integer pixels',np.array_equal(a,np.repeat(np.repeat(n,scale,0),scale,1)))
 check(name+': binary alpha',set(np.unique(a[:,:,3])).issubset({0,255}))
 if s['opaque']: check(name+': opaque',np.all(n[:,:,3]==255))
 for axis in s['repeat_axes']:
  check(name+': repeat '+axis,np.array_equal(n[:,0],n[:,-1]) if axis=='x' else np.array_equal(n[0],n[-1]))
 for p in s['pieces']:
  x,y,w,h=p['rect_native'];check(p['name']+': in canvas',x>=0 and y>=0 and x+w<=n.shape[1] and y+h<=n.shape[0]);crop=n[y:y+h,x:x+w]
  for axis in p.get('repeat_axes',[]): check(p['name']+': repeat '+axis,np.array_equal(crop[:,0],crop[:,-1]) if axis=='x' else np.array_equal(crop[0],crop[-1]))
  if 'walking_span' in p:
   x0,x1=p['walking_span'];wy=p['walking_y'];check(p['name']+': solid walking span',np.all(n[wy,x0:x1,3]==255))
  for sx,sy,sw in p.get('step_treads',[]): check(p['name']+': solid tread '+str(sy),np.all(n[sy,sx:sx+sw,3]==255))
  piece=Image.open(R/'pieces'/f"{p['name']}.png");check(p['name']+': exact dimensions',piece.size==(w*scale,h*scale))
g=np.array(Image.open(R/'native'/'01-ground-bands.png'));check('ground: flora stays in y8..15',np.all(g[:8,:,3]==0));check('ground: plain fill join',np.all(g[55,:,:3]==(145,89,55)));check('underside: 16 rows plain fill',np.all(g[72:88,:,:3]==(145,89,55)))
w=np.array(Image.open(R/'native'/'02-ground-wall-corners.png'));check('corners: lower right quarter empty',np.all(w[128:,128:,3]==0))
for nm,y in [('18-far-forest',280),('19-mid-forest',320),('20-foreground',84)]:
 a=np.array(Image.open(R/'native'/f'{nm}.png'));check(nm+': solid lower band',np.all(a[y:,:,3]==255))
result={'passed':all(x['passed'] for x in checks),'check_count':len(checks),'failed':[x for x in checks if not x['passed']],'checks':checks,'scope':'Dimensions, grid, alpha, seams and declared anchors. Does not certify subjective style equivalence or runtime collision implementation.'}
(R/'validation.json').write_text(json.dumps(result,indent=2));print(json.dumps({k:v for k,v in result.items() if k!='checks'},indent=2))
raise SystemExit(0 if result['passed'] else 1)
