pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root
    required property var auth
    required property var users
    required property var settings
    required property var keyboardState
    required property string terminalFont
    property alias usernameField: username
    property alias passwordField: password
    property alias loginButton: login
    function initialFocus() { if (username.text.length) password.forceActiveFocus(); else username.forceActiveFocus(); }
    function submit() {
        auth.submit(username.text, password.text);
        if (auth.busy) password.clear();
    }
    width: 1600; height: 900

    Text {
        x: 550; y: 428; width: 137; height: 44
        style: root.settings.crt ? Text.Outline : Text.Normal
        styleColor: "#457cdfe5"
        text: "User"
        color: root.settings.accent
        font.family: root.terminalFont; font.pixelSize: 26
        horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter
    }
    TerminalField {
        id: username
        objectName: "username"
        x: 716; y: 428
        text: root.users.lastUser
        maximumLength: 256
        rightPadding: userChooser.visible ? 34 : 9
        accent: root.settings.accent
        panelOpacity: root.settings.panelOpacity
        terminalFont: root.terminalFont
        enabled: !root.auth.busy && !root.auth.offline
        Accessible.name: qsTr("Usuario")
        Accessible.description: qsTr("Escribe un usuario. Alt+Abajo abre la lista de usuarios.")
        KeyNavigation.tab: password
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Down && (event.modifiers & Qt.AltModifier) && userChooser.visible) {
                userMenu.open();
                event.accepted = true;
            }
        }
        onAccepted: password.forceActiveFocus()
    }
    TerminalButton {
        crt: root.settings.crt
        id: userChooser
        objectName: "userChooser"
        x: 969; y: 433; width: 25; height: 34
        text: "⌄"; subtle: true
        visible: root.users.count > 1
        enabled: username.enabled
        accent: root.settings.accent
        terminalFont: root.terminalFont
        Accessible.name: qsTr("Seleccionar usuario")
        KeyNavigation.tab: password
        KeyNavigation.backtab: username
        onClicked: userMenu.open()
        Menu {
            id: userMenu
            objectName: "userMenu"
            x: -253; y: 39; width: 283
            background: Rectangle { color: "#080e1c"; border.color: root.settings.accent }
            Instantiator {
                model: root.users
                onObjectAdded: (index, object) => userMenu.insertItem(index, object)
                onObjectRemoved: (index, object) => userMenu.removeItem(object)
                delegate: MenuItem {
                    id: userOption
                    required property string name
                    text: name
                    font.family: root.terminalFont; font.pixelSize: 20
                    contentItem: Text { text: userOption.text; textFormat: Text.PlainText; color: root.settings.accent; font: userOption.font }
                    background: Rectangle { color: userOption.highlighted ? "#254654" : "#080e1c" }
                    onTriggered: { username.text = name; password.clear(); password.forceActiveFocus(); }
                }
            }
        }
    }
    Text {
        x: 550; y: 489; width: 137; height: 44
        style: root.settings.crt ? Text.Outline : Text.Normal
        styleColor: "#457cdfe5"
        text: "Password"
        color: root.settings.accent
        font.family: root.terminalFont; font.pixelSize: 26
        horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter
    }
    TerminalField {
        id: password
        objectName: "password"
        x: 716; y: 489
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhHiddenText | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        accent: root.settings.accent
        panelOpacity: root.settings.panelOpacity
        terminalFont: root.terminalFont
        enabled: !root.auth.busy && !root.auth.offline
        Accessible.name: qsTr("Contraseña")
        KeyNavigation.backtab: username
        KeyNavigation.tab: login
        onAccepted: root.submit()
    }
    Text {
        objectName: "capsLock"
        x: 716; y: 543; width: 283
        visible: root.keyboardState.enabled && root.keyboardState.capsLock
        text: qsTr("BLOQ MAYÚS ACTIVADO")
        color: root.settings.errorColor
        font.family: root.terminalFont; font.pixelSize: 15
        Accessible.role: Accessible.StaticText
    }
    TerminalButton {
        crt: root.settings.crt
        id: login
        objectName: "login"
        x: 732; y: 596; width: 137; height: 41
        text: root.auth.busy ? "…" : "Login"
        accent: root.settings.accent
        terminalFont: root.terminalFont
        animations: root.settings.animations
        enabled: !root.auth.busy && !root.auth.offline && root.auth.sessionIndex >= 0
        Accessible.name: qsTr("Iniciar sesión")
        KeyNavigation.backtab: password
        onClicked: root.submit()
    }
    Text {
        objectName: "authMessage"
        x: 505; y: 658; width: 590; height: 75
        text: root.auth.sessions.count === 0 ? qsTr("No hay sesiones instaladas.") : root.auth.message
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        color: root.auth.failed ? root.settings.errorColor : root.settings.accent
        font.family: root.terminalFont; font.pixelSize: 19
        Accessible.role: Accessible.StaticText
        Accessible.name: text
    }
    CrtOverlay { strength: root.settings.crtStrength; x: 548; y: 413; width: 474; height: 240; visible: root.settings.crt }
    Connections {
        target: root.auth
        function onFocusPassword() { password.clear(); password.forceActiveFocus(); }
        function onFocusUser() { username.forceActiveFocus(); }
    }
    Component.onCompleted: Qt.callLater(initialFocus)
}
