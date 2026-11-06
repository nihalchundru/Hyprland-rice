import QtQuick

// Digital readout sitting in the Material 3 "clamshell" shape -- wide with flat
// top and bottom, which is exactly the silhouette a time string wants.
Item {
    id: root

    implicitWidth: 268
    implicitHeight: 92

    M3Shape {
        anchors.fill: parent
        kind: "clamshell"
        fillColor: M3Theme.palette.secondaryContainer
    }

    Column {
        anchors.centerIn: parent
        spacing: 1

        // Keep the text well inside the shape: clamshell tapers at the ends.
        width: root.width * 0.74

        Text {
            width: parent.width
            text: Qt.formatDateTime(TimeSource.date, "HH:mm:ss")
            color: M3Theme.palette.onSecondaryContainer
            font.family: M3Theme.font
            font.pixelSize: 30
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            // Centred alignment keeps the clock from visibly shifting as digits
            // change. For truly fixed-width digits you'd want tabular figures
            // (font.features), but that property only exists on Qt 6.6+ and
            // would be a hard error on older Qt -- not worth the risk here.
        }

        Text {
            width: parent.width
            text: Qt.formatDateTime(TimeSource.date, "dddd d MMMM")
            color: M3Theme.palette.onSecondaryContainer
            opacity: 0.78
            font.family: M3Theme.font
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
