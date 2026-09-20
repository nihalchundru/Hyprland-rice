import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: wallRoot
    property var colors
    property bool open: false
    property var wallpapers: []
    property string selectedPath: ""

    function toggle() {
        open = !open
        if (open) listProc.running = true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-wallpaper"

    anchors { top: true; left: true; right: true }
    implicitHeight: open ? 420 : 0
    color: "transparent"
    exclusiveZone: -1
    visible: open

    // Load list of wallpapers
    Process {
        id: listProc
        command: ["bash", "-c",
            "THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin); " +
            "if [ \"$THEME\" = \"iris\" ] || [ \"$THEME\" = \"matugen\" ]; then " +
            "bash ~/.config/hypr/scripts/list-all-wallpapers.sh; " +
            "else bash ~/.config/hypr/scripts/list-wallpapers.sh; fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try { wallRoot.wallpapers = JSON.parse(this.text) }
                catch(e) { wallRoot.wallpapers = [] }
            }
        }
    }

    // Load current wallpaper path for pre-selection
    Process {
        id: currentWallProc
        command: ["bash", "-c",
            "grep -oP '(?<=url\\(\")[^\"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1 || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: { wallRoot.selectedPath = this.text.trim() }
        }
        running: true
    }

    Process { id: applyProc }
    function applyWallpaper(path) {
        wallRoot.selectedPath = path
        var theme = wallRoot.colors.theme || "catppuccin"
        if (theme === "iris") {
            applyProc.command = [
                "bash",
                `${Quickshell.env("HOME")}/.config/hypr/scripts/iris-apply.sh`,
                path
            ]
        } else if (theme === "matugen") {
            applyProc.command = [
                "bash",
                `${Quickshell.env("HOME")}/.config/hypr/scripts/matugen-apply.sh`,
                path
            ]
        } else {
            applyProc.command = [
                "bash",
                `${Quickshell.env("HOME")}/.config/hypr/scripts/set-wallpaper.sh`,
                path
            ]
        }
        applyProc.running = true
        // Small delay so user sees selection before close
        closeTimer.start()
    }

    Timer {
        id: closeTimer
        interval: 350
        onTriggered: wallRoot.open = false
    }

    // ── Main card — grows from pill header ───────────────────────────────────
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6

        // Wide enough for 3 rectangular thumbnails at retina res
        width:  wallRoot.open ? 900 : 130
        height: wallRoot.open ? 408 : 28
        radius: 16
        color:  wallRoot.colors.bg
        border.color: wallRoot.colors.accent
        border.width: 1
        clip: true
        antialiasing: true

        Behavior on width  { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // ── Header label ──────────────────────────────────────────────────────
        RowLayout {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 6
            height: 22
            spacing: 6
            opacity: wallRoot.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }

            Text {
                text: "󰸉  Wallpapers"
                color: wallRoot.colors.accent
                font.bold: true
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }

            Text {
                text: wallRoot.wallpapers.length > 0
                    ? "— " + wallRoot.wallpapers.length + " available"
                    : ""
                color: wallRoot.colors.sub
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        // ── Wallpaper grid ────────────────────────────────────────────────────
        GridView {
            id: grid
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 36
            anchors.margins: 14

            opacity: wallRoot.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 160 } }

            // 3 columns, 16:9 aspect ratio thumbnails
            // At 900px wide, 14px margins each side, 10px spacing:
            // available = 900 - 28 - 20 = 852 / 3 = 284px per cell
            // height = 284 * 9/16 = 160px + label = 185px
            cellWidth:  284
            cellHeight: 186

            model: wallRoot.wallpapers
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Item {
                width:  274
                height: 176

                Rectangle {
                    id: thumbCard
                    anchors.fill: parent
                    anchors.margins: 5
                    radius: 12

                    // Accent border when selected, subtle border otherwise
                    border.color: isSelected
                        ? wallRoot.colors.accent
                        : Qt.rgba(1, 1, 1, 0.08)
                    border.width: isSelected ? 3 : 1

                    color: wallRoot.colors.surface
                    clip: true
                    antialiasing: true

                    property bool isSelected: modelData.path === wallRoot.selectedPath

                    // Scale up slightly when selected
                    scale: isSelected ? 1.03 : 1.0
                    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    Behavior on border.width { NumberAnimation { duration: 180 } }

                    // ── High-res thumbnail ────────────────────────────────────
                    Image {
                        id: thumb
                        anchors.fill: parent
                        anchors.bottomMargin: 28
                        source: "file://" + modelData.path
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true         // crisp downscaling on retina
                        cache: true
                        asynchronous: true   // load without blocking UI
			layer.enabled: true
    			layer.effect: OpacityMask {
        		    maskSource: Rectangle {
                            width:  thumb.width
            	            height: thumb.height
            		    radius: 12
                            }
                        }
                        // Loading placeholder
                        Rectangle {
                            anchors.fill: parent
                            color: wallRoot.colors.surface2
                            visible: thumb.status !== Image.Ready
                            Text {
                                anchors.centerIn: parent
                                text: "󰸉"
                                color: wallRoot.colors.sub
                                font.pixelSize: 24
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }

                    // ── Label bar at bottom ───────────────────────────────────
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height: 28
                        color: thumbCard.isSelected
                            ? Qt.rgba(
                                parseInt(wallRoot.colors.accent.slice(1,3), 16)/255,
                                parseInt(wallRoot.colors.accent.slice(3,5), 16)/255,
                                parseInt(wallRoot.colors.accent.slice(5,7), 16)/255,
                                0.85)
                            : Qt.rgba(0, 0, 0, 0.55)

                        Behavior on color { ColorAnimation { duration: 180 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 4

                            Text {
                                visible: thumbCard.isSelected
                                text: "✓"
                                color: wallRoot.colors.bg
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: thumbCard.isSelected
                                    ? wallRoot.colors.bg
                                    : "#FFFFFF"
                                font.pixelSize: 10
                                font.bold: thumbCard.isSelected
                                font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // ── Click handler ─────────────────────────────────────────
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: wallRoot.applyWallpaper(modelData.path)

                        onEntered: {
                            if (!thumbCard.isSelected)
                                thumbCard.border.color = Qt.rgba(1,1,1,0.2)
                        }
                        onExited: {
                            if (!thumbCard.isSelected)
                                thumbCard.border.color = Qt.rgba(1,1,1,0.08)
                        }
                    }
                }
            }
        }
    }
}
