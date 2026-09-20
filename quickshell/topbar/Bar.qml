import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: barRoot
    property var colors
    property string clockTime: "00:00"
    property string clockDate: ""

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-bar"

    anchors { top: true; left: true; right: true }
    implicitHeight: expanded ? 190 : 45
    color: "transparent"
    exclusiveZone: 33

    property bool expanded: false

    function calendarDays() {
        var now = new Date()
        var year = now.getFullYear()
        var month = now.getMonth()
        var firstDay = new Date(year, month, 1).getDay()
        var daysInMonth = new Date(year, month + 1, 0).getDate()
        var today = now.getDate()
        var days = []
        for (var i = 0; i < firstDay; i++) days.push({ day: "", today: false })
        for (var d = 1; d <= daysInMonth; d++) days.push({ day: d.toString(), today: d === today })
        return days
    }

    // Pill grows downward from a fixed top anchor — width stays centered
    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6
        width: barRoot.expanded ? 260 : 145
        height: barRoot.expanded ? 170 : 28
        radius: 16
        color: barRoot.colors.bg
        border.color: barRoot.colors.accent
        border.width: 1
        clip: true
        antialiasing: true

        Behavior on width  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: barRoot.expanded = true
            onExited: barRoot.expanded = false
        }

        RowLayout {
            visible: !barRoot.expanded
            anchors.centerIn: parent
            spacing: 6
            Text {
                text: barRoot.clockTime
                color: barRoot.colors.accent
                font.bold: true
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                text: barRoot.clockDate
                color: barRoot.colors.sub
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        ColumnLayout {
            visible: barRoot.expanded
            opacity: barRoot.expanded ? 1 : 0
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Behavior on opacity { NumberAnimation { duration: 150 } }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: barRoot.clockTime
                    color: barRoot.colors.accent
                    font.bold: true
                    font.pixelSize: 22
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.fillWidth: true
                }
                Text {
                    text: barRoot.clockDate
                    color: barRoot.colors.sub
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            GridLayout {
                columns: 7
                columnSpacing: 2
                rowSpacing: 4
                Layout.fillWidth: true

                Repeater {
                    model: ["S","M","T","W","T","F","S"]
                    Text {
                        text: modelData
                        color: barRoot.colors.sub
                        font.pixelSize: 9
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 28
                    }
                }

                Repeater {
                    model: barRoot.calendarDays()
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 22
                        radius: 8
                        color: modelData.today ? barRoot.colors.accent : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            color: modelData.today ? barRoot.colors.bg : barRoot.colors.text
                            font.pixelSize: 10
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: modelData.today
                        }
                    }
                }
            }
        }
    }
}
