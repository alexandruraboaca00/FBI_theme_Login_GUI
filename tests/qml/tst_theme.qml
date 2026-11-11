import QtQuick
import QtQuick.Controls.Basic
import QtTest

Item {
    id: harness
    width: 1920; height: 1080
    property bool primaryScreen: true
    property var config: ({Background: "assets/reference.jpg", Animations: false})
    QtObject {
        id: sddm
        property bool canPowerOff: true
        property bool canReboot: true
        property bool canSuspend: true
        property int calls: 0
        property int powerCalls: 0
        property string lastUser: ""
        property int lastSession: -1
        property int secretLength: 0
        signal loginFailed()
        signal loginSucceeded()
        signal informationMessage(string message)
        signal socketDisconnected()
        function login(user, secret, index) {
            calls++; lastUser = user; lastSession = index; secretLength = secret.length;
        }
        function powerOff() { powerCalls++; }
        function reboot() { powerCalls++; }
        function suspend() { powerCalls++; }
    }
    ListModel {
        id: userModel
        property string lastUser: "test.operator"
        property int lastIndex: 0
        ListElement { name: "test.operator"; realName: "Test"; icon: "" }
        ListElement { name: "second.operator"; realName: "Second"; icon: "missing-avatar.png" }
    }
    ListModel {
        id: sessionModel
        property int lastIndex: 1
        ListElement { name: "Plasma (Wayland)"; file: "plasma.desktop" }
        ListElement { name: "Example X11"; file: "example.desktop" }
    }
    QtObject {
        id: keyboard
        property bool enabled: true
        property bool capsLock: false
        property int currentLayout: 0
        property var layouts: [{longName: "English (US)", shortName: "us"}, {longName: "Español", shortName: "es"}]
    }
    Loader { id: themeLoader; anchors.fill: parent; source: "../../src/theme/Main.qml" }
    TestCase {
        id: tests
        name: "FederalTheme"
        when: windowShown && themeLoader.status === Loader.Ready
        function item(name) { return findChild(themeLoader.item, name); }
        function typeText(text) { for (let i = 0; i < text.length; ++i) keyClick(text.charAt(i)); }
        function init() {
            themeLoader.active = false;
            harness.config = ({Background: "assets/reference.jpg", Animations: false});
            if (sessionModel.count === 0) {
                sessionModel.append({name: "Plasma (Wayland)", file: "plasma.desktop"});
                sessionModel.append({name: "Example X11", file: "example.desktop"});
            }
            sddm.calls = 0; sddm.powerCalls = 0;
            sddm.canPowerOff = true; sddm.canReboot = true; sddm.canSuspend = true;
            keyboard.capsLock = false;
            harness.primaryScreen = true;
            themeLoader.active = true;
            tryCompare(themeLoader, "status", Loader.Ready);
            wait(30);
        }
        function test_initial_and_keyboard_login() {
            compare(item("username").text, "test.operator");
            compare(item("sessions").currentIndex, 1);
            verify(item("password").activeFocus);
            compare(item("password").echoMode, TextInput.Password);
            typeText("dummy-only");
            keyClick(Qt.Key_Return);
            compare(sddm.calls, 1);
            compare(sddm.lastUser, "test.operator");
            compare(sddm.lastSession, 1);
            compare(sddm.secretLength, 10);
            compare(item("password").text, "");
            verify(themeLoader.item.controller.busy);
            verify(!item("login").enabled);
            themeLoader.item.controller.submit("test.operator", "dummy-only");
            compare(sddm.calls, 1);
        }
        function test_failure_and_retry() {
            item("password").text = "dummy-only";
            item("login").clicked();
            sddm.loginFailed();
            verify(!themeLoader.item.controller.busy);
            compare(item("password").text, "");
            verify(item("password").activeFocus);
            verify(item("authMessage").text.indexOf("denegado") >= 0);
            grabImage(themeLoader.item).save("tests/screenshots/mock-auth-failure.png");
            typeText("dummy-retry"); keyClick(Qt.Key_Return);
            compare(sddm.calls, 2);
            sddm.loginSucceeded();
            verify(themeLoader.item.controller.busy);
        }
        function test_manual_user_empty_password_and_validation() {
            item("username").text = "   ";
            item("login").clicked();
            compare(sddm.calls, 0);
            verify(item("username").activeFocus);
            item("username").text = " unlisted.operator ";
            item("login").clicked();
            compare(sddm.lastUser, "unlisted.operator");
            compare(sddm.secretLength, 0);
        }
        function test_tab_focus() {
            item("username").forceActiveFocus();
            keyClick(Qt.Key_Tab); verify(item("password").activeFocus);
            keyClick(Qt.Key_Tab); verify(item("login").activeFocus);
            keyClick(Qt.Key_Backtab); verify(item("password").activeFocus);
        }
        function test_session_and_layout_keyboard() {
            item("sessionButton").clicked(); wait(30);
            const sessions = item("sessions");
            sessions.forceActiveFocus();
            keyClick(Qt.Key_Space); wait(30);
            compare(sessions.popup.contentItem.itemAtIndex(0).text, "Plasma (Wayland)");
            keyClick(Qt.Key_Home); keyClick(Qt.Key_Return); wait(30);
            compare(themeLoader.item.controller.sessionIndex, 0);
            const layouts = item("layouts");
            layouts.forceActiveFocus(); keyClick(Qt.Key_Space); wait(30);
            compare(layouts.popup.contentItem.itemAtIndex(0).text, "English (US)");
            keyClick(Qt.Key_End); keyClick(Qt.Key_Return); wait(30);
            compare(keyboard.currentLayout, 1);
            keyboard.currentLayout = 0;
        }
        function test_user_menu_keyboard() {
            item("username").forceActiveFocus(); keyClick(Qt.Key_Down, Qt.AltModifier); wait(30);
            compare(item("userMenu").count, 2);
            verify(item("userMenu").opened);
            keyClick(Qt.Key_Down); keyClick(Qt.Key_Down);
            compare(item("userMenu").currentIndex, 1);
            keyClick(Qt.Key_Return); wait(30);
            compare(item("username").text, "second.operator");
            verify(item("password").activeFocus);
        }
        function test_power_escape_and_confirmation() {
            item("powerOff").clicked(); wait(30);
            verify(item("powerDialog").opened);
            keyClick(Qt.Key_Escape); wait(30);
            verify(!item("powerDialog").opened);
            compare(sddm.powerCalls, 0);
            item("reboot").clicked(); wait(30);
            item("confirmPower").clicked();
            compare(sddm.powerCalls, 1);
            sddm.canSuspend = false;
            wait(30); verify(!item("suspend").visible);
        }
        function test_plain_messages_and_disconnect() {
            sddm.informationMessage("<b>Test message</b>");
            compare(item("authMessage").textFormat, Text.PlainText);
            compare(item("authMessage").text, "<b>Test message</b>");
            sddm.socketDisconnected();
            verify(!item("login").enabled);
            themeLoader.item.controller.submit("test.operator", "dummy-only");
            compare(sddm.calls, 0);
        }
        function test_secondary_screen() {
            harness.primaryScreen = false; wait(30);
            verify(!item("login").visible);
            verify(!item("login").enabled);
            verify(!item("sessions").visible);
        }
        function test_invalid_session() {
            themeLoader.item.controller.sessionIndex = -1;
            themeLoader.item.controller.submit("test.operator", "dummy-only");
            compare(sddm.calls, 0);
            verify(!themeLoader.item.controller.busy);
        }
        function test_clock_and_animation() {
            verify(/^\d{2}\/\d{2}\/\d{4}$/.test(item("clockDate").text));
            verify(/^([01]\d|2[0-3]):[0-5]\d$/.test(item("clockTime").text));
            const map = item("networkMap");
            compare(map.phase, 0);
            harness.config = ({Animations: true});
            wait(180); verify(map.phase > 0);
            harness.config = ({Animations: false});
            const stopped = map.phase;
            wait(160); compare(map.phase, stopped);
        }
        function test_new_header_clock() {
            harness.config = ({ClockPosition: "header", CRT: true, CRTStrength: 0.24, AnimatedMap: true, MapOpacity: 0.24, Animations: false});
            wait(30);
            verify(item("headerClockTime").visible);
            verify(item("headerClockDate").visible);
            verify(!item("clockTime").visible);
            verify(/^\d{2}\/\d{2}\/\d{4}$/.test(item("headerClockDate").text));
            compare(item("networkMap").opacity, 0.24);
        }
        function test_caps_lock() {
            verify(!item("capsLock").visible);
            keyboard.capsLock = true; wait(20);
            verify(item("capsLock").visible);
        }
        function test_map_variants() {
            harness.config = ({ClockPosition: "header", MapStyle: "dots", MapOpacity: 0.48, MapDotSize: 2.7, Animations: false});
            wait(40);
            const map = item("networkMap");
            verify(!map.threats);
            verify(!item("seaTraffic").visible);
            compare(map.opacity, 0.48);
            harness.config = ({ClockPosition: "header", MapStyle: "threats", MapOpacity: 0.56, Animations: true});
            wait(180);
            verify(map.threats);
            verify(item("seaTraffic").visible);
            compare(item("seaTraffic").vesselCount, 4);
            compare(map.height, 570);
            compare(map.width, 1420);
            compare(map.opacity, 0.56);
            verify(map.phase > 0);
            verify(item("headerClockTime").visible);
            verify(item("username").enabled);
            verify(item("password").enabled);
            verify(item("login").enabled);
            harness.config = ({MapStyle: "threats", Animations: false});
            const stopped = map.phase;
            wait(140); compare(map.phase, stopped);
            harness.config = ({MapStyle: "threats", ShowShips: false, Animations: false});
            wait(20); verify(!item("seaTraffic").visible);
        }
        function test_zero_sessions() {
            themeLoader.active = false;
            sessionModel.clear();
            themeLoader.active = true;
            tryCompare(themeLoader, "status", Loader.Ready);
            compare(themeLoader.item.controller.sessionIndex, -1);
            verify(!item("login").enabled);
            themeLoader.item.controller.submit("test.operator", "dummy-only");
            compare(sddm.calls, 0);
            verify(item("authMessage").text.indexOf("sesiones") >= 0);
        }
    }
}
