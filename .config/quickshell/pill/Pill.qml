pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // current state of the pill
    property string mode: "idle"
    // sticky = opened by click/IPC, so it does not auto-collapse when the mouse leaves
    property bool sticky: false
    property bool hovering: false

    SystemClock {
        id: clk
        precision: SystemClock.Minutes
    }
    readonly property date now: clk.date

    readonly property string workspaceLabel: {
        const ws = Hyprland.focusedWorkspace;
        if (!ws) return "Desktop";
        return /^\d+$/.test(ws.name) ? "Workspace " + ws.name : ws.name;
    }

    // states that have real content; everything else shows a placeholder
    readonly property var built: ["idle", "hover", "calendar", "control", "sound", "display", "wifi", "bluetooth",
                                       "launcher", "themes", "wallpaper", "power", "auth", "notify"]
    readonly property var subpages: ["sound", "display", "wifi", "bluetooth"]

    // anything beyond idle/hover grabs input (click outside + Esc close it)
    // (a toast never grabs input: it must not steal focus or swallow outside clicks)
    readonly property bool active: ["idle", "hover", "notify"].indexOf(mode) < 0

    // Default size of every state. Pages with variable content report their real
    // height through setHeight(), which overrides the default below.
    readonly property var geo: ({
        idle:      { w: Theme.idleW, h: Theme.idleH },
        hover:     { w: 560, h: Media.hasPlayer ? Settings.get("expandedHeight") : Math.max(64, Settings.get("expandedHeight") - 48) },
        calendar:  { w: 430, h: 340 },
        control:   { w: 560, h: 580 },
        sound:     { w: 560, h: 560 },
        display:   { w: 560, h: 300 },
        wifi:      { w: 560, h: 420 },
        bluetooth: { w: 560, h: 420 },
        launcher:  { w: Settings.get("launcherWidth"), h: 560 },
        themes:    { w: 880, h: 236 },
        wallpaper: { w: 1000, h: 262 },
        power:     { w: 576, h: 136 },
        auth:      { w: 460, h: 290 },
        notify:    { w: Settings.get("notifWidth"), h: 80 }
    })

    property var heights: ({})

    function setHeight(m, h) {
        if (heights[m] === h) return;
        const o = Object.assign({}, heights);
        o[m] = h;
        heights = o;
    }

    readonly property real targetW: (geo[mode] || geo.idle).w
    readonly property real targetH: heights[mode] !== undefined ? heights[mode] : (geo[mode] || geo.idle).h
    readonly property real targetR: Math.min(targetH / 2,
        mode === "idle" ? Settings.get("cornerRadius") : Settings.get("cornerRadiusExp"))

    function open(m, keep) {
        if (!geo[m]) {
            console.warn("pill: unknown mode '" + m + "'");
            return;
        }
        mode = m;
        sticky = !!keep;
    }

    function toggle(m) {
        if (mode === m) close();
        else open(m, true);
    }

    function close() {
        mode = "idle";
        sticky = false;
    }

    // Esc: sub-page -> control center, anything else -> close
    function back() {
        if (mode === "auth") { AuthState.cancel(); return; }
        if (subpages.indexOf(mode) >= 0) open("control", true);
        else close();
    }
}
