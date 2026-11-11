import QtQuick
import QtQuick.Window
import "components"

Rectangle {
    id: root
    objectName: "federalTheme"
    width: 1920; height: 1080
    color: "#000314"
    // SDDM 0.21 supplies a separate root per physical screen.
    // SDDM injects these context properties at runtime.
    // qmllint disable unqualified
    property bool interactive: primaryScreen
    readonly property var greeterBackend: sddm
    readonly property var availableSessions: sessionModel
    readonly property var availableUsers: userModel
    readonly property var keyboardState: keyboard
    readonly property var themeConfig: config
    // qmllint enable unqualified
    readonly property alias controller: authController
    readonly property real canvasScale: Math.min(width / 1600, height / 900)
    Settings { id: themeSettings; sourceConfig: root.themeConfig }
    FontLoader { id: fontLoader; source: "assets/ShareTechMono-Regular.ttf" }
    AuthController { id: authController; backend: root.greeterBackend; sessions: root.availableSessions }
    Backdrop { anchors.fill: parent; settings: themeSettings }
    Item {
        width: 1600; height: 900
        anchors.centerIn: parent
        scale: root.canvasScale
        NetworkMap {
            x: 90; y: themeSettings.mapStyle === "threats" ? 200 : 245
            width: 1420; height: themeSettings.mapStyle === "threats" ? 570 : 490
            settings: themeSettings
        }
        HeaderClock {
            x: 640; y: 330; width: 320; height: 65
            visible: root.interactive && themeSettings.clock && themeSettings.headerClock
            settings: themeSettings
            terminalFont: fontLoader.status === FontLoader.Ready ? fontLoader.name : "monospace"
        }
        LoginPanel {
            id: loginPanel
            visible: root.interactive
            enabled: visible
            x: themeSettings.offsetX; y: themeSettings.offsetY
            auth: authController; users: root.availableUsers; settings: themeSettings; keyboardState: root.keyboardState
            terminalFont: fontLoader.status === FontLoader.Ready ? fontLoader.name : "monospace"
        }
        UtilityBar {
            id: utilities
            x: 48; y: 858; width: 1504; height: 32
            visible: root.interactive && themeSettings.utilities
            enabled: visible
            auth: authController; settings: themeSettings; keyboardState: root.keyboardState
            terminalFont: fontLoader.status === FontLoader.Ready ? fontLoader.name : "monospace"
        }
        Text {
            x: 400; y: 600; width: 800
            visible: !root.interactive
            text: qsTr("Acceso disponible en la pantalla principal")
            color: themeSettings.accent
            font.family: fontLoader.name; font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
