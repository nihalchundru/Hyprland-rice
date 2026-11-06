.pragma library

// Material 3 shape geometry engine.
//
// Every shape is a signed distance function (SDF) in a normalised space:
// origin at the centre, shape contained within radius 1, negative = inside.
// The outline is then recovered by ray-marching (bisection) along evenly
// spaced angles, giving a polar sample array.
//
// Because every shape is sampled at the SAME angle set, morphing between any
// two shapes is a component-wise lerp of two radius arrays. That is the whole
// trick behind M3 shape morphing, and it is what animates the password
// characters in and out.

var SAMPLES = 96;
var TAU = Math.PI * 2;

// ---------------------------------------------------------------------------
// primitive SDFs
// ---------------------------------------------------------------------------

function sdCircle(x, y, r) {
    return Math.sqrt(x * x + y * y) - r;
}

function sdEllipse(x, y, rx, ry) {
    // Not a true distance, but sign-correct and monotonic along a ray, which
    // is all the bisection needs.
    return Math.sqrt((x / rx) * (x / rx) + (y / ry) * (y / ry)) - 1;
}

function sdRoundBox(x, y, hx, hy, r) {
    var qx = Math.abs(x) - hx + r;
    var qy = Math.abs(y) - hy + r;
    var ax = Math.max(qx, 0);
    var ay = Math.max(qy, 0);
    return Math.sqrt(ax * ax + ay * ay) + Math.min(Math.max(qx, qy), 0) - r;
}

function sdRoundBox4(x, y, hx, hy, rtl, rtr, rbr, rbl) {
    // Per-corner radius. Screen coords: y grows downward.
    var r;
    if (y < 0) {
        r = (x < 0) ? rtl : rtr;
    } else {
        r = (x < 0) ? rbl : rbr;
    }
    return sdRoundBox(x, y, hx, hy, r);
}

// Radial distance to a regular n-gon with circumradius 1.
function polyRad(theta, n, vertexUp) {
    var seg = TAU / n;
    // edge midpoints sit at pi/n + k*seg, so shift by that to get m = 0 there
    var a = theta + (vertexUp ? Math.PI / 2 : 0) - Math.PI / n;
    var m = a - seg * Math.round(a / seg);
    return Math.cos(Math.PI / n) / Math.cos(m);
}

// round > 0 dilates the polygon, which rounds its corners by that amount.
function sdPoly(x, y, n, vertexUp, round) {
    var theta = Math.atan2(y, x);
    var len = Math.sqrt(x * x + y * y);
    return len - polyRad(theta, n, vertexUp) - round;
}

// Scalloped / petal outlines: r = base + amp * cos(lobes * theta)
function sdScallop(x, y, base, amp, lobes, phase) {
    var theta = Math.atan2(y, x);
    var len = Math.sqrt(x * x + y * y);
    return len - (base + amp * Math.cos(lobes * (theta - phase)));
}

// Spiky star: |cos| raised to a power above 1 narrows the peaks into points.
function sdStar(x, y, lobes, inner, outer, phase) {
    var theta = Math.atan2(y, x);
    var len = Math.sqrt(x * x + y * y);
    var t = Math.abs(Math.cos(lobes * 0.5 * (theta - phase)));
    return len - (inner + (outer - inner) * Math.pow(t, 1.6));
}

var UP = -Math.PI / 2; // phase that puts a lobe at the top

// ---------------------------------------------------------------------------
// the shape set
// ---------------------------------------------------------------------------

