import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// qs -c m3 ipc call ui toggleOverview. Esc closes.
PanelWindow {
    id: win
    readonly property bool open: UiState.overviewOpen
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: row.opacity > 0.01
    onOpenChanged: if (open) keys.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        color: M3Colors.scrim
        opacity: win.open ? 0.55 : 0
        FadeBehavior on opacity { time: M3Motion.medium1 }
        MouseArea { anchors.fill: parent; onClicked: UiState.overviewOpen = false }
    }
    Item { id: keys; focus: win.open; Keys.onEscapePressed: UiState.overviewOpen = false }

    OverviewView {
        id: row
        anchors.centerIn: parent
        width: Math.min(parent.width - 96, 1400)
        live: win.open
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.92
        onPicked: UiState.overviewOpen = false
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
    }
}
