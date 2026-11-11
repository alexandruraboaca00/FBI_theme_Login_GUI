import QtQuick
import "../assets/WorldDots.js" as World
import "../assets/WorldLand.js" as Land

Item {
    id: root
    objectName: "networkMap"
    required property var settings
    property real phase: 0
    readonly property bool threats: settings.mapStyle === "threats"
    // lon/lat for decorative nodes, never a connection to a live threat feed.
    readonly property var cities: [[-122,38],[-74,41],[-46,-24],[-.1,52],[9,50],[37,56],[77,29],[139,36],[104,1],[151,-34],[28,-26]]
    function position(city) { return [(city[0]+180)/360, (82-city[1])/145]; }
    function protectCenter(c, w, h) {
        // Remove brightness smoothly behind clock, labels, fields and errors.
        c.save();
        c.globalAlpha = 1;
        c.globalCompositeOperation = "destination-out";
        c.translate(w*.5, h*.48); c.scale(w*.24, h*.64);
        const gradient = c.createRadialGradient(0,0,0,0,0,1);
        gradient.addColorStop(0,"rgba(0,0,0,0.97)");
        gradient.addColorStop(.55,"rgba(0,0,0,0.88)");
        gradient.addColorStop(1,"rgba(0,0,0,0)");
        c.fillStyle=gradient; c.fillRect(-1,-1,2,2);
        c.restore();
        // The taller map must remain behind the reference emblem, including its rim.
        c.save();
        c.globalAlpha=1; c.globalCompositeOperation="destination-out";
        c.translate(w*.5,175-root.y); c.scale(155,155);
        const emblemMask=c.createRadialGradient(0,0,0,0,0,1);
        emblemMask.addColorStop(0,"rgba(0,0,0,1)");
        emblemMask.addColorStop(.90,"rgba(0,0,0,1)");
        emblemMask.addColorStop(1,"rgba(0,0,0,0)");
        c.fillStyle=emblemMask; c.fillRect(-1,-1,2,2);
        c.restore();
    }
    onThreatsChanged: { land.requestPaint(); routes.requestPaint(); }
    visible: settings.animatedMap
    opacity: settings.mapOpacity
    // Static land and animated paths are separate: land is painted once.
    Canvas {
        id: land
        anchors.fill: parent
        onPaint: {
            const c = getContext("2d");
            c.clearRect(0, 0, width, height);
            c.globalAlpha=1; c.globalCompositeOperation="source-over";
            if (root.threats) {
                c.fillStyle="#343961"; c.strokeStyle="#7867a0"; c.lineWidth=.8;
                for (const polygon of Land.polygons) {
                    c.beginPath();
                    for (const ring of polygon) {
                        for (let i=0; i<ring.length; ++i) {
                            const x=ring[i][0]*width, y=ring[i][1]*height;
                            if (i===0) c.moveTo(x,y); else c.lineTo(x,y);
                        }
                        c.closePath();
                    }
                    c.fill(); c.stroke();
                }
                c.fillStyle="rgba(103,199,219,0.55)";
                for (const p of World.points) c.fillRect(p[0]*width,p[1]*height,1.5,1.5);
                root.protectCenter(c,width,height);
                return;
            }
            c.fillStyle = "#73c6d4";
            for (const p of World.points) {
                const dx=(p[0]-.5)/.25, dy=(p[1]-.56)/.48;
                c.globalAlpha=Math.min(1, .08 + (dx*dx+dy*dy)*.75);
                c.fillRect(p[0] * width, p[1] * height, root.settings.mapDotSize, root.settings.mapDotSize);
            }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
    Canvas {
        id: routes
        anchors.fill: parent
        onPaint: {
            const c = getContext("2d");
            c.clearRect(0, 0, width, height);
            c.globalAlpha=1; c.globalCompositeOperation="source-over";
            if (root.threats) {
                // Each route has a flight, an arrival pulse and a short cooldown.
                // Warm/cyan palette and city clusters are retained from the first version.
                for (let i=0; i<root.cities.length; ++i) {
                    const a=root.position(root.cities[i]);
                    const b=root.position(root.cities[(i+4)%root.cities.length]);
                    const ax=a[0]*width, ay=a[1]*height, bx=b[0]*width, by=b[1]*height;
                    const cx=(ax+bx)/2, cy=Math.min(ay,by)-height*(.12+(i%3)*.018);
                    const warm=i%3!==0;
                    const red=warm ? 255 : 87, green=warm ? 130 : 224, blue=warm ? 113 : 244;
                    const cycle=(root.phase*(1.65+(i%4)*.15)+i*.137)%1;
                    const flight=Math.min(1,cycle/.72);
                    const head=flight*flight*(3-2*flight);
                    c.strokeStyle=warm ? "rgba(255,91,104,0.20)" : "rgba(71,217,235,0.24)";
                    c.lineWidth=.8; c.beginPath(); c.moveTo(ax,ay); c.quadraticCurveTo(cx,cy,bx,by); c.stroke();
                    if (cycle < .74) {
                        // A short tapered tail follows the packet along the same curve.
                        for (let k=0; k<12; ++k) {
                            const t0=Math.max(0,head-(12-k)*.009);
                            const t1=Math.max(0,head-(11-k)*.009);
                            const u0=1-t0, u1=1-t1;
                            c.strokeStyle=Qt.rgba(red/255,green/255,blue/255,.06+k*.047);
                            c.lineWidth=1+k*.11;
                            c.beginPath();
                            c.moveTo(u0*u0*ax+2*u0*t0*cx+t0*t0*bx,u0*u0*ay+2*u0*t0*cy+t0*t0*by);
                            c.lineTo(u1*u1*ax+2*u1*t1*cx+t1*t1*bx,u1*u1*ay+2*u1*t1*cy+t1*t1*by);
                            c.stroke();
                        }
                        const u=1-head;
                        const x=u*u*ax+2*u*head*cx+head*head*bx, y=u*u*ay+2*u*head*cy+head*head*by;
                        const halo=c.createRadialGradient(x,y,0,x,y,9);
                        halo.addColorStop(0,Qt.rgba(red/255,green/255,blue/255,.65));
                        halo.addColorStop(1,"rgba(0,0,0,0)");
                        c.fillStyle=halo; c.fillRect(x-9,y-9,18,18);
                        c.fillStyle=warm ? "#ffd3a8" : "#bcfcff";
                        c.beginPath(); c.arc(x,y,2.3,0,Math.PI*2); c.fill();
                    }
                    const arrival=Math.max(0,(cycle-.72)/.28);
                    const energy=cycle<.72 ? .16 : Math.pow(1-arrival,2);
                    for (let k=0; k<7; ++k) {
                        const angle=k*2.399+i, radius=3+Math.sqrt(k)*4;
                        c.fillStyle=Qt.rgba(1,k%3===0 ? .65 : .30,.38,.38+energy*.56);
                        c.beginPath(); c.arc(bx+Math.cos(angle)*radius,by+Math.sin(angle)*radius*.65,1.7,0,Math.PI*2); c.fill();
                    }
                    if (cycle >= .72) {
                        for (let ring=0; ring<2; ++ring) {
                            const wave=arrival-ring*.18;
                            if (wave<0 || wave>1) continue;
                            c.strokeStyle=Qt.rgba(1,.33,.40,(1-wave)*.82);
                            c.lineWidth=1.6-ring*.4;
                            c.beginPath(); c.arc(bx,by,5+wave*27,0,Math.PI*2); c.stroke();
                        }
                    }
                    const glow=c.createRadialGradient(bx,by,0,bx,by,20);
                    glow.addColorStop(0,Qt.rgba(1,.36,.42,.25+energy*.5));
                    glow.addColorStop(1,"rgba(255,91,106,0)");
                    c.fillStyle=glow; c.fillRect(bx-20,by-20,40,40);
                    c.fillStyle=Qt.rgba(1,.76,.63,.5+energy*.5);
                    c.beginPath(); c.arc(bx,by,2+energy,0,Math.PI*2); c.fill();
                }
                root.protectCenter(c,width,height);
                return;
            }
            const paths = [[.22,.30,.53,.26], [.28,.37,.74,.36], [.43,.65,.57,.31], [.80,.73,.54,.27]];
            for (let i = 0; i < paths.length; ++i) {
                const p = paths[i];
                const ax=p[0]*width, ay=p[1]*height, bx=p[2]*width, by=p[3]*height;
                const cx=(ax+bx)/2, cy=Math.min(ay,by)-height*.16;
                c.strokeStyle="rgba(105,205,220,0.48)"; c.lineWidth=1;
                c.beginPath(); c.moveTo(ax,ay); c.quadraticCurveTo(cx,cy,bx,by); c.stroke();
                const t=(root.phase+i*.23)%1, u=1-t;
                const x=u*u*ax+2*u*t*cx+t*t*bx, y=u*u*ay+2*u*t*cy+t*t*by;
                c.fillStyle="#a8f9ff";
                c.beginPath(); c.arc(x,y,3,0,Math.PI*2); c.fill();
            }
        }
    }
    SeaTraffic {
        anchors.fill: parent
        visible: root.threats && root.settings.ships
        phase: root.phase
        protect: root.protectCenter
    }
    Connections {
        target: root.settings
        function onMapDotSizeChanged() { land.requestPaint(); }
    }
    Timer {
        interval: root.threats ? 33 : 66
        running: root.visible && root.settings.animations && root.opacity > 0
        repeat: true
        onTriggered: { root.phase += root.threats ? 0.002 : 0.004; routes.requestPaint(); }
    }
}
