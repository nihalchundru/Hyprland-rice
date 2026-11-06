pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── source: your write-colors.sh output ──
    property var raw: ({})
    readonly property string themeName: raw.theme ?? ""

    FileView {
        path: Config.colorsPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parse(text())
    }

    function parse(t) {
        try {
            const j = JSON.parse(t)
            if (j && j.bg) root.raw = j
        } catch (e) {
            console.warn("Colors: invalid colors.json, keeping previous palette")
        }
    }

    // ── helpers ──
    function pick(k, d) { return Qt.color(raw[k] ?? d) }
    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1)
    }
    function lum(c) {
        const f = v => v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
        return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b)
    }
    function contrast(a, b) {
        const x = lum(a), y = lum(b)
        return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05)
    }
    // pick whichever of a/b reads better on top of `c`
    function onColor(c, a, b) { return contrast(c, a) >= contrast(c, b) ? a : b }
    // tonal container: accent pulled toward the background
    function container(c) { return mix(c, _bg, dark ? 0.62 : 0.78) }

    // ── source palette (fallbacks = catppuccin mocha) ──
    readonly property color _bg:      pick("bg",       "#1e1e2e")
    readonly property color _surface: pick("surface",  "#313244")
    readonly property color _surface2:pick("surface2", "#45475a")
    readonly property color _text:    pick("text",     "#cdd6f4")
    readonly property color _sub:     pick("sub",      "#6c7086")
    readonly property color _accent:  pick("accent",   "#cba6f7")
    readonly property color _accent2: pick("accent2",  "#89b4fa")
    readonly property color _red:     pick("red",      "#f38ba8")
    readonly property color _teal:    pick("teal",     "#94e2d5")

    readonly property bool dark: lum(_bg) < lum(_text)

    // ── M3: primary ──
    readonly property color primary:            _accent
    readonly property color onPrimary:          onColor(primary, _bg, _text)
    readonly property color primaryContainer:   container(_accent)
    readonly property color onPrimaryContainer: onColor(primaryContainer, _text, _bg)

    // ── M3: secondary (tonal, subtle) ──
    readonly property color secondary:            _accent2
    readonly property color onSecondary:          onColor(secondary, _bg, _text)
    readonly property color secondaryContainer:   mix(_surface2, _accent2, 0.30)
    readonly property color onSecondaryContainer: onColor(secondaryContainer, _text, _bg)

    // ── M3: tertiary ──
    readonly property color tertiary:            _teal
    readonly property color onTertiary:          onColor(tertiary, _bg, _text)
    readonly property color tertiaryContainer:   container(_teal)
    readonly property color onTertiaryContainer: onColor(tertiaryContainer, _text, _bg)

    // ── M3: error ──
    readonly property color error:            _red
    readonly property color onError:          onColor(error, _bg, _text)
    readonly property color errorContainer:   container(_red)
    readonly property color onErrorContainer: onColor(errorContainer, _text, _bg)

    // ── M3: surfaces ──
    readonly property color background:   _bg
    readonly property color onBackground: _text
    readonly property color surface:      _bg
    readonly property color onSurface:    _text
    readonly property color onSurfaceVariant: mix(_text, _bg, 0.25)
    readonly property color surfaceDim:   mix(_bg, "#000000", dark ? 0.25 : 0.08)
    readonly property color surfaceBright: mix(_bg, _surface, 0.8)
    readonly property color surfaceContainerLowest:  mix(_bg, dark ? "#000000" : "#ffffff", dark ? 0.25 : 0.6)
    readonly property color surfaceContainerLow:     mix(_bg, _surface, 0.35)
    readonly property color surfaceContainer:        mix(_bg, _surface, 0.65)
    readonly property color surfaceContainerHigh:    _surface
    readonly property color surfaceContainerHighest: mix(_surface2, _text, 0.05)

    readonly property color outline:        _sub
    readonly property color outlineVariant: mix(_sub, _bg, 0.5)
    readonly property color inverseSurface:   _text
    readonly property color inverseOnSurface: _bg
    readonly property color scrim:  "#000000"
    readonly property color shadow: "#000000"

    // ── extra semantic colors from your palette ──
    readonly property color success: pick("green",  "#a6e3a1")
    readonly property color warning: pick("yellow", "#f9e2af")
    readonly property color orange:  pick("orange", "#fab387")
    readonly property color purple:  pick("purple", "#cba6f7")
}