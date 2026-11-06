.pragma library

// Music visualizer helpers (plain JS so they can be tested outside Quickshell).

// One line from `cava` in raw ascii mode, e.g. "12;34;56;78;" (values 0-100).
// Returns `bars` levels between 0 and 1, or null if the line isn't a frame.
function parseFrame(line, bars) {
    var parts = String(line || "").split(";"), out = [];
    for (var i = 0; i < parts.length; i++) {
        if (parts[i].trim() === "") continue;
        var v = Number(parts[i]);
        if (isNaN(v)) return null;
        out.push(Math.max(0, Math.min(1, v / 100)));
    }
    if (out.length === 0) return null;
    while (out.length < bars) out.push(0);
    return out.slice(0, bars);
}

// The "static loop" style: a smooth wave that travels across the bars. 0.2 - 1.
function loopLevel(i, phase) {
    return 0.2 + 0.8 * (0.5 + 0.5 * Math.sin(phase + i * 0.7));
}
