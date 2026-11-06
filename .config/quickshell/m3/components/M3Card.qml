import QtQuick
import qs.tokens

// variant: elevated | filled | outlined. Children go into the padded content area.
Item {
    id: root
    property string variant: "filled"
    property bool clickable: false
    property int padding: 16
    default property alias content: inner.data
    signal clicked()
    implicitWidth: 240
    implicitHeight: 120

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: M3Shape.medium
        color: root.variant === "elevated" ? M3Colors.surfaceContainerLow
             : root.variant === "outlined" ? M3Colors.surface : M3Colors.surfaceContainerHighest
        border.width: root.variant === "outlined" ? 1 : 0
        border.color: M3Colors.outlineVariant
        ColorBehavior on color {}
        StateLayer {
            visible: root.clickable
            anchors.fill: parent; radius: bg.radius
            hovered: ma.containsMouse; pressed: ma.pressed
        }
    }
    Item { id: inner; anchors.fill: parent; anchors.margins: root.padding }
    MouseArea {
        id: ma
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
