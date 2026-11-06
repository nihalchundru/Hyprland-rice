//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "core"
import "modules/bar"
import "modules/controlcenter"
import "modules/notifications"
import "modules/osd"
import "modules/launcher"
import "modules/theming"
import "modules/widgets"

ShellRoot {
    id: root

    // ------------------------------------------------------------------------
    // Startup Matugen Execution on ~/.config/rofi/images/a.png
    // Calls your existing ~/.config/hypr/scripts/matugen-apply.sh directly
    // without touching or overriding matugen-scheme-type.
    // ------------------------------------------------------------------------
    Component.onCompleted: {
        Theme.runStartupMatugen(Theme.defaultWallpaperPath);
    }

    // ------------------------------------------------------------------------
    // Stage 3: Top Bar mounted across all connected monitors
    // Supports pill / notch / islands layouts + Morphing Workspaces + Notch
    // ------------------------------------------------------------------------
    Variants {
        model: Quickshell.screens

        TopBar {}
    }

    // ------------------------------------------------------------------------
    // Stage 4: Control Center Drawer, Notification Popups & Morphing OSD
    // ------------------------------------------------------------------------
    Variants {
        model: Quickshell.screens

        ControlCenter {}
    }

    Variants {
        model: Quickshell.screens

        NotificationPopup {}
    }

    Variants {
        model: Quickshell.screens

        MorphOsd {}
    }

    // ------------------------------------------------------------------------
    // Stage 5: App Launcher, Theme & Wallpaper Studio, Desktop Widgets
    // ------------------------------------------------------------------------
    Variants {
        model: Quickshell.screens

        AppLauncher {}
    }

    Variants {
        model: Quickshell.screens

        ThemeWallpaperSheet {}
    }

    Variants {
        model: Quickshell.screens

        DesktopWidgets {}
    }

    // ------------------------------------------------------------------------
    // IPC Handler (`qs -p ~/.config/quickshell/m32 ipc call m32 <action>`)
    // ------------------------------------------------------------------------
    IpcHandler {
        target: "m32"

        function reloadMatugen(): void {
            Theme.runStartupMatugen(Theme.defaultWallpaperPath);
        }

        function setWallpaper(path: string): void {
            StateStore.applyWallpaper(path);
        }

        function setLayout(layout: string): void {
            StateStore.setLayout(layout);
        }

        function cycleLayout(): void {
            StateStore.cycleLayout();
        }

        function toggleNotch(): void {
            StateStore.notchExpanded = !StateStore.notchExpanded;
        }

        function toggleLauncher(): void {
            StateStore.launcherOpen = !StateStore.launcherOpen;
        }

        function toggleControlCenter(): void {
            StateStore.controlCenterOpen = !StateStore.controlCenterOpen;
        }

        function toggleThemeSwitcher(): void {
            StateStore.themeSwitcherOpen = !StateStore.themeSwitcherOpen;
        }

        function toggleWallpaperPicker(): void {
            StateStore.wallpaperPickerOpen = !StateStore.wallpaperPickerOpen;
        }

        function toggleOverview(): void {
            StateStore.overviewOpen = !StateStore.overviewOpen;
        }

        function toggleKeybinds(): void {
            StateStore.keybindsOpen = !StateStore.keybindsOpen;
        }

        function lock(): void {
            StateStore.lockscreenActive = true;
        }

        function notify(summary: string, body: string): void {
            Services.pushNotification("m32", summary, body, "normal");
        }

        function volumeUp(): void {
            Services.adjustVolume(5);
        }

        function volumeDown(): void {
            Services.adjustVolume(-5);
        }

        function volumeMute(): void {
            Services.toggleMute();
        }

        function brightnessUp(): void {
            Services.adjustBrightness(5);
        }

        function brightnessDown(): void {
            Services.adjustBrightness(-5);
        }
    }
}
