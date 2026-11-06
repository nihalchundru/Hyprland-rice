import QtQuick
import qs.tokens
import qs.services
import qs.components

Rectangle {
    implicitWidth: r.implicitWidth + 12
    implicitHeight: 36
    radius: height / 2
    color: M3Colors.surfaceContainerHigh
    Row {
        id: r
        anchors.centerIn: parent
        BarIcon { icon: Network.icon; onClicked: UiState.quickSettingsOpen = !UiState.quickSettingsOpen }
        BarIcon { visible: Bt.available; icon: Bt.icon; onClicked: UiState.quickSettingsOpen = !UiState.quickSettingsOpen }
        BarIcon {
            icon: Audio.icon
            onClicked: UiState.quickSettingsOpen = !UiState.quickSettingsOpen
            onMiddleClicked: Audio.toggleMute()
            onScrolled: d => Audio.setVolume(Audio.volume + d * 0.05)
        }
        BarIcon { visible: Battery.present; icon: Battery.icon; tint: Battery.low ? M3Colors.error : M3Colors.fgSurfaceVariant; onClicked: UiState.quickSettingsOpen = !UiState.quickSettingsOpen }
        M3Text {
            visible: Battery.present
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(Battery.percentage * 100) + "%"
            role: M3Type.labelMedium
            color: M3Colors.fgSurfaceVariant
        }
        BarIcon {
            icon: Notifs.dnd ? "notifications_off" : "notifications"
            badge: Notifs.count
            onClicked: UiState.notifCenterOpen = !UiState.notifCenterOpen
            onMiddleClicked: Notifs.dnd = !Notifs.dnd
        }
    }
}
