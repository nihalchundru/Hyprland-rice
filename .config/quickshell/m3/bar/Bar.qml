import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        WlrLayershell.namespace: "m3-bar"
        anchors { top: true; left: true; right: true }
        margins { top: M3Config.barFloating ? 8 : 0; left: M3Config.barFloating ? 8 : 0; right: M3Config.barFloating ? 8 : 0 }
        implicitHeight: 48
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: M3Config.barFloating ? 24 : 0
            color: M3Config.barFloating ? M3Colors.surfaceContainer : M3Colors.surfaceContainerLow
            ColorBehavior on color {}
            SpatialBehavior on radius {}
        }

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            BarIcon { icon: "apps"; onClicked: UiState.launcherOpen = !UiState.launcherOpen }
            Workspaces { count: M3Config.workspaceCount }
            M3Text {
                visible: M3Config.barTitle
                Layout.maximumWidth: 280
                elide: Text.ElideRight
                text: Hypr.activeTitle
                role: M3Type.labelLarge
                color: M3Colors.fgSurfaceVariant
            }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 12
            MouseArea {
                implicitWidth: clockRow.implicitWidth; implicitHeight: 36
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.calendarOpen = !UiState.calendarOpen
                Row {
                    id: clockRow
                    anchors.centerIn: parent
                    spacing: 8
                    M3Text { text: Clock.time; role: M3Type.titleMedium; anchors.verticalCenter: parent.verticalCenter }
                    M3Text { visible: M3Config.barDate; text: Clock.dateShort; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant; anchors.verticalCenter: parent.verticalCenter }
                }
            }
            MediaPill { visible: M3Config.barMedia && opacity > 0.01 }
        }

        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            TrayView { visible: M3Config.barTray }
            StatusCluster {}
            BarIcon { icon: "right_panel_open"; onClicked: UiState.sidebarOpen = !UiState.sidebarOpen }
            BarIcon { icon: "power_settings_new"; onClicked: UiState.sessionOpen = !UiState.sessionOpen }
        }
    }
}
