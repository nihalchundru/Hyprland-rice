pragma Singleton
import QtQuick
import Quickshell

// Describes every settings page. The window and the search both read this,
// so adding a row here is all it takes to add a setting.
Singleton {
    id: root

    readonly property var pages: [
        {
            id: "bar", title: "Bar & Island", icon: "window",
            subtitle: "Shape and size of the pill and how it behaves.",
            groups: [
                { title: "", rows: [
                    { type: "toggle", key: "notchMode", label: "Notch mode" },
                    { type: "slider", key: "barHeight", label: "Bar height", min: 24, max: 64, step: 1, unit: "px" },
                    { type: "slider", key: "collapsedWidth", label: "Collapsed width", min: 240, max: 460, step: 2, unit: "px" },
                    { type: "slider", key: "expandedHeight", label: "Expanded height", min: 90, max: 200, step: 1, unit: "px" },
                    { type: "slider", key: "gap", label: "Gap from screen edge", min: 0, max: 40, step: 1, unit: "px" },
                    { type: "slider", key: "innerPadding", label: "Inner padding", min: 4, max: 36, step: 1, unit: "px" },
                    { type: "slider", key: "cornerRadius", label: "Corner radius", min: 0, max: 40, step: 1, unit: "px" },
                    { type: "slider", key: "cornerRadiusExp", label: "Corner radius (expanded)", min: 0, max: 50, step: 1, unit: "px" },
                    { type: "slider", key: "stageLift", label: "Stage lift on hover", min: 0, max: 20, step: 1, unit: "px" }
                ] }
            ]
        },
        {
            id: "clock", title: "Clock & Date", icon: "clock",
            subtitle: "Clock format and what the pill shows.",
            groups: []
        },
        {
            id: "appearance", title: "Appearance", icon: "palette",
            subtitle: "Theme, colors and fonts.",
            groups: []
        },
        {
            id: "motion", title: "Motion", icon: "motion",
            subtitle: "How fast the shell animates, or whether it animates at all.",
            groups: [
                { title: "", rows: [
                    { type: "toggle", key: "reduceMotion", label: "Reduce motion" },
                    { type: "slider", key: "motionMove", label: "Movement (size / position)", min: 0, max: 1000, step: 10, unit: "ms" },
                    { type: "slider", key: "motionFade", label: "Fades & colour", min: 0, max: 600, step: 10, unit: "ms" },
                    { type: "slider", key: "hoverResponse", label: "Hover response", min: 0, max: 600, step: 10, unit: "ms" },
                    { type: "slider", key: "bounce", label: "Bounce", min: 0, max: 100, step: 5, unit: "%" }
                ] }
            ]
        },
        {
            id: "launcher", title: "Launcher", icon: "search",
            subtitle: "Size of the app launcher and its result rows.",
            groups: [
                { title: "", rows: [
                    { type: "slider", key: "launcherWidth", label: "Width", min: 400, max: 1100, step: 10, unit: "px" },
                    { type: "slider", key: "launcherRowH", label: "Row height", min: 40, max: 90, step: 2, unit: "px" },
                    { type: "slider", key: "launcherRows", label: "Rows before scrolling", min: 3, max: 12, step: 1, unit: "" }
                ] }
            ]
        },
        {
            id: "notifications", title: "Notifications", icon: "bell",
            subtitle: "How long popups stay up and how much they show.",
            groups: [
                { title: "", rows: [
                    { type: "slider", key: "notifTimeout", label: "Popup timeout", min: 1000, max: 15000, step: 250, unit: "ms" },
                    { type: "slider", key: "notifUrgentTimeout", label: "Urgent timeout", min: 1000, max: 30000, step: 500, unit: "ms" },
                    { type: "slider", key: "notifWidth", label: "Width", min: 320, max: 700, step: 10, unit: "px" },
                    { type: "toggle", key: "notifShowBody", label: "Show body text" },
                    { type: "slider", key: "notifHistoryH", label: "History height", min: 100, max: 420, step: 10, unit: "px" }
                ] }
            ]
        },
        {
            id: "control", title: "Control Center", icon: "sliders",
            subtitle: "Arrange, resize, add and remove the controls.",
            groups: []
        },
        {
            id: "system", title: "System", icon: "gear",
            subtitle: "About, maintenance and reset.",
            groups: []
        }
    ]

    function byId(id) {
        return pages.find(p => p.id === id) || pages[0];
    }

    // every row whose label contains the query
    function search(q) {
        q = q.trim().toLowerCase();
        const out = [];
        if (q === "") return out;
        pages.forEach(p => p.groups.forEach(g => g.rows.forEach(r => {
            if (r.label.toLowerCase().indexOf(q) >= 0) out.push(r);
        })));
        return out;
    }
}
