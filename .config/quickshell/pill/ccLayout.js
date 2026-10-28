.pragma library

// Control Center layout engine. A layout is an array of {id, x, y, w, h} in grid
// cells. Every function returns a NEW array and never mutates its input.

var CONTROLS = {
    wifi:      { title: "Wi-Fi",         icon: "wifi",      kind: "tile" },
    focus:     { title: "Focus",         icon: "focus",     kind: "tile" },
    lock:      { title: "Lock",          icon: "lock",      kind: "circle" },
    bluetooth: { title: "Bluetooth",     icon: "bluetooth", kind: "tile" },
    game:      { title: "Game Mode",     icon: "gamepad",   kind: "tile" },
    night:     { title: "Night Light",   icon: "moon",      kind: "circle" },
    sound:     { title: "Sound",         icon: "volume",    kind: "slider" },
    display:   { title: "Display",       icon: "sun",       kind: "slider" },
    notifs:    { title: "Notifications", icon: "bell",      kind: "notifs" },
    playing:   { title: "Now Playing",   icon: "music",     kind: "playing" }
};

// order controls are placed in by the default layout and listed in the tray
var ORDER = ["wifi", "focus", "lock", "bluetooth", "game", "night", "sound", "display", "notifs", "playing"];

var MIN_COLS = 5, MAX_COLS = 9;

function seq(a, b) {
    var r = [];
    for (var i = a; i <= b; i++) r.push(i);
    return r;
}

// every size a control supports for a given column count, smallest first
function sizesFor(id, cols) {
    var kind = CONTROLS[id].kind, out = [];
    if (kind === "tile") [1, 3, 4].forEach(function (w) { if (w <= cols) out.push([w, 1]); });
    else if (kind === "circle") [1, 3].forEach(function (w) { if (w <= cols) out.push([w, 1]); });
    else if (kind === "slider") seq(3, cols).forEach(function (w) { out.push([w, 1]); });
    else if (kind === "notifs") seq(3, cols).forEach(function (w) { seq(2, 6).forEach(function (h) { out.push([w, h]); }); });
    else if (kind === "playing") seq(3, cols).forEach(function (w) { [2, 3].forEach(function (h) { out.push([w, h]); }); });
    out.sort(function (a, b) { return (a[0] * a[1]) - (b[0] * b[1]) || a[0] - b[0]; });
    return out;
}

function defaultSize(id, cols) {
    var kind = CONTROLS[id].kind;
    if (kind === "tile") return [3, 1];
    if (kind === "circle") return [1, 1];
    if (kind === "slider") return [cols, 1];
    if (kind === "notifs") return [cols, 3];
    return [3, 2];
}

function nearestSize(id, cols, w, h) {
    var best = null, bestD = Infinity;
    sizesFor(id, cols).forEach(function (s) {
        var d = (s[0] - w) * (s[0] - w) + (s[1] - h) * (s[1] - h);
        if (d < bestD) { bestD = d; best = s; }
    });
    return best;
}

function overlaps(a, b) {
    return a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h;
}

function copy(layout) {
    return layout.map(function (e) { return { id: e.id, x: e.x, y: e.y, w: e.w, h: e.h }; });
}

function find(layout, id) {
    for (var i = 0; i < layout.length; i++) if (layout[i].id === id) return layout[i];
    return null;
}

function rowsOf(layout) {
    var r = 0;
    layout.forEach(function (e) { r = Math.max(r, e.y + e.h); });
    return r;
}

// make one entry valid: a supported size, inside the columns
function fit(e, cols) {
    var w = e.w, h = e.h;
    var ok = sizesFor(e.id, cols).some(function (s) { return s[0] === w && s[1] === h; });
    if (!ok) { var s = nearestSize(e.id, cols, w, h); w = s[0]; h = s[1]; }
    return {
        id: e.id,
        x: Math.max(0, Math.min(cols - w, Math.round(e.x))),
        y: Math.max(0, Math.round(e.y)),
        w: w, h: h
    };
}

