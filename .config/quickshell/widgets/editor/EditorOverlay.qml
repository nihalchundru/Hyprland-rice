import QtQuick
import "../core"
import "../components"

Item {
    id: root
    anchors.fill: parent

    readonly property real inset: LayoutStore.panelOpen ? panel.width : 0

    opacity: LayoutStore.editMode ? 1 : 0
    visible: LayoutStore.editMode || opacity > 0
    Behavior on opacity { NumberAnimation { duration: 180 } }

    // ---------- drag state ----------
    property string mode: ""            // "" | "move" | "resize"
    property int edgeX: 0
    property int edgeY: 0
    property real pressX: 0
    property real pressY: 0
    property var start: ({ x: 0, y: 0, w: 1, h: 1 })
    property var ghost: ({ x: 0, y: 0, w: 1, h: 1 })
    property bool ghostValid: true
    readonly property bool dragging: mode !== ""
    readonly property bool moved:
        ghost.x !== start.x || ghost.y !== start.y
        || ghost.w !== start.w || ghost.h !== start.h

    function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }

    function begin(id, m, ex, ey, mx, my) {
        const wd = LayoutStore.find(id);
        if (!wd) return;
        root.forceActiveFocus();        // take focus back from any text field
        LayoutStore.selectedId = id;
        LayoutStore.dragId = id;
        mode = m;
        edgeX = ex;
        edgeY = ey;
        pressX = mx;
        pressY = my;
        start = { x: wd.x, y: wd.y, w: wd.w, h: wd.h };
        ghost = start;
        ghostValid = true;
    }

    function update(mx, my) {
        if (!dragging) return;
        const wd = LayoutStore.find(LayoutStore.dragId);
        if (!wd) return;

        const step = LayoutStore.cell + LayoutStore.gap;
        const dx = (mx - pressX) / step;
        const dy = (my - pressY) / step;
        const lim = LayoutStore.limits(wd.type);

        let x = start.x, y = start.y, w = start.w, h = start.h;

        if (mode === "move") {
            x = Math.round(start.x + dx);
            y = Math.round(start.y + dy);
        } else {
            if (edgeX > 0) {
                w = clamp(Math.round(start.w + dx), lim.minW, lim.maxW);
            } else if (edgeX < 0) {
                w = clamp(Math.round(start.w - dx), lim.minW, lim.maxW);
                x = start.x + start.w - w;
            }
            if (edgeY > 0) {
                h = clamp(Math.round(start.h + dy), lim.minH, lim.maxH);
            } else if (edgeY < 0) {
                h = clamp(Math.round(start.h - dy), lim.minH, lim.maxH);
                y = start.y + start.h - h;
            }
        }

        ghost = { x: x, y: y, w: w, h: h };
        ghostValid = LayoutStore.fits(wd.id, x, y, w, h);
    }

    function finish() {
        if (!dragging) return;
        const id = LayoutStore.dragId;
        const g = ghost;
        const commit = moved && ghostValid;
        mode = "";
        LayoutStore.dragId = "";
        if (commit) LayoutStore.setRect(id, g.x, g.y, g.w, g.h);
    }

    function nudge(dx, dy) {
        if (!root.activeFocus) return;  // ignore keys that bubbled up from a text field
        const wd = LayoutStore.find(LayoutStore.selectedId);
        if (!wd) return;
        if (LayoutStore.fits(wd.id, wd.x + dx, wd.y + dy, wd.w, wd.h))
            LayoutStore.setRect(wd.id, wd.x + dx, wd.y + dy, wd.w, wd.h);
    }

    // ---------- keyboard ----------
    focus: true
    Keys.onEscapePressed: LayoutStore.editMode = false
    Keys.onLeftPressed:   nudge(-1, 0)
    Keys.onRightPressed:  nudge(1, 0)
    Keys.onUpPressed:     nudge(0, -1)
    Keys.onDownPressed:   nudge(0, 1)
    Keys.onDeletePressed: {
        if (root.activeFocus && LayoutStore.selectedId !== "")
            LayoutStore.removeWidget(LayoutStore.selectedId);
    }

    // Ctrl+Z undo, Ctrl+Shift+Z or Ctrl+Y redo
    Keys.onPressed: event => {
        if (!root.activeFocus) return;
        if (!(event.modifiers & Qt.ControlModifier)) return;

        if (event.key === Qt.Key_Z) {
            if (event.modifiers & Qt.ShiftModifier) LayoutStore.redo();
            else LayoutStore.undo();
            event.accepted = true;
        } else if (event.key === Qt.Key_Y) {
            LayoutStore.redo();
            event.accepted = true;
        }
    }

    onVisibleChanged: if (visible && LayoutStore.editMode) forceActiveFocus()

    Connections {
        target: LayoutStore
        function onEditModeChanged() {
            if (LayoutStore.editMode) root.forceActiveFocus();
            else { root.mode = ""; LayoutStore.dragId = ""; LayoutStore.selectedId = ""; }
        }
        function onFocusEditor() { root.forceActiveFocus(); }
    }

    // ---------- content ----------

    // click on empty space deselects
    MouseArea {
        anchors.fill: parent
        onPressed: root.forceActiveFocus()
        onClicked: LayoutStore.selectedId = ""
    }

    Repeater {
        model: LayoutStore.idModel

        delegate: EditItem {
            required property string itemId
            wid: itemId
            overlay: root
        }
    }

    // landing preview
    Rectangle {
        visible: root.dragging && root.moved
        x: LayoutStore.posX(root.ghost.x)
        y: LayoutStore.posY(root.ghost.y)
        width: LayoutStore.px(root.ghost.w)
        height: LayoutStore.px(root.ghost.h)
        radius: LayoutStore.radius
        color: Qt.alpha(root.ghostValid ? Theme.ok : Theme.danger, 0.18)
        border.width: 2
        border.color: root.ghostValid ? Theme.ok : Theme.danger

        Behavior on x      { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        Behavior on y      { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        Behavior on width  { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

        Txt {
            anchors.centerIn: parent
            text: root.ghost.w + " × " + root.ghost.h
            color: root.ghostValid ? Theme.ok : Theme.danger
            font.weight: Font.Bold
        }
    }

    // toolbar (centered in the area the panel leaves free)
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -root.inset / 2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        width: barRow.width + 32
        height: 52
        radius: 26
        color: Qt.alpha(Theme.card, 0.96)
        border.width: 1
        border.color: Qt.alpha(Theme.onSurface, 0.08)

        Behavior on anchors.horizontalCenterOffset {
            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
        }

        Row {
            id: barRow
            anchors.centerIn: parent
            spacing: 12

            Txt {
                anchors.verticalCenter: parent.verticalCenter
                text: "Drag · handles resize · arrows nudge · Ctrl+Z undo"
                color: Theme.onSurfaceDim
                font.pixelSize: 12
            }
            Btn {
                anchors.verticalCenter: parent.verticalCenter
                radius: 16
                implicitHeight: 32
                text: "Undo"
                enabled: LayoutStore.canUndo
                onClicked: LayoutStore.undo()
            }
            Btn {
                anchors.verticalCenter: parent.verticalCenter
                radius: 16
                implicitHeight: 32
                text: "Redo"
                enabled: LayoutStore.canRedo
                onClicked: LayoutStore.redo()
            }
            Btn {
                anchors.verticalCenter: parent.verticalCenter
                radius: 16
                implicitHeight: 32
                text: LayoutStore.panelOpen ? "Hide panel" : "Show panel"
                onClicked: LayoutStore.panelOpen = !LayoutStore.panelOpen
            }
            Btn {
                anchors.verticalCenter: parent.verticalCenter
                radius: 16
                implicitHeight: 32
                primary: true
                text: "Done"
                onClicked: LayoutStore.editMode = false
            }
        }
    }

    Panel {
        id: panel
    }
}