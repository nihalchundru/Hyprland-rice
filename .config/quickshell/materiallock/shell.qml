import QtQuick
import Quickshell
import Quickshell.Hyprland

// Entry point: run with  quickshell -c src/shell.qml  (see README).
// The process IS the lock: it grabs the keyboard, and exits on successful
// PAM auth so Hyprland returns to the session.
ShellRoot {
    PanelWindow {
        id: win

        // cover the whole screen, above everything
        // PanelWindow.anchors is a group of bools, not a string list
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusiveZone: -1
        aboveWindows: true // stack above the session
        focusable: true
        visible: true

        // keeps keyboard focus on the lock even if the pointer moves away
        HyprlandFocusGrab {
            windows: [win]
            active: win.visible
        }

        LockScreen {
            anchors.fill: parent
            onUnlocked: Qt.quit()
        }
    }
}
