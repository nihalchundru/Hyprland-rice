pragma Singleton
import QtQuick
import Quickshell
import "Calc.js" as Calc

// Launcher search. Result kinds: app {entry}, calc {value}, run {cmd}
Singleton {
    id: root
    readonly property var all: DesktopEntries.applications.values.filter(a => !a.noDisplay)

    function terminalCmd(cmd) {
        const t = M3Config.terminal
        if (t === "kitty") return [t, "sh", "-c", cmd]
        if (t === "wezterm") return [t, "start", "--", "sh", "-c", cmd]
        return [t, "-e", "sh", "-c", cmd]
    }

    function search(raw) {
        const q = raw.trim()
        const byName = (a, b) => a.name.localeCompare(b.name)
        if (q === "")
            return all.slice().sort(byName).map(a => ({ kind: "app", entry: a, name: a.name, sub: a.genericName || a.comment || "" }))
        if (q[0] === ">" || q[0] === "!") {
            const cmd = q.slice(1).trim(), term = q[0] === ">"
            return cmd === "" ? [] : [{ kind: "run", term: term, cmd: cmd,
                name: (term ? "Run in terminal  " : "Run  ") + cmd,
                sub: term ? "Opens " + M3Config.terminal : "Background, no terminal" }]
        }

        const out = []
        if (q[0] === "=" || /[-+*\/^%(]/.test(q)) {
            const v = Calc.evaluate(q[0] === "=" ? q.slice(1) : q)
            if (v !== null) out.push({ kind: "calc", name: "= " + Calc.format(v), sub: "Enter to copy", value: Calc.format(v) })
        }

        const ql = q.toLowerCase()
        const terms = ql.split(/\s+/)
        const apps = []
        for (const a of all) {
            const n = a.name.toLowerCase()
            let s = 0
            if (n === ql) s = 100
            else if (n.startsWith(ql)) s = 80
            else if (n.split(/[\s\-_.]+/).some(w => w.startsWith(ql))) s = 60
            else if (n.includes(ql)) s = 40
            else {
                const hay = ((a.genericName || "") + " " + (a.keywords || []).join(" ") + " " + (a.comment || "")).toLowerCase()
                if (terms.every(t => hay.includes(t))) s = 20
            }
            if (s > 0) apps.push({ kind: "app", score: s, entry: a, name: a.name, sub: a.genericName || a.comment || "" })
        }
        apps.sort((a, b) => b.score - a.score || byName(a, b))
        return out.concat(apps).slice(0, 100)
    }
}
