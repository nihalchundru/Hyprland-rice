pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── colors.json lives in the topbar config and is shared ──────────
    readonly property string colorsPath: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"

    FileView {
        path: root.colorsPath
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: c
            property string text: "#e7ad97"
            property string accent: "#4ab369"
            property string green: "#52b870"
            property string red: "#dc8767"
            property string accent2: "#4ab369"
            property string yellow: "#dc8767"
            property string purple: "#4ab369"
            property string teal: "#93d2a6"
        }
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t,
                       a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t, 1);
    }

    // ── palette ───────────────────────────────────────────────────────
    readonly property color body: "#000000"          // hardcoded on purpose
    // palette colours the accent can be set to (Settings -> Appearance)
    function swatch(name) {
        switch (name) {
        case "red": return Qt.color(c.red);
        case "green": return Qt.color(c.green);
        case "yellow": return Qt.color(c.yellow);
        case "blue": return Qt.color(c.accent2);
        case "purple": return Qt.color(c.purple);
        case "teal": return Qt.color(c.teal);
        }
        return Qt.color(c.accent);      // "default": the theme's own accent
    }

    // "Color burst": each surface of the pill gets its own palette colour
    function burstFor(mode) {
        switch (mode) {
        case "calendar": return swatch("yellow");
        case "control":
        case "sound":
        case "display":
        case "wifi":
        case "bluetooth": return swatch("blue");
        case "launcher": return swatch("green");
        case "themes":
        case "wallpaper": return swatch("purple");
        case "power": return swatch("red");
        case "notify": return swatch("teal");
        case "auth": return swatch("yellow");
        }
        return baseAccent;
    }

    readonly property color baseAccent: {
        const custom = String(Settings.get("accentCustom"));
        if (/^#[0-9a-fA-F]{6}$/.test(custom)) return Qt.color(custom);
        return swatch(String(Settings.get("accentChoice")));
    }
    readonly property color accent: Settings.get("colorBurst") ? burstFor(Pill.mode) : baseAccent
    readonly property color text: c.text
    readonly property color green: c.green
    readonly property color red: c.red

    // derived neutrals: faint tints of `text` over black
    // surface depth scales how far cards sit above the black body
    readonly property real depth: Math.max(0.2, Settings.get("surfaceDepth") / 50)
    readonly property color tile: mix(body, text, 0.07 * depth)
    readonly property color tileHi: mix(body, text, 0.12 * depth)
    readonly property color inset: mix(body, text, 0.035 * depth)
    readonly property color dim: mix(body, text, 0.62)     // secondary text
    readonly property color faint: mix(body, text, 0.30)   // inactive dots, dimmest text
    readonly property color onAccent: mix(body, accent, 0.12)
    readonly property color knob: mix(accent, Qt.color("#ffffff"), 0.65)   // slider handles

    // ── sizing / motion ───────────────────────────────────────────────
    // bar & island (Settings -> Bar & Island)
    readonly property bool notch: !!Settings.get("notchMode")
    readonly property int idleW: Settings.get("collapsedWidth")
    readonly property int idleH: Settings.get("barHeight")
    readonly property int margin: notch ? 0 : Settings.get("gap")      // notch hangs from the edge
    readonly property int pad: Settings.get("innerPadding")
    readonly property int windowH: 820
    // motion (Settings -> Motion)
    readonly property bool reduce: !!Settings.get("reduceMotion")
    readonly property int animMs: reduce ? 0 : Settings.get("motionMove")
    readonly property int fadeMs: reduce ? 0 : Settings.get("motionFade")
    readonly property int hoverInMs: Settings.get("hoverResponse")
    readonly property real bounce: reduce ? 0 : Settings.get("bounce") / 100
    readonly property int easing: bounce > 0 ? Easing.OutBack : Easing.OutQuint
    readonly property real overshoot: bounce * 2.5
    readonly property int hoverOutMs: 350
    // type + shape (Settings -> Appearance): px() scales a font size, r() a corner radius
    readonly property string fontFamily: Settings.get("fontBody") || "Inter"
    readonly property string fontDisplay: Settings.get("fontDisplay") || fontFamily
    readonly property real fontScale: Settings.get("fontSize") / 15
    readonly property real roundness: Settings.get("cornerRoundness") / 100
    function ms(n) { return reduce ? 0 : n; }       // fixed-length animations still obey Reduce motion
    function px(n) { return Math.max(8, Math.round(n * fontScale)); }
    function r(n) { return n * roundness; }

    // folder holding the helper scripts (change if you rename the config folder)
    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/pill/scripts/"
}
