import QtQuick
import QtQuick.Effects

// Image clipped to a rounded rectangle (uses MultiEffect mask).
Item {
    id: root
    property alias source: img.source
    property real radius: 16
    readonly property bool ready: img.status === Image.Ready

    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: Math.max(1, root.width * 2)
        sourceSize.height: Math.max(1, root.height * 2)
        visible: false
    }
    Rectangle {
        id: mask
        anchors.fill: parent
        radius: root.radius
        visible: false
        layer.enabled: true
    }
    MultiEffect {
        anchors.fill: parent
        source: img
        maskEnabled: true
        maskSource: mask
        visible: root.ready
    }
}
