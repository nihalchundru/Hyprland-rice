import QtQuick
import "ccLayout.js" as Lay

// Settings -> Control Center. Edits the real layout; the pill's control center
// redraws from the same saved layout, so changes show up immediately.
Item {
    id: root

    signal dismissRequested()

    readonly property int cell: 64
    readonly property int gap: 12
    readonly property int step: cell + gap

    property int cols: 7
    property var layout: []          // working copy (replaced, never mutated)
    property var history: []         // undo stack of {cols, layout}
    property var dragStart: []       // layout when a drag / resize began
    property string selected: ""
    property string draggingId: ""
    property var menu: null          // {id, x, y} while the size menu is open

    readonly property var byId: {
        const m = {};
        layout.forEach(e => { m[e.id] = e; });
        return m;
    }
    readonly property var missing: Lay.missing(layout)
    readonly property int rows: Math.max(Lay.rowsOf(layout) + 1, 4)      // one spare row to drop into
    readonly property real gridW: cols * cell + (cols - 1) * gap
    readonly property real gridH: rows * cell + (rows - 1) * gap

    implicitHeight: col.implicitHeight
    height: implicitHeight
    focus: true

    // ── state ───────────────────────────────────────────────────────────
    function load() {
        cols = Settings.get("controlCols");
        layout = Lay.sanitize(Settings.get("controlLayout"), cols);
    }

    function save() {
        Settings.set("controlCols", cols);
        Settings.set("controlLayout", layout);
    }

    function pushHistory(l, c) {
        history = history.concat([{ cols: c, layout: l }]);
        if (history.length > 50) history = history.slice(history.length - 50);
    }

    function apply(l, c) {
        pushHistory(layout, cols);
        if (c !== undefined) cols = c;
        layout = l;
        save();
    }

    function applyIfChanged(l) {
        if (JSON.stringify(l) !== JSON.stringify(layout)) apply(l);
    }

    function undo() {
        if (history.length === 0) return;
        const h = history[history.length - 1];
        history = history.slice(0, history.length - 1);
        cols = h.cols;
        layout = h.layout;
        selected = "";
        save();
    }

    function resetAll() {
        selected = "";
        menu = null;
        apply(Lay.defaultLayout(7), 7);
    }

    function tidyUp() { applyIfChanged(Lay.tidy(layout, cols)); }

    function setColumns(n) {
        if (n === cols) return;
        menu = null;
        apply(Lay.setCols(layout, n), n);
    }

    function addControl(id) {
        selected = id;
        apply(Lay.add(layout, cols, id));
    }

    function removeControl(id) {
        if (selected === id) selected = "";
        menu = null;
        apply(Lay.remove(layout, id));
    }

    function nudgeSelected(dx, dy) { applyIfChanged(Lay.nudge(layout, cols, selected, dx, dy)); }
    function stepSelected(dir) { applyIfChanged(Lay.stepSize(layout, cols, selected, dir)); }

    // live preview while dragging: always computed from the layout at the start of
    // the gesture, so pushed neighbours settle back when you move away
    function previewMove(id, cx, cy) { layout = Lay.moveTo(dragStart, cols, id, cx, cy); }
    function previewResize(id, w, h) { layout = Lay.resizeTo(dragStart, cols, id, w, h); }

    function finishDrag() {
        if (JSON.stringify(layout) !== JSON.stringify(dragStart)) {
            pushHistory(dragStart, cols);
            save();
        }
    }

    function openMenu(id, x, y) { menu = { id: id, x: x, y: y }; }

    function pickSize(w, h) {
        if (!menu) return;
        const id = menu.id;
        menu = null;
        applyIfChanged(Lay.resizeTo(layout, cols, id, w, h));
    }

    Component.onCompleted: load()

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (root.menu) root.menu = null;
            else if (root.selected !== "") root.selected = "";
            else root.dismissRequested();
            event.accepted = true;
            return;
        }
        if (root.selected === "") return;
        let handled = true;
        switch (event.key) {
        case Qt.Key_Left: root.nudgeSelected(-1, 0); break;
        case Qt.Key_Right: root.nudgeSelected(1, 0); break;
        case Qt.Key_Up: root.nudgeSelected(0, -1); break;
        case Qt.Key_Down: root.nudgeSelected(0, 1); break;
        case Qt.Key_BracketLeft: root.stepSelected(-1); break;
        case Qt.Key_BracketRight: root.stepSelected(1); break;
        case Qt.Key_Delete:
        case Qt.Key_Backspace: root.removeControl(root.selected); break;
        default: handled = false;
        }
        event.accepted = handled;
    }

    // ── UI ──────────────────────────────────────────────────────────────
    Column {
        id: col
        width: parent.width
        spacing: 14

        Text {
            text: "Layout"
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(13)
        }

        // toolbar: columns, Tidy / Undo / Reset, hint
        Item {
            width: parent.width
            height: 34

            Row {
                id: bar
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    model: [5, 6, 7, 8, 9]

                    Rectangle {
                        required property int modelData
                        readonly property bool cur: root.cols === modelData
                        width: 32
                        height: 32
                        radius: Theme.r(16)
                        color: cur ? Theme.accent : Theme.tile
                        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: parent.cur ? Theme.onAccent : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(13)
                            font.weight: Font.Medium
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setColumns(parent.modelData)
                        }
                    }
                }

                Item { width: 6; height: 1 }

                PillButton { label: "Tidy"; onClicked: root.tidyUp() }
                PillButton {
                    label: "Undo"
                    opacity: root.history.length > 0 ? 1 : 0.4
                    onClicked: root.undo()
                }
                PillButton { label: "Reset"; onClicked: root.resetAll() }
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, parent.width - bar.width - 20)
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideLeft
                text: "Drag to move \u00b7 corner to resize \u00b7 right-click for sizes"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
            }
        }

        // the grid
        Item {
            id: holder
            width: parent.width
            height: root.gridH

            Item {
                id: grid
                x: (holder.width - root.gridW) / 2
                width: root.gridW
                height: root.gridH

                // empty cells
                Repeater {
                    model: root.cols * root.rows

                    Rectangle {
                        required property int index
                        x: (index % root.cols) * root.step
                        y: Math.floor(index / root.cols) * root.step
                        width: root.cell
                        height: root.cell
                        radius: root.cell / 2
                        color: Theme.mix(Theme.body, Theme.text, 0.05)
                    }
                }

                // empty space: deselect
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        root.selected = "";
                        root.menu = null;
                        root.forceActiveFocus();
                    }
                }

                // the controls (one persistent delegate per control, so a drag
                // is never interrupted by the model changing underneath it)
                Repeater {
                    model: Lay.ORDER

                    delegate: Item {
                        id: box
                        required property string modelData

                        readonly property var e: root.byId[modelData] || null
                        readonly property bool sel: root.selected === modelData
                        readonly property bool dragging: root.draggingId === modelData
                        readonly property bool resizable: e !== null && Lay.sizesFor(modelData, root.cols).length > 1
                        property real dragX: 0
                        property real dragY: 0

                        visible: e !== null
                        x: dragging ? dragX : (e ? e.x * root.step : 0)
                        y: dragging ? dragY : (e ? e.y * root.step : 0)
                        width: e ? e.w * root.cell + (e.w - 1) * root.gap : 0
                        height: e ? e.h * root.cell + (e.h - 1) * root.gap : 0
                        z: dragging ? 30 : (sel ? 20 : 1)
                        opacity: dragging ? 0.92 : 1

                        Behavior on x { enabled: !box.dragging; NumberAnimation { duration: Theme.animMs > 0 ? 180 : 0; easing.type: Easing.OutCubic } }
                        Behavior on y { enabled: !box.dragging; NumberAnimation { duration: Theme.animMs > 0 ? 180 : 0; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: Theme.animMs > 0 ? 180 : 0; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: Theme.animMs > 0 ? 180 : 0; easing.type: Easing.OutCubic } }

                        // the real control, as a live preview
                        ControlItem {
                            anchors.fill: parent
                            cid: box.modelData
                            loaded: box.e !== null
                        }

                        // selection outline
                        Rectangle {
                            visible: box.sel
                            anchors.fill: parent
                            anchors.margins: -3
                            radius: Math.min(height / 2, 30)
                            color: "transparent"
                            border.width: 2
                            border.color: Theme.accent
                        }

                        // covers the preview so clicks select / drag instead of operating the control
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: box.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                            property real px: 0
                            property real py: 0
                            property bool moved: false

                            function endDrag() {
                                if (moved) {
                                    root.draggingId = "";
                                    root.finishDrag();
                                }
                                moved = false;
                            }

                            onPressed: mouse => {
                                root.forceActiveFocus();
                                root.selected = box.modelData;
                                root.menu = null;
                                if (mouse.button === Qt.RightButton) {
                                    root.openMenu(box.modelData, box.x + mouse.x, box.y + mouse.y);
                                    return;
                                }
                                px = mouse.x;
                                py = mouse.y;
                                moved = false;
                                root.dragStart = root.layout;
                            }

                            onPositionChanged: mouse => {
                                if (!(mouse.buttons & Qt.LeftButton)) return;
                                if (!moved && Math.hypot(mouse.x - px, mouse.y - py) < 6) return;
                                const p = mapToItem(grid, mouse.x, mouse.y);
                                box.dragX = p.x - px;
                                box.dragY = p.y - py;
                                if (!moved) {
                                    moved = true;
                                    root.draggingId = box.modelData;
                                }
                                root.previewMove(box.modelData,
                                                 Math.round(box.dragX / root.step),
                                                 Math.round(box.dragY / root.step));
                            }

                            onReleased: endDrag()
                            onCanceled: endDrag()
                        }

                        // delete badge
                        Rectangle {
                            visible: box.sel && !box.dragging
                            x: -9
                            y: -9
                            width: 24
                            height: 24
                            radius: Theme.r(12)
                            color: Theme.red
                            border.width: 2
                            border.color: Theme.body

                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 2
                                radius: Theme.r(1)
                                color: Theme.body
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.removeControl(box.modelData)
                            }
                        }

                        // resize handle (bottom-right corner)
                        Item {
                            visible: box.sel && box.resizable && !box.dragging
                            x: box.width - 16
                            y: box.height - 16
                            width: 28
                            height: 28

                            Rectangle {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                radius: Theme.r(7)
                                color: Theme.accent
                                border.width: 2
                                border.color: Theme.body
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.SizeFDiagCursor

                                property real sx: 0
                                property real sy: 0
                                property real sw: 1
                                property real sh: 1

                                onPressed: mouse => {
                                    const p = mapToItem(grid, mouse.x, mouse.y);
                                    sx = p.x;
                                    sy = p.y;
                                    sw = box.e.w;
                                    sh = box.e.h;
                                    root.dragStart = root.layout;
                                    root.forceActiveFocus();
                                }
                                onPositionChanged: mouse => {
                                    if (!pressed) return;
                                    const p = mapToItem(grid, mouse.x, mouse.y);
                                    root.previewResize(box.modelData,
                                                       sw + (p.x - sx) / root.step,
                                                       sh + (p.y - sy) / root.step);
                                }
                                onReleased: root.finishDrag()
                                onCanceled: root.finishDrag()
                            }
                        }
                    }
                }

                // size menu: a click outside it closes it
                MouseArea {
                    anchors.fill: parent
                    z: 90
                    visible: root.menu !== null
                    onPressed: root.menu = null
                }

                Rectangle {
                    id: menuPanel
                    visible: root.menu !== null
                    z: 100
                    width: 236
                    height: menuCol.implicitHeight + 24
                    x: root.menu ? Math.max(0, Math.min(root.menu.x, root.gridW - width)) : 0
                    y: root.menu ? Math.max(0, Math.min(root.menu.y, root.gridH - height)) : 0
                    radius: Theme.r(20)
                    color: Theme.tile
                    border.width: 1
                    border.color: Theme.tileHi

                    Column {
                        id: menuCol
                        x: 12
                        y: 12
                        width: parent.width - 24
                        spacing: 8

                        Text {
                            text: root.menu ? Lay.CONTROLS[root.menu.id].title + " \u00b7 sizes" : ""
                            color: Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(12)
                        }

                        Flow {
                            width: parent.width
                            spacing: 6

                            Repeater {
                                model: root.menu ? Lay.sizesFor(root.menu.id, root.cols) : []

                                Rectangle {
                                    required property var modelData
                                    readonly property var cur: root.menu ? root.byId[root.menu.id] : null
                                    readonly property bool isCur: !!cur && cur.w === modelData[0] && cur.h === modelData[1]
                                    width: 50
                                    height: 28
                                    radius: Theme.r(14)
                                    color: isCur ? Theme.accent : (chipMa.containsMouse ? Theme.tileHi : Theme.inset)

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.modelData[0] + "\u00d7" + parent.modelData[1]
                                        color: parent.isCur ? Theme.onAccent : Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.px(12)
                                        font.weight: Font.Medium
                                    }
                                    MouseArea {
                                        id: chipMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.pickSize(parent.modelData[0], parent.modelData[1])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // tray
        Text {
            text: "Add a control"
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(13)
        }

        Flow {
            width: parent.width
            spacing: 8

            Repeater {
                model: root.missing

                Rectangle {
                    id: chip
                    required property string modelData
                    readonly property var size: Lay.defaultSize(modelData, root.cols)
                    width: chipRow.implicitWidth + 28
                    height: 42
                    radius: Theme.r(21)
                    color: chipMa2.containsMouse ? Theme.tileHi : Theme.tile

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 8

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: Lay.CONTROLS[chip.modelData].icon
                            size: 16
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Lay.CONTROLS[chip.modelData].title
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(14)
                            font.weight: Font.Medium
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.size[0] + "\u00d7" + chip.size[1]
                            color: Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(12)
                        }
                    }
                    MouseArea {
                        id: chipMa2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.addControl(chip.modelData)
                    }
                }
            }
        }

        Text {
            visible: root.missing.length === 0
            text: "Every control is in use."
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(13)
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: "Drag a control to move it, pull its corner to resize, right-click for every size it supports. With one selected: arrows nudge, [ and ] step through sizes, Delete removes."
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(12)
        }
    }
}
