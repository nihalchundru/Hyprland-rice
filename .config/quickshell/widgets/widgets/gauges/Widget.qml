import QtQuick
import "../../core"
import "../../components"
import "../../services"

Item {
    id: root

    property int cols: 3
    property int rows: 2
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    Component.onCompleted: Stats.users++
    Component.onDestruction: Stats.users--

    readonly property bool showLabels: (settings.showLabels ?? true) && rows >= 2
    readonly property var picks: [settings.ring1 ?? "cpu", settings.ring2 ?? "ram", settings.ring3 ?? "disk"]
    readonly property var colors: [root.accent, root.accent2, root.accent3]
    readonly property real labelH: showLabels ? 22 : 0

    function valueOf(m) { return m === "ram" ? Stats.ram : m === "disk" ? Stats.disk : Stats.cpu; }
    function nameOf(m)  { return m === "ram" ? "RAM" : m === "disk" ? "DISK" : "CPU"; }

    Row {
        anchors.fill: parent

        Repeater {
            model: 3

            delegate: Item {
                id: slot
                required property int index

                width: root.width / 3
                height: root.height
                readonly property real d: Math.max(0, Math.min(width - 10, root.height - root.labelH, 120))

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Ring {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: slot.d
                        height: slot.d
                        value: root.valueOf(root.picks[slot.index])
                        color: root.colors[slot.index]
                        trackColor: Theme.track

                        Txt {
                            anchors.centerIn: parent
                            text: Math.round(root.valueOf(root.picks[slot.index]) * 100) + "%"
                            font.pixelSize: Math.max(9, slot.d * 0.24)
                            font.weight: Font.Bold
                        }
                    }

                    Txt {
                        visible: root.showLabels
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.nameOf(root.picks[slot.index])
                        color: Theme.onSurfaceDim
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                    }
                }
            }
        }
    }
}