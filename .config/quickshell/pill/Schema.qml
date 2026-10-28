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
            id: "media", title: "Media", icon: "music",
            subtitle: "The now-playing card inside the expanded island.",
            groups: [
                { title: "", rows: [
                    { type: "slider", key: "mediaSongW", label: "Song name width", min: 60, max: 300, step: 2, unit: "px" },
                    { type: "slider", key: "mediaArt", label: "Album art size", min: 28, max: 96, step: 2, unit: "px" }
                ] },
                { title: "What to show", rows: [
                    { type: "toggle", key: "mediaAlbum", label: "Album line" },
                    { type: "toggle", key: "mediaArtist", label: "Artist line" },
                    { type: "toggle", key: "mediaTransport", label: "Transport buttons" },
                    { type: "toggle", key: "mediaLyrics", label: "Lyrics", note: "Synced lyrics, fetched from lrclib.net. That sends the song's title, artist, album and length there." },
                    { type: "toggle", key: "mediaScroll", label: "Scroll to change track" }
                ] }
            ]
        },
        {
            id: "clock", title: "Clock & Date", icon: "clock",
            subtitle: "Clock format and what the pill shows.",
            groups: [
                { title: "Clock", rows: [
                    { type: "toggle", source: "clock24", label: "24-hour clock" },
                    { type: "toggle", key: "showSeconds", label: "Show seconds" }
                ] },
                { title: "Date", rows: [
                    { type: "choice", key: "dateFormat", label: "Date format", options: ClockFmt.dateFormats },
                    { type: "toggle", key: "showDate", label: "Show the date in the expanded pill" },
                    { type: "choice", key: "weekStart", label: "Week starts on", options: [
                        { value: 0, label: "Sunday" }, { value: 1, label: "Monday" }
                    ] }
                ] }
            ]
        },
        {
            id: "appearance", title: "Appearance", icon: "palette",
            subtitle: "Theme, wallpaper, fonts, corners, and surface depth.",
            groups: [
                { title: "", rows: [
                    { type: "nav", label: "Theme", valueSource: "theme", action: "themes" },
                    { type: "nav", label: "Wallpaper", value: "Choose\u2026", action: "wallpaper" }
                ] },
                { title: "Accent", rows: [
                    { type: "swatches", label: "Accent colour" },
                    { type: "text", key: "accentCustom", label: "Custom (#rrggbb)", kind: "hex", placeholder: "#rrggbb" },
                    { type: "toggle", key: "colorBurst", label: "Color burst (a different palette colour per surface)" }
                ] },
                { title: "Type", rows: [
                    { type: "slider", key: "fontSize", label: "Font size", min: 12, max: 18, step: 1, unit: "px" },
                    { type: "text", key: "fontBody", label: "Body font", kind: "font", placeholder: "Inter" },
                    { type: "text", key: "fontDisplay", label: "Display font", kind: "font", placeholder: "Inter" }
                ] },
                { title: "Shape & depth", rows: [
                    { type: "slider", key: "cornerRoundness", label: "Corner roundness", min: 0, max: 100, step: 5, unit: "%" },
                    { type: "slider", key: "surfaceDepth", label: "Surface depth", min: 10, max: 100, step: 5, unit: "%" }
                ] }
            ]
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
            id: "dock", title: "Dock", icon: "dock",
            subtitle: "Where the dock sits, how big its icons are, and which apps stay pinned.",
            groups: [
                { title: "", rows: [
                    { type: "toggle", key: "dockEnabled", label: "Dock" },
                    { type: "choice", key: "dockPosition", label: "Position", options: [
                        { value: "left", label: "Left" }, { value: "bottom", label: "Bottom" }, { value: "right", label: "Right" }
                    ] },
                    { type: "slider", key: "dockIconSize", label: "Icon size", min: 24, max: 72, step: 2, unit: "px" },
                    { type: "toggle", key: "dockNotch", label: "Notch mode" },
                    { type: "slider", key: "dockGap", label: "Gap from screen edge", min: 0, max: 40, step: 1, unit: "px", hideWhen: "dockNotch" },
                    { type: "choice", key: "dockHide", label: "Hide", options: [
                        { value: "never", label: "Never" }, { value: "under", label: "Under windows" }, { value: "auto", label: "Auto-hide" }
                    ] },
                    { type: "toggle", key: "dockReserve", label: "Reserve screen space", note: "Windows won't overlap the dock. A dock that hides can't hold space, so this is only offered when Hide is Never.", showIf: ["dockHide", "never"] },
                    { type: "text", key: "dockMonitor", label: "Only on monitor (blank = all)", kind: "text", placeholder: "DP-1" }
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
                    { type: "toggle", key: "notifShowBody", label: "Show body text" }
                ] },
                { title: "Volume / Brightness OSD", upper: true, rows: [
                    { type: "slider", key: "osdTime", label: "On-screen time", min: 500, max: 5000, step: 100, unit: "ms" },
                    { type: "slider", key: "osdThickness", label: "Level bar thickness", min: 2, max: 14, step: 1, unit: "px" }
                ] }
            ]
        },
        {
            id: "control", title: "Control Center", icon: "sliders",
            subtitle: "Arrange, resize, add and remove the controls.",
            custom: "control",
            groups: []
        },
        {
            id: "system", title: "System", icon: "gear",
            subtitle: "About, maintenance and reset.",
            groups: [
                { title: "About", rows: [
                    { type: "info", label: "Quickshell", valueSource: "version" },
                    { type: "info", label: "Config folder", valueSource: "configDir" },
                    { type: "info", label: "Settings file", valueSource: "settingsFile" },
                    { type: "info", label: "Colours file", valueSource: "colorsFile" },
                    { type: "info", label: "Monitors", valueSource: "screens" },
                    { type: "info", label: "Polkit agent", valueSource: "polkit" }
                ] },
                { title: "Maintenance", rows: [
                    { type: "action", label: "Reload shell", note: "Re-reads every file. Use it after editing the QML.", button: "Reload", action: "reload" },
                    { type: "action", label: "Open config folder", button: "Open", action: "openConfig" },
                    { type: "action", label: "Open settings file", button: "Open", action: "openSettings" }
                ] },
                { title: "Reset", rows: [
                    { type: "action", label: "Reset all settings", note: "Back to defaults, including the control center layout. Themes, wallpapers, clock format and night light are not touched.", button: "Reset", action: "resetAll", danger: true, confirm: true }
                ] }
            ]
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
