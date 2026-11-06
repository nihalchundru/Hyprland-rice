import QtQuick
import QtQuick.Layouts

Rectangle {
    id: statsPillRoot
    width: 114
    height: 38
    radius: height / 2
    
    color: statsHoverZone.containsMouse ? barRoot.colors.surface : barRoot.colors.bg2
    border.color: statsHoverZone.containsMouse ? barRoot.colors.accent2 : barRoot.colors.surface2
    border.width: 1
    antialiasing: true

    scale: statsHoverZone.containsMouse ? 1.04 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: statsHoverZone
        anchors.fill: parent
        hoverEnabled: true
    }

    // FIX: Swapped RowLayout for a clean positioning Row centered perfectly inside the pill card
    Row {
        anchors.centerIn: parent
        spacing: 10

        // CPU Metric Stacking Block
        Row {
            spacing: 4
            Text { text: ""; color: barRoot.colors.accent; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            Text { text: barRoot.cpuDisplay; color: barRoot.colors.text; font.bold: true; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
        }

        // RAM Metric Stacking Block
        Row {
            spacing: 4
            Text { text: ""; color: barRoot.colors.accent2; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            Text { text: barRoot.ramDisplay; color: barRoot.colors.text; font.bold: true; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
        }
    }
}
