import QtQuick
import "shapes.js" as Shapes

// Material 3 analog clock.
// Dial  = 12-sided cookie shape (leftmost shape of the sheet's bottom row).
// Second hand sweeps smoothly and extends OUT of the dial shape.
// Centre = stacked hour/minute digits, 12-hour format.
Canvas {
    id: root

    property color dialColor: "#2b2930"
    property color hourColor: "#e6e0e9"
    property color minuteColor: "#dc8767"
    property color secondColor: "#d0bcff"
    property color hourDigitColor: "#93d2a6"
    property color minuteDigitColor: "#e5c07b"
    property color meridiemColor: "#938f99"
    property color hubColor: "#e6e0e9"

    readonly property real radius: Math.min(width, height) / 2
    readonly property real dialR: radius * 0.78

    property real h: 0
    property real m: 0
    property real s: 0   // fractional seconds for a smooth sweep

    // QtQuick FrameAnimation has no triggeredOnStart; first paint comes
    // from Component.onCompleted's requestPaint
    FrameAnimation {
        running: root.visible
        onTriggered: {
            var d = new Date()
            root.h = d.getHours()
            root.m = d.getMinutes()
            root.s = d.getSeconds() + d.getMilliseconds() / 1000
            root.requestPaint()
        }
    }

    antialiasing: true

    function hand(angle, len, w, color) {
        var ctx = getContext("2d")
        ctx.save()
        ctx.translate(width / 2, height / 2)
        ctx.rotate(angle * Math.PI / 180)
        ctx.strokeStyle = color
        ctx.lineWidth = w
        ctx.lineCap = "round"
        ctx.beginPath()
        // start BELOW the centre so the hand's tail passes through the hub
        ctx.moveTo(0, len * 0.18)
        ctx.lineTo(0, -len)
        ctx.stroke()
        ctx.restore()
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var cx = width / 2, cy = height / 2

        // dial: 12-sided cookie
        Shapes.draw(ctx, "cookie12", cx, cy, dialR, dialColor)

        // stacked 12h time in the middle, hands render ON TOP of it
        var hh = h % 12
        if (hh === 0) hh = 12
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        var fs = radius * 0.34
        ctx.font = "600 " + fs + "px sans-serif"
        ctx.fillStyle = hourDigitColor
        ctx.fillText(("" + hh).padStart(2, "0"), cx, cy - fs * 0.55)
        ctx.fillStyle = minuteDigitColor
        ctx.fillText(("" + Math.floor(m)).padStart(2, "0"), cx, cy + fs * 0.55)

        // AM / PM under the stacked digits
        ctx.fillStyle = meridiemColor
        ctx.font = "500 " + (fs * 0.42) + "px sans-serif"
        ctx.fillText(h >= 12 ? "PM" : "AM", cx, cy + fs * 1.38)

        // hour + minute hands (stay inside the dial)
        var hAngle = ((h % 12) + m / 60) * 30
        var mAngle = (m + s / 60) * 6
        hand(hAngle, dialR * 0.46, radius * 0.055, hourColor)
        hand(mAngle, dialR * 0.66, radius * 0.035, minuteColor)

        // smooth second hand, extending OUT of the dial shape
        var sAngle = s * 6
        hand(sAngle, dialR * 1.32, radius * 0.014, secondColor)

        // hub
        ctx.beginPath()
        ctx.fillStyle = hubColor
        ctx.arc(cx, cy, radius * 0.028, 0, 2 * Math.PI)
        ctx.fill()
    }
}
