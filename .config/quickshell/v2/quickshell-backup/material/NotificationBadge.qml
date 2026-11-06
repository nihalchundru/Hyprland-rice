import QtQuick
import QtQuick.Layouts

Rectangle {
    id: alertBadgeRoot
    
    // Animate visibility state changes smoothly: Slides and fades into focus!
    visible: barRoot.unreadAlerts > 0
    width: visible ? 38 : 0
    height: 38
    radius: height / 2
    
    color: badgeClickZone.containsMouse ? barRoot.colors.surface : barRoot.colors.bg2
    border.color: badgeClickZone.containsMouse ? barRoot.colors.accent : barRoot.colors.surface2
    border.width: 1
    antialiasing: true

    scale: badgeClickZone.containsMouse ? 1.04 : 1.0

    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: badgeClickZone
        anchors.fill: parent
        hoverEnabled: true
        // Tapping the icon instantly flushes the counter back down to zero
        onClicked: barRoot.unreadAlerts = 0
    }

    Item {
        anchors.centerIn: parent
        width: 24; height: 24

        // The Signature Material 3 Bumpy Flower Indicator Ring
        Item {
            anchors.centerIn: parent
            width: 24; height: 24

            Repeater {
                model: 8
                Rectangle {
                    anchors.centerIn: parent
                    width: 3.5; height: 20; radius: 1.5
                    color: barRoot.colors.accent
                    rotation: (index * 45)
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 12; height: 12; radius: 6
                color: barRoot.colors.accent
            }
        }

        // Live text digits overlay tracking unread message packets
        Text {
            anchors.centerIn: parent
            text: barRoot.unreadAlerts.toString()
            color: barRoot.colors.bg
            font.bold: true
            font.pixelSize: 9
            font.family: "JetBrainsMono Nerd Font"
        }
    }
}
