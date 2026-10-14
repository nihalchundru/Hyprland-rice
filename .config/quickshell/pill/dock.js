.pragma library

// Pure helpers for the dock: matching running windows to desktop entries and
// building the icon list. Kept free of Quickshell types so they can be tested.

function norm(s) {
    return String(s || "").toLowerCase().replace(/\.desktop$/, "");
}

function tail(id) {
    var i = norm(id);
    return i.substring(i.lastIndexOf(".") + 1);
}

// does this desktop entry belong to a window class / app id (already normalised)?
function entryMatches(e, k) {
    if (!e || !k) return false;
    if (norm(e.id) === k) return true;
    if (e.startupClass && norm(e.startupClass) === k) return true;
    if (e.name && norm(e.name) === k) return true;
    if (tail(e.id) === k) return true;               // "org.gnome.Nautilus" vs app id "nautilus"
    return false;
}

// best desktop entry for an app id: exact id first, then the looser matches
function findEntry(apps, appId) {
    var k = norm(appId);
    if (!k || !apps) return null;
    var i;
    for (i = 0; i < apps.length; i++) if (norm(apps[i].id) === k) return apps[i];
    for (i = 0; i < apps.length; i++) if (entryMatches(apps[i], k)) return apps[i];
    return null;
}

// Build the dock's icons: pinned apps first (in pinned order, running or not),
// then every other running app in the order its first window appeared.
//   pinnedIds: desktop entry ids,  apps: desktop entries,  tops: toplevel windows
function build(pinnedIds, apps, tops) {
    var groups = [], byKey = {};
    (tops || []).forEach(function (t) {
        var k = norm(t.appId);
        if (!k) return;
        var g = byKey[k];
        if (!g) { g = { key: k, appId: t.appId, windows: [] }; byKey[k] = g; groups.push(g); }
        g.windows.push(t);
    });

    var items = [], seen = {};
    (pinnedIds || []).forEach(function (pid) {
        var entry = null, k = norm(pid);
        for (var i = 0; i < (apps || []).length; i++) if (norm(apps[i].id) === k) { entry = apps[i]; break; }
        if (!entry || seen[k]) return;                 // uninstalled, or pinned twice
        seen[k] = true;
        var windows = [];
        groups = groups.filter(function (g) {
            if (entryMatches(entry, g.key)) { windows = windows.concat(g.windows); return false; }
            return true;
        });
        items.push({ key: "pin:" + k, id: entry.id, appId: entry.id, name: entry.name, entry: entry, windows: windows, pinned: true });
    });

    groups.forEach(function (g) {
        var entry = findEntry(apps, g.appId);
        items.push({
            key: "run:" + g.key, id: entry ? entry.id : "", appId: g.appId,
            name: entry ? entry.name : g.appId, entry: entry, windows: g.windows, pinned: false
        });
    });
    return items;
}

// clicking an app that has several windows cycles through them
function nextToActivate(windows) {
    if (!windows || windows.length === 0) return null;
    var idx = -1;
    for (var i = 0; i < windows.length; i++) if (windows[i].activated) { idx = i; break; }
    return windows[(idx + 1) % windows.length];
}

// ── hiding ───────────────────────────────────────────────────────────────────────
function rectsOverlap(a, b) {
    return a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h;
}

// the dock's rectangle in global (layout) coordinates when fully shown
//   pos: left|bottom|right, W/H: the monitor's logical size, mx/my: where the monitor starts
function dockRect(pos, W, H, along, across, gap, mx, my) {
    if (pos === "left")  return { x: mx + gap, y: my + (H - along) / 2, w: across, h: along };
    if (pos === "right") return { x: mx + W - across - gap, y: my + (H - along) / 2, w: across, h: along };
    return { x: mx + (W - along) / 2, y: my + H - across - gap, w: along, h: across };
}

// Is a window in the dock's way? Only windows on this monitor's visible workspace
// count (`clients` are Hyprland's window objects; mon = {id, ws}).
function covered(clients, mon, rect) {
    return (clients || []).some(function (c) {
        if (!c || !c.mapped || c.hidden || !c.at || !c.size) return false;
        if (c.monitor !== mon.id) return false;
        if (!c.workspace || c.workspace.id !== mon.ws) return false;
        return rectsOverlap({ x: c.at[0], y: c.at[1], w: c.size[0], h: c.size[1] }, rect);
    });
}
