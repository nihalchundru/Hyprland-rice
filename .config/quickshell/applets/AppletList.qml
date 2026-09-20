import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: appletWindow

    property string title: "Applet"
    property string icon: ""
    property var options: []
    property string current: ""
    property int selectedIndex: 0
    signal optionSelected(string value)

    visible: false
    focusable: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "qs-applet"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    // Colors
    property var colors: ({
        bg: "#1E1E2E", surface: "#313244", surface2: "#45475A",
        text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7",
        accent2: "#89B4FA", green: "#A6E3A1"
    })

    Process {
        id: cr
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { appletWindow.colors = JSON.parse(this.text) } catch(e) {}
            }
        }
        running: true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: cr.running = true }

    function open() {
        selectedIndex = 0
        // Pre-select current option
        for (var i = 0; i < options.length; i++) {
            if (options[i].value === current) { selectedIndex = i; break }
        }
        visible = true
    }

    function close() { visible = false }

    Keys.onEscapePressed: close()
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Down) {
            event.accepted = true
            selectedIndex = Math.min(selectedIndex + 1, options.length - 1)
            listView.positionViewAtIndex(selectedIndex, ListView.Contain)
        } else if (event.key === Qt.Key_Up) {
            event.accepted = true
            selectedIndex = Math.max(selectedIndex - 1, 0)
            listView.positionViewAtIndex(selectedIndex, ListView.Contain)
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true
            if (selectedIndex >= 0 && selectedIndex < options.length) {
                optionSelected(options[selectedIndex].value)
                close()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: appletWindow.close()
        Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0,0.55) }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 480
        height: Math.min(72 + options.length * 48 + 60, 560)
        radius: 16
        color: appletWindow.colors.bg
        border.color: appletWindow.colors.accent
        border.width: 1
        Behavior on color        { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        MouseArea { anchors.fill: parent; onClicked: event => event.accepted = true }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: appletWindow.icon + "  " + appletWindow.title
                    color: appletWindow.colors.accent
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: closeHov.containsMouse ? appletWindow.colors.surface : "transparent"
                    Text { anchors.centerIn: parent; text: "✕"; color: appletWindow.colors.sub; font.pixelSize: 12 }
                    MouseArea { id: closeHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: appletWindow.close() }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: appletWindow.colors.surface }

            // List
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: appletWindow.options
                clip: true; spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: appletWindow.selectedIndex
                highlightMoveDuration: 150; highlightMoveVelocity: -1

                highlight: Rectangle {
                    radius: 8; color: appletWindow.colors.surface2
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Rectangle {
                        width: 3; height: 24; radius: 2
                        color: appletWindow.colors.accent
                        anchors.left: parent.left; anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                delegate: Rectangle {
                    id: del
                    required property var modelData
                    required property int index
                    width: listView.width; height: 44; radius: 8
                    color: hov.containsMouse && appletWindow.selectedIndex !== index
                        ? appletWindow.colors.surface : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10

                        // Option icon if provided
                        Text {
                            text: del.modelData.icon || ""
                            color: appletWindow.selectedIndex === del.index
                                ? appletWindow.colors.accent : appletWindow.colors.sub
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                            visible: (del.modelData.icon || "") !== ""
                            Layout.alignment: Qt.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 1
                            Text {
                                text: del.modelData.label || del.modelData.value
                                color: appletWindow.selectedIndex === del.index
                                    ? appletWindow.colors.text : appletWindow.colors.sub
                                font.pixelSize: 13
                                font.bold: appletWindow.selectedIndex === del.index
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            Text {
                                text: del.modelData.desc || ""
                                color: appletWindow.colors.sub
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                                visible: text !== ""
                            }
                        }

                        // Checkmark for current
                        Text {
                            text: ""
                            color: appletWindow.colors.green
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            visible: del.modelData.value === appletWindow.current
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: hov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { appletWindow.optionSelected(del.modelData.value); appletWindow.close() }
                        onEntered: appletWindow.selectedIndex = del.index
                    }
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true; spacing: 16
                Repeater {
                    model: [{ key: "↑↓", label: "navigate" }, { key: "⏎", label: "select" }, { key: "esc", label: "close" }]
                    Row { spacing: 4
                        Rectangle { width: fl.width + 8; height: 18; radius: 4; color: appletWindow.colors.surface
                            Text { id: fl; anchors.centerIn: parent; text: modelData.key; color: appletWindow.colors.sub; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font" }
                        }
                        Text { text: modelData.label; color: appletWindow.colors.sub; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
