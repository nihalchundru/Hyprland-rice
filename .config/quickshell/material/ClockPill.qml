
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: pill
    width: barRoot.clockExpanded ? 620 : 180 
    height: barRoot.clockExpanded ? 215 : 38
    radius: barRoot.clockExpanded ? 24 : height / 2
    color: barRoot.colors.bg2
    border.color: barRoot.colors.surface2
    border.width: 1
    clip: true
    antialiasing: true

    Behavior on width  { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        onEntered: if (!barRoot.notificationActive) barRoot.clockExpanded = true
        onExited: barRoot.clockExpanded = false
    }

    // COLLAPSED VIEW
    Item {
        id: collapsedContainer
        anchors.fill: parent
        visible: !barRoot.clockExpanded
        opacity: barRoot.clockExpanded ? 0 : 1

        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 16; spacing: 10
            Item {
                id: smallBumpyIcon; Layout.preferredWidth: 26; Layout.preferredHeight: 26; Layout.alignment: Qt.AlignVCenter
                Repeater { model: 8; Rectangle { anchors.centerIn: parent; width: 9; height: 24; radius: width / 2; color: barRoot.colors.accent; rotation: (index * 45) } }
                Rectangle { anchors.centerIn: parent; width: 18; height: 18; radius: 9; color: barRoot.colors.accent }
            }
            Text { text: barRoot.clockTime; color: barRoot.colors.text; font.bold: true; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; Layout.alignment: Qt.AlignVCenter }
            Text { text: barRoot.clockDate; color: barRoot.colors.sub; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; Layout.alignment: Qt.AlignVCenter; Layout.fillWidth: true }
        }
    }

    // EXPANDED THREE-PANEL HOVER VIEW
    RowLayout {
        visible: barRoot.clockExpanded; opacity: barRoot.clockExpanded ? 1 : 0
        anchors.fill: parent; anchors.margins: 16; spacing: 18
        Behavior on opacity { NumberAnimation { duration: 180 } }

        ColumnLayout {
            Layout.preferredWidth: 190; Layout.fillHeight: true; Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter; spacing: 4
            GridLayout {
                columns: 7; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true
                Repeater { model: ["S","M","T","W","T","F","S"]; Text { text: modelData; color: barRoot.colors.accent; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignHCenter; Layout.preferredWidth: 24 } }
                Repeater {
                    model: barRoot.calendarDays()
                    Rectangle {
                        Layout.preferredWidth: 24; Layout.preferredHeight: 22; radius: modelData.today ? 10 : 5
                        color: modelData.today ? barRoot.colors.accent : (modelData.day === "" ? "transparent" : barRoot.colors.surface)
                        Text { anchors.centerIn: parent; text: modelData.day; color: modelData.today ? barRoot.colors.bg : barRoot.colors.text; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; font.bold: modelData.today }
                    }
                }
            }
        }

        Rectangle { Layout.fillHeight: true; width: 1; color: barRoot.colors.surface2 }
        WeatherSection {}
        Rectangle { Layout.fillHeight: true; width: 1; color: barRoot.colors.surface2 }
        TimerSection {}
    }
}
