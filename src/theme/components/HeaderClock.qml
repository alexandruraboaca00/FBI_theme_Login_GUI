import QtQuick

Item {
    id: root
    required property var settings
    required property string terminalFont
    property date now: new Date()
    Timer { interval: 1000; running: root.visible; repeat: true; onTriggered: root.now = new Date() }
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 3
        Text {
            objectName: "headerClockTime"
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.now, root.settings.clockFormat)
            color: root.settings.accent
            font.family: root.terminalFont; font.pixelSize: 34
            font.letterSpacing: 3
            style: Text.Outline; styleColor: "#407cdfe5"
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 28; height: 1; color: root.settings.accent; opacity: 0.4 }
            Text {
                objectName: "headerClockDate"
                text: Qt.formatDateTime(root.now, root.settings.dateFormat)
                color: root.settings.accent
                font.family: root.terminalFont; font.pixelSize: 17
                font.letterSpacing: 1
                opacity: 0.85
            }
            Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 28; height: 1; color: root.settings.accent; opacity: 0.4 }
        }
    }
    CrtOverlay { anchors.fill: parent; visible: root.settings.crt; strength: root.settings.crtStrength }
}
