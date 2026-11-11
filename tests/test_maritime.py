"""Check every maritime segment against the bundled 1:110m land mask."""
import json
from pathlib import Path
import re
import pytest

PROJECT = Path(__file__).parents[1]
source = (PROJECT / 'src/theme/assets/SeaRoutes.js').read_text()
ROUTES = json.loads(re.search(r'var routes = (.*);', source)[1])
features = json.loads((PROJECT / 'tests/fixtures/ne_110m_land.geojson').read_text())['features']
POLYGONS = []
for feature in features:
    g = feature['geometry']
    for p in ([g['coordinates']] if g['type'] == 'Polygon' else g['coordinates']):
        ring = p[0]
        POLYGONS.append((p, min(x[0] for x in ring), max(x[0] for x in ring),
                         min(x[1] for x in ring), max(x[1] for x in ring)))


def inside(x, y, ring):
    result = False
    for a, b in zip(ring, ring[1:] + ring[:1]):
        if (a[1] > y) != (b[1] > y) and x < (b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0]:
            result = not result
    return result


@pytest.mark.parametrize('route', ROUTES)
def test_route_stays_in_water(route):
    for a, b in zip(route, route[1:]):
        for step in range(101):
            t = step / 100
            x, y = a[0]+(b[0]-a[0])*t, a[1]+(b[1]-a[1])*t
            for p, left, right, bottom, top in POLYGONS:
                if left <= x <= right and bottom <= y <= top:
                    assert not (inside(x, y, p[0]) and not any(inside(x, y, h) for h in p[1:])), (x, y)
