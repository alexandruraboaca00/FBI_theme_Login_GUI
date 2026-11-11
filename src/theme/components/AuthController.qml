import QtQuick

QtObject {
    id: root
    required property var backend
    required property var sessions
    property bool busy: false
    property bool offline: false
    property bool failed: false
    property string message: ""
    property int sessionIndex: sessions.count > 0 ? Math.max(0, Math.min(sessions.lastIndex, sessions.count - 1)) : -1
    signal focusPassword()
    signal focusUser()

    function submit(user, password) {
        if (busy || offline) return;
        if (user.trim().length === 0) {
            failed = true;
            message = qsTr("Introduce un usuario.");
            focusUser();
            return;
        }
        if (sessionIndex < 0 || sessionIndex >= sessions.count) {
            failed = true;
            message = qsTr("No hay una sesión disponible. Comprueba la instalación.");
            return;
        }
        failed = false;
        message = qsTr("Autenticando…");
        busy = true;
        backend.login(user.trim(), password, sessionIndex);
    }
    property Connections events: Connections {
        target: root.backend
        function onLoginFailed() {
            root.busy = false;
            root.failed = true;
            root.message = qsTr("Acceso denegado. Comprueba usuario y contraseña.");
            root.focusPassword();
        }
        function onLoginSucceeded() {
            root.busy = true;
            root.failed = false;
            root.message = qsTr("Iniciando sesión…");
        }
        function onInformationMessage(message) { root.message = message; }
        function onSocketDisconnected() {
            root.offline = true;
            root.busy = false;
            root.failed = true;
            root.message = qsTr("Se ha perdido la conexión con SDDM.");
        }
    }
}
