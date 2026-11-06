pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int currentIndex: 0
    property int previewIndex: -1
    property bool wallpaperFeatureEnabled: true
    property bool wallpaperMode: false
    property var wallpaperTheme: ({})

    onPreviewIndexChanged: {
        if (previewIndex >= 0 && previewIndex < themes.length)
            applyKittyTheme(themes[previewIndex])
        else
            applyKittyTheme(current)
    }

    readonly property var current: {
        if (themes.length === 0) return null
        if (previewIndex >= 0 && previewIndex < themes.length)
            return themes[previewIndex]
        if (wallpaperMode && wallpaperTheme && wallpaperTheme.bgBase)
            return wallpaperTheme
        if (currentIndex >= 0 && currentIndex < themes.length)
            return themes[currentIndex]
        return themes[0]
    }

    readonly property int    count:         themes.length
    readonly property string currentName:   current ? (current.name   || "") : ""
    readonly property string currentFamily: current ? (current.family || "") : ""

    readonly property color bgBase:        current ? current.bgBase        : "#1E1E2E"
    readonly property color bgSurface:     current ? current.bgSurface     : "#313244"
    readonly property color bgHover:       current ? current.bgHover       : "#45475A"
    readonly property color bgSelected:    current ? current.bgSelected    : "#45475A"
    readonly property color bgBorder:      current ? current.bgBorder      : "#45475A"
    readonly property color bgOverlay:     "#88000000"
    readonly property color textPrimary:   current ? current.textPrimary   : "#CDD6F4"
    readonly property color textSecondary: current ? current.textSecondary : "#9399B2"
    readonly property color textMuted:     current ? current.textMuted     : "#6C7086"
    readonly property color accentPrimary: current ? current.accentPrimary : "#CBA6F7"
    readonly property color accentCyan:    current ? current.accentCyan    : "#94E2D5"
    readonly property color accentGreen:   current ? current.accentGreen   : "#A6E3A1"
    readonly property color accentOrange:  current ? current.accentOrange  : "#F9E2AF"
    readonly property color accentRed:     current ? current.accentRed     : "#F38BA8"

    // ── Call HyDE ARM theme-switch.sh instead of just applying colors ────────
    function setTheme(index) {
        if (index < 0 || index >= themes.length) return
        wallpaperMode = false
        currentIndex  = index
        const name    = themes[index].name

        // Special routing for dynamic themes
        if (name === "iris" || name === "matugen") {
            switchProc.command = ["bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/theme-switch.sh", name]
        } else {
            switchProc.command = ["bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/theme-switch.sh", name]
        }
        switchProc.running = true

        // Save index
        saveProc.command = ["sh", "-c",
            'printf "%s" "$1" > "$HOME/.config/quickshell/theme.conf"', "sh", String(index)]
        saveProc.running = true
    }

    function setWallpaperMode() {
        wallpaperMode = true
        saveProc.command = ["sh", "-c",
            'printf "%s" wallpaper > "$HOME/.config/quickshell/theme.conf"']
        saveProc.running = true
        if (wallpaperTheme && wallpaperTheme.bgBase)
            applyKittyTheme(wallpaperTheme)
    }

    function setWallpaperFromImage(img) {
        if (!wallpaperFeatureEnabled) return
        if (img && img.length > 0) {
            // Route to iris or matugen based on active dynamic engine
            const engine = Quickshell.env("HOME")
            generateProc.command = ["bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/iris-apply.sh", img]
            generateProc.running = true
        }
        setWallpaperMode()
    }

    function applyKittyTheme(t) {
        if (!t || !t.bgBase) return
        const conf = [
            "foreground "          + (t.textPrimary   || "#CDD6F4"),
            "background "          + (t.bgBase        || "#1E1E2E"),
            "cursor "              + (t.accentPrimary  || "#CBA6F7"),
            "cursor_text_color "   + (t.bgBase        || "#1E1E2E"),
            "selection_background "+ (t.bgSelected     || "#45475A"),
            "selection_foreground "+ (t.textPrimary    || "#CDD6F4"),
            "color0 "  + (t.bgSurface    || "#313244"),
            "color1 "  + (t.accentRed    || "#F38BA8"),
            "color2 "  + (t.accentGreen  || "#A6E3A1"),
            "color3 "  + (t.accentOrange || "#F9E2AF"),
            "color4 "  + (t.accentPrimary|| "#CBA6F7"),
            "color5 "  + (t.accentPrimary|| "#CBA6F7"),
            "color6 "  + (t.accentCyan   || "#94E2D5"),
            "color7 "  + (t.textSecondary|| "#9399B2"),
            "color8 "  + (t.textMuted    || "#6C7086"),
            "color9 "  + (t.accentRed    || "#F38BA8"),
            "color10 " + (t.accentGreen  || "#A6E3A1"),
            "color11 " + (t.accentOrange || "#F9E2AF"),
            "color12 " + (t.accentPrimary|| "#CBA6F7"),
            "color13 " + (t.accentPrimary|| "#CBA6F7"),
            "color14 " + (t.accentCyan   || "#94E2D5"),
            "color15 " + (t.textPrimary  || "#CDD6F4"),
        ].join("\n")

        kittyProc.command = ["sh", "-c",
            "printf '%s\\n' '" + conf + "' > $HOME/.config/kitty/theme-colors.conf; " +
            "for sock in /tmp/kitty-*; do [ -S \"$sock\" ] && " +
            "kitty @ --to \"unix:$sock\" set-colors --all --configured " +
            "foreground=" + (t.textPrimary||"#CDD6F4") + " " +
            "background=" + (t.bgBase||"#1E1E2E") + "; done 2>/dev/null"
        ]
        kittyProc.running = true
    }

    Process { id: switchProc;   running: false }
    Process { id: saveProc;     running: false }
    Process { id: generateProc; running: false }
    Process { id: kittyProc;    running: false }

    // Load on startup
    Process {
        id: loadProc
        command: ["sh", "-c", "cat $HOME/.config/quickshell/theme.conf 2>/dev/null || echo 0"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = this.text.trim()
                if (raw === "wallpaper") {
                    root.wallpaperMode = true
                    return
                }
                const idx = parseInt(raw)
                if (!isNaN(idx) && idx >= 0 && idx < root.themes.length)
                    root.currentIndex = idx
            }
        }
    }

    // Live reload wallpaper-theme.json
    FileView {
        id: wallpaperThemeFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme-switcher/wallpaper-theme.json"
        watchChanges: true
        onTextChanged: {
            const raw = wallpaperThemeFile.text()
            if (!raw) return
            try {
                root.wallpaperTheme = JSON.parse(raw)
                if (root.wallpaperMode && root.wallpaperTheme.bgBase)
                    root.applyKittyTheme(root.wallpaperTheme)
            } catch(e) {}
        }
    }

    // Load themes.json
    FileView {
        id: themesFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme-switcher/themes.json"
        onTextChanged: {
            const raw = themesFile.text()
            if (!raw) return
            try { root.themes = JSON.parse(raw) } catch(e) {}
        }
    }

    property var themes: []
}
