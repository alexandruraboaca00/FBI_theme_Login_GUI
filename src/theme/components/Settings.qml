import QtQuick

QtObject {
    required property var sourceConfig
    function value(key, fallback) {
        const v = sourceConfig[key];
        return v === undefined || v === null || v === "" ? fallback : v;
    }
    function flag(key, fallback) { return String(value(key, fallback)).toLowerCase() === "true"; }
    function number(key, fallback, lo, hi) {
        const n = Number(value(key, fallback));
        return isFinite(n) ? Math.max(lo, Math.min(hi, n)) : fallback;
    }
    readonly property string background: String(value("Background", "assets/reference.jpg"))
    readonly property bool crop: value("BackgroundMode", "fit") === "crop"
    readonly property real dim: number("Dim", 0, 0, 0.8)
    readonly property color accent: value("Accent", "#7cdfe5")
    readonly property color errorColor: value("ErrorColor", "#ff7279")
    readonly property real panelOpacity: number("PanelOpacity", 0.1, 0, 1)
    readonly property bool utilities: flag("ShowUtilities", true)
    readonly property bool clock: flag("ShowClock", true)
    readonly property bool crt: flag("CRT", true)
    readonly property bool headerClock: value("ClockPosition", "footer") === "header"
    readonly property real crtStrength: number("CRTStrength", 0.09, 0, 0.35)
    readonly property bool ships: flag("ShowShips", true)
    readonly property bool animatedMap: flag("AnimatedMap", true)
    readonly property real mapOpacity: number("MapOpacity", 0.13, 0, 0.65)
    readonly property string mapStyle: String(value("MapStyle", "dots"))
    readonly property real mapDotSize: number("MapDotSize", 2, 1, 4)
    readonly property bool animations: flag("Animations", true)
    readonly property string clockFormat: "HH:mm"
    readonly property string dateFormat: "dd/MM/yyyy"
    readonly property real offsetX: number("PanelOffsetX", 0, -80, 80)
    readonly property real offsetY: number("PanelOffsetY", 0, -45, 45)
}
