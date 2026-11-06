import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// Toggle: bell in the bar, or qs -c m3 ipc call ui toggleNotifications
PanelWindow {
    id: win
    readonly property bool open: UiState.notifCenterOpen
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-notif-center"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: panel.opacity > 0.01

    MouseArea { anchors.fill: parent; onClicked: UiState.notifCenterOpen = false }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: M3Config.barFloating ? 64 : 56
        anchors.rightMargin: 12
        width: 400
        height: Math.min(win.height - anchors.topMargin - 16, 16 + 48 + 12 + (Notifs.count > 0 ? list.contentHeight : 150) + 16)
        radius: 28
        color: M3Colors.surfaceContainer
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.92
        transformOrigin: Item.TopRight
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
        SpatialBehavior on height {}
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                spacing: 8
                M3Text { text: "Notifications"; role: M3Type.titleLarge; Layout.fillWidth: true }
                M3Button { text: "Clear all"; variant: "text"; size: "xs"; visible: Notifs.count > 0; onClicked: Notifs.dismissAll() }
                M3Button {
                    id: dndBtn
                    icon: Notifs.dnd ? "notifications_off" : "do_not_disturb_on"
                    variant: "tonal"; toggle: true
                    onClicked: Notifs.dnd = checked
                }
                Binding { target: dndBtn; property: "checked"; value: Notifs.dnd }
            }

            ListView {
                id: list
                visible: Notifs.count > 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                boundsBehavior: Flickable.StopAtBounds
                model: Notifs.all.slice().reverse()
                delegate: NotificationCard {
                    required property var modelData
                    notif: modelData
                    width: list.width
                    onCloseRequested: modelData.dismiss()
                    onActivated: modelData.dismiss()
                }
            }

            ColumnLayout {
                visible: Notifs.count === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                Item { Layout.fillHeight: true }
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 96; Layout.preferredHeight: 96
                    MorphShape { anchors.fill: parent; size: 96; shape: Notifs.dnd ? "pill" : "softBurst"; color: M3Colors.secondaryContainer }
                    Icon { anchors.centerIn: parent; name: Notifs.dnd ? "notifications_off" : "check"; size: 36; color: M3Colors.fgSecondaryContainer; fill: 1 }
                }
                M3Text { Layout.alignment: Qt.AlignHCenter; text: Notifs.dnd ? "Do not disturb is on" : "All caught up"; role: M3Type.titleMedium; color: M3Colors.fgSurfaceVariant }
                Item { Layout.fillHeight: true }
            }
        }
    }
}
