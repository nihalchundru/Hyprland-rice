.pragma library

// Parse synced lyrics in LRC format: "[01:23.45] some words".
// Tag lines like "[ar: Artist]" have no timestamp and are ignored.
function parseLrc(text) {
    var out = [];
    String(text || "").split("\n").forEach(function (raw) {
        var stamps = [];
        var re = /\[(\d+):(\d+(?:\.\d+)?)\]/g;
        var m;
        while ((m = re.exec(raw)) !== null) stamps.push(parseInt(m[1], 10) * 60 + parseFloat(m[2]));
        if (stamps.length === 0) return;
        var body = raw.replace(/\[\d+:\d+(?:\.\d+)?\]/g, "").trim();
        stamps.forEach(function (t) { out.push({ t: t, text: body }); });
    });
    out.sort(function (a, b) { return a.t - b.t; });
    return out;
}

// the line being sung at `pos` seconds ("" before the first line)
function lineAt(lines, pos) {
    var cur = "";
    for (var i = 0; i < lines.length; i++) {
        if (lines[i].t <= pos) cur = lines[i].text;
        else break;
    }
    return cur;
}

// from a search result list, the entry with synced lyrics closest to this length
function pickSearch(results, duration) {
    var best = null, bestD = Infinity;
    (results || []).forEach(function (r) {
        if (!r || typeof r.syncedLyrics !== "string" || r.syncedLyrics === "") return;
        var d = duration > 0 && typeof r.duration === "number" ? Math.abs(r.duration - duration) : 0;
        if (d < bestD) { bestD = d; best = r; }
    });
    return best;
}
