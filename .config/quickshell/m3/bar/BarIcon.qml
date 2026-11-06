import QtQuick
import qs.tokens
import qs.components

Item {
    id: root
    property string icon: ""
    property color tint: M3Colors.fgSurfaceVariant
    property bool filled: false
    property int badge: 0
    property int iconSize: 22
    signal clicked()
    signal middleClicked()
    signal scrolled(int dir)
    implicitWidth: 36
    implicitHeight: 36

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: ma.pressed ? 12 : height / 2
        color: "transparent"
        SpatialBehavior on radius {}
        StateLayer { anchors.fill: parent; radius: bg.radius; tint: root.tint; hovered: ma.containsMouse; pressed: ma.pressed }
    }
    Icon { anchors.centerIn: parent; name: root.icon; size: root.iconSize; color: root.tint; fill: root.filled ? 1 : 0 }
    Rectangle {
        visible: opacity > 0.01
        opacity: root.badge > 0 ? 1 : 0
        FadeBehavior on opacity { time: M3Motion.short3 }
        x: parent.width - 18; y: 3
        width: Math.max(14, bt.implicitWidth + 6); height: 14; radius: 7
        color: M3Colors.error
        M3Text { id: bt; anchors.centerIn: parent; text: root.badge > 9 ? "9+" : String(root.badge); color: M3Colors.fgError; role: ({ size: 9, line: 12, weight: Font.Bold, tracking: 0 }) }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: m => { if (m.button === Qt.MiddleButton) root.middleClicked(); else root.clicked() }
        onWheel: w => root.scrolled(w.angleDelta.y > 0 ? 1 : -1)
    }
}
