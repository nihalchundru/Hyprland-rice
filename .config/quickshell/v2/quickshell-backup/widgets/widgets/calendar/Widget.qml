import QtQuick
import Quickshell
import "../../core"
import "../../components"

Item {
    id: root

    property int cols: 3
    property int rows: 3
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    readonly property int weekStart: (settings.mondayFirst ?? false) ? 1 : 0
    property int monthOffset: 0

    SystemClock { id: clock; precision: SystemClock.Minutes }

    readonly property var today: clock.date
    readonly property var viewFirst: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)
    readonly property int lead: (viewFirst.getDay() - weekStart + 7) % 7

    readonly property real headerH: 28
    readonly property real weekdayH: 20
    readonly property real cellW: width / 7
    readonly property real rowH: Math.min(cellW, (height - headerH - weekdayH) / 6)

    readonly property var initials: ["S", "M", "T", "W", "T", "F", "S"]

    component Nav: Item {
        id: nav
        property string glyph
        signal clicked()
        width: 24
        height: 24

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Theme.cardAlt
            opacity: ma.containsMouse ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
        Txt {
            anchors.centerIn: parent
            text: nav.glyph
            color: Theme.onSurfaceDim
            font.pixelSize: 16
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: nav.clicked()
        }
    }

    Column {
        anchors.fill: parent

        // header
        Item {
            width: parent.width
            height: root.headerH

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Txt {
                    text: Qt.formatDate(root.viewFirst, "MMMM")
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.monthOffset = 0
                    }
                }
                Txt {
                    text: root.viewFirst.getFullYear()
                    color: Theme.onSurfaceDim
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Nav { glyph: "‹"; onClicked: root.monthOffset-- }
                Nav { glyph: "›"; onClicked: root.monthOffset++ }
            }
        }

        // weekday initials
        Row {
            width: parent.width
            height: root.weekdayH
            Repeater {
                model: 7
                Item {
                    required property int index
                    width: root.cellW
                    height: root.weekdayH
                    Txt {
                        anchors.centerIn: parent
                        text: root.initials[(index + root.weekStart) % 7]
                        color: Theme.onSurfaceDim
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                    }
                }
            }
        }

        // 6 weeks x 7 days
        Grid {
            columns: 7
            Repeater {
                model: 42

                Item {
                    id: day
                    required property int index

                    readonly property var d: new Date(root.viewFirst.getFullYear(),
                                                      root.viewFirst.getMonth(),
                                                      index - root.lead + 1)
                    readonly property bool inMonth: d.getMonth() === root.viewFirst.getMonth()
                    readonly property bool isToday:
                        d.getFullYear() === root.today.getFullYear()
                        && d.getMonth() === root.today.getMonth()
                        && d.getDate() === root.today.getDate()

                    width: root.cellW
                    height: root.rowH

                    Rectangle {
                        visible: day.isToday
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) - 2
                        height: width
                        radius: width * 0.38
                        color: root.accent
                    }
                    Txt {
                        anchors.centerIn: parent
                        text: day.d.getDate()
                        font.pixelSize: Math.max(9, root.rowH * 0.4)
                        font.weight: day.isToday ? Font.Bold : Font.Normal
                        color: day.isToday ? Theme.onAccent
                             : day.inMonth ? Theme.onSurface
                             : Qt.alpha(Theme.onSurfaceDim, 0.45)
                    }
                }
            }
        }
    }
}