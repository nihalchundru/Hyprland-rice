pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // "idle" | "focus" | "short" | "long"
    property string phase: "idle"
    property bool running: false
    property int sessions: 0            // finished focus sessions
    property int focusMins: 25
    property int shortMins: 5
    property int longMins: 15
    property int longEvery: 4
    property bool autoStart: false

    property real endTime: 0            // ms epoch, only valid while running
    property int remaining: focusMins * 60

    readonly property bool active: phase !== "idle"
    readonly property int total: phaseSeconds(phase === "idle" ? "focus" : phase)
    readonly property real progress: total > 0 ? 1 - remaining / total : 0
    readonly property string timeText: {
        const m = Math.floor(remaining / 60)
        const s = remaining % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }
        // phase color from the theme palette (colors.json), shared by the timer page and the idle chip
    function pick(v, fallback) {
        return (v === undefined || v === null) ? fallback : v
    }
    readonly property color phaseColor: phase === "short" ? pick(Theme.green, "#30D158")
                                      : phase === "long"  ? pick(Theme.accent2, "#0A84FF")
                                      : pick(Theme.accent, "#FF9F0A")

    function phaseSeconds(p) {
        if (p === "short") return shortMins * 60
        if (p === "long") return longMins * 60
        return focusMins * 60
    }

    function begin(p) {
        phase = p
        remaining = phaseSeconds(p)
        running = false
        if (autoStart) resume()
    }

    function resume() {
        endTime = Date.now() + remaining * 1000
        running = true
    }

    function pause() {
        running = false
    }

    function toggle() {
        if (!active) { begin("focus"); resume() }
        else if (running) pause()
        else resume()
    }

    function skip() {
        if (!active) return
        finishPhase()
    }

    function reset() {
        running = false
        phase = "idle"
        sessions = 0
        remaining = focusMins * 60
    }

    function finishPhase() {
        if (phase === "focus") {
            sessions++
            begin(sessions % longEvery === 0 ? "long" : "short")
        } else {
            begin("focus")
        }
    }

    // ── custom lengths (minutes) ──────────────────────────────────
    function clampMins(v, lo, hi) {
        return Math.max(lo, Math.min(hi, Math.round(v)))
    }

    // apply a changed length right away if it affects what is on screen
    function refreshLength(changed) {
        if (!active) {
            remaining = focusMins * 60
            return
        }
        if (phase !== changed) return
        remaining = phaseSeconds(phase)
        if (running) endTime = Date.now() + remaining * 1000
    }

    function setFocus(m) { focusMins = clampMins(m, 1, 180); refreshLength("focus") }
    function setShort(m) { shortMins = clampMins(m, 1, 60);  refreshLength("short") }
    function setLong(m)  { longMins  = clampMins(m, 1, 90);  refreshLength("long") }

    Timer {
        interval: 250
        repeat: true
        running: root.running
        onTriggered: {
            root.remaining = Math.max(0, Math.ceil((root.endTime - Date.now()) / 1000))
            if (root.remaining === 0) root.finishPhase()
        }
    }
}