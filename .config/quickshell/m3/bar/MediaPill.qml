import QtQuick
import qs.tokens
import qs.services
import qs.components

Item {
    id: root
    opacity: Media.has ? 1 : 0
    visible: opacity > 0.01
    FadeBehavior on opacity { time: M3Motion.short4 }
    implicitHeight: 32
    implicitWidth: Media.has ? row.implicitWidth + 24 : 0
    SpatialBehavior on implicitWidth {}

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: ma.pressed ? 10 : height / 2
        color: M3Colors.secondaryContainer
        SpatialBehavior on radius {}
        StateLayer { anchors.fill: parent; radius: bg.radius; tint: M3Colors.fgSecondaryContainer; hovered: ma.containsMouse; pressed: ma.pressed }
    }
    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
        Icon { name: Media.playing ? "graphic_eq" : "pause"; size: 18; color: M3Colors.fgSecondaryContainer; fill: 1; anchors.verticalCenter: parent.verticalCenter }
        M3Text {
            width: Math.min(implicitWidth, 180)
            elide: Text.ElideRight
            text: Media.artist ? Media.title + " · " + Media.artist : Media.title
            role: M3Type.labelMedium
            color: M3Colors.fgSecondaryContainer
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: m => { if (m.button === Qt.MiddleButton) Media.next(); else Media.toggle() }
    }
}
