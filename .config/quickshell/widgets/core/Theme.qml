pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string colorsPath:
        Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"

    property var raw: ({})

    // ---------- helpers ----------
    function key(k, fallback) {
        const v = raw[k];
        return (typeof v === "string" && v.length) ? v : fallback;
    }

    function same(a, b) {
        return Qt.color(a).toString() === Qt.color(b).toString();
    }

    // First key whose color differs from everything in `avoid`.
    // If none does, rotate the hue of avoid[0].
    function distinct(keys, avoid) {
        for (const k of keys) {
            const v = raw[k];
            if (typeof v === "string" && v.length && !avoid.some(a => same(a, v)))
                return v;
        }
        const c = Qt.color(avoid[0]);
        const h = Math.max(0, c.hslHue);
        return Qt.hsla((h + 0.5) % 1, c.hslSaturation, c.hslLightness, 1).toString();
    }

    // ---------- raw (non-animated) picks ----------
    readonly property string _accent:  key("accent", "#4ab369")
    readonly property string _accent2: distinct(["accent2", "yellow", "teal", "red"], [_accent])
    readonly property string _accent3: distinct(["teal", "orange", "purple", "green"], [_accent, _accent2])
    readonly property string _warn:    key("yellow", "#dc8767")
    readonly property string _danger: {
        const r = key("red", "#dc8767");
        if (!same(r, _warn)) return r;
        const c = Qt.color(r);
        return Qt.hsla(0.01, Math.max(c.hslSaturation, 0.6), Math.min(c.hslLightness, 0.55), 1).toString();
    }

    // ---------- semantic roles (animated) ----------
    property color card:      key("bg", "#432934")
    property color cardAlt:   key("surface", "#593745")
    property color track:     key("sub", "#7b5a68")
    property color onSurface: key("text", "#e7ad97")
    property color accent:    _accent
    property color accent2:   _accent2
    property color accent3:   _accent3
    property color ok:        key("green", "#52b870")
    property color warn:      _warn
    property color danger:    _danger

    // derived
    readonly property color onSurfaceDim: Qt.tint(card, Qt.alpha(onSurface, 0.55))
    readonly property color onAccent: card

    readonly property string name: raw.theme ?? ""

    Behavior on card      { ColorAnimation { duration: 300 } }
    Behavior on cardAlt   { ColorAnimation { duration: 300 } }
    Behavior on track     { ColorAnimation { duration: 300 } }
    Behavior on onSurface { ColorAnimation { duration: 300 } }
    Behavior on accent    { ColorAnimation { duration: 300 } }
    Behavior on accent2   { ColorAnimation { duration: 300 } }
    Behavior on accent3   { ColorAnimation { duration: 300 } }
    Behavior on ok        { ColorAnimation { duration: 300 } }
    Behavior on warn      { ColorAnimation { duration: 300 } }
    Behavior on danger    { ColorAnimation { duration: 300 } }

    FileView {
        path: root.colorsPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.raw = JSON.parse(text());
            } catch (e) {
                console.warn("Theme: could not parse colors.json:", e);
            }
        }
    }
}