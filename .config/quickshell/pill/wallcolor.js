.pragma library

// Which colours is a wallpaper made of? Input: a small grid of pixels as "RRGGBB" strings.

var BUCKETS = ["red", "orange", "yellow", "green", "teal", "blue", "purple", "pink", "dark", "light"];

// the dots in the picker (fixed colours: they describe the wallpapers, not your theme)
var COLORS = {
    red: "#e5534b", orange: "#f0883e", yellow: "#e3b341", green: "#57ab5a", teal: "#39c5bb",
    blue: "#5a9cf5", purple: "#986ee2", pink: "#e86aa6", dark: "#161616", light: "#ececec"
};

// hue (0-360) -> colour name
function hueBucket(h) {
    if (h < 15 || h >= 345) return "red";
    if (h < 45) return "orange";
    if (h < 70) return "yellow";
    if (h < 165) return "green";
    if (h < 200) return "teal";
    if (h < 255) return "blue";
    if (h < 295) return "purple";
    return "pink";
}

// r,g,b 0-255 -> {h, s, v}
function hsv(r, g, b) {
    r /= 255; g /= 255; b /= 255;
    var max = Math.max(r, g, b), min = Math.min(r, g, b), d = max - min, h = 0;
    if (d > 0) {
        if (max === r) h = ((g - b) / d) % 6;
        else if (max === g) h = (b - r) / d + 2;
        else h = (r - g) / d + 4;
        h *= 60;
        if (h < 0) h += 360;
    }
    return { h: h, s: max === 0 ? 0 : d / max, v: max };
}

// A wallpaper "has" a colour when at least 12% of it is that colour. Dark and
// light are stricter (half the image), so "dark" means a dark wallpaper rather
// than one that merely has a shadow somewhere.
function classify(hexList) {
    var counts = {}, total = 0;
    BUCKETS.forEach(function (b) { counts[b] = 0; });
    (hexList || []).forEach(function (hex) {
        if (!/^[0-9a-fA-F]{6}$/.test(hex)) return;
        var p = hsv(parseInt(hex.substr(0, 2), 16), parseInt(hex.substr(2, 2), 16), parseInt(hex.substr(4, 2), 16));
        total++;
        if (p.v < 0.25) counts.dark++;
        else if (p.s < 0.15 && p.v > 0.8) counts.light++;
        else if (p.s >= 0.25) counts[hueBucket(p.h)]++;
        // anything else is a muted mid-tone: it has no colour name
    });
    if (total === 0) return [];
    var out = [];
    BUCKETS.forEach(function (b) {
        var need = (b === "dark" || b === "light") ? 0.5 : 0.12;
        if (counts[b] / total >= need) out.push(b);
    });
    return out;
}
