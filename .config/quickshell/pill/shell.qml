import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    Component.onCompleted: console.log("pill: notifications tracked =", Notifs.count,
                                       "| polkit agent registered =", AuthState.registered)

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
        // a password prompt always gets the keyboard; other pages take it on demand
        WlrLayershell.keyboardFocus: Pill.mode === "auth" ? WlrKeyboardFocus.Exclusive
                                   : Pill.active ? WlrKeyboardFocus.OnDemand
                                   : WlrKeyboardFocus.None

        mask: Region { item: notch.body }

        // click anywhere outside the pill closes it
        HyprlandFocusGrab {
            windows: [win]
            active: Pill.active
            // an auth prompt is waiting on you: clicking elsewhere must not hide it
            onCleared: if (Pill.mode !== "auth") Pill.close()
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
                if (["launcher", "themes", "wallpaper", "power", "auth"].indexOf(Pill.mode) < 0)
                    escItem.forceActiveFocus();
            }
        }

        Notch {
            id: notch
            anchors.fill: parent
        }

        // polkit agent lives in its own file: if your Quickshell has no polkit
        // module, only the password prompt is lost and the rest keeps working
        Loader {
            source: "PolkitBridge.qml"
            onStatusChanged: {
                if (status === Loader.Error)
                    console.warn("pill: polkit module unavailable, password prompts are disabled");
            }
        }
    }

    // the settings app is only created while it is open
    LazyLoader {
        id: settingsLoader
        active: false

        SettingsWindow {
            onCloseRequested: settingsLoader.active = false
        }
    }

    // qs -c pill ipc call settings toggle   (or: open, close, page <id>)
    IpcHandler {
        target: "settings"

        function open(): void { settingsLoader.active = true; }
        function close(): void { settingsLoader.active = false; }
        function toggle(): void { settingsLoader.active = !settingsLoader.active; }
        function page(id: string): void {
            Settings.requestedPage = id;
            settingsLoader.active = true;
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
