import QtQuick

// Digital Clock & Date for lockscreen2 center column
Item {
    id: root

    property date now: new Date()
    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property int rawHour: now.getHours()
    readonly property int hour12: rawHour % 12 === 0 ? 12 : rawHour % 12
    readonly property string minuteText: now.getMinutes().toString().padStart(2, "0")
    readonly property string ampm: rawHour >= 12 ? "PM" : "AM"

    readonly property string formattedDate: {
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        return days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()] + " " + now.getFullYear();
    }

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        // 10:53 PM
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Text {
                text: root.hour12 + ":" + root.minuteText
                color: Colors.text
                font.pixelSize: 42
                font.weight: Font.Bold
                font.letterSpacing: -0.5
            }

            Text {
                text: root.ampm
                color: Colors.accent
                font.pixelSize: 22
                font.weight: Font.Bold
                anchors.baseline: parent.children[0].baseline
            }
        }

        // Friday, 6 March 2026
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.formattedDate
            color: Colors.sub
            font.pixelSize: 15
            font.weight: Font.Medium
            font.letterSpacing: 0.3
        }
    }
}
