pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property var types: ({
        clock: {
            name: "Clock", desc: "Time and date",
            defaultW: 2, defaultH: 2, minW: 1, minH: 1, maxW: 4, maxH: 4,
            settings: [
                { key: "format",        label: "Time format",    kind: "choice", options: ["24h", "12h"], def: "24h" },
                { key: "showDate",      label: "Show date",      kind: "toggle", def: true },
                { key: "accentMinutes", label: "Accent minutes", kind: "toggle", def: false }
            ]
        },
        calendar: {
            name: "Calendar", desc: "Month view with today highlighted",
            defaultW: 3, defaultH: 3, minW: 2, minH: 3, maxW: 5, maxH: 6,
            settings: [
                { key: "mondayFirst", label: "Week starts Monday", kind: "toggle", def: false }
            ]
        },
        battery: {
            name: "Battery", desc: "Charge level and time left",
            defaultW: 3, defaultH: 1, minW: 2, minH: 1, maxW: 6, maxH: 2,
            settings: []
        },
        weather: {
            name: "Weather", desc: "Current conditions",
            defaultW: 3, defaultH: 1, minW: 2, minH: 1, maxW: 6, maxH: 2,
            settings: [
                { key: "units",    label: "Units",    kind: "choice", options: ["metric", "imperial"], def: "metric" },
                { key: "location", label: "Location", kind: "text",   placeholder: "auto or a city name", def: "auto" }
            ]
        },
        gauges: {
            name: "Gauges", desc: "Three live usage rings",
            defaultW: 3, defaultH: 2, minW: 2, minH: 1, maxW: 6, maxH: 3,
            settings: [
                { key: "ring1",      label: "Ring 1", kind: "choice", options: ["cpu", "ram", "disk"], def: "cpu" },
                { key: "ring2",      label: "Ring 2", kind: "choice", options: ["cpu", "ram", "disk"], def: "ram" },
                { key: "ring3",      label: "Ring 3", kind: "choice", options: ["cpu", "ram", "disk"], def: "disk" },
                { key: "showLabels", label: "Show labels", kind: "toggle", def: true }
            ]
        },
        graph: {
            name: "Graph", desc: "CPU and RAM history",
            defaultW: 3, defaultH: 2, minW: 2, minH: 2, maxW: 6, maxH: 4,
            settings: [
                { key: "showGrid", label: "Grid lines", kind: "toggle", def: true }
            ]
        },
        music: {
            name: "Music", desc: "Now playing with controls",
            defaultW: 2, defaultH: 3, minW: 2, minH: 2, maxW: 6, maxH: 4,
            settings: [
                { key: "showArt", label: "Show album art", kind: "toggle", def: true },
                { key: "player",  label: "Preferred player", kind: "text", placeholder: "any (e.g. spotify)", def: "" }
            ]
        },
        todo: {
            name: "To-do", desc: "Checklist saved to todos.json",
            defaultW: 3, defaultH: 3, minW: 2, minH: 2, maxW: 5, maxH: 6,
            settings: [
                { key: "title",    label: "Title", kind: "text", placeholder: "To-do", def: "To-do" },
                { key: "hideDone", label: "Hide completed", kind: "toggle", def: false }
            ]
        }
    })

    readonly property var list:
        Object.keys(types).map(k => Object.assign({ type: k }, types[k]))

    function info(type) { return types[type] ?? null; }

    function defaultSettings(type) {
        const out = {};
        for (const s of (types[type]?.settings ?? []))
            out[s.key] = s.def;
        return out;
    }
}