import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    IpcHandler {
        target: "overview"
        function toggle() {
            if (overviewWindow.visible) {
                overviewWindow.visible = false
            } else {
                // Capture workspaces first then show
                captureProc.running = true
            }
        }
        function close() { overviewWindow.visible = false }
    }

    // ── Colors ───────────────────────────────────────────────────────────────
    property var colors: ({
        bg: "#1E1E2E", surface: "#313244", surface2: "#45475A",
        text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7",
        accent2: "#89B4FA", red: "#F38BA8"
    })

    Process {
        id: colorReader
        command: ["cat", `${Quickshell.env("HOME")}/.config/quickshell/topbar/colors.json`]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.colors = JSON.parse(this.text) } catch(e) {}
            }
        }
        running: true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: colorReader.running = true }

    // ── Workspace data ────────────────────────────────────────────────────────
    property int activeWorkspace: 1
    property var workspaceWindows: ({})

    Process {
        id: captureProc
        command: ["bash", `${Quickshell.env("HOME")}/.config/hypr/scripts/capture-workspaces.sh`]
        stdout: StdioCollector {
            onStreamFinished: {
                wsInfoProc.running = true
            }
        }
    }

    Process {
        id: wsInfoProc
        command: ["bash", "-c",
            "hyprctl activeworkspace -j | python3 -c \"import json,sys; print(json.load(sys.stdin)['id'])\""]
        stdout: StdioCollector {
            onStreamFinished: {
                root.activeWorkspace = parseInt(this.text.trim()) || 1
                windowInfoProc.running = true
            }
        }
    }

    Process {
        id: windowInfoProc
        command: ["bash", "-c", `hyprctl clients -j | python3 -c "
import json,sys
clients = json.load(sys.stdin)
result = {}
for c in clients:
    ws = str(c.get('workspace', {}).get('id', 0))
    if ws not in result:
        result[ws] = []
    title = c.get('title', '')[:28]
    cls = c.get('class', '')
    result[ws].append({'title': title, 'class': cls})
print(json.dumps(result))
"`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspaceWindows = JSON.parse(this.text)
                } catch(e) {
                    root.workspaceWindows = {}
                }
                // Reload all images and show
                imageReloader.running = true
                overviewWindow.visible = true
            }
        }
    }

    // Force QML to reload images by changing a counter
    property int imageVersion: 0
    Process {
        id: imageReloader
        command: ["bash", "-c", "echo done"]
        stdout: StdioCollector {
            onStreamFinished: { root.imageVersion++ }
        }
    }

    // ── Overview Window ───────────────────────────────────────────────────────
    PanelWindow {
        id: overviewWindow
        visible: false
        color: Qt.rgba(40/255, 44/255, 52/255, 0.7)

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-overview"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors { top: true; left: true; right: true }
        implicitHeight: 800

        // Keyboard close
        Keys.onEscapePressed: overviewWindow.visible = false

        // Click outside cards to close
        MouseArea {
            anchors.fill: parent
            onClicked: overviewWindow.visible = false
            z: 0
        }

        ColumnLayout {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 500  // Adjust this freely to move it down from the top edge
            spacing: 24
            z:  1
       }
            // ── Title ─────────────────────────────────────────────────────────
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "  Workspace Overview"
                color: root.colors.accent
                font.pixelSize: 22
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }

            // ── Workspace grid ────────────────────────────────────────────────
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Repeater {
                    model: [1, 2, 3, 4, 5]

                    Rectangle {
                        id: wsCard
                        property int wsId: modelData
                        property bool isActive: wsId === root.activeWorkspace
                        property var windows: root.workspaceWindows[wsId.toString()] || []

                        width:  320
                        height: 200
                        radius: 16
                        color:  "transparent"
                        border.color: isActive ? root.colors.accent : Qt.rgba(1,1,1,0.15)
                        border.width: isActive ? 3 : 1
                        clip: true
                        antialiasing: true

                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                        // ── Screenshot preview ────────────────────────────────
                        Image {
                            id: wsThumb
                            anchors.fill: parent
                            // Force reload by appending version to URL
                            source: "file:///tmp/hyde-overview/ws-" + wsCard.wsId +
                                    ".png?v=" + root.imageVersion
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            mipmap: true
                            asynchronous: false
                            cache: false   // always reload fresh

                            // Fallback if no screenshot
                            Rectangle {
                                anchors.fill: parent
                                color: root.colors.surface
                                visible: wsThumb.status !== Image.Ready
                                Text {
                                    anchors.centerIn: parent
                                    text: wsCard.wsId.toString()
                                    color: root.colors.sub
                                    font.pixelSize: 48
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                        }

                        // ── Dark overlay for text readability ─────────────────
                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(0, 0, 0, 0.35)
                        }

                        // ── Active indicator ──────────────────────────────────
                        Rectangle {
                            visible: wsCard.isActive
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            width: 10; height: 10
                            radius: 5
                            color: root.colors.accent
                        }

                        // ── Workspace number ──────────────────────────────────
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 8
                            width: 28; height: 28
                            radius: 14
                            color: wsCard.isActive
                                ? root.colors.accent
                                : Qt.rgba(0, 0, 0, 0.5)

                            Text {
                                anchors.centerIn: parent
                                text: wsCard.wsId.toString()
                                color: wsCard.isActive
                                    ? root.colors.bg
                                    : root.colors.text
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        // ── Window list overlay ───────────────────────────────
                        ColumnLayout {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 8
                            spacing: 2

                            Repeater {
                                model: wsCard.windows.slice(0, 3)
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 20
                                    radius: 6
                                    color: Qt.rgba(0, 0, 0, 0.55)

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 6
                                        text: modelData.title
                                        color: "#FFFFFF"
                                        font.pixelSize: 10
                                        font.family: "JetBrainsMono Nerd Font"
                                        elide: Text.ElideRight
                                        width: parent.width - 12
                                    }
                                }
                            }

                            // Show +N more if more than 3 windows
                            Text {
                                visible: wsCard.windows.length > 3
                                text: "+" + (wsCard.windows.length - 3) + " more"
                                color: Qt.rgba(1, 1, 1, 0.6)
                                font.pixelSize: 9
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        // ── Click to switch workspace ─────────────────────────
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                switchProc.command = [
                                    "hyprctl", "dispatch",
                                    "workspace", wsCard.wsId.toString()
                                ]
                                switchProc.running = true
                                overviewWindow.visible = false
                            }

                            onEntered: wsCard.scale = 1.04
                            onExited:  wsCard.scale = 1.0
                        }
                    }
                }
            }

            // ── Hint ──────────────────────────────────────────────────────────
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Click a workspace to switch  •  ESC to close"
                color: Qt.rgba(1, 1, 1, 0.4)
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        Process { id: switchProc }
    }

