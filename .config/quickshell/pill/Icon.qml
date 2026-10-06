import QtQuick
import QtQuick.Effects

// Tinted SVG icon from ./icons (white strokes, recolored at runtime).
Item {
    id: root

    property string name: ""
    property color color: Theme.text
    property real size: 20

    width: size
    height: size

    Image {
        anchors.fill: parent
        source: root.name ? Qt.resolvedUrl("icons/" + root.name + ".svg") : ""
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        smooth: true
        mipmap: true
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.color
        }
    }
}
