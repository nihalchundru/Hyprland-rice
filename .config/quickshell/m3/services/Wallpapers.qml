pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Lists ~/.config/hypr/wallpapers/** and applies via the current theme.
// iris / matugen regen colors from the wallpaper; static themes re-run write-colors.sh.
Singleton {
    id: root
    readonly property string dir: Quickshell.env("HOME") + "/.config/hypr/wallpapers"
    property var all: []
    property string applied: ""

    function refresh() { if (!find.running) find.running = true }

    function apply(path) {
        applied = path
        setp.command = ["bash", "-c",
            "T=$(cat \"$HOME/.config/hypr/themes/current-name\" 2>/dev/null || echo catppuccin); " +
            "case \"$T\" in " +
            "iris) exec bash \"$HOME/.config/hypr/scripts/iris-apply.sh\" \"$1\" ;; " +
            "matugen) exec bash \"$HOME/.config/hypr/scripts/matugen-apply.sh\" \"$1\" ;; " +
            "*) bash \"$HOME/.config/hypr/scripts/set-wallpaper.sh\" \"$1\" && " +
            "exec bash \"$HOME/.config/hypr/scripts/write-colors.sh\" \"$T\" ;; " +
            "esac",
            "_", path]
        setp.running = true
        UiState.wallpaperOpen = false
    }

    // Theme change for static themes: store the name, then regen colors for every app
    function setTheme(name) {
        setp.command = ["bash", "-c",
            "echo \"$1\" > \"$HOME/.config/hypr/themes/current-name\" && " +
            "exec bash \"$HOME/.config/hypr/scripts/write-colors.sh\" \"$1\"",
            "_", name]
        setp.running = true
    }

    function random() {
        if (all.length > 0) apply(all[Math.floor(Math.random() * all.length)].path)
    }

    Process {
        id: find
        command: ["find", root.dir, "-type", "f", "(", "-iname", "*.png", "-o", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.webp", ")"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                for (const p of text.split("\n")) {
                    if (!p) continue
                    const parts = p.slice(root.dir.length + 1).split("/")
                    out.push({ path: p, folder: parts.length > 1 ? parts[0] : "", name: parts[parts.length - 1] })
                }
                out.sort((a, b) => a.path.localeCompare(b.path))
                root.all = out
            }
        }
    }
    Process { id: setp }
}