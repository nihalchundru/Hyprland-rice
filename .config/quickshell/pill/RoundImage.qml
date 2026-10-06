import QtQuick
import QtQuick.Effects

// Image with rounded corners (mask based, needs Qt 6.5+).
Item {
    id: root

    property alias source: img.source
    property real radius: 12

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.tileHi
    }

    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(root.width * 2, root.height * 2)
        visible: status === Image.Ready
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: mask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }
    }

    Item {
        id: mask
        anchors.fill: parent
        layer.enabled: true
        visible: false
        Rectangle {
            anchors.fill: parent
            radius: root.radius
        }
    }
}
