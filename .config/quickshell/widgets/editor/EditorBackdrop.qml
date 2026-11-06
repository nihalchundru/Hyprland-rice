import QtQuick
import "../core"

Item {
    id: root
    anchors.fill: parent

    property int cols: 1
    property int rows: 1

    opacity: LayoutStore.editMode ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 180 } }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.card, 0.5)
    }

    Repeater {
        model: root.cols * root.rows

        Rectangle {
            required property int index
            x: LayoutStore.posX(index % root.cols)
            y: LayoutStore.posY(Math.floor(index / root.cols))
            width: LayoutStore.cell
            height: LayoutStore.cell
            radius: 12
            color: Qt.alpha(Theme.onSurface, 0.05)
            border.width: 1
            border.color: Qt.alpha(Theme.onSurface, 0.09)
        }
    }
}