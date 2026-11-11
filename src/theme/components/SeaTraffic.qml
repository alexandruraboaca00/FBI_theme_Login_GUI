import QtQuick
import "../assets/SeaRoutes.js" as Maritime

Canvas {
    id: root
    objectName: "seaTraffic"
    required property real phase
    required property var protect
    readonly property int vesselCount: Maritime.routes.length
    antialiasing: true
    onPhaseChanged: if (visible) requestPaint()
    onVisibleChanged: if (visible) requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const c=getContext("2d");
        c.clearRect(0,0,width,height);
        c.globalAlpha=1; c.globalCompositeOperation="source-over";
        for (let i=0; i<Maritime.routes.length; ++i) {
            c.strokeStyle="rgba(106,211,223,0.19)"; c.lineWidth=.7;
            c.beginPath();
            for (let k=0; k<Maritime.routes[i].length; ++k) {
                const p=Maritime.project(Maritime.routes[i][k]);
                if (k===0) c.moveTo(p[0]*width,p[1]*height);
                else c.lineTo(p[0]*width,p[1]*height);
            }
            c.stroke();
            // Slower than the network packets; coast-to-coast travel is decorative.
            const t=(root.phase*.32+i*.241)%1;
            const ship=Maritime.sample(i,t,width,height);
            c.save(); c.translate(ship.x,ship.y); c.rotate(ship.heading);
            c.globalAlpha=Math.min(1,t/.04,(1-t)/.04);
            // Fine V-shaped wakes behind the stern.
            for (let k=0; k<3; ++k) {
                c.strokeStyle=Qt.rgba(.54,.88,.96,.42-k*.11);
                c.lineWidth=.8;
                c.beginPath(); c.moveTo(-7-k*4,-2-k);
                c.lineTo(-11-k*4,-3.5-k); c.stroke();
                c.beginPath(); c.moveTo(-7-k*4,2+k);
                c.lineTo(-11-k*4,3.5+k); c.stroke();
            }
            c.fillStyle="#163e54"; c.strokeStyle="#b0f2ef"; c.lineWidth=1;
            c.beginPath(); c.moveTo(8,0); c.lineTo(3,-3.5);
            c.lineTo(-6,-3.5); c.lineTo(-7,0); c.lineTo(-6,3.5);
            c.lineTo(3,3.5); c.closePath(); c.fill(); c.stroke();
            c.fillStyle="#87d9e6"; c.fillRect(-3,-1.5,5,3);
            c.fillStyle="#dcffff"; c.fillRect(-4,-2,1,4);
            c.restore();
        }
        root.protect(c,width,height);
    }
}
