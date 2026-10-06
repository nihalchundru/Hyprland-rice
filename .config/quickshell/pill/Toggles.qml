pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Control-center toggles and one-shot actions.
// Edit the commands below if your rice locks/suspends differently.
Singleton {
    id: root

    property bool focus: false        // do-not-disturb (used by notifications in stage 4)
    property bool gameMode: false     // animations + blur off

    Process {
        command: ["hyprctl", "getoption", "animations:enabled", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.gameMode = JSON.parse(text).int === 0; } catch (e) {}
            }
        }
    }

    function setGameMode(on) {
        gameMode = on;
        if (on) Quickshell.execDetached(["hyprctl", "--batch",
            "keyword animations:enabled 0 ; keyword decoration:blur:enabled 0"]);
        else Quickshell.execDetached(["hyprctl", "reload"]);
    }

    function lock() {
        Pill.close();
        Quickshell.execDetached(["sh", "-c", "pidof hyprlock || hyprlock"]);
    }

    function suspend() {
        Pill.close();
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function logout() {
        Pill.close();
        Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
    }

    function reboot() {
        Pill.close();
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function poweroff() {
        Pill.close();
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }
}
