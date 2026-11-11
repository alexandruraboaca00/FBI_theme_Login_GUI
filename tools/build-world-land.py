# Run from the project root; standard library only.
import json
from pathlib import Path
geo = json.loads(Path("tests/fixtures/ne_110m_land.geojson").read_text())
polygons = []
for feature in geo["features"]:
    geometry = feature["geometry"]
    groups = [geometry["coordinates"]] if geometry["type"] == "Polygon" else geometry["coordinates"]
    for polygon in groups:
        if max(point[1] for point in polygon[0]) < -60:
            continue
        polygons.append([[[round((x+180)/360, 5), round((82-y)/145, 5)] for x,y,*_ in ring] for ring in polygon])
Path("src/theme/assets/WorldLand.js").write_text("// Natural Earth 1:110m land, public domain. Offline polygons.\n.pragma library\nvar polygons = " + json.dumps(polygons, separators=(",", ":")) + ";\n")
