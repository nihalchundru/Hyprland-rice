import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// shell.qml
// ============================================================================

ShellRoot {
id: root


// ================================================================
// Control center IPC signal
// ================================================================

signal toggleControlCenter()

// ================================================================
// Notification service
// ================================================================

NotificationService {
    id: notificationService
}

// ================================================================
// Per-screen pieces
// ================================================================

Variants {
    model: Quickshell.screens

    Item {
        required property var modelData

        // ============================================================
        // TOPBAR
        // ============================================================

        Notch {
            id: topbar
            screen: modelData
            notifications: notificationService
        }

        MediaPanel {
            id: mediaPanel
            screen: modelData
            colors: topbar.colors
            player: topbar.activePlayer
        }

        WeatherPanel {
            id: weatherPanel
            screen: modelData
            colors: topbar.colors
            location: topbar.location
        }

        ControlCenter {
            id: controlCenter
            screen: modelData
            colors: topbar.colors
        }

        // ============================================================
        // Topbar → panels
        // ============================================================

        Connections {
            target: topbar

            function onMediaExpandRequested() {
                mediaPanel.open = true
            }

            function onWeatherExpandRequested() {
                weatherPanel.open = true
            }

            function onControlCenterRequested() {
                controlCenter.open = true
            }
        }

        // ============================================================
        // IPC → Control Center
        // ============================================================

        Connections {
            target: root

            function onToggleControlCenter() {
                controlCenter.open = !controlCenter.open
            }
        }
    }
}

// ================================================================
// Global components
// ================================================================

ThemeSwitcher {
    id: themeSwitcher
}

WallpaperSwitcher {
    id: wallpaperSwitcher
}

Launcher {
    id: launcher
}

PolkitAuth {
    id: polkitAuth
}
// ================================================================
// TOPBAR IPC
// ================================================================

IpcHandler {
    target: "topbar"

    function toggleControl() {
        root.toggleControlCenter()
    }

    function toggleWallpaper() {
        wallpaperSwitcher.toggle()
    }

    function toggleTheme() {
        themeSwitcher.toggle()
    }

    function toggleLauncher() {
        launcher.toggle()
    }
}


}
