import QtQuick

Item {
    id: root
    required property var settings
    // The master stays untouched. Replace the baked controls with an adjacent
    // blank scan of the same image. All coordinates use the reference canvas.
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: /^(\/|[a-z]+:)/i.test(root.settings.background) ? root.settings.background : Qt.resolvedUrl("../" + root.settings.background)
        fillMode: root.settings.crop ? Image.PreserveAspectCrop : Image.PreserveAspectFit
        smooth: true
        mipmap: true
        onStatusChanged: if (status === Image.Error && source.toString() !== Qt.resolvedUrl("../assets/reference.jpg").toString()) source = "../assets/reference.jpg"
    }
    Item {
        width: 1600
        height: 900
        anchors.centerIn: parent
        scale: root.settings.crop ? Math.max(root.width / width, root.height / height) : Math.min(root.width / width, root.height / height)
        Image {
            x: 548; y: 413; width: 474; height: 240
            source: "../assets/reference.jpg"
            sourceClipRect: Qt.rect(1070, 413, 474, 240)
            smooth: true
            mipmap: true
            visible: backgroundImage.source.toString() === Qt.resolvedUrl("../assets/reference.jpg").toString()
        }
    }
    Rectangle { anchors.fill: parent; color: "black"; opacity: root.settings.dim }
}
