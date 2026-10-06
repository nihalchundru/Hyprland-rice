import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    // One layer-shell window. Only the pill's rectangle takes input (mask),
    // everything else passes clicks through to your desktop.
    PanelWindow {
        id: win

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Theme.windowH
        exclusiveZone: Theme.idleH + Theme.margin * 2
        color: "transparent"

        WlrLayershell.namespace: "pill"
        WlrLayershell.layer: WlrLayer.Top
        // keyboard only while something is open, so idle/hover never steal focus
        WlrLayershell.keyboardFocus: Pill.active ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        mask: Region { item: notch.body }

        // click anywhere outside the pill closes it
        HyprlandFocusGrab {
            windows: [win]
            active: Pill.active
            onCleared: Pill.close()
        }

        // Esc: back one level / close
        Item {
            id: escItem
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: Pill.back()
        }

        // pages with their own text input / key handling take focus while open;
        // hand it back to the Esc item when leaving them
        Connections {
            target: Pill
            function onModeChanged() {
                if (["launcher", "themes", "wallpaper", "power"].indexOf(Pill.mode) < 0)
                    escItem.forceActiveFocus();
            }
        }

        Notch {
            id: notch
            anchors.fill: parent
        }
    }

    // qs -c pill ipc call pill open calendar
    IpcHandler {
        target: "pill"

        function open(mode: string): void { Pill.open(mode, true); }
        function toggle(mode: string): void { Pill.toggle(mode); }
        function close(): void { Pill.close(); }
        function current(): string { return Pill.mode; }
    }
}
