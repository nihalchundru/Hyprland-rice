import QtQuick
import Quickshell
import Quickshell.Io

// Pulls the palette from your topbar's colors.json and derives a two-stop
// gradient for the visualizer.
//
//   ~/.config/quickshell/topbar/colors.json
//
// The file is watched, so re-theming the topbar re-themes the visualizer live.
//
// We don't assume a schema: every hex value in the file is collected, and a
// gradient is chosen from well-known key names (primary/secondary/tertiary,
// pywal's colorN, matugen, ...) falling back to "the two most distinct vivid
// colors in the file". Log the `keys` property if you want to pin specific keys.
QtObject {
    id: root

    // ── fallbacks, used until (or unless) colors.json is readable ──────────
    property string fallbackTop: "#7ee7c7"
    property string fallbackBottom: "#5b8cff"

    // ── results ────────────────────────────────────────────────────────────
    // The raw hex strings are kept alongside the colors: the helper functions
    // below work on hex text, and passing a QML `color` into JS would NOT give a
    // parseable "#rrggbb" string (it yields NaN -> an invalid, black color).
    property string gradientTopHex: fallbackTop
    property string gradientBottomHex: fallbackBottom
    readonly property color gradientTop: root.gradientTopHex
    readonly property color gradientBottom: root.gradientBottomHex
    // Peak "pellets": keep the bar's bright hue but push its saturation up, so
    // a 2px cap still reads as coloured rather than white. (Lightening can't do
    // this: Qt.lighter clamps value at 1.0, so a bright top stays pastel.)
    property real peakSaturation: 0.55
    readonly property color peakColor: root.saturate(root.gradientTopHex, root.peakSaturation, 0.9)

    // ── introspection ──────────────────────────────────────────────────────
    // normalized key -> color, e.g. { primary: "#8ab4f8", color1: "#..." }
    property var palette: ({})
    // every distinct color found, in file order
    property var colors: []
    // status for debugging
    property string status: "loading"

    readonly property string configPath: {
        const base = Quickshell.env("XDG_CONFIG_HOME")
            || ((Quickshell.env("HOME") || "") + "/.config");
        return base + "/quickshell/topbar/colors.json";
    }

    // ── hex / color helpers ────────────────────────────────────────────────
    function normKey(k) {
        return String(k).toLowerCase().replace(/[^a-z0-9]/g, "");
    }

    function isHex(v) {
        return typeof v === "string"
            && /^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(v.trim());
    }

    // Normalizes to "#rrggbb", expanding shorthand and dropping any alpha.
    function toHex(v) {
        let s = v.trim();
        if (s[0] !== "#")
            s = "#" + s;
        const h = s.slice(1);
        if (h.length === 3)
            s = "#" + h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
        else if (h.length === 4)
            s = "#" + h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
        else if (h.length === 8)
            s = "#" + h.slice(0, 6);
        return s.toLowerCase();
    }

    function hsv(hex) {
        const r = parseInt(hex.slice(1, 3), 16) / 255;
        const g = parseInt(hex.slice(3, 5), 16) / 255;
        const b = parseInt(hex.slice(5, 7), 16) / 255;
        const max = Math.max(r, g, b), min = Math.min(r, g, b), d = max - min;
        let h = 0;
        if (d > 0) {
            if (max === r) h = ((g - b) / d) % 6;
            else if (max === g) h = (b - r) / d + 2;
            else h = (r - g) / d + 4;
            h *= 60;
            if (h < 0) h += 360;
        }
        return { h: h, s: max === 0 ? 0 : d / max, v: max };
    }

    function hueDist(a, b) {
        if (!a || !b)
            return 0;
        let d = Math.abs(hsv(a).h - hsv(b).h);
        return d > 180 ? 360 - d : d;
    }

    function walk(node, flat, ordered) {
        if (!node || typeof node !== "object")
            return;

        if (Array.isArray(node)) {
            for (let i = 0; i < node.length; i++) {
                const v = node[i];
                if (isHex(v))
                    ordered.push(toHex(v));
                else if (v && typeof v === "object")
                    walk(v, flat, ordered);
            }
            return;
        }

        for (const k in node) {
            const v = node[k];
            if (isHex(v)) {
                const h = toHex(v);
                const nk = normKey(k);
                if (!(nk in flat))
                    flat[nk] = h;
                ordered.push(h);
            } else if (v && typeof v === "object") {
                walk(v, flat, ordered);
            }
        }
    }

    // Look up a color by normalized key name, with a prefix fallback so that
    // camelCase / suffixed keys like "accentColor" or "primaryContainer" hit.
    function findKey(flat, names) {
        for (let i = 0; i < names.length; i++)
            if (flat[names[i]])
                return flat[names[i]];
        const keys = Object.keys(flat);
        for (let i = 0; i < names.length; i++)
            for (let k = 0; k < keys.length; k++)
                if (keys[k].indexOf(names[i]) === 0)
                    return flat[keys[k]];
        return null;
    }

    function lighten(hex, amt) {
        const f = (c) => Math.round(c + (255 - c) * amt).toString(16).padStart(2, "0");
        return "#" + f(parseInt(hex.slice(1, 3), 16))
                   + f(parseInt(hex.slice(3, 5), 16))
                   + f(parseInt(hex.slice(5, 7), 16));
    }

    function hsv2hex(h, s, v) {
        const c = v * s;
        const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
        const m = v - c;
        let r = 0, g = 0, b = 0;
        if (h < 60) { r = c; g = x; }
        else if (h < 120) { r = x; g = c; }
        else if (h < 180) { g = c; b = x; }
        else if (h < 240) { g = x; b = c; }
        else if (h < 300) { r = x; b = c; }
        else { r = c; b = x; }
        const f = (t) => Math.round((t + m) * 255).toString(16).padStart(2, "0");
        return "#" + f(r) + f(g) + f(b);
    }

    // Raise saturation at the same hue (and floor the brightness) so a pastel
    // palette colour still looks coloured when drawn as a thin cap.
    function saturate(hex, add, minV) {
        // Guard: a non-string (or non-hex) input would poison the maths and
        // produce "#NaNNaNNaN", which Qt paints black.
        if (typeof hex !== "string" || !isHex(hex))
            return root.fallbackTop;
        const q = hsv(toHex(hex));
        const s = Math.min(1, q.s + add * (1 - q.s));
        const v = Math.max(q.v, minV === undefined ? 0.9 : minV);
        return hsv2hex(q.h, s, v);
    }

    // Candidate key names (normalized) for each end of the gradient.
    readonly property var _topKeys: [
        "primary", "accent", "secondary", "tertiary", "blue", "cyan", "teal",
        "sky", "aqua", "color6", "color4", "color2", "color14", "highlight",
        "foreground", "text"
    ]
    readonly property var _bottomKeys: [
        "tertiary", "secondary", "purple", "violet", "magenta", "pink",
        "indigo", "color5", "color13", "color12", "color4", "primary", "accent"
    ]

    function pickGradient(flat, ordered) {
        let top = findKey(flat, root._topKeys);

        let bottom = null;
        const bottomPick = findKey(flat, root._bottomKeys);
        if (bottomPick && bottomPick !== top && hueDist(bottomPick, top) > 25)
            bottom = bottomPick;

        // Fallback: most vivid color, then the most visually distinct one.
        if (!top || !bottom) {
            const uniq = [];
            for (let i = 0; i < ordered.length; i++)
                if (uniq.indexOf(ordered[i]) === -1)
                    uniq.push(ordered[i]);
            const vivid = uniq.slice().sort((a, b) => {
                const sa = hsv(a), sb = hsv(b);
                return (sb.s * sb.v) - (sa.s * sa.v);
            });
            if (!top)
                top = vivid[0] || fallbackTop;
            if (!bottom) {
                let best = null, bestD = -1;
                for (let i = 0; i < vivid.length; i++) {
                    const d = hueDist(vivid[i], top);
                    if (d > bestD) { bestD = d; best = vivid[i]; }
                }
                // Single-hue palette: fade from a lightened version of the hue.
                bottom = (best && best !== top) ? best : lighten(top, 0.35);
            }
        }

        // Put the lighter color on top so bars fade from bright to deep.
        if (hsv(top).v < hsv(bottom).v)
            return [bottom, top];
        return [top, bottom];
    }

    function refresh() {
        const txt = file.text();
        if (!txt)
            return;

        let data;
        try {
            data = JSON.parse(txt);
        } catch (e) {
            root.status = "colors.json: invalid JSON";
            console.warn("cava-visualizer: colors.json parse error:", e);
            return;
        }

        const flat = {};
        const ordered = [];
        walk(data, flat, ordered);

        root.palette = flat;
        root.colors = ordered;

        if (ordered.length === 0) {
            root.status = "colors.json: no hex colors found";
            return;
        }

        const picked = pickGradient(flat, ordered);
        root.gradientTopHex = picked[0];
        root.gradientBottomHex = picked[1];
        root.status = "ok (" + ordered.length + " colors, keys: "
            + Object.keys(flat).join(", ") + ")";
        console.info("cava-visualizer:", root.status);
    }

    property FileView file: FileView {
        path: root.configPath
        watchChanges: true
        onFileChanged: root.file.reload()
        onLoaded: root.refresh()
        onTextChanged: root.refresh()
        onLoadFailed: (error) => {
            root.status = "colors.json not readable, using fallback";
            console.info("cava-visualizer:", root.status);
        }
    }
}
