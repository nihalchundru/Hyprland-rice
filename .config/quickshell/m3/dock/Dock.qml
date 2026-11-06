import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// Pinned apps come from "pinned" in config.json (desktop entry ids). Auto-hides unless dockAutoHide is false.
PanelWindow {
    id: win
    screen: Quickshell.screens[0]
    WlrLayershell.namespace: "m3-dock"
    exclusionMode: M3Config.dockAutoHide ? ExclusionMode.Ignore : ExclusionMode.Auto
    anchors.bottom: true
    implicitWidth: Math.max(400, pill.width + 64)
    implicitHeight: 120
    color: "transparent"
    mask: Region { item: hotZone; Region { item: pill } }

    readonly property bool revealed: hz.containsMouse || hovIdx >= 0 || !M3Config.dockAutoHide || hideTimer.running
    property int hovIdx: -1
    onHovIdxChanged: if (hovIdx < 0) hideTimer.restart()

    readonly property var entries: {
        const out = [], seen = {}
        for (const id of M3Config.pinned) {
            const o = { id: id, entry: DesktopEntries.heuristicLookup(id), pinned: true, wins: [] }
            out.push(o); seen[id.toLowerCase()] = o
        }
        for (const t of ToplevelManager.toplevels.values) {
            const k = (t.appId || "").toLowerCase()
            if (seen[k]) seen[k].wins.push(t)
            else { const o = { id: t.appId, entry: DesktopEntries.heuristicLookup(t.appId), pinned: false, wins: [t] }; out.push(o); seen[k] = o }
        }
        return out
    }

    Timer { id: hideTimer; interval: 350 }

    // Input region: a thin strip at the bottom edge while hidden, grows to cover the dock while shown.
    Item {
        id: hotZone
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(pill.width + 96, 520)
        height: win.revealed ? 96 : 8
        MouseArea { id: hz; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; onContainsMouseChanged: if (!containsMouse) hideTimer.restart() }
    }

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        width: row.implicitWidth + 24
        height: 68
        radius: 34
        color: M3Colors.surfaceContainer
        y: win.revealed ? win.height - height - 12 : win.height + 4
        SpatialBehavior on y {}
        SpatialBehavior on width {}

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6
            Repeater {
                model: win.entries
                Item {
                    id: it
                    required property var modelData
                    required property int index
                    readonly property bool running: modelData.wins.length > 0
                    readonly property bool active: modelData.wins.some(w => w.activated)
                    readonly property string label: modelData.entry ? modelData.entry.name : (modelData.id || "")
                    width: 52; height: 52
                    transformOrigin: Item.Bottom
                    scale: !M3Config.dockMagnify || win.hovIdx < 0 ? 1 : (it.index === win.hovIdx ? 1.3 : 1)
                    SpatialBehavior on scale { eps: 0.002 }

                    Image {
                        anchors.fill: parent; anchors.margins: 6
                        sourceSize.width: 96; sourceSize.height: 96
                        source: Quickshell.iconPath(it.modelData.entry ? it.modelData.entry.icon : (it.modelData.id || "").toLowerCase(), "application-x-executable")
                    }
                    Rectangle {
                        visible: it.running
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom; anchors.bottomMargin: -2
                        height: 4; radius: 2
                        width: it.active ? 16 : 6
                        color: M3Colors.primary
                        SpatialBehavior on width {}
                    }
                    M3Tooltip { text: it.label; shown: ma.containsMouse }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onContainsMouseChanged: { if (containsMouse) win.hovIdx = it.index; else if (win.hovIdx === it.index) win.hovIdx = -1 }
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: m => {
                            const d = it.modelData
                            if (!it.running || m.button === Qt.MiddleButton) {
                                if (d.entry) d.entry.execute(); else Quickshell.execDetached([d.id])
                            } else {
                                const i = d.wins.findIndex(w => w.activated)
                                d.wins[(i + 1) % d.wins.length].activate()
                            }
                        }
                    }
                }
            }
        }
    }
}
