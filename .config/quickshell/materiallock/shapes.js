.pragma library

// All 16 shapes from the reference sheet, in sheet order.
// Labels sit BELOW each shape on the sheet, so row-1 shapes are:
// oval, pill, triangle, arrow, fan — etc.
var ORDER = [
    "oval", "pill", "triangle", "arrow", "fan",
    "diamond", "clamshell", "pentagon", "gem", "verySunny",
    "sunny", "cookie4", "cookie6", "cookie7", "cookie9",
    "cookie12"
]

function lerp(a, b, t) { return [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t] }

function polyPoints(cx, cy, R, n, rot) {
    var pts = []
    for (var i = 0; i < n; i++) {
        var a = rot + i * 2 * Math.PI / n
        pts.push([cx + R * Math.cos(a), cy + R * Math.sin(a)])
    }
    return pts
}

// n-gon with corners rounded by factor t (0 = sharp, 0.5 = very round)
function roundedPoly(ctx, cx, cy, R, n, rot, t) {
    var pts = polyPoints(cx, cy, R, n, rot)
    var start = lerp(pts[0], pts[1], t)
    ctx.moveTo(start[0], start[1])
    for (var i = 1; i <= n; i++) {
        var corner = pts[i % n]
        var nxt = pts[(i + 1) % n]
        var to = lerp(corner, nxt, t)
        ctx.quadraticCurveTo(corner[0], corner[1], to[0], to[1])
    }
    ctx.closePath()
}

// Flower / cookie: radius modulated by cos(lobes * theta)
function lobed(ctx, cx, cy, R, lobes, amp, rot) {
    var steps = 240
    for (var i = 0; i <= steps; i++) {
        var th = rot + i * 2 * Math.PI / steps
        var r = R * (1 + amp * Math.cos(lobes * (th - rot)))
        var x = cx + r * Math.cos(th), y = cy + r * Math.sin(th)
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
    }
    ctx.closePath()
}

function ellipse(ctx, cx, cy, rx, ry, rot) {
    ctx.save()
    ctx.translate(cx, cy)
    ctx.rotate(rot)
    ctx.moveTo(0, -ry)
    ctx.bezierCurveTo(rx, -ry, rx, ry, 0, ry)
    ctx.bezierCurveTo(-rx, ry, -rx, -ry, 0, -ry)
    ctx.restore()
}

function capsule(ctx, cx, cy, w, h, rot) {
    ctx.save()
    ctx.translate(cx, cy)
    ctx.rotate(rot)
    var r = h / 2, x = -w / 2 + r
    ctx.moveTo(x, -r)
    ctx.lineTo(w / 2 - r, -r)
    ctx.arc(w / 2 - r, 0, r, -Math.PI / 2, Math.PI / 2)
    ctx.lineTo(x, r)
    ctx.arc(x, 0, r, Math.PI / 2, -Math.PI / 2)
    ctx.closePath()
    ctx.restore()
}

// Quarter disc with a rounded corner at the centre point
function fan(ctx, cx, cy, R) {
    var k = 0.28
    ctx.moveTo(cx + R * k, cy)
    ctx.quadraticCurveTo(cx, cy, cx, cy - R * k)
    ctx.arc(cx, cy, R, -Math.PI / 2, 0)
    ctx.closePath()
}

// Rounded upward triangle whose bottom edge is pinched inward
function arrow(ctx, cx, cy, R) {
    var top = [cx, cy - R]
    var bl = [cx - R * 0.95, cy + R * 0.72]
    var br = [cx + R * 0.95, cy + R * 0.72]
    var mid = [cx, cy + R * 0.30]
    var t = 0.30
    var a = lerp(top, br, t)
    ctx.moveTo(a[0], a[1])
    ctx.quadraticCurveTo(br[0], br[1], lerp(br, mid, 0.45)[0], lerp(br, mid, 0.45)[1])
    ctx.quadraticCurveTo(mid[0], mid[1], lerp(mid, bl, 0.45)[0], lerp(mid, bl, 0.45)[1])
    ctx.quadraticCurveTo(bl[0], bl[1], lerp(bl, top, t)[0], lerp(bl, top, t)[1])
    ctx.quadraticCurveTo(top[0], top[1], a[0], a[1])
    ctx.closePath()
}

function draw(ctx, name, cx, cy, R, color) {
    ctx.beginPath()
    ctx.fillStyle = color
    switch (name) {
    case "oval":      ellipse(ctx, cx, cy, R * 0.62, R, -0.6); break
    case "pill":      capsule(ctx, cx, cy, R * 1.9, R * 1.15, -0.35); break
    case "triangle":  roundedPoly(ctx, cx, cy, R, 3, -Math.PI / 2, 0.30); break
    case "arrow":     arrow(ctx, cx, cy, R); break
    case "fan":       fan(ctx, cx - R * 0.45, cy + R * 0.45, R * 1.55); break
    case "diamond":
        ctx.save(); ctx.translate(cx, cy); ctx.scale(0.82, 1.0); ctx.translate(-cx, -cy)
        roundedPoly(ctx, cx, cy, R, 4, -Math.PI / 2, 0.26); ctx.restore(); break
    case "clamshell": roundedPoly(ctx, cx, cy, R, 6, 0, 0.30); break
    case "pentagon":  roundedPoly(ctx, cx, cy, R, 5, -Math.PI / 2, 0.24); break
    case "gem":       roundedPoly(ctx, cx, cy, R, 7, -Math.PI / 2, 0.34); break
    // lobed() peaks at base*(1+amp): base radii below are pre-divided so
    // the outer bumps of every cookie/sunny shape stay inside R
    case "verySunny": lobed(ctx, cx, cy, R * 0.74, 8, 0.30, -Math.PI / 2); break
    case "sunny":     lobed(ctx, cx, cy, R * 0.73, 6, 0.32, -Math.PI / 2); break
    case "cookie4":   lobed(ctx, cx, cy, R * 0.79, 4, 0.22, -Math.PI / 4); break
    case "cookie6":   lobed(ctx, cx, cy, R * 0.85, 6, 0.13, -Math.PI / 2); break
    case "cookie7":   lobed(ctx, cx, cy, R * 0.85, 7, 0.13, -Math.PI / 2); break
    case "cookie9":   lobed(ctx, cx, cy, R * 0.86, 9, 0.12, -Math.PI / 2); break
    case "cookie12":  lobed(ctx, cx, cy, R * 0.885, 12, 0.085, -Math.PI / 2); break
    default:          ctx.arc(cx, cy, R, 0, 2 * Math.PI)
    }
    ctx.fill()
}
