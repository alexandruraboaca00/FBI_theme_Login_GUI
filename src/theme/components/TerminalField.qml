import QtQuick
import QtQuick.Controls.Basic

TextField {
    id: control
    property color accent: "#7cdfe5"
    property string terminalFont: "monospace"
    property real panelOpacity: 0.1
    implicitWidth: 283
    implicitHeight: 44
    renderType: Text.NativeRendering
    color: accent
    placeholderTextColor: "#547d8c"
    selectionColor: "#426c82"
    selectedTextColor: "#e2ffff"
    font.family: terminalFont
    font.pixelSize: 23
    leftPadding: 9
    rightPadding: 9
    verticalAlignment: TextInput.AlignVCenter
    selectByMouse: true
    persistentSelection: false
    passwordCharacter: "*"
    passwordMaskDelay: 0
    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
    maximumLength: 512
    background: Rectangle {
        color: Qt.rgba(0.02, 0.08, 0.13, control.panelOpacity)
        border.color: control.accent
        border.width: 1
        opacity: control.enabled ? (control.activeFocus ? 0.9 : 0.65) : 0.35
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            color: "transparent"
            border.color: control.accent
            opacity: control.activeFocus ? 0.2 : 0.07
        }
    }
}
