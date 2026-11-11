import QtQuick

Canvas {
    // Non-interactive phosphor mask; never captures keys, clicks or credentials.
    property real strength: 0.09
    onStrengthChanged: requestPaint()
    antialiasing: false
    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = Qt.rgba(0, 0, 0.03, strength);
        for (let y = 0; y < height; y += 3) ctx.fillRect(0, y, width, 1);
    }
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
}
