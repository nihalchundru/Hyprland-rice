import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.theme
import qs.services
import qs.components
import qs.modules.bar.widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        anchors { top: true; left: true; right: true }
        implicitHeight: Config.bar.height
        color: "transparent"
        WlrLayershell.namespace: "qs-v2-bar"

        Item {
            anchors.fill: parent
            anchors.leftMargin: Config.bar.marginX
            anchors.rightMargin: Config.bar.marginX
            anchors.topMargin: Config.bar.marginY
            anchors.bottomMargin: Config.bar.marginY

            // ── left ──
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Config.bar.gap

                IconButton {
                    icon: "apps"
                    variant: "filled"
                    size: Config.bar.groupHeight
                    iconSize: 22
                    onClicked: Panels.toggle("launcher")
                }
                Workspaces { screen: win.modelData }
                ActiveWindow {}
            }

            // ── center ──
            ClockWidget { anchors.centerIn: parent }

            // ── right ──
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Config.bar.gap

                Tray {}
                PanelToggles {}
                Group {
                    NetworkWidget {}
                    VolumeWidget {}
                    BatteryWidget {}
                }
            }
        }
    }
}