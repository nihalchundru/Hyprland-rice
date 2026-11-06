import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Laptop battery. Hidden on machines with no battery, so desktops don't show
// an empty slot.
Rectangle {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev ? dev.isLaptopBattery === true : false
    readonly property bool ready: dev ? dev.ready === true : false
    readonly property real pct: ready ? dev.percentage : 0
    // changeRate is positive while charging, negative while discharging —
    // avoids depending on any enum values.
    readonly property bool charging: ready ? dev.changeRate > 0 : false
    readonly property bool low: ready && !charging && pct <= 20

    visible: present
    implicitWidth: visible ? row.implicitWidth + Theme.pad * 2 : 0
    implicitHeight: 24
    radius: 8
    color: hover.hovered ? Theme.surfaceHi : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        // Nerd Font glyph (nf-fa-battery_full). Decorative only.
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.charging ? "\uf0e7" : "\uf240"
            color: root.charging ? Theme.cheese : (root.low ? Theme.tomato : Theme.basil)
            font.family: Theme.mono
            font.pixelSize: 11
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.pct) + "%"
            color: root.low ? Theme.tomato : Theme.cream
            font.family: Theme.mono
            font.pixelSize: 11
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.ready && !root.charging && root.pct <= 20 && root.dev.timeToEmpty > 0
            text: {
                if (!root.dev) return "";
                const mins = Math.round(root.dev.timeToEmpty / 60);
                return Math.floor(mins / 60) + "h" + String(mins % 60).padStart(2, "0");
            }
            color: Theme.muted
            font.family: Theme.mono
            font.pixelSize: 11
        }
    }

    HoverHandler { id: hover }

    // Left click asks UPower, via loginctl, for a suspend. Swap for whatever
    // your power menu is if you have one.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["sh", "-c", "systemctl suspend"])
    }
}
