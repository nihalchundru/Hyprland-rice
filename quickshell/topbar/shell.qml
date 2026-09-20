import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    IpcHandler {
        target: "topbar"
        function toggleLauncher()  { appLauncher.toggle() }
        function toggleTheme()     { themeSwitcher.toggle() }
        function toggleWallpaper() { wallpaperSwitcher.toggle() }
        function toggleControl()   { controlPanel.toggle() }
    }

    property var colors: ({
        bg: "#1E1E2E", bg2: "#181825", surface: "#313244", surface2: "#45475A",
        text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7", accent2: "#89B4FA",
        green: "#A6E3A1", red: "#F38BA8", yellow: "#F9E2AF", teal: "#94E2D5",
        theme: "catppuccin"
    })
    property var palettes: ({})

    Process {
        id: colorReader
        command: ["cat", `${Quickshell.env("HOME")}/.config/quickshell/topbar/colors.json`]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.colors = JSON.parse(this.text) }
                catch(e) {}
            }
        }
    }
    Process {
        id: paletteReader
        command: ["cat", `${Quickshell.env("HOME")}/.config/quickshell/topbar/palettes.json`]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.palettes = JSON.parse(this.text) }
                catch(e) {}
            }
        }
        running: true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: colorReader.running = true
    }

    property string clockTime: "00:00"
    property string clockDate: ""

    Process {
        id: procClock
        command: ["date", "+%I:%M %p"]
        stdout: StdioCollector { onStreamFinished: root.clockTime = this.text.trim() }
    }
    Process {
        id: procDate
        command: ["date", "+%a %b %d"]
        stdout: StdioCollector { onStreamFinished: root.clockDate = this.text.trim() }
    }
    Timer { interval: 1000;  running: true; repeat: true; triggeredOnStart: true; onTriggered: procClock.running = true }
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: procDate.running = true }

    Bar {
        colors: root.colors
        clockTime: root.clockTime
        clockDate: root.clockDate
    }

    ThemeSwitcher {
        id: themeSwitcher
        colors: root.colors
        palettes: root.palettes
    }

    WallpaperSwitcher {
        id: wallpaperSwitcher
        colors: root.colors
    }

    ControlPanel {
        id: controlPanel
        colors: root.colors
    }

    AppLauncher {
        id: appLauncher
        colors: root.colors
    }
}
