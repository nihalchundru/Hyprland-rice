pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Night Light: off -> warm -> warmer -> night. The state is kept in the same
// file your rice already uses (~/.config/hypr/themes/nightshift-state) and is
// applied with hyprsunset. If your rice applies it differently, change apply().
Singleton {
    id: root

    readonly property var states: ["off", "warm", "warmer", "night"]
    readonly property var kelvin: ({ warm: 4500, warmer: 3800, night: 3000 })
    readonly property var labels: ({ off: "Off", warm: "Warm", warmer: "Warmer", night: "Night" })

    property string current: "off"
    readonly property bool active: current !== "off"
    readonly property string label: labels[current] || "Off"

    function apply(s) {
        current = s;
        stateFile.setText(s + "\n");
        if (s === "off") Quickshell.execDetached(["pkill", "-x", "hyprsunset"]);
        else Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset; exec hyprsunset -t " + kelvin[s]]);
    }

    function cycle() { apply(states[(states.indexOf(current) + 1) % states.length]); }
    function toggle() { apply(active ? "off" : "warm"); }

    FileView {
        id: stateFile
        path: Quickshell.env("HOME") + "/.config/hypr/themes/nightshift-state"
        watchChanges: true
        printErrors: false
        onLoaded: {
            const t = text().trim();
            if (root.states.indexOf(t) >= 0) root.current = t;
        }
        onFileChanged: reload()
    }
}
