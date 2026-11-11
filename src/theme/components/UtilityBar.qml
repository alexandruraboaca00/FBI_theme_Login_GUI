pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root
    required property var auth
    required property var settings
    required property var keyboardState
    required property string terminalFont
    property date now: new Date()
    property string pendingAction: ""
    property string pendingLabel: ""
    function ask(action, label) { pendingAction = action; pendingLabel = label; confirmation.open(); }
    Timer { interval: 1000; running: root.settings.clock; repeat: true; onTriggered: root.now = new Date() }
    Row {
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        spacing: 12
        TerminalButton {
            crt: root.settings.crt
            objectName: "sessionButton"
            width: 110; height: 32; subtle: true
            text: qsTr("Sesión")
            accent: root.settings.accent; terminalFont: root.terminalFont
            enabled: !root.auth.busy && !root.auth.offline
            onClicked: sessionPopup.open()
            Popup {
                id: sessionPopup
                y: -70; width: 310; height: 60
                padding: 12
                background: Rectangle { color: "#080e1c"; border.color: root.settings.accent }
                contentItem: TerminalCombo {
                    objectName: "sessions"
                    model: root.auth.sessions
                    currentIndex: root.auth.sessionIndex
                    enabled: !root.auth.busy && !root.auth.offline && count > 0
                    onActivated: root.auth.sessionIndex = currentIndex
                    accent: root.settings.accent; terminalFont: root.terminalFont
                    Accessible.name: qsTr("Sesión de escritorio")
                }
                onOpened: contentItem.forceActiveFocus()
            }
        }
        TerminalCombo {
            objectName: "layouts"
            width: 170
            textRole: "longName"
            model: root.keyboardState.layouts
            currentIndex: root.keyboardState.currentLayout
            visible: root.keyboardState.enabled && count > 0
            enabled: !root.auth.busy && !root.auth.offline && count > 1
            onActivated: root.keyboardState.currentLayout = currentIndex
            accent: root.settings.accent; terminalFont: root.terminalFont
            Accessible.name: qsTr("Distribución del teclado")
        }
    }
    Row {
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        spacing: 12
        Item {
            width: clockContent.implicitWidth; height: 32
            anchors.verticalCenter: parent.verticalCenter
            visible: root.settings.clock && !root.settings.headerClock
            Row {
                id: clockContent
                spacing: 12
            Text {
                objectName: "clockDate"
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(root.now, root.settings.dateFormat)
                color: root.settings.accent
                font.family: root.terminalFont; font.pixelSize: 17
                style: root.settings.crt ? Text.Outline : Text.Normal
                styleColor: "#307cdfe5"
            }
            Rectangle { width: 1; height: 25; color: root.settings.accent; opacity: 0.35 }
            Text {
                objectName: "clockTime"
                text: Qt.formatDateTime(root.now, root.settings.clockFormat)
                color: root.settings.accent
                font.family: root.terminalFont; font.pixelSize: 28
                style: root.settings.crt ? Text.Outline : Text.Normal
                styleColor: "#407cdfe5"
            }
            }
            CrtOverlay { strength: root.settings.crtStrength; anchors.fill: parent; visible: root.settings.crt }
        }
        Repeater {
            model: [
                { label: qsTr("Suspender"), action: "suspend", available: root.auth.backend.canSuspend },
                { label: qsTr("Reiniciar"), action: "reboot", available: root.auth.backend.canReboot },
                { label: qsTr("Apagar"), action: "powerOff", available: root.auth.backend.canPowerOff }
            ]
            TerminalButton {
                crt: root.settings.crt
                required property var modelData
                objectName: modelData.action
                width: 110; height: 32
                text: modelData.label; subtle: true
                visible: modelData.available
                enabled: !root.auth.busy && !root.auth.offline
                accent: root.settings.accent; terminalFont: root.terminalFont
                animations: root.settings.animations
                onClicked: root.ask(modelData.action, modelData.label)
            }
        }
    }
    Dialog {
        id: confirmation
        objectName: "powerDialog"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(420, parent.width - 32)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: 24
        background: Rectangle { color: "#080e1c"; border.color: root.settings.accent }
        contentItem: Column {
            spacing: 24
            Text {
                width: parent.width
                text: root.pendingLabel + "?"
                textFormat: Text.PlainText
                color: root.settings.accent
                font.family: root.terminalFont; font.pixelSize: 23
                horizontalAlignment: Text.AlignHCenter
            }
            Row {
                spacing: 12
                TerminalButton {
                    crt: root.settings.crt
                    id: cancel
                    text: qsTr("Cancelar")
                    terminalFont: root.terminalFont; accent: root.settings.accent
                    onClicked: confirmation.close()
                }
                TerminalButton {
                    crt: root.settings.crt
                    objectName: "confirmPower"
                    text: qsTr("Confirmar")
                    terminalFont: root.terminalFont; accent: root.settings.accent
                    enabled: !root.auth.busy && !root.auth.offline
                    onClicked: {
                        confirmation.close();
                        const backend = root.auth.backend;
                        if (root.pendingAction === "powerOff" && backend.canPowerOff) backend.powerOff();
                        else if (root.pendingAction === "reboot" && backend.canReboot) backend.reboot();
                        else if (root.pendingAction === "suspend" && backend.canSuspend) backend.suspend();
                    }
                }
            }
        }
        onOpened: cancel.forceActiveFocus()
    }
}
