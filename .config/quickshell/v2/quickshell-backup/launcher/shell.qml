import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    id: root
    property string font: "JetBrainsMono Nerd Font"

    // Keep alive
    PanelWindow {
        visible: false
        WlrLayershell.namespace: "qs-launcher-daemon"
        width: 1; height: 1
    }

    // Colors from colors.json
    property var colors: ({
        bg: "#1E1E2E", surface: "#313244", surface2: "#45475A",
        text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7",
        accent2: "#89B4FA", green: "#A6E3A1", red: "#F38BA8"
    })

    Process {
        id: colorReader
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.colors = JSON.parse(this.text) } catch(e) {}
            }
        }
        running: true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: colorReader.running = true }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcherPanel.visible = !launcherPanel.visible
            if (launcherPanel.visible) {
                searchInput.text = ""
                selectedIndex = 0
                searchInput.forceActiveFocus()
            }
        }
    }

    property int selectedIndex: 0

    ScriptModel {
        id: filteredApps
        objectProp: "id"
        values: {
            const all = [...DesktopEntries.applications.values]
            const q = searchInput.text.trim().toLowerCase()
            if (q === "") return all.sort((a, b) => a.name.localeCompare(b.name))
            return all.filter(d =>
                (d.name && d.name.toLowerCase().includes(q)) ||
                (d.genericName && d.genericName.toLowerCase().includes(q)) ||
                (d.keywords && d.keywords.some(k => k.toLowerCase().includes(q))) ||
                (d.categories && d.categories.some(c => c.toLowerCase().includes(q)))
            ).sort((a, b) => {
                const an = a.name.toLowerCase()
                const bn = b.name.toLowerCase()
                const aS = an.startsWith(q)
                const bS = bn.startsWith(q)
                if (aS && !bS) return -1
                if (!aS && bS) return 1
                return an.localeCompare(bn)
            })
        }
    }

    function launchApp(entry) {
        entry.execute()
        launcherPanel.visible = false
    }

    PanelWindow {
        id: launcherPanel
        visible: false
        focusable: true
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qs-launcher"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }

        MouseArea {
            anchors.fill: parent
            onClicked: launcherPanel.visible = false
            Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0,0.55) }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 580; height: 480; radius: 16
            color: root.colors.bg
            border.color: root.colors.accent; border.width: 1
            Behavior on color        { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea { anchors.fill: parent; onClicked: event => event.accepted = true }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12

                // Header
                Text {
                    text: "  Applications"
                    color: root.colors.accent
                    font.pixelSize: 14; font.family: root.font; font.bold: true
                }

                // Search bar
                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 10
                    color: root.colors.surface
                    border.color: searchInput.activeFocus ? root.colors.accent : root.colors.surface2
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10

                        Text {
                            text: ""
                            color: root.colors.sub
                            font.pixelSize: 16; font.family: root.font
                            Layout.alignment: Qt.AlignVCenter
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                            color: root.colors.text
                            font.pixelSize: 15; font.family: root.font
                            clip: true; focus: true

                            Text {
                                anchors.fill: parent
                                text: "Type to search..."
                                color: root.colors.sub; font: parent.font
                                visible: !parent.text && !parent.activeFocus
                                verticalAlignment: Text.AlignVCenter
                            }

                            onTextChanged: root.selectedIndex = 0
                            Keys.onEscapePressed: launcherPanel.visible = false
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Down) {
                                    event.accepted = true
                                    root.selectedIndex = Math.min(root.selectedIndex + 1, resultsList.count - 1)
                                    resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else if (event.key === Qt.Key_Up) {
                                    event.accepted = true
                                    root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                                    resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    event.accepted = true
                                    const entry = filteredApps.values[root.selectedIndex]
                                    if (entry) root.launchApp(entry)
                                } else if (event.key === Qt.Key_Tab) {
                                    event.accepted = true
                                    root.selectedIndex = Math.min(root.selectedIndex + 1, resultsList.count - 1)
                                    resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                }
                            }
                        }
                    }
                }

                // Count
                Text {
                    text: resultsList.count + " application" + (resultsList.count !== 1 ? "s" : "")
                    color: root.colors.sub; font.pixelSize: 11; font.family: root.font
                }

                // App list
                ListView {
                    id: resultsList
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: filteredApps; clip: true; spacing: 2
                    boundsBehavior: Flickable.StopAtBounds
                    currentIndex: root.selectedIndex
                    highlightMoveDuration: 150; highlightMoveVelocity: -1

                    highlight: Rectangle {
                        radius: 8; color: root.colors.surface2
                        visible: root.selectedIndex >= 0
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Rectangle {
                            width: 3; height: 24; radius: 2
                            color: root.colors.accent
                            anchors.left: parent.left; anchors.leftMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    delegate: Rectangle {
                        id: del
                        required property var modelData; required property int index
                        width: resultsList.width; height: 44; radius: 8
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 12

                            Item {
                                width: 28; height: 28; Layout.alignment: Qt.AlignVCenter
                                IconImage {
                                    anchors.fill: parent
                                    source: Quickshell.iconPath(del.modelData.icon ?? "", true)
                                    visible: (del.modelData.icon ?? "") !== ""
                                }
                                Text {
                                    anchors.centerIn: parent; text: ""
                                    color: root.colors.accent; font.pixelSize: 20; font.family: root.font
                                    visible: (del.modelData.icon ?? "") === ""
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 1
                                Text {
                                    text: del.modelData.name ?? ""
                                    color: root.selectedIndex === del.index ? root.colors.text : root.colors.sub
                                    font.pixelSize: 13; font.family: root.font
                                    font.bold: root.selectedIndex === del.index
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                                Text {
                                    text: del.modelData.genericName ?? del.modelData.comment ?? ""
                                    color: root.colors.sub; font.pixelSize: 11; font.family: root.font
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                    visible: text !== ""
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root.launchApp(del.modelData)
                            onPositionChanged: root.selectedIndex = del.index
                        }
                    }

                    Text {
                        anchors.centerIn: parent; text: "  No applications found"
                        color: root.colors.sub; font.pixelSize: 14; font.family: root.font
                        visible: resultsList.count === 0 && searchInput.text !== ""
                    }
                }

                // Footer
                RowLayout {
                    Layout.fillWidth: true; spacing: 16
                    Repeater {
                        model: [{ key: "↑↓", label: "navigate" }, { key: "⏎", label: "launch" }, { key: "esc", label: "close" }]
                        Row { spacing: 4
                            Rectangle { width: fl.width + 8; height: 18; radius: 4; color: root.colors.surface
                                Text { id: fl; anchors.centerIn: parent; text: modelData.key; color: root.colors.sub; font.pixelSize: 10; font.family: root.font }
                            }
                            Text { text: modelData.label; color: root.colors.sub; font.pixelSize: 10; font.family: root.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
