import QtQuick
import qs.tokens

// M3 Expressive loading indicator: shape cycles while rotating.
Item {
    id: root
    property real size: 48
    property bool contained: true
    property var shapes: ["softBurst", "cookie9Sided", "pentagon", "pill", "sunny", "cookie4Sided", "oval"]
    property int idx: 0
    implicitWidth: size; implicitHeight: size

    Rectangle {
        visible: root.contained
        anchors.fill: parent
        radius: width / 2
        color: M3Colors.secondaryContainer
    }
    Item {
        id: spin
        anchors.centerIn: parent
        width: root.size * 0.62; height: width
        NumberAnimation on rotation { from: 0; to: 360; duration: 4800; loops: Animation.Infinite; running: root.visible }
        MorphShape {
            anchors.fill: parent
            size: spin.width
            shape: root.shapes[root.idx]
            color: M3Colors.primary
        }
    }
    Timer {
        interval: 650; repeat: true; running: root.visible
        onTriggered: root.idx = (root.idx + 1) % root.shapes.length
    }
}