// Remove collisions. The pinned entry (the one being moved) stays; everything
// else keeps its place if it can, otherwise is pushed down until it is free.
function resolve(layout, pinId) {
    var items = copy(layout);
    var pinned = pinId ? find(items, pinId) : null;
    var rest = items.filter(function (e) { return e !== pinned; })
                    .sort(function (a, b) { return a.y - b.y || a.x - b.x; });
    var placed = pinned ? [pinned] : [];
    rest.forEach(function (e) {
        var guard = 0;
        while (placed.some(function (p) { return overlaps(p, e); }) && guard++ < 1000) e.y++;
        placed.push(e);
    });
    return items;
}

function findSpot(layout, cols, w, h) {
    for (var y = 0; y < 200; y++) {
        for (var x = 0; x + w <= cols; x++) {
            var cand = { x: x, y: y, w: w, h: h };
            if (!layout.some(function (e) { return overlaps(e, cand); })) return { x: x, y: y };
        }
    }
    return { x: 0, y: rowsOf(layout) };
}

function add(layout, cols, id) {
    if (!CONTROLS[id] || find(layout, id)) return copy(layout);
    var s = defaultSize(id, cols);
    var spot = findSpot(layout, cols, s[0], s[1]);
    var out = copy(layout);
    out.push({ id: id, x: spot.x, y: spot.y, w: s[0], h: s[1] });
    return out;
}

function remove(layout, id) {
    return copy(layout).filter(function (e) { return e.id !== id; });
}

function missing(layout) {
    return ORDER.filter(function (id) { return !find(layout, id); });
}

function defaultLayout(cols) {
    var out = [];
    ORDER.forEach(function (id) { if (id !== "playing") out = add(out, cols, id); });
    return out;
}

function moveTo(layout, cols, id, x, y) {
    var out = copy(layout), e = find(out, id);
    if (!e) return out;
    e.x = Math.max(0, Math.min(cols - e.w, Math.round(x)));
    e.y = Math.max(0, Math.round(y));
    return resolve(out, id);
}

function nudge(layout, cols, id, dx, dy) {
    var e = find(layout, id);
    return e ? moveTo(layout, cols, id, e.x + dx, e.y + dy) : copy(layout);
}

// w/h may be fractional (a corner being dragged): snaps to the nearest supported size
function resizeTo(layout, cols, id, w, h) {
    var out = copy(layout), e = find(out, id);
    if (!e) return out;
    var s = nearestSize(id, cols, w, h);
    e.w = s[0]; e.h = s[1];
    e.x = Math.max(0, Math.min(cols - e.w, e.x));
    return resolve(out, id);
}

// [ and ]: move to the previous / next supported size
function stepSize(layout, cols, id, dir) {
    var e = find(layout, id);
    if (!e) return copy(layout);
    var sizes = sizesFor(id, cols), idx = 0;
    for (var i = 0; i < sizes.length; i++) if (sizes[i][0] === e.w && sizes[i][1] === e.h) idx = i;
    var n = sizes[Math.max(0, Math.min(sizes.length - 1, idx + dir))];
    return resizeTo(layout, cols, id, n[0], n[1]);
}

// close gaps: every control moves up as far as it can
function tidy(layout, cols) {
    var items = copy(layout).sort(function (a, b) { return a.y - b.y || a.x - b.x; });
    var placed = [];
    items.forEach(function (e) {
        while (e.y > 0) {
            e.y--;
            if (placed.some(function (p) { return overlaps(p, e); })) { e.y++; break; }
        }
        placed.push(e);
    });
    return items;
}

function setCols(layout, cols) {
    return resolve(layout.map(function (e) { return fit(e, cols); }), null);
}

// Turn whatever is stored into a valid layout. null/undefined means "never
// customised" and gives the default; an empty array is a deliberate empty layout.
function sanitize(stored, cols) {
    if (!Array.isArray(stored)) return defaultLayout(cols);
    var seen = {}, out = [];
    stored.forEach(function (e) {
        if (!e || !CONTROLS[e.id] || seen[e.id]) return;
        seen[e.id] = true;
        out.push(fit({ id: e.id, x: +e.x || 0, y: +e.y || 0, w: +e.w || 1, h: +e.h || 1 }, cols));
    });
    return resolve(out, null);
}
