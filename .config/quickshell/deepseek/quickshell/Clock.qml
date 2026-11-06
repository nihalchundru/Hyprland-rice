import Quickshell
import QtQuick

// Local wall clock. SystemClock.Minutes keeps the timer cheap — it only
// wakes up once a minute instead of once a second.
Rectangle {
    id: root

    implicitWidth: label.implicitWidth + Theme.pad * 2
    implicitHeight: 24
    radius: 8
    color: hover.hovered ? Theme.surfaceHi : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
        color: Theme.cream
        font.family: Theme.sans
        font.pixelSize: Theme.fontPx
        font.weight: Font.DemiBold
    }

    HoverHandler { id: hover }
}
