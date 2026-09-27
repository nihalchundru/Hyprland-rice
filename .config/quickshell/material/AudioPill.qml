import QtQuick
import QtQuick.Layouts

Rectangle {
    id: audioPillRoot
    width: 82; height: 38; radius: height / 2
    
    // Morph background and border colors dynamically on mouse hover
    color: audioHoverZone.containsMouse ? barRoot.colors.surface : barRoot.colors.bg2
    border.color: audioHoverZone.containsMouse ? barRoot.colors.accent : barRoot.colors.surface2
    border.width: 1
    antialiasing: true

    // Buttery-smooth structural physics transformations
    scale: audioHoverZone.containsMouse ? 1.04 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: audioHoverZone
        anchors.fill: parent
        hoverEnabled: true
        scrollGestureEnabled: true
        
        // Retain original vector mouse-wheel volume scroll logic
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                // Vol Up script triggers here
            } else {
                // Vol Down script triggers here
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent; spacing: 6
        Text { text: "  "; color: barRoot.colors.accent; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
        Text { text: barRoot.volDisplay; color: barRoot.colors.text; font.bold: true; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
    }
}
