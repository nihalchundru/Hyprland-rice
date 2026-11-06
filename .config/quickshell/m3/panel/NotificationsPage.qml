import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.components
import qs.notifications

Page {
    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            M3Text { text: "Notifications"; role: M3Type.titleLarge; Layout.fillWidth: true }
            M3Button { text: "Clear all"; variant: "text"; size: "xs"; visible: Notifs.count > 0; onClicked: Notifs.dismissAll() }
            M3Button { id: dnd; text: "Do not disturb"; icon: Notifs.dnd ? "notifications_off" : "do_not_disturb_on"; variant: "tonal"; size: "s"; toggle: true; onClicked: Notifs.dnd = checked }
            Binding { target: dnd; property: "checked"; value: Notifs.dnd }
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
            Item { Layout.fillHeight: true }
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 110; Layout.preferredHeight: 110
                MorphShape { size: 110; shape: Notifs.dnd ? "pill" : "softBurst"; color: M3Colors.secondaryContainer }
                Icon { anchors.centerIn: parent; name: Notifs.dnd ? "notifications_off" : "check"; size: 44; fill: 1; color: M3Colors.fgSecondaryContainer }
            }
            M3Text { Layout.alignment: Qt.AlignHCenter; text: Notifs.dnd ? "Do not disturb is on" : "All caught up"; role: M3Type.titleMedium; color: M3Colors.fgSurfaceVariant }
            Item { Layout.fillHeight: true }
        }
    }
}
