import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: launchRoot
    property var colors
    property bool open: false
    property var apps: []
    property string searchText: ""
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    function toggle() {
        open = !open
        if (open) {
            searchText = ""
            searchBox.text = ""
            listProc.running = true
            searchBox.forceActiveFocus()
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-launcher"

    anchors { top: true; left: true; right: true }
    implicitHeight: 440
    color: "transparent"
    exclusiveZone: -1
    visible: open

    Process {
        id: listProc
        command: ["bash", `${Quickshell.env("HOME")}/.config/hypr/scripts/list-apps.sh`]
        stdout: StdioCollector {
            onStreamFinished: {
                try { launchRoot.apps = JSON.parse(this.text) }
                catch(e) { launchRoot.apps = [] }
            }
        }
    }

    Process { id: launchProc }
    function launchApp(execCmd) {
        launchProc.command = ["bash", "-c", execCmd + " &"]
        launchProc.running = true
        launchRoot.open = false
    }

    property var filteredApps: {
        if (searchText === "") return apps
        var s = searchText.toLowerCase()
        return apps.filter(a => a.name.toLowerCase().includes(s))
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6
        width: launchRoot.open ? 380 : 130
        height: launchRoot.open ? 428 : 28
        radius: 16
        color: launchRoot.colors.bg
        border.color: launchRoot.colors.accent
        border.width: 1
        clip: true
        antialiasing: true

        Behavior on width  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 8
            anchors.margins: 14
            spacing: 8
            opacity: launchRoot.open ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 150 } }

            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 12
                color: launchRoot.colors.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    Text { text: "󰍉"; color: launchRoot.colors.accent; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                    TextField {
                        id: searchBox
                        Layout.fillWidth: true
                        placeholderText: "Search apps..."
                        color: launchRoot.colors.text
                        placeholderTextColor: launchRoot.colors.sub
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        background: Item {}
                        onTextChanged: launchRoot.searchText = text
                        Keys.onReturnPressed: {
                            if (launchRoot.filteredApps.length > 0)
                                launchRoot.launchApp(launchRoot.filteredApps[0].exec)
                        }
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: launchRoot.filteredApps
                clip: true
                spacing: 2

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 48
                    radius: 10
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 10

                        Rectangle {
                            width: 34; height: 34
                            radius: 17
                            color: launchRoot.colors.surface

                            Image {
                                anchors.centerIn: parent
                                width: 22; height: 22
                                source: modelData.icon ? "file://" + modelData.icon : ""
                                fillMode: Image.PreserveAspectFit
                                visible: modelData.icon !== ""
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: modelData.icon === ""
                                text: modelData.name.charAt(0).toUpperCase()
                                color: launchRoot.colors.accent
                                font.pixelSize: 14
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        Text {
                            text: modelData.name
                            color: launchRoot.colors.text
                            font.pixelSize: 13
                            font.family: "JetBrainsMono Nerd Font"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: launchRoot.launchApp(modelData.exec)
                        onEntered: parent.color = launchRoot.colors.surface
                        onExited: parent.color = "transparent"
                    }

                    Behavior on color { ColorAnimation { duration: 100 } }
                }
            }
        }
    }
}
