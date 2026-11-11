pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic

ComboBox {
    id: control
    property color accent: "#7cdfe5"
    property string terminalFont: "monospace"
    implicitWidth: 245
    implicitHeight: 32
    textRole: "name"
    font.family: terminalFont
    font.pixelSize: 16
    focusPolicy: Qt.StrongFocus
    leftPadding: 10
    rightPadding: 25
    contentItem: Text {
        text: control.displayText
        textFormat: Text.PlainText
        font: control.font
        color: control.accent
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
    indicator: Text {
        x: control.width - 21
        anchors.verticalCenter: parent.verticalCenter
        text: "⌄"
        color: control.accent
        font.pixelSize: 18
    }
    background: Rectangle {
        color: "#080e1c"
        border.color: control.accent
        opacity: control.activeFocus ? 1 : 0.4
    }
    delegate: ItemDelegate {
        id: option
        required property int index
        required property var model
        width: control.width
        text: model[control.textRole]
        font: control.font
        highlighted: control.highlightedIndex === index
        contentItem: Text { text: option.text; textFormat: Text.PlainText; font: control.font; color: control.accent; elide: Text.ElideRight }
        background: Rectangle { color: option.highlighted ? "#254654" : "#080e1c" }
    }
    popup: Popup {
        y: -height - 5
        width: control.width
        padding: 1
        implicitHeight: Math.min(contentItem.implicitHeight + 2, 220)
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        background: Rectangle { color: "#080e1c"; border.color: control.accent }
    }
}