function sdfFor(kind) {
    switch (kind) {
    case "circle":      return function (x, y) { return sdCircle(x, y, 0.95); };
    case "oval":        return function (x, y) { return sdEllipse(x, y, 0.99, 0.72); };
    case "pill":        return function (x, y) { return sdRoundBox(x, y, 0.84, 0.40, 0.40); };
    case "triangle":    return function (x, y) { return sdPoly(x, y, 3, true, 0.13); };
    case "diamond":     return function (x, y) { return sdPoly(x, y, 4, true, 0.13); };
    case "pentagon":    return function (x, y) { return sdPoly(x, y, 5, true, 0.11); };
    case "gem":         return function (x, y) { return sdPoly(x, y, 8, false, 0.12); };
    case "clamshell":   return function (x, y) {
        // flat-topped hexagon, stretched horizontally, heavily rounded
        return sdPoly(x / 1.22, y, 6, false, 0.14);
    };
    case "fan":         return function (x, y) {
        // square top-left corner, big sweep on the top-right
        return sdRoundBox4(x, y, 0.78, 0.78, 0.03, 0.78, 0.34, 0.12);
    };
    case "arrow":       return function (x, y) {
        // rounded triangle with a bite taken out of the bottom edge
        return Math.max(sdPoly(x, y, 3, true, 0.12), -sdCircle(x, y - 0.66, 0.42));
    };
    case "sunny":       return function (x, y) { return sdScallop(x, y, 0.80, 0.17, 8, UP); };
    case "very_sunny":  return function (x, y) { return sdScallop(x, y, 0.85, 0.115, 14, UP); };
    case "cookie4":     return function (x, y) { return sdScallop(x, y, 0.64, 0.32, 4, UP); };
    case "cookie6":     return function (x, y) { return sdScallop(x, y, 0.68, 0.28, 6, UP); };
    case "cookie7":     return function (x, y) { return sdScallop(x, y, 0.71, 0.25, 7, UP); };
    case "cookie9":     return function (x, y) { return sdScallop(x, y, 0.73, 0.23, 9, UP); };
    case "cookie12":    return function (x, y) { return sdScallop(x, y, 0.75, 0.21, 12, UP); };
    case "flower":      return function (x, y) { return sdScallop(x, y, 0.56, 0.40, 6, UP); };
    case "star":        return function (x, y) { return sdStar(x, y, 6, 0.46, 1.0, UP); };
    case "star12":      return function (x, y) { return sdStar(x, y, 12, 0.62, 1.0, UP); };
    }
    return function (x, y) { return sdCircle(x, y, 0.95); };
}

// Every shape name, in the order they appear in the Material 3 shape sheet.
function shapeNames() {
    return [
        "circle", "oval", "pill", "triangle", "arrow", "fan",
        "diamond", "clamshell", "pentagon", "gem",
        "very_sunny", "sunny",
        "cookie4", "cookie6", "cookie7", "cookie9", "cookie12",
        "flower", "star", "star12"
    ];
}

// ---------------------------------------------------------------------------
// sampling
// ---------------------------------------------------------------------------

var _cache = {};

function radii(kind, n) {
    n = n || SAMPLES;
    var key = kind + ":" + n;
    if (_cache[key]) return _cache[key];

    var sdf = sdfFor(kind);
    var out = [];
    var i, k;
    for (i = 0; i < n; i++) {
        var th = TAU * i / n;
        var dx = Math.cos(th);
        var dy = Math.sin(th);
        // bisect on the sign of the SDF along this ray
        var lo = 0;
        var hi = 2.5;
        for (k = 0; k < 30; k++) {
            var mid = (lo + hi) * 0.5;
            if (sdf(mid * dx, mid * dy) < 0) lo = mid;
            else hi = mid;
        }
        out.push(lo);
    }

    // normalise so the outermost point is exactly 1 -> every shape fills its
    // box consistently whatever its SDF units were
    var mx = 0;
    for (i = 0; i < n; i++) if (out[i] > mx) mx = out[i];
    if (mx > 0) for (i = 0; i < n; i++) out[i] /= mx;

    _cache[key] = out;
    return out;
}

function lerp(a, b, t) {
    var n = Math.min(a.length, b.length);
    var out = [];
    for (var i = 0; i < n; i++) out.push(a[i] + (b[i] - a[i]) * t);
    return out;
}

// Build an SVG path string (used by ShapePath/PathSvg).
function pathFrom(rs, size, cx, cy) {
    var s = size * 0.5;
    var d = "";
    for (var i = 0; i < rs.length; i++) {
        var th = TAU * i / rs.length;
        var x = cx + rs[i] * s * Math.cos(th);
        var y = cy + rs[i] * s * Math.sin(th);
        d += (i === 0 ? "M" : "L") + x.toFixed(2) + " " + y.toFixed(2) + " ";
    }
    return d + "Z";
}

// Convenience: path for a single shape, or a morph when `from` is given.
function buildPath(kind, fromKind, morph, size, cx, cy) {
    if (fromKind && morph < 1) {
        return pathFrom(lerp(radii(fromKind), radii(kind), Math.max(0, morph)), size, cx, cy);
    }
    return pathFrom(radii(kind), size, cx, cy);
}

// Deterministic shape for a typed character, so the same password always
// renders the same way and the whole shape sheet gets used.
function kindForChar(ch) {
    var names = shapeNames();
    var code = ch.charCodeAt(0);
    // The multiplier must be coprime with names.length (11 vs 20) so that
    // consecutive characters walk the whole shape sheet instead of collapsing
    // onto a handful of shapes.
    var idx = (code * 11 + 5) % names.length;
    return names[idx];
}
