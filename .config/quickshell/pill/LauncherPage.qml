import QtQuick
import Quickshell
import Quickshell.Widgets

// App launcher: type to filter, Up/Down to move, Enter to launch.
Item {
    id: root
    width: 760
    height: 560

    function filterApps(q) {
        const all = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        q = q.trim().toLowerCase();
        if (q === "")
            return all.slice().sort((a, b) => a.name.localeCompare(b.name));

        const scored = [];
        all.forEach(e => {
            const n = e.name.toLowerCase();
            let s = -1;
            if (n.startsWith(q)) s = 3;
            else if (n.indexOf(" " + q) >= 0) s = 2.5;
            else if (n.indexOf(q) >= 0) s = 2;
            else if ((e.genericName || "").toLowerCase().indexOf(q) >= 0) s = 1.5;
            else if (String(e.keywords || "").toLowerCase().indexOf(q) >= 0) s = 1;
            else if ((e.comment || "").toLowerCase().indexOf(q) >= 0) s = 0.5;
            if (s >= 0) scored.push({ e: e, s: s });
        });
        scored.sort((a, b) => (b.s - a.s) || a.e.name.localeCompare(b.e.name));
        return scored.map(x => x.e);
    }

    readonly property var apps: filterApps(search.text)

    function launch() {
        const e = apps[list.currentIndex];
        if (!e) return;
        Pill.close();
        e.execute();
    }

    // Keyboard move: keep the row in view, and stop a resting mouse from
    // stealing the selection back while the list scrolls.
    function move(delta) {
        list.holdSelection();
        list.currentIndex = Math.max(0, Math.min(apps.length - 1, list.currentIndex + delta));
        list.positionViewAtIndex(list.currentIndex, ListView.Contain);
    }

    onAppsChanged: {
        list.holdSelection();
        list.currentIndex = 0;
        list.positionViewAtBeginning();
    }

    onVisibleChanged: {
        if (visible) {
            search.clear();
            search.focusInput();
            list.holdSelection();
            list.currentIndex = 0;
            list.positionViewAtBeginning();
        }
    }

    // while true, scrolling does not re-select the row under the cursor
    Timer {
        id: holdTimer
        interval: 300
        onTriggered: list.held = false
    }

    SearchField {
        id: search
        x: 24
        y: 16
        width: root.width - 48
        placeholder: "Search…"
        onNavUp: root.move(-1)
        onNavDown: root.move(1)
        onAccepted: root.launch()
    }

    Rectangle {
        x: 24
        y: 66
        width: root.width - 48
        height: 1
        color: Theme.tileHi
    }

    ListView {
        id: list
        x: 16
        y: 78
        width: root.width - 32
        height: root.height - 78 - 16
        clip: true
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        model: root.apps

        property bool held: false

        function holdSelection() {
            held = true;
            holdTimer.restart();
        }

        // select whatever row is under the cursor
        function syncToCursor() {
            if (held || !ma.containsMouse) return;
            const i = indexAt(ma.mouseX + contentX, ma.mouseY + contentY);
            if (i >= 0 && i !== currentIndex) currentIndex = i;
        }

        // wheel scrolling moves rows under a resting cursor: follow it
        onContentYChanged: syncToCursor()

        // Built-in highlight: Qt always draws it underneath the rows, and it
        // glides to the current row. The accent bar stretches while it travels.
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 200
        highlightMoveVelocity: -1
        highlightResizeDuration: 0

        highlight: Item {
            id: hl
            readonly property bool moving: !!list.currentItem && Math.abs(y - list.currentItem.y) > 1

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: Theme.tile
            }

            Rectangle {
                x: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 3
                height: hl.moving ? 42 : 28
                radius: 1.5
                color: Theme.accent
                Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            }
        }

        delegate: Item {
            id: row
            required property var modelData
            required property int index
            readonly property bool sel: ListView.isCurrentItem

            width: list.width
            height: 62

            Rectangle {
                id: iconBg
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 46
                height: 46
                radius: 14
                color: Theme.inset
                scale: row.sel ? 1.08 : 1.0
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 32
                    source: Quickshell.iconPath(row.modelData.icon, true)
                            || Quickshell.iconPath("application-x-executable")
                }
            }

            Column {
                anchors.left: iconBg.right
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width: parent.width
                    text: row.modelData.name
                    elide: Text.ElideRight
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    visible: text !== ""
                    text: row.modelData.comment || row.modelData.genericName || ""
                    elide: Text.ElideRight
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }
        }
    }

    // One mouse layer over the list. It only reacts to real pointer movement,
    // so scrolling alone never changes the selection. Wheel events fall through
    // to the list underneath.
    MouseArea {
        id: ma
        x: list.x
        y: list.y
        width: list.width
        height: list.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        property real lastX: -1
        property real lastY: -1

        onPositionChanged: mouse => {
            if (Math.abs(mouse.x - lastX) < 2 && Math.abs(mouse.y - lastY) < 2) return;
            lastX = mouse.x;
            lastY = mouse.y;
            list.held = false;
            const i = list.indexAt(mouse.x + list.contentX, mouse.y + list.contentY);
            if (i >= 0) list.currentIndex = i;
        }

        onClicked: mouse => {
            const i = list.indexAt(mouse.x + list.contentX, mouse.y + list.contentY);
            if (i < 0) return;
            list.currentIndex = i;
            root.launch();
        }
    }

    Text {
        visible: root.apps.length === 0
        anchors.horizontalCenter: parent.horizontalCenter
        y: 130
        text: "No results"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 14
    }
}
