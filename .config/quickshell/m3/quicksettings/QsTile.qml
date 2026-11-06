import QtQuick
import qs.tokens
import qs.components

// Toggle tile: the icon blob morphs (circle <-> soft burst) and the tile goes pill-shaped when on.
Item {
    id: root
    property string icon: ""
    property string label: ""
    property string sub: ""
    property bool checked: false
    signal clicked()
    implicitHeight: 72
    opacity: enabled ? 1 : M3Opacity.disabledContent

    property real cornerRadius: ma.pressed ? 14 : (checked ? 36 : 22)
    SpatialBehavior on cornerRadius {}

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Math.max(0, Math.min(root.cornerRadius, height / 2))
        color: root.checked ? M3Colors.primaryContainer : M3Colors.surfaceContainerHigh
        ColorBehavior on color {}
        StateLayer {
            anchors.fill: parent; radius: bg.radius
            tint: root.checked ? M3Colors.fgPrimaryContainer : M3Colors.fgSurface
            hovered: ma.containsMouse; pressed: ma.pressed
        }
    }
    Row {
        anchors.verticalCenter: parent.verticalCenter
        x: 14
        spacing: 12
        Item {
            width: 44; height: 44
            MorphShape {
                anchors.fill: parent
                size: 44
                shape: root.checked ? "softBurst" : "circle"
                color: root.checked ? M3Colors.primary : M3Colors.surfaceContainerHighest
            }
            Icon {
                anchors.centerIn: parent
                name: root.icon; size: 22; fill: root.checked ? 1 : 0
                color: root.checked ? M3Colors.fgPrimary : M3Colors.fgSurfaceVariant
            }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: root.width - 14 - 44 - 12 - 14
            M3Text { width: parent.width; elide: Text.ElideRight; text: root.label; role: M3Type.titleSmall; color: root.checked ? M3Colors.fgPrimaryContainer : M3Colors.fgSurface }
            M3Text { width: parent.width; elide: Text.ElideRight; text: root.sub; role: M3Type.bodySmall; color: root.checked ? M3Colors.fgPrimaryContainer : M3Colors.fgSurfaceVariant }
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
