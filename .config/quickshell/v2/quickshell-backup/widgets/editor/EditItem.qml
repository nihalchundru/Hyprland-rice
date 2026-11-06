import QtQuick
import "../core"

Item {
    id: root

    property string wid: ""
    property var overlay

    readonly property var wd: LayoutStore.find(wid)
    readonly property bool selected: LayoutStore.selectedId === wid

    visible: wd !== null
    x: LayoutStore.posX(wd?.x ?? 0)
    y: LayoutStore.posY(wd?.y ?? 0)
    width: LayoutStore.px(wd?.w ?? 1)
    height: LayoutStore.px(wd?.h ?? 1)

    // same glide as the card underneath
    Behavior on x      { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on y      { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on width  { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: root.wd?.style?.radius ?? LayoutStore.radius
        color: "transparent"
        border.width: root.selected ? 2 : 1
        border.color: root.selected ? Theme.accent : Qt.alpha(Theme.onSurface, 0.3)
    }

    // move
    MouseArea {
        id: moveArea
        anchors.fill: parent
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        onPressed: m => {
            const p = mapToItem(root.overlay, m.x, m.y);
            root.overlay.begin(root.wid, "move", 0, 0, p.x, p.y);
        }
        onPositionChanged: m => {
            if (!pressed) return;
            const p = mapToItem(root.overlay, m.x, m.y);
            root.overlay.update(p.x, p.y);
        }
        onReleased: root.overlay.finish()
        onCanceled: root.overlay.finish()
    }

    // resize handles (only for the selected widget)
    Repeater {
        model: [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]

        delegate: Handle {
            required property var modelData
            ex: modelData[0]
            ey: modelData[1]
            wid: root.wid
            overlay: root.overlay
            visible: root.selected
        }
    }
}