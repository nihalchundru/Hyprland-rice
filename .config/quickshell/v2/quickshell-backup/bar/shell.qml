import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// shell.qml — entry point for this config.
//
// Quickshell loads whichever file is named shell.qml in the config directory
// you point it at, e.g.:
//   qs -c notch     (loads ~/.config/quickshell/notch/shell.qml)
//
// This file's only job is to instantiate one Notch per connected monitor.
// All the actual behavior/visuals live in Notch.qml.
// ============================================================================

ShellRoot {
    id: root

    // Per-screen pieces — one instance per monitor
    Variants {
        model: Quickshell.screens

        Item {
            required property var modelData

            Notch {
                id: notch
                screen: modelData
            }

            MediaPanel {
                id: mediaPanel
                screen: modelData
                colors: notch.colors       // reuse the same theme colors
                player: notch.activePlayer // reuse the same MPRIS player, no double polling
            }

            WeatherPanel {
                id: weatherPanel
                screen: modelData
                colors: notch.colors
                location: notch.location
            }

            ControlCenter {
                id: controlCenter
                screen: modelData
                colors: notch.colors
                player: notch.activePlayer
            }

            Connections {
                target: notch
                function onMediaExpandRequested() { mediaPanel.open = true }
                function onWeatherExpandRequested() { weatherPanel.open = true }
                function onControlCenterRequested() { controlCenter.open = true }
            }
        }
    }

    // Global, single-instance pieces (keybind-triggered, not per-monitor) —
    // their IpcHandlers must live directly under ShellRoot like this one
    // does, matching your working sidebar's pattern; nested inside the
    // per-screen Variants above, `qs ipc` couldn't discover them at all.
    ThemeSwitcher {
        id: themeSwitcher
    }

    WallpaperSwitcher {
        id: wallpaperSwitcher
    }

    Launcher {
        id: launcher
    }

    IpcHandler {
        target: "theme"
        function toggle() { themeSwitcher.toggle() }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle() { wallpaperSwitcher.toggle() }
    }

    IpcHandler {
        target: "launcher"
        function toggle() { launcher.toggle() }
    }
}
