// Hand-authored offshore paths (lon/lat), decorative, no vessel tracking.
.pragma library
var routes = [[[-62,32],[-52,37],[-40,42],[-28,47],[-16,49],[-10,50]],[[-148,15],[-154,27],[-158,39],[-170,44]],[[63,-12],[73,-18],[86,-24],[99,-27],[109,-28]],[[-112,12],[-119,22],[-128,29],[-140,31]]];

function project(p) { return [(p[0]+180)/360, (82-p[1])/145]; }
function sample(index, progress, width, height) {
    const points=routes[index].map(project);
    const lengths=[];
    let total=0;
    for (let i=1; i<points.length; ++i) {
        const dx=(points[i][0]-points[i-1][0])*width;
        const dy=(points[i][1]-points[i-1][1])*height;
        const length=Math.sqrt(dx*dx+dy*dy);
        lengths.push(length); total+=length;
    }
    let distance=Math.max(0,Math.min(1,progress))*total;
    for (let i=0; i<lengths.length; ++i) {
        if (distance<=lengths[i] || i===lengths.length-1) {
            const t=distance/lengths[i], a=points[i], b=points[i+1];
            return {x:(a[0]+(b[0]-a[0])*t)*width,
                    y:(a[1]+(b[1]-a[1])*t)*height,
                    heading:Math.atan2((b[1]-a[1])*height,(b[0]-a[0])*width)};
        }
        distance-=lengths[i];
    }
    return {x:0,y:0,heading:0};
}
