pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland
import "dock.js" as DockJs

// Dock state and actions. Settings live in Settings -> Dock.
Singleton {
    id: root

    readonly property bool enabled: !!Settings.get("dockEnabled")
    readonly property string position: Settings.get("dockPosition")      // left | bottom | right
    readonly property bool vertical: position !== "bottom"
    readonly property int iconSize: Settings.get("dockIconSize")
    readonly property bool notch: !!Settings.get("dockNotch")
    readonly property int gap: notch ? 0 : Settings.get("dockGap")
    readonly property string monitor: String(Settings.get("dockMonitor") || "").trim()

    // blank = every monitor; otherwise a name, or several separated by commas
    function showOn(name) {
        if (monitor === "") return true;
        return monitor.split(",").some(m => m.trim() === name);
    }

    // pinned apps first, then whatever else is running
    readonly property var items: DockJs.build(
        Settings.get("dockPinned") || [],
        DesktopEntries.applications.values,
        ToplevelManager.toplevels.values)

    // ── actions ─────────────────────────────────────────────────────────
    function launch(it) {
        if (it && it.entry) it.entry.execute();
    }

    function focusWindow(w) {
        if (w.minimized) w.minimized = false;
        w.activate();
    }

    function activate(it) {
        if (it.windows.length === 0) { launch(it); return; }
        focusWindow(DockJs.nextToActivate(it.windows));
    }

    function closeAll(it) {
        it.windows.slice().forEach(w => w.close());
    }

    function pin(id) {
        const l = (Settings.get("dockPinned") || []).slice();
        if (id && l.indexOf(id) < 0) {
            l.push(id);
            Settings.set("dockPinned", l);
        }
    }

    function unpin(id) {
        Settings.set("dockPinned", (Settings.get("dockPinned") || []).filter(x => x !== id));
    }

    // what the right-click menu offers for one icon
    function menuRows(it) {
        const rows = [];
        if (it.entry) rows.push({ label: "New window", run: () => launch(it) });
        if (it.windows.length > 1)
            it.windows.slice(0, 6).forEach(w => rows.push({ label: w.title || it.name, run: () => focusWindow(w) }));
        if (it.entry && it.id)
            rows.push({ label: it.pinned ? "Unpin from dock" : "Pin to dock", run: () => (it.pinned ? unpin(it.id) : pin(it.id)) });
        if (it.windows.length > 0)
            rows.push({ label: it.windows.length > 1 ? "Close all windows" : "Close", danger: true, run: () => closeAll(it) });
        return rows;
    }
}
