
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

            Notch {
                id: notch
                screen: modelData
                notifications: notificationService
            }

            MediaPanel {
                id: mediaPanel
                screen: modelData
                colors: notch.colors
                player: notch.activePlayer
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
            }

            // ============================================================
            // Notch → panels
            // ============================================================

            Connections {
                target: notch

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
    // Standalone Polkit authentication
    // ================================================================

    PolkitAuth {
        id: polkitAuth
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

    // ================================================================
    // IPC
    // ================================================================

    IpcHandler {
        target: "notch"

        function toggleControl() {
            root.toggleControlCenter()
        }
    }

    IpcHandler {
        target: "theme"

        function toggle() {
            themeSwitcher.toggle()
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle() {
            wallpaperSwitcher.toggle()
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle() {
            launcher.toggle()
        }
    }
}

