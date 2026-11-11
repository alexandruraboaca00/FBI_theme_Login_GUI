# Run from the project root. No external packages.
import json
from pathlib import Path
geo=json.loads(Path('tests/fixtures/ne_110m_land.geojson').read_text())
polys=[]
for f in geo['features']:
 g=f['geometry']
 polys += [g['coordinates']] if g['type']=='Polygon' else g['coordinates']
def inside(x,y,ring):
 c=False
 for i in range(len(ring)):
  a,b=ring[i-1],ring[i]
  if (a[1]>y)!=(b[1]>y) and x<(b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0]:c=not c
 return c
bounds=[(p,min(v[0] for v in p[0]),max(v[0] for v in p[0]),min(v[1] for v in p[0]),max(v[1] for v in p[0])) for p in polys]
points=[]
for y in range(-57,81,3):
 for x in range(-177,180,3):
  if any(lo<=x<=hi and bot<=y<=top and inside(x,y,p[0]) and not any(inside(x,y,h) for h in p[1:]) for p,lo,hi,bot,top in bounds):points.append([round((x+180)/360,5),round((82-y)/145,5)])
Path('src/theme/assets/WorldDots.js').write_text('// Natural Earth 1:110m land, public domain. Offline dotted projection.\n.pragma library\nvar points = '+json.dumps(points,separators=(',',':'))+';\n')
print(len(points),'land dots')
