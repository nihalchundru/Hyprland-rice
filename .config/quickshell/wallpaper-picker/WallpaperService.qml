pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property list<string> wallpapers: []
    property string currentWallpaper: ""
    property string backend: "awww"

    function updateScanner() {
        const theme = _themeNameReader.text
            ? _themeNameReader.text.trim()
            : "catppuccin"

        let scanDir

        if (theme === "iris" || theme === "matugen") {
            scanDir = "~/.config/hypr/wallpapers"
        } else {
            scanDir = "~/.config/hypr/wallpapers/" + theme
        }

        scanner.command = [
            "bash",
            "-c",
            `find ${scanDir} -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \\) 2>/dev/null | sort | head -300`
        ]
    }

    // Wallpaper scanner
    Process {
        id: scanner
        running: false

        stdout: SplitParser {
            onRead: data => {
                const path = data.trim()
                if (path !== "")
                    root.wallpapers = [...root.wallpapers, path]
            }
        }
    }

    // Load current wallpaper
    Process {
        id: currentWallLoader
        command: [
            "bash",
            "-c",
            "grep -oP '(?<=url\\(\")[^\"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1 || echo ''"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const p = this.text.trim()
                if (p !== "")
                    root.currentWallpaper = p
            }
        }
    }

    Component.onCompleted: {
        updateScanner()
        scanner.running = true
    }

    function rescan() {
        wallpapers = []
        updateScanner()
        scanner.running = true
        currentWallLoader.running = true
    }

    function setWallpaper(path) {
        currentWallpaper = path

        const theme = _themeNameReader.text
            ? _themeNameReader.text.trim()
            : "catppuccin"

        if (theme === "iris") {
            applyProc.command = [
                "bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/iris-apply.sh",
                path
            ]
        } else if (theme === "matugen") {
            applyProc.command = [
                "bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/matugen-apply.sh",
                path
            ]
        } else {
            applyProc.command = [
                "bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/set-wallpaper.sh",
                path
            ]
        }

        applyProc.running = true
    }

    // Read active theme
    Process {
        id: _themeNameReader

        property string text: "catppuccin"

        command: [
            "cat",
            Quickshell.env("HOME") + "/.config/hypr/themes/current-name"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                _themeNameReader.text = this.text.trim()
                updateScanner()
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: _themeNameReader.running = true
    }

    Process {
        id: applyProc
        running: false
    }
}
