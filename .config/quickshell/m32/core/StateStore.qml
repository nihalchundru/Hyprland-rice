pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME") || "/home/user"
    readonly property string hyprDir: homeDir + "/.config/hypr"
    readonly property string themesDir: hyprDir + "/themes"
    readonly property string scriptsDir: hyprDir + "/scripts"
    readonly property string m32Dir: homeDir + "/.config/quickshell/m32"

    // ------------------------------------------------------------------------
    // Reactive State Properties (from THEMING.md State Files Reference)
    // ------------------------------------------------------------------------
    property string currentTheme: "matugen"                 // ~/.config/hypr/themes/current-name
    property string irisCurrentWall: ""                     // ~/.config/hypr/themes/iris-current-wall
    property string matugenCurrentWall: homeDir + "/.config/rofi/images/a.png" // ~/.config/hypr/themes/matugen-current-wall
    property string wallTransition: "grow"                  // ~/.config/hypr/themes/wall-transition
    property string wallTransitionDuration: "1.0"           // ~/.config/hypr/themes/wall-transition-duration
    property string nightShiftState: "off"                  // ~/.config/hypr/themes/night-shift-state
    property string clockFormat: "12"                       // ~/.config/hypr/themes/clock-format
    property string activeLockscreen: "quickshell"          // ~/.config/hypr/active-lockscreen
    property string activeBar: "quickshell"                 // ~/.config/hypr/bar/active-bar
    property string qsLayout: "pill"                        // ~/.config/hypr/bar/qs-layout (pill|notch|islands)
    property string currentWallpaper: homeDir + "/.config/rofi/images/a.png"

    // ------------------------------------------------------------------------
    // Global UI Overlay / Drawer Visibility States (shared across m32 modules)
    // ------------------------------------------------------------------------
    property bool controlCenterOpen: false
    property bool notificationCenterOpen: false
    property bool launcherOpen: false
    property bool themeSwitcherOpen: false
    property bool wallpaperPickerOpen: false
    property bool overviewOpen: false
    property bool keybindsOpen: false
    property bool lockscreenActive: false
    property bool notchExpanded: false
    property bool dndEnabled: false
    property bool desktopWidgetsVisible: true

    readonly property var transitionStyles: ["grow", "wave", "wipe", "fade", "outer"]
    readonly property var transitionDurations: ["0.5", "1.0", "1.8", "2.5", "4.0"]
    readonly property var layoutModes: ["pill", "notch", "islands"]
    readonly property var nightShiftModes: ["off", "warm", "warmer", "night"]

    function closeAllPopups() {
        controlCenterOpen = false;
        notificationCenterOpen = false;
        launcherOpen = false;
        themeSwitcherOpen = false;
        wallpaperPickerOpen = false;
        overviewOpen = false;
        keybindsOpen = false;
        notchExpanded = false;
    }

    // ------------------------------------------------------------------------
    // Actions & Script Invokers (per THEMING.md — no scheme override!)
    // ------------------------------------------------------------------------
    function writeStateFile(relPath, value) {
        var fullPath = homeDir + "/" + relPath;
        stateWriterProc.command = [
            "sh", "-c",
            "mkdir -p \"$(dirname \"$1\")\" && printf '%s\\n' \"$2\" > \"$1\"",
            "sh", fullPath, String(value)
        ];
        stateWriterProc.running = true;
    }

    function setLayout(mode) {
        if (layoutModes.indexOf(mode) === -1) return;
        qsLayout = mode;
        writeStateFile(".config/hypr/bar/qs-layout", mode);
    }

    function cycleLayout() {
        var idx = layoutModes.indexOf(qsLayout);
        var next = layoutModes[(idx + 1) % layoutModes.length];
        setLayout(next);
    }

    function setClockFormat(fmt) {
        clockFormat = String(fmt);
        writeStateFile(".config/hypr/themes/clock-format", clockFormat);
    }

    function toggleClockFormat() {
        setClockFormat(clockFormat === "24" ? "12" : "24");
    }

    function setNightShift(state) {
        nightShiftState = state;
        writeStateFile(".config/hypr/themes/night-shift-state", state);
        var tempMap = { "off": 6500, "warm": 4500, "warmer": 3600, "night": 2800 };
        var temp = tempMap[state] || 6500;
        if (state === "off") {
            actionProc.command = ["sh", "-c", "pkill -x hyprsunset || pkill -x wlsunset || true"];
        } else {
            actionProc.command = ["sh", "-c", "(pkill -x hyprsunset; hyprsunset -t " + temp + " &) 2>/dev/null || true"];
        }
        actionProc.running = true;
    }

    function cycleNightShift() {
        var idx = nightShiftModes.indexOf(nightShiftState);
        var next = nightShiftModes[(idx + 1) % nightShiftModes.length];
        setNightShift(next);
    }

    function setTransitionStyle(style) {
        wallTransition = style;
        writeStateFile(".config/hypr/themes/wall-transition", style);
    }

    function setTransitionDuration(dur) {
        wallTransitionDuration = String(dur);
        writeStateFile(".config/hypr/themes/wall-transition-duration", String(dur));
    }

    function applyTheme(themeName) {
        currentTheme = themeName;
        writeStateFile(".config/hypr/themes/current-name", themeName);
        if (themeName === "matugen") {
            applyMatugen(currentWallpaper || (homeDir + "/.config/rofi/images/a.png"));
        } else if (themeName === "iris") {
            applyIris(irisCurrentWall || currentWallpaper || (homeDir + "/.config/rofi/images/a.png"));
        } else {
            actionProc.command = ["bash", scriptsDir + "/write-colors.sh", themeName];
            actionProc.running = true;
            themeWallProc.command = [
                "sh", "-c",
                "W=$(find \"$HOME/.config/hypr/wallpapers/$1\" -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null | sort | head -n1); [ -n \"$W\" ] && bash \"$2\" \"$W\"",
                "sh", "x", themeName, scriptsDir + "/set-wallpaper.sh"
            ];
            themeWallProc.running = true;
        }
    }

    function applyMatugen(wallpaperPath) {
        var wall = wallpaperPath || currentWallpaper || (homeDir + "/.config/rofi/images/a.png");
        matugenCurrentWall = wall;
        currentWallpaper = wall;
        actionProc.command = ["bash", scriptsDir + "/matugen-apply.sh", wall];
        actionProc.running = true;
    }

    function applyIris(wallpaperPath) {
        var wall = wallpaperPath || irisCurrentWall || currentWallpaper;
        irisCurrentWall = wall;
        currentWallpaper = wall;
        actionProc.command = ["bash", scriptsDir + "/iris-apply.sh", wall];
        actionProc.running = true;
    }

    function applyWallpaper(wallpaperPath) {
        currentWallpaper = wallpaperPath;
        if (currentTheme === "matugen") {
            applyMatugen(wallpaperPath);
        } else if (currentTheme === "iris") {
            applyIris(wallpaperPath);
        } else {
            actionProc.command = ["bash", scriptsDir + "/set-wallpaper.sh", wallpaperPath];
            actionProc.running = true;
        }
    }

    // ------------------------------------------------------------------------
    // Periodic State File Synchronizer
    // ------------------------------------------------------------------------
    Process {
        id: stateWriterProc
    }

    Process {
        id: actionProc
        onExited: Theme.reloadColors()
    }

    // Picks the first wallpaper in ~/.config/hypr/wallpapers/<theme> for static themes
    Process {
        id: themeWallProc
    }

    Process {
        id: stateReaderProc
        command: [
            "sh", "-c",
            "read_f() { [ -f \"$1\" ] && tr -d '\\r\\n' < \"$1\" || printf '%s' \"$2\"; }; " +
            "printf '{\"currentTheme\":\"%s\",\"irisWall\":\"%s\",\"matugenWall\":\"%s\",\"transition\":\"%s\",\"duration\":\"%s\",\"nightShift\":\"%s\",\"clockFormat\":\"%s\",\"lockscreen\":\"%s\",\"activeBar\":\"%s\",\"qsLayout\":\"%s\"}\\n' " +
            "\"$(read_f \"$HOME/.config/hypr/themes/current-name\" \"matugen\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/themes/iris-current-wall\" \"\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/themes/matugen-current-wall\" \"$HOME/.config/rofi/images/a.png\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/themes/wall-transition\" \"grow\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/themes/wall-transition-duration\" \"1.0\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/themes/night-shift-state\" \"off\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/themes/clock-format\" \"12\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/active-lockscreen\" \"quickshell\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/bar/active-bar\" \"quickshell\")\" " +
            "\"$(read_f \"$HOME/.config/hypr/bar/qs-layout\" \"pill\")\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = this.text ? this.text.trim() : "";
                if (!txt) return;
                try {
                    var s = JSON.parse(txt);
                    if (s.currentTheme) root.currentTheme = s.currentTheme;
                    if (s.irisWall) root.irisCurrentWall = s.irisWall;
                    if (s.matugenWall) root.matugenCurrentWall = s.matugenWall;
                    if (s.transition) root.wallTransition = s.transition;
                    if (s.duration) root.wallTransitionDuration = s.duration;
                    if (s.nightShift) root.nightShiftState = s.nightShift;
                    if (s.clockFormat) root.clockFormat = s.clockFormat;
                    if (s.lockscreen) root.activeLockscreen = s.lockscreen;
                    if (s.activeBar) root.activeBar = s.activeBar;
                    if (s.qsLayout) root.qsLayout = s.qsLayout;
                } catch (e) {}
            }
        }
        running: true
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        onTriggered: stateReaderProc.running = true
    }
}
