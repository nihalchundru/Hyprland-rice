import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.components

ColumnLayout {
    id: root
    property string icon: ""
    property string title: ""
    property string sub: ""
    property var options: []
    property string value: ""
    property bool open: false
    signal picked(string v)
    Layout.fillWidth: true
    spacing: 6

    SRow {
        icon: root.icon; title: root.title; sub: root.sub
        Rectangle {
            width: 260; height: 40; radius: 20
            color: M3Colors.surfaceContainerHighest
            StateLayer { anchors.fill: parent; radius: parent.radius; hovered: dma.containsMouse; pressed: dma.pressed }
            M3Text { x: 16; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 56; elide: Text.ElideRight; text: root.value; role: M3Type.bodyMedium }
            Icon { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; name: root.open ? "expand_less" : "expand_more"; size: 22; color: M3Colors.fgSurfaceVariant }
            MouseArea { id: dma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.open = !root.open }
        }
    }
    Rectangle {
        Layout.fillWidth: true
        visible: root.open
        implicitHeight: Math.min(220, list.contentHeight + 8)
        radius: 20
        color: M3Colors.surfaceContainerHighest
        clip: true
        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 4
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.options
            delegate: Item {
                id: it
                required property string modelData
                width: list.width; height: 40
                StateLayer { anchors.fill: parent; radius: 14; hovered: ima.containsMouse; pressed: ima.pressed }
                M3Text { x: 14; anchors.verticalCenter: parent.verticalCenter; text: it.modelData; role: M3Type.bodyMedium; color: it.modelData === root.value ? M3Colors.primary : M3Colors.fgSurface }
                Icon { visible: it.modelData === root.value; anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; name: "check"; size: 20; color: M3Colors.primary }
                MouseArea { id: ima; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.picked(it.modelData); root.open = false } }
            }
        }
    }
}
