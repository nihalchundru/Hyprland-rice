import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// Open: power button in the bar / quick settings, or qs -c m3 ipc call ui toggleSession. Esc closes.
PanelWindow {
    id: win
    readonly property bool open: UiState.sessionOpen
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-session"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: card.opacity > 0.01

    readonly property var items: [
        { icon: "lock", label: "Lock", lock: true },
        { icon: "logout", label: "Log out", hypr: true },
        { icon: "bedtime", label: "Suspend", cmd: ["systemctl", "suspend"] },
        { icon: "restart_alt", label: "Reboot", cmd: ["systemctl", "reboot"] },
        { icon: "power_settings_new", label: "Shut down", cmd: ["systemctl", "poweroff"], danger: true }
    ]
    function run(it) {
        UiState.sessionOpen = false
        if (it.lock) UiState.locked = true
        else if (it.hypr) Hypr.dispatch(Hypr.lua ? "hl.dsp.exit()" : "exit")
        else Quickshell.execDetached(it.cmd)
    }
    onOpenChanged: if (open) keys.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        color: M3Colors.scrim
        opacity: win.open ? 0.5 : 0
        FadeBehavior on opacity { time: M3Motion.medium1 }
        MouseArea { anchors.fill: parent; onClicked: UiState.sessionOpen = false }
    }
    Item { id: keys; focus: win.open; Keys.onEscapePressed: UiState.sessionOpen = false }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: row.implicitWidth + 48
        height: row.implicitHeight + 48
        radius: 36
        color: M3Colors.surfaceContainerHigh
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.9
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
        MouseArea { anchors.fill: parent }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 16
            Repeater {
                model: win.items
                Column {
                    id: it
                    required property var modelData
                    spacing: 8
                    M3Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon: it.modelData.icon; size: "l"; round: false
                        variant: it.modelData.danger ? "filled" : "tonal"
                        onClicked: win.run(it.modelData)
                    }
                    M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: it.modelData.label; role: M3Type.labelLarge; color: M3Colors.fgSurfaceVariant }
                }
            }
        }
    }
}
