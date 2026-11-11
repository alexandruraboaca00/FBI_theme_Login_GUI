import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control
    property color accent: "#7cdfe5"
    property string terminalFont: "monospace"
    property bool crt: true
    property bool animations: true
    property bool subtle: false
    implicitWidth: 138
    implicitHeight: 42
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font.family: terminalFont
    font.pixelSize: subtle ? 16 : 23
    opacity: enabled ? 1 : 0.42
    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        style: control.crt ? Text.Outline : Text.Normal
        styleColor: Qt.rgba(control.accent.r, control.accent.g, control.accent.b, 0.18)
        font: control.font
        color: control.accent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        color: control.down ? "#416b76" : control.hovered ? "#294755" : control.subtle ? "#080e1c" : "#294651"
        border.color: control.accent
        border.width: control.activeFocus ? 2 : 1
        opacity: control.subtle && !control.hovered && !control.activeFocus ? 0.55 : 0.9
        Behavior on color { ColorAnimation { duration: control.animations ? 100 : 0 } }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            color: "transparent"
            border.color: control.accent
            opacity: 0.13
        }
    }
}
