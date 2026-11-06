import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root
    property string font: "JetBrainsMono Nerd Font"
    property string searchText: ""
    property string previewPath: ""

    // Read theme colors from colors.json
    property var colors: ({
        bg: "#1E1E2E", surface: "#313244", surface2: "#45475A",
        text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7",
        accent2: "#89B4FA", green: "#A6E3A1", red: "#F38BA8"
    })
    Process {
        id: colorReader
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"]
        stdout: StdioCollector { onStreamFinished: { try { root.colors = JSON.parse(this.text) } catch(e) {} } }
        running: true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: colorReader.running = true }

    IpcHandler {
        target: "wallpaper-picker"
        function toggle(): void {
            wallpaperPanel.visible = !wallpaperPanel.visible
            if (wallpaperPanel.visible) {
                root.searchText = ""; root.previewPath = ""
                searchInput.forceActiveFocus()
                WallpaperService.rescan()
            }
        }
    }

    property var filteredWallpapers: {
        const q = searchText.toLowerCase()
        if (q === "") return WallpaperService.wallpapers
        return WallpaperService.wallpapers.filter(p => p.split("/").pop().toLowerCase().includes(q))
    }

    PanelWindow {
        id: wallpaperPanel
        visible: false; focusable: true; color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qs-wallpaper-picker"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }

        MouseArea {
            anchors.fill: parent; onClicked: wallpaperPanel.visible = false
            Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0,0.55) }
        }

        Rectangle {
            anchors.centerIn: parent; width: 800; height: 580; radius: 16
            color: root.colors.bg
            border.color: root.colors.accent; border.width: 1
            MouseArea { anchors.fill: parent; onClicked: event => event.accepted = true }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "󰸉  Wallpapers"; color: root.colors.accent; font.pixelSize: 14; font.family: root.font; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: root.filteredWallpapers.length + " images"; color: root.colors.sub; font.pixelSize: 11; font.family: root.font }
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: refreshHov.containsMouse ? root.colors.surface : "transparent"
                        Text { anchors.centerIn: parent; text: "󰑐"; color: root.colors.sub; font.pixelSize: 14; font.family: root.font }
                        MouseArea { id: refreshHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: WallpaperService.rescan() }
                    }
                }

                // Search
                Rectangle {
                    Layout.fillWidth: true; height: 36; radius: 8
                    color: root.colors.surface
                    border.color: searchInput.activeFocus ? root.colors.accent : root.colors.surface2; border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8
                        Text { text: ""; color: root.colors.sub; font.pixelSize: 13; font.family: root.font; Layout.alignment: Qt.AlignVCenter }
                        TextInput {
                            id: searchInput; Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                            color: root.colors.text; font.pixelSize: 13; font.family: root.font; clip: true; selectByMouse: true
                            onTextChanged: root.searchText = text
                            Keys.onEscapePressed: {
                                if (root.previewPath !== "") root.previewPath = ""
                                else wallpaperPanel.visible = false
                            }
                        }
                        Text { text: "Search wallpapers..."; color: root.colors.sub; font.pixelSize: 13; font.family: root.font
                            visible: searchInput.text === "" && !searchInput.activeFocus }
                    }
                }

                // Grid
                GridView {
                    id: wallGrid
                    Layout.fillWidth: true; Layout.fillHeight: true
                    cellWidth: Math.floor(width / 4)
                    cellHeight: cellWidth * 0.6 + 8
                    clip: true; boundsBehavior: Flickable.StopAtBounds
                    model: root.filteredWallpapers

                    delegate: Item {
                        required property string modelData; required property int index
                        width: wallGrid.cellWidth; height: wallGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent; anchors.margins: 4; radius: 8
                            color: root.colors.surface
                            border.color: WallpaperService.currentWallpaper === modelData
                                ? root.colors.accent
                                : (imgHov.containsMouse ? root.colors.surface2 : "transparent")
                            border.width: WallpaperService.currentWallpaper === modelData ? 2 : 1
                            clip: true

                            Image {
                                anchors.fill: parent; anchors.margins: 2
                                source: "file://" + modelData
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 240; sourceSize.height: 140
                                asynchronous: true; smooth: true; mipmap: true
                                Rectangle {
                                    anchors.fill: parent; color: root.colors.surface
                                    visible: parent.status !== Image.Ready
                                    Text { anchors.centerIn: parent; text: "󰋩"; color: root.colors.sub; font.pixelSize: 24; font.family: root.font }
                                }
                            }

                            // Label
                            Rectangle {
                                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                                height: 20; color: Qt.rgba(0,0,0,0.6)
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.split("/").slice(-2).join("/")
                                    color: "#ffffff"; font.pixelSize: 9; font.family: root.font
                                    elide: Text.ElideMiddle; width: parent.width - 8; horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // Active dot
                            Rectangle {
                                anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 6
                                width: 20; height: 20; radius: 10; color: root.colors.green
                                visible: WallpaperService.currentWallpaper === modelData
                                Text { anchors.centerIn: parent; text: ""; color: root.colors.bg; font.pixelSize: 12; font.family: root.font }
                            }

                            MouseArea {
                                id: imgHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) root.previewPath = modelData
                                    else { WallpaperService.setWallpaper(modelData); wallpaperPanel.visible = false }
                                }
                            }
                        }
                    }

                    Text { anchors.centerIn: parent; text: "󰋩  No wallpapers found"
                        color: root.colors.sub; font.pixelSize: 13; font.family: root.font
                        horizontalAlignment: Text.AlignHCenter; visible: wallGrid.count === 0 }
                }

                // Footer
                RowLayout {
                    Layout.fillWidth: true; spacing: 16
                    Repeater {
                        model: [{ key: "click", label: "apply" }, { key: "right-click", label: "preview" }, { key: "esc", label: "close" }]
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

        // Preview overlay
        Rectangle {
            anchors.fill: parent; color: Qt.rgba(0,0,0,0.85)
            visible: root.previewPath !== ""
            MouseArea { anchors.fill: parent; onClicked: root.previewPath = "" }
            Image {
                anchors.centerIn: parent; width: parent.width * 0.8; height: parent.height * 0.8
                source: root.previewPath !== "" ? "file://" + root.previewPath : ""
                fillMode: Image.PreserveAspectFit; asynchronous: true
            }
            Rectangle {
                anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 40; width: applyR.width + 32; height: 40; radius: 20; color: root.colors.accent
                Row { id: applyR; anchors.centerIn: parent; spacing: 8
                    Text { text: ""; color: root.colors.bg; font.pixelSize: 14; font.family: root.font; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Apply Wallpaper"; color: root.colors.bg; font.pixelSize: 13; font.family: root.font; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { WallpaperService.setWallpaper(root.previewPath); root.previewPath = ""; wallpaperPanel.visible = false }
                }
            }
        }
    }
}
