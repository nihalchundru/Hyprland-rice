import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "dock.js" as DockJs

// The dock: one of these per monitor. The window spans the screen edge, but
// only the dock itself (and an open menu, and the reveal strip) takes input;
// the rest is click-through.
PanelWindow {
    id: win

    required property var modelData          // the screen
    screen: modelData

    readonly property string pos: Dock.position
    readonly property bool vertical: Dock.vertical
    readonly property int pad: 10
    readonly property int sp: 8
    readonly property int room: 300          // spare room on the screen side, for menus
    readonly property int n: Dock.items.length
    readonly property real along: n > 0 ? n * Dock.iconSize + (n - 1) * sp + 2 * pad : 0
    readonly property real across: Dock.iconSize + 8 + 2 * pad
    readonly property real corner: Math.min(Theme.r(22), Math.min(along, across) / 2)

    // ── hiding ──────────────────────────────────────────────────────────
    // never: always shown. auto: shown while the pointer is on the dock or its edge.
    // under: shown unless a window is in the way (and while the pointer is on it).
    readonly property string hideMode: Settings.get("dockHide")
    // only a dock that never hides can hold a strip of the screen
    readonly property bool reserve: !!Settings.get("dockReserve") && hideMode === "never"

    property bool stripHover: false          // pointer on the reveal strip at the screen edge
    property bool covered: false             // (under mode) a window overlaps the dock
    readonly property bool hot: stripHover || bodyHover.hovered
    readonly property bool wantShown: hideMode === "never" || hot || menuOpen || (hideMode === "under" && !covered)
    property bool shown: true
    property real reveal: shown ? 1 : 0
    Behavior on reveal { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutCubic } }

    // how far the dock slides toward the edge when hidden
    readonly property real slide: (1 - reveal) * (across + Dock.gap + 2)

    onWantShownChanged: {
        if (wantShown) { hideDelay.stop(); shown = true; }
        else hideDelay.restart();
    }

    Timer {
        id: hideDelay
        interval: 400                        // a short grace period, so crossing a gap doesn't flicker it
        onTriggered: win.shown = false
    }

    // ── "under windows": ask Hyprland where the windows are ─────────────
    function recompute() {
        const mon = Hyprland.monitorFor(win.screen);
        if (!mon || !mon.lastIpcObject) return;
        const m = mon.lastIpcObject;
        const rect = DockJs.dockRect(win.pos, win.screen.width, win.screen.height,
                                     win.along, win.across, Dock.gap, m.x || 0, m.y || 0);
        const clients = Hyprland.toplevels.values.map(t => t.lastIpcObject);
        covered = DockJs.covered(clients, { id: m.id, ws: m.activeWorkspace ? m.activeWorkspace.id : -1 }, rect);
    }

    Connections {
        target: Hyprland
        enabled: win.hideMode === "under"
        function onRawEvent(event) { refreshTimer.restart(); }
    }

    Timer {
        id: refreshTimer
        interval: 90
        onTriggered: {
            Hyprland.refreshToplevels();
            Hyprland.refreshMonitors();
            calcTimer.restart();
        }
    }
    Timer { id: calcTimer; interval: 140; onTriggered: win.recompute() }
    Timer {
        interval: 2000
        repeat: true
        running: win.hideMode === "under" && win.visible
        onTriggered: refreshTimer.restart()
    }

    onHideModeChanged: {
        if (hideMode === "under") refreshTimer.restart();
        else covered = false;
    }
    onAlongChanged: { if (hideMode === "under") refreshTimer.restart(); }
    onAcrossChanged: { if (hideMode === "under") refreshTimer.restart(); }
    onPosChanged: { if (hideMode === "under") refreshTimer.restart(); }

    Component.onCompleted: {
        if (!wantShown) hideDelay.restart();
        if (hideMode === "under") refreshTimer.restart();
    }

    // ── right-click menu state (per window, so it only opens on this monitor) ──
    property var menuItem: null
    property var menuList: []
    property real menuAx: 0
    property real menuAy: 0
    readonly property bool menuOpen: menuItem !== null

    function openMenu(it, cx, cy) {
        menuList = Dock.menuRows(it);
        menuAx = cx;
        menuAy = cy;
        menuItem = it;
    }

    visible: Dock.enabled && Dock.showOn(modelData.name) && n > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: win.reserve ? across + Dock.gap : 0

    anchors {
        bottom: true            // bottom dock: the edge itself; side docks: the strip runs bottom to top
        left: win.pos !== "right"
        right: win.pos !== "left"
        top: win.pos !== "bottom"
    }
    implicitHeight: win.vertical ? 0 : across + Dock.gap + room
    implicitWidth: win.vertical ? across + Dock.gap + room : 0

    WlrLayershell.namespace: "pill-dock"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: win.menuOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: Region {
        item: bodyRect
        Region { item: menu }
        Region { item: hotRect }
    }

    // click outside the menu closes it
    HyprlandFocusGrab {
        windows: [win]
        active: win.menuOpen
        onCleared: win.menuItem = null
    }

    Item {
        id: stage
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: win.menuItem = null

        // thin strip along the screen edge that brings a hidden dock back
        Item {
            id: hotRect
            readonly property bool active: win.hideMode !== "never"
            readonly property int thick: 6

            width: !active ? 0 : (win.vertical ? thick : win.along + 80)
            height: !active ? 0 : (win.vertical ? win.along + 80 : thick)
            x: win.pos === "left" ? 0 : win.pos === "right" ? stage.width - width : (stage.width - width) / 2
            y: win.vertical ? (stage.height - height) / 2 : stage.height - height

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onContainsMouseChanged: win.stripHover = containsMouse
            }
        }

        Rectangle {
            id: bodyRect
            width: win.vertical ? win.across : win.along
            height: win.vertical ? win.along : win.across
            x: (win.pos === "left" ? Dock.gap - win.slide
              : win.pos === "right" ? stage.width - width - Dock.gap + win.slide
              : (stage.width - width) / 2)
            y: win.vertical ? (stage.height - height) / 2
                            : stage.height - height - Dock.gap + win.slide
            radius: win.corner
            color: Theme.body

            HoverHandler { id: bodyHover }

            // notch mode: square off the corners on the screen-edge side
            Rectangle {
                visible: Dock.notch
                color: Theme.body
                x: win.pos === "right" ? parent.width - width : 0
                y: win.pos === "bottom" ? parent.height - height : 0
                width: win.vertical ? win.corner + 1 : parent.width
                height: win.vertical ? parent.height : win.corner + 1
            }

            Grid {
                x: win.pad
                y: win.pad
                columns: win.vertical ? 1 : Math.max(1, win.n)
                spacing: win.sp

                Repeater {
                    model: Dock.items

                    DockItem {
                        size: Dock.iconSize
                        edge: win.pos
                        onMenuRequested: (it, cx, cy) => win.openMenu(it, cx, cy)
                    }
                }
            }
        }

        // right-click menu (zero-sized while closed, so it adds nothing to the input region)
        Rectangle {
            id: menu
            readonly property int menuW: 232
            readonly property int rowH: 36

            width: win.menuOpen ? menuW : 0
            height: win.menuOpen ? menuCol.implicitHeight + 16 : 0
            visible: win.menuOpen
            radius: Theme.r(18)
            color: Theme.body
            border.width: 1
            border.color: Theme.tileHi
            z: 50

            x: win.vertical
               ? (win.pos === "left" ? bodyRect.x + bodyRect.width + 10 : bodyRect.x - width - 10)
               : Math.max(8, Math.min(win.menuAx - width / 2, stage.width - width - 8))
            y: win.vertical
               ? Math.max(8, Math.min(win.menuAy - height / 2, stage.height - height - 8))
               : bodyRect.y - height - 10

            Column {
                id: menuCol
                x: 8
                y: 8
                width: parent.width - 16

                Text {
                    width: parent.width
                    height: menu.rowH - 6
                    leftPadding: 10
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: win.menuItem ? win.menuItem.name : ""
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(12)
                }

                Repeater {
                    model: win.menuList

                    Rectangle {
                        id: row
                        required property var modelData
                        width: menuCol.width
                        height: menu.rowH
                        radius: Theme.r(12)
                        color: rowMa.containsMouse ? Theme.tile : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 10
                            width: parent.width - 20
                            elide: Text.ElideRight
                            text: row.modelData.label
                            color: row.modelData.danger ? Theme.red : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(14)
                        }

                        MouseArea {
                            id: rowMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const run = row.modelData.run;
                                win.menuItem = null;
                                run();
                            }
                        }
                    }
                }
            }
        }
    }
}
