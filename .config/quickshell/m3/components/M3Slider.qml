import QtQuick
import qs.tokens

Item {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    property real stepSize: 0
    property bool showLabel: true
    signal moved(real value)
    implicitWidth: 240
    implicitHeight: 44

    readonly property real frac: to > from ? Math.max(0, Math.min(1, (value - from) / (to - from))) : 0
    readonly property real trackH: 16
    readonly property real gap: 6

    function setFromX(px) {
        let f = Math.max(0, Math.min(1, px / width))
        let v = from + f * (to - from)
        if (stepSize > 0) v = Math.round((v - from) / stepSize) * stepSize + from
        v = Math.max(from, Math.min(to, v))
        if (v !== value) { value = v; moved(v) }
    }

    Rectangle {  // active
        x: 0; y: (root.height - height) / 2
        width: Math.max(0, handle.x - root.gap)
        height: root.trackH
        color: M3Colors.primary
        topLeftRadius: height / 2; bottomLeftRadius: height / 2
        topRightRadius: 2; bottomRightRadius: 2
    }
    Rectangle {  // inactive
        x: handle.x + handle.width + root.gap
        y: (root.height - height) / 2
        width: Math.max(0, root.width - x)
        height: root.trackH
        color: M3Colors.secondaryContainer
        topLeftRadius: 2; bottomLeftRadius: 2
        topRightRadius: height / 2; bottomRightRadius: height / 2
    }
    Rectangle {
        id: handle
        width: ma.pressed ? 2 : 4
        height: root.height
        radius: width / 2
        x: root.frac * (root.width - width)
        color: M3Colors.primary
        SpatialBehavior on width {}
    }
    Rectangle {  // value label
        width: 48; height: 44; radius: 22
        x: Math.max(0, Math.min(root.width - width, handle.x + handle.width / 2 - width / 2))
        y: -height - 4
        color: M3Colors.inverseSurface
        opacity: ma.pressed && root.showLabel ? 1 : 0
        visible: opacity > 0.01
        FadeBehavior on opacity { time: M3Motion.short3 }
        M3Text {
            anchors.centerIn: parent
            text: String(parseFloat(root.value.toFixed(2)))
            color: M3Colors.inverseOnSurface
            role: M3Type.labelLarge
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        preventStealing: true
        cursorShape: Qt.PointingHandCursor
        onPressed: m => root.setFromX(m.x)
        onPositionChanged: m => { if (pressed) root.setFromX(m.x) }
    }
}
