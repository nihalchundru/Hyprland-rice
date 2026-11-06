import QtQuick
import qs.tokens

// model: [{text: "Copy", icon: "content_copy"}, ...]. Position it yourself (x/y), toggle with open.
Rectangle {
    id: root
    property var model: []
    property bool open: false
    property real itemHeight: 48
    signal triggered(int index)
    width: 200
    height: col.implicitHeight + 16
    radius: M3Shape.large
    color: M3Colors.surfaceContainer
    transformOrigin: Item.TopLeft
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.8
    visible: opacity > 0.01
    z: 500
    FadeBehavior on opacity { time: M3Motion.short3 }
    SpatialBehavior on scale { eps: 0.002 }

    Column {
        id: col
        y: 8
        width: parent.width
        Repeater {
            model: root.model
            Item {
                id: it
                required property var modelData
                required property int index
                width: col.width
                height: root.itemHeight
                StateLayer { anchors.fill: parent; hovered: ma.containsMouse; pressed: ma.pressed }
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    spacing: 12
                    Icon { visible: !!it.modelData.icon; name: it.modelData.icon || ""; color: M3Colors.fgSurfaceVariant; anchors.verticalCenter: parent.verticalCenter }
                    M3Text { text: it.modelData.text; role: M3Type.labelLarge; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.triggered(it.index); root.open = false }
                }
            }
        }
    }
}
