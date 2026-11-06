import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// ============================================================================
// WallpaperSwitcher.qml — qs-wallpaper
//
// Same carousel mechanics as ThemeSwitcher.qml (keyboard nav, wheel,
// peeking neighbor cards, counter, Enter-to-apply), applied to wallpapers.
// Listing/apply logic follows your original reference file: theme-aware
// source list (iris/matugen see the full wallpaper library, static themes
// see only their own folder) and a theme-specific apply script.
// ============================================================================

PanelWindow {
    id: wallRoot

    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8",
        theme: "catppuccin"
    })
    function c(key) {
        return (wallRoot.colors && wallRoot.colors[key]) ? wallRoot.colors[key] : "#888888"
    }

    FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"
        watchChanges: true
        onLoaded: {
            try { wallRoot.colors = JSON.parse(text()) }
            catch (e) { console.log("WallpaperSwitcher: failed to parse colors.json, using fallback:", e) }
        }
        onLoadFailed: (error) => console.log("WallpaperSwitcher: colors.json load failed, using fallback:", error)
        onFileChanged: reload()
    }

    property bool open: false
    property var wallpapers: []       // [{ name, path }]
    property string selectedPath: ""
    property int highlightIndex: 0

    function toggle() {
        open = !open
        if (open) {
            listProc.running = true
            currentWallProc.running = true
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-wallpaper"
    WlrLayershell.keyboardFocus: wallRoot.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1
    height: 260
    visible: open

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: wallRoot.open = false
    }

    // ------------------------------------------------------------------
    // Listing — theme-aware, same rule as your reference file: iris/matugen
    // see the whole wallpaper library, static themes see only their own folder.
    // ------------------------------------------------------------------
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
                try { wallRoot.wallpapers = JSON.parse(text) }
                catch (e) { wallRoot.wallpapers = [] }
                // Highlight whichever wallpaper is actually active, once the list is in
                var idx = wallRoot.wallpapers.findIndex(function(w) { return w.path === wallRoot.selectedPath })
                wallRoot.highlightIndex = idx >= 0 ? idx : 0
                Qt.callLater(function() { card.forceActiveFocus() })
            }
        }
    }

    Process {
        id: currentWallProc
        command: ["bash", "-c",
            "grep -oP '(?<=url\\(\")[^\"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1 || echo ''"]
        stdout: StdioCollector { onStreamFinished: wallRoot.selectedPath = text.trim() }
    }

    Process { id: applyProc }
    function applyWallpaper(path) {
        previewTimer.stop()
        wallRoot.previewActive = false
        wallRoot.selectedPath = path
        var theme = wallRoot.c("theme")
        var script = "set-wallpaper.sh"
        if (theme === "iris") script = "iris-apply.sh"
        else if (theme === "matugen") script = "matugen-apply.sh"
        applyProc.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/" + script, path]
        applyProc.running = true
        closeTimer.start() // small delay so the selection is visible before closing
    }
    Timer { id: closeTimer; interval: 350; onTriggered: wallRoot.open = false }

    // ------------------------------------------------------------------
    // Hover preview — lightweight background-only swap (NOT the full
    // per-theme apply script) so browsing over iris/matugen wallpapers
    // doesn't trigger expensive live recoloring on every hover. Debounced
    // with a short dwell timer so it doesn't fire on every mouse pass-through,
    // and reverts back to the actually-selected wallpaper if you hover away
    // without clicking/Enter-ing to commit.
    //
    // ASSUMPTION: set-wallpaper.sh only swaps the background image without
    // triggering a recolor — this is inferred from your original reference
    // file's own fallback logic (only iris/matugen call the recolor-aware
    // scripts, everything else calls this one), not independently verified.
    // If set-wallpaper.sh actually does more than that on your system,
    // hovering will do more than intended — tell me and I'll adjust.
    // ------------------------------------------------------------------
    property string hoveredPath: ""
    property bool previewActive: false

    Process { id: previewProc }
    function setPreview(path) {
        previewProc.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/set-wallpaper.sh", path]
        previewProc.running = true
        wallRoot.previewActive = true
    }
    function revertPreview() {
        if (wallRoot.previewActive) {
            previewProc.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/set-wallpaper.sh", wallRoot.selectedPath]
            previewProc.running = true
            wallRoot.previewActive = false
        }
    }
    Timer {
        id: previewTimer
        interval: 300 // dwell time before a hover actually triggers a preview
        repeat: false
        onTriggered: if (wallRoot.hoveredPath.length > 0) wallRoot.setPreview(wallRoot.hoveredPath)
    }

    onOpenChanged: if (!open) wallRoot.revertPreview() // closing without committing reverts

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8 // floating pill, detached from the bezel
        width: 900
        height: wallRoot.open ? 230 : 0
        color: "#000000"
        radius: 26 // full pill, all corners rounded
        clip: true
        antialiasing: true

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: {} }

        // Arrow-key navigation is treated as "hover" too, same as the
        // mouse — moving to an item with the keyboard triggers the same
        // live preview as hovering it, not just the outline.
        function navigateTo(newIndex) {
            wallRoot.highlightIndex = newIndex
            var w = wallRoot.wallpapers[newIndex]
            if (w) {
                wallRoot.hoveredPath = w.path
                previewTimer.restart()
            }
        }
        Keys.onLeftPressed:  card.navigateTo(Math.max(0, wallRoot.highlightIndex - 1))
        Keys.onRightPressed: card.navigateTo(Math.min(wallRoot.wallpapers.length - 1, wallRoot.highlightIndex + 1))
        Keys.onReturnPressed: {
            var w = wallRoot.wallpapers[wallRoot.highlightIndex]
            if (w) wallRoot.applyWallpaper(w.path)
        }
        Keys.onEnterPressed: {
            var w = wallRoot.wallpapers[wallRoot.highlightIndex]
            if (w) wallRoot.applyWallpaper(w.path)
        }
        focus: wallRoot.open

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            // Header — "Wallpaper" left, current theme name right (matches reference)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Wallpaper"
                    color: wallRoot.c("text")
                    font.pixelSize: 15
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: wallRoot.c("theme")
                    color: wallRoot.c("sub")
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Carousel
            ListView {
                id: carousel
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                model: wallRoot.wallpapers
                spacing: 14
                clip: false // lets neighbor thumbnails peek past the edges
                currentIndex: wallRoot.highlightIndex
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: (width - 190) / 2
                preferredHighlightEnd: (width - 190) / 2
                highlightMoveDuration: 200

                WheelHandler {
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                            wallRoot.highlightIndex = Math.min(wallRoot.wallpapers.length - 1, wallRoot.highlightIndex + 1)
                        else
                            wallRoot.highlightIndex = Math.max(0, wallRoot.highlightIndex - 1)
                    }
                }

                delegate: Item {
                    width: 190
                    height: carousel.height

                    Rectangle {
                        id: thumbCard
                        anchors.centerIn: parent
                        // "selected" now means EITHER keyboard-navigated to
                        // OR mouse-hovered — both drive the same
                        // wallRoot.highlightIndex, so there's exactly one
                        // concept of "current item" instead of two
                        // disconnected ones (which was why hovering showed
                        // no outline before: hover never touched this).
                        property bool selected: index === wallRoot.highlightIndex
                        width: 180
                        height: 110
                        radius: 16
                        color: wallRoot.c("surface")
                        antialiasing: true
                        // NOTE: no `clip: true` needed here anymore — the
                        // Image below is masked to the rounded shape
                        // directly instead, which is also what makes the
                        // corners ACTUALLY round (plain `clip: true` only
                        // clips to the bounding box, not the curve — same
                        // bug we hit with the media panel's album art).

                        Item {
                            id: thumbMask
                            anchors.fill: parent
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle { width: thumbMask.width; height: thumbMask.height; radius: 16 }
                            }

                            Image {
                                id: thumb
                                anchors.fill: parent
                                source: "file://" + modelData.path
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                mipmap: true
                                asynchronous: true
                                cache: true

                                Rectangle {
                                    anchors.fill: parent
                                    visible: thumb.status !== Image.Ready
                                    color: wallRoot.c("surface")
                                    Text {
                                        anchors.centerIn: parent
                                        text: "\u26f6" // standard picture-frame-ish glyph, safe
                                        color: wallRoot.c("sub")
                                        font.pixelSize: 22
                                    }
                                }
                            }
                        }

                        // Border-only overlay, drawn AFTER (on top of) the
                        // image — this is the actual fix for the missing
                        // outline. thumbCard's own `border.color` was being
                        // painted first, then fully covered by the
                        // full-bleed Image on top of it.
                        Rectangle {
                            anchors.fill: parent
                            radius: 16
                            color: "transparent"
                            border.color: thumbCard.selected ? "#5eead4" : "transparent"
                            border.width: 2
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wallRoot.highlightIndex = index
                                wallRoot.applyWallpaper(modelData.path)
                            }
                            onEntered: {
                                wallRoot.highlightIndex = index
                                wallRoot.hoveredPath = modelData.path
                                previewTimer.restart()
                            }
                            onExited: {
                                previewTimer.stop()
                                if (wallRoot.hoveredPath === modelData.path) {
                                    wallRoot.revertPreview()
                                    wallRoot.hoveredPath = ""
                                }
                            }
                        }
                    }
                }
            }

            // Footer — filename left, counter + "Enter to apply" right (matches reference)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: wallRoot.wallpapers.length > 0 && wallRoot.wallpapers[wallRoot.highlightIndex]
                        ? wallRoot.wallpapers[wallRoot.highlightIndex].name : ""
                    color: wallRoot.c("sub")
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                }
                Text {
                    text: (wallRoot.wallpapers.length > 0 ? (wallRoot.highlightIndex + 1) : 0) + "/" + wallRoot.wallpapers.length + "  ·  Enter to apply"
                    color: wallRoot.c("sub")
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
    }
}
