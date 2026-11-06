pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ------------------------------------------------------------------------
    // Paths
    // ------------------------------------------------------------------------
    readonly property string homeDir: Quickshell.env("HOME") || "/home/user"
    readonly property string m32Dir: homeDir + "/.config/quickshell/m32"
    readonly property string topbarColorsPath: homeDir + "/.config/quickshell/topbar/colors.json"
    readonly property string defaultWallpaperPath: homeDir + "/.config/rofi/images/a.png"

    // Raw parsed dictionary from ~/.config/quickshell/topbar/colors.json
    // Exact pattern from THEMING.md:
    //   Process { command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"] ... }
    property var c: ({})
    property int revision: 0

    // ------------------------------------------------------------------------
    // Lookup helper (reads UPPERCASE or lowercase keys from topbar/colors.json)
    // ------------------------------------------------------------------------
    function getHex(key, fallbackHex) {
        var _ = revision;
        if (c) {
            if (c[key] !== undefined && c[key] !== "")
                return c[key];
            var lower = key.toLowerCase();
            if (c[lower] !== undefined && c[lower] !== "")
                return c[lower];
            var upper = key.toUpperCase();
            if (c[upper] !== undefined && c[upper] !== "")
                return c[upper];
        }
        return fallbackHex;
    }

    function withAlpha(col, alpha) {
        var base = Qt.color(col);
        return Qt.rgba(base.r, base.g, base.b, alpha);
    }

    function blend(colA, colB, ratio) {
        var a = Qt.color(colA);
        var b = Qt.color(colB);
        var r = Math.max(0, Math.min(1, ratio));
        return Qt.rgba(
            a.r * (1 - r) + b.r * r,
            a.g * (1 - r) + b.g * r,
            a.b * (1 - r) + b.b * r,
            1.0
        );
    }

    // ------------------------------------------------------------------------
    // THEMING.md Color Keys (Read directly from ~/.config/quickshell/topbar/colors.json)
    // ------------------------------------------------------------------------
    readonly property color bg:        getHex("BG", "#141218")
    readonly property color bg2:       getHex("BG2", "#1d1b20")
    readonly property color surface:   getHex("SURFACE", "#211f26")
    readonly property color surface2:  getHex("SURFACE2", "#2b2930")
    readonly property color text:      getHex("TEXT", "#e6e0e9")
    readonly property color sub:       getHex("SUB", "#cac4d0")
    readonly property color accent:    getHex("ACCENT", "#d0bcff")
    readonly property color accent2:   getHex("ACCENT2", "#ccc2dc")

    readonly property color green:     getHex("GREEN", "#a6e3a1")
    readonly property color red:       getHex("RED", "#f2b8b5")
    readonly property color yellow:    getHex("YELLOW", "#f9e2af")
    readonly property color teal:      getHex("TEAL", "#94e2d5")
    readonly property color orange:    getHex("ORANGE", accent)
    readonly property color purple:    getHex("PURPLE", accent2)

    readonly property color barBg:     getHex("BAR_BG", withAlpha(bg, 0.85))
    readonly property color wbActBg:   getHex("WB_ACT_BG", accent)
    readonly property color wbActFg:   getHex("WB_ACT_FG", bg)

    // ------------------------------------------------------------------------
    // Material 3 Tonal Roles (100% driven by your BG, BG2, SURFACE, SURFACE2,
    // TEXT, SUB, ACCENT, ACCENT2, TEAL, RED from topbar/colors.json!)
    // ------------------------------------------------------------------------
    readonly property color background:              bg
    readonly property color onBackground:            text

    readonly property color m3Surface:               bg
    readonly property color surfaceDim:              blend(bg, "#000000", 0.18)
    readonly property color surfaceBright:           blend(surface2, text, 0.10)

    readonly property color surfaceContainerLowest:  blend(bg, "#000000", 0.22)
    readonly property color surfaceContainerLow:     bg2
    readonly property color surfaceContainer:        surface
    readonly property color surfaceContainerHigh:    surface2
    readonly property color surfaceContainerHighest: blend(surface2, text, 0.10)

    readonly property color surfaceVariant:          surface2
    readonly property color onSurface:               text
    readonly property color onSurfaceVariant:        sub

    readonly property color inverseSurface:          text
    readonly property color inverseOnSurface:        bg

    readonly property color outline:                 sub
    readonly property color outlineVariant:          blend(surface2, sub, 0.35)
    readonly property color shadow:                  "#000000"
    readonly property color scrim:                   "#000000"
    readonly property color sourceColor:             accent

    // Primary -> ACCENT / WB_ACT_BG / WB_ACT_FG
    readonly property color primary:                 accent
    readonly property color onPrimary:               wbActFg
    readonly property color primaryContainer:        blend(surface, accent, 0.32)
    readonly property color onPrimaryContainer:      blend(accent, text, 0.35)
    readonly property color inversePrimary:          blend(accent, bg, 0.45)
    readonly property color primaryFixed:            onPrimaryContainer
    readonly property color primaryFixedDim:         accent
    readonly property color onPrimaryFixed:          bg
    readonly property color onPrimaryFixedVariant:   primaryContainer

    // Secondary -> ACCENT2
    readonly property color secondary:               accent2
    readonly property color onSecondary:             bg
    readonly property color secondaryContainer:      blend(surface, accent2, 0.28)
    readonly property color onSecondaryContainer:    blend(accent2, text, 0.35)
    readonly property color secondaryFixed:          onSecondaryContainer
    readonly property color secondaryFixedDim:       accent2
    readonly property color onSecondaryFixed:        bg
    readonly property color onSecondaryFixedVariant: secondaryContainer

    // Tertiary -> TEAL
    readonly property color tertiary:                teal
    readonly property color onTertiary:              bg
    readonly property color tertiaryContainer:       blend(surface, teal, 0.28)
    readonly property color onTertiaryContainer:     blend(teal, text, 0.35)
    readonly property color tertiaryFixed:           onTertiaryContainer
    readonly property color tertiaryFixedDim:        teal
    readonly property color onTertiaryFixed:         bg
    readonly property color onTertiaryFixedVariant:  tertiaryContainer

    // Error -> RED
    readonly property color error:                   red
    readonly property color onError:                 bg
    readonly property color errorContainer:          blend(surface, red, 0.32)
    readonly property color onErrorContainer:        blend(red, text, 0.35)

    // ------------------------------------------------------------------------
    // Typography Tokens
    // ------------------------------------------------------------------------
    readonly property string fontFamily:     "Rubik"
    readonly property string fontFamilySans: "Inter"
    readonly property string fontFamilyMono: "JetBrainsMono Nerd Font"
    readonly property string iconFont:       "Material Symbols Rounded"

    // ------------------------------------------------------------------------
    // Startup Matugen Runner & 2-Second Color Polling (exact THEMING.md pattern)
    // ------------------------------------------------------------------------
    function runStartupMatugen(wallpaperPath) {
        var wall = wallpaperPath || defaultWallpaperPath;
        bootMatugenProc.running = false;
        bootMatugenProc.command = [
            "bash",
            homeDir + "/.config/hypr/scripts/matugen-apply.sh",
            wall
        ];
        bootMatugenProc.running = true;
    }

    function reloadColors() {
        colorReader.running = false;
        colorReader.running = true;
    }

    Process {
        id: bootMatugenProc
        command: ["bash", root.homeDir + "/.config/hypr/scripts/matugen-apply.sh", root.defaultWallpaperPath]
        onExited: (exitCode, exitStatus) => {
            colorReader.running = true;
        }
    }

    // Exact THEMING.md color reader from ~/.config/quickshell/topbar/colors.json
    Process {
        id: colorReader
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.c = JSON.parse(this.text);
                    root.revision = root.revision + 1;
                } catch (e) {}
            }
        }
        running: true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: colorReader.running = true
    }
}
