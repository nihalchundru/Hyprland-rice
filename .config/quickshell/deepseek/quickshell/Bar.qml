import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// One bar per monitor. Instantiated by the Variants block in shell.qml,
// which injects the ShellScreen through `modelData`.
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    // The Hyprland monitor this bar lives on. Used to show only the
    // workspaces that belong to this screen.
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: Theme.gap
        left: Theme.gap
        right: Theme.gap
    }
    implicitHeight: Theme.barHeight
    // Reserve the bar's footprint so maximised windows don't slide under it.
    // (Requires 1 or 3 anchors to take effect — we have 3.)
    exclusiveZone: Theme.barHeight + Theme.gap
    // The window itself stays transparent so the rounded surface below is
    // what you actually see.
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.surface
        border.width: 1
        border.color: Theme.line

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.pad
            anchors.rightMargin: Theme.pad
            spacing: Theme.gap

            // ---- left: workspaces + focused window ----
            RowLayout {
                spacing: Theme.gap

                Workspaces { monitor: bar.hyprMonitor }
                ActiveWindow {}
            }

            // Two equal springs keep the centre group genuinely centred
            // instead of merely "after the left group".
            Item { Layout.fillWidth: true }

            // ---- centre: now playing + clock ----
            RowLayout {
                spacing: Theme.gap

                Media {}
                Clock {}
            }

            Item { Layout.fillWidth: true }

            // ---- right: audio, power, tray ----
            RowLayout {
                spacing: Theme.gap

                Volume {}
                Battery {}
                Tray { barWindow: bar }
            }
        }
    }
}
