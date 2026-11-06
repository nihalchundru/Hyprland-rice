pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Reads ~/.config/quickshell/topbar/colors.json (any flat or nested JSON of color strings).
Singleton {
    id: root
    property var raw: ({})
    property var palette: ["#89b4fa", "#cba6f7", "#f38ba8", "#fab387", "#a6e3a1"]

    property color background: pick(["background", "bg", "surface", "base", "surface_container"], "#1e1e2e")
    property color foreground: pick(["on_background", "foreground", "fg", "text", "on_surface"], "#cdd6f4")
    property color primary:    pick(["primary", "accent", "color4", "blue"], "#89b4fa")
    property color secondary:  pick(["secondary", "color5", "mauve", "tertiary"], "#cba6f7")
    property color tertiary:   pick(["tertiary", "color6", "teal", "color2"], "#a6e3a1")
    property color outline:    pick(["outline", "border", "surface_variant", "overlay"], "#45475a")
    property color error:      pick(["error", "red", "color1"], "#f38ba8")

    function flatten(obj, out) {
        for (const k in obj) {
            const v = obj[k];
            if (typeof v === "string" && /^#?[0-9a-fA-F]{6,8}$/.test(v)) out[k.toLowerCase()] = v[0] === "#" ? v : "#" + v;
            else if (v && typeof v === "object") flatten(v, out);
        }
        return out;
    }
    property var flat: flatten(raw, {})

    function pick(names, fallback) {
        for (const n of names) if (flat[n] !== undefined) return flat[n];
        // partial match, e.g. "m3primary"
        for (const n of names) for (const k in flat) if (k.endsWith(n)) return flat[k];
        return fallback;
    }

    function parseLenient(txt) {
        // tolerate // and /* */ comments and trailing commas that strict JSON rejects
        txt = txt.replace(/\/\/[^\n]*/g, "").replace(/\/\*[\s\S]*?\*\//g, "");
        txt = txt.replace(/,\s*([}\]])/g, "$1");
        return JSON.parse(txt);
    }

    function reparse() {
        try {
            let txt = file.text();
            try { root.raw = JSON.parse(txt); }
            catch (e) { root.raw = parseLenient(txt); }
            const vals = [primary, secondary, tertiary, error].map(c => c.toString());
            root.palette = vals;
        } catch (e) {
            console.warn("colors.json parse failed:", e.message, "| content:", file.text().slice(0, 200));
        }
    }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.reparse()
        printErrors: false
    }
}
