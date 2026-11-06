import QtQuick
import Quickshell
import qs.tokens
import qs.services
import qs.components

Row {
    spacing: 2
    Repeater {
        model: Tray.items
        Item {
            id: ti
            required property var modelData
            width: 30; height: 30
            Rectangle {
                id: bg
                anchors.fill: parent; radius: ma.pressed ? 10 : 15; color: "transparent"
                SpatialBehavior on radius {}
                StateLayer { anchors.fill: parent; radius: bg.radius; hovered: ma.containsMouse; pressed: ma.pressed }
            }
            Image {
                anchors.centerIn: parent
                width: 18; height: 18
                sourceSize.width: 36; sourceSize.height: 36
                source: ti.modelData.icon
                smooth: true
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: m => {
                    const p = ti.mapToItem(null, 0, ti.height)
                    if (m.button === Qt.LeftButton && !ti.modelData.onlyMenu) ti.modelData.activate()
                    else if (m.button === Qt.MiddleButton) ti.modelData.secondaryActivate()
                    else if (ti.modelData.hasMenu) ti.modelData.display(QsWindow.window, p.x, p.y)
                }
            }
        }
    }
}
