import QtQuick
import qs.theme

Item {
    id: root
    property color color: Colors.onSurface
    property real radius: 0
    readonly property bool hovered: area.containsMouse
    readonly property bool pressed: area.pressed

    signal clicked()
    signal rightClicked()
    signal middleClicked()

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.color
        opacity: !root.enabled ? 0
               : root.pressed ? M3.stateLayer.pressed
               : root.hovered ? M3.stateLayer.hover : 0
        Behavior on opacity { NumberAnimation { duration: M3.motion.short2 } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: m => {
            if (m.button === Qt.RightButton) root.rightClicked()
            else if (m.button === Qt.MiddleButton) root.middleClicked()
            else root.clicked()
        }
    }
}