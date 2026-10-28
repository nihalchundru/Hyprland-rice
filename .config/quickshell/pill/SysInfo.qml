pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Facts and actions for Settings -> System.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string configDir: home + "/.config/quickshell/pill"
    readonly property string settingsFile: configDir + "/settings.json"
    readonly property string colorsFile: home + "/.config/quickshell/topbar/colors.json"

    property string qsVersion: "checking\u2026"

    function pretty(p) {
        return p.indexOf(home) === 0 ? "~" + p.slice(home.length) : p;
    }

    function screensText() {
        const s = Quickshell.screens;
        if (!s || s.length === 0) return "none";
        return s.length + (s.length === 1 ? " monitor" : " monitors") + "  \u00b7  pill on " + s[0].name;
    }

    function value(src) {
        switch (src) {
        case "version": return qsVersion;
        case "configDir": return pretty(configDir);
        case "settingsFile": return pretty(settingsFile);
        case "colorsFile": return pretty(colorsFile);
        case "screens": return screensText();
        case "polkit": return AuthState.registered ? "Registered" : "Not registered";
        }
        return "";
    }

    // Anything that tears the settings window down is deferred one turn of the
    // event loop, so a click handler never destroys the window it is running in.
    function run(action) {
        switch (action) {
        case "reload":
            Qt.callLater(function () { Quickshell.reload(false); });
            break;
        case "openConfig":
            Quickshell.execDetached(["xdg-open", configDir]);
            break;
        case "openSettings":
            Quickshell.execDetached(["xdg-open", settingsFile]);
            break;
        case "resetAll":
            Settings.resetAll();
            break;
        }
    }

    Process {
        command: ["qs", "--version"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim().split("\n")[0];
                root.qsVersion = line !== "" ? line : "unknown";
            }
        }
    }
}
