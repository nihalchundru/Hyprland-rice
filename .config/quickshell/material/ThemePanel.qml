import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: themePanelRoot
    property var colors
    property var palettes: ({})
    property bool open: false
    property var wallpapers: []
    property string selectedPath: ""

    function toggle() { open = !open; if (open) { listProc.running = false; listProc.running = true; currentWallProc.running = false; currentWallProc.running = true; } }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-material-dashboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; left: true; right: true }
    implicitHeight: open ? 500 : 0
    color: "transparent"
    exclusiveZone: -1
    visible: open

    Process { id: applyThemeProc }
    function applyTheme(n) { applyThemeProc.command = ["bash", "-c", "bash ~/.config/hypr/scripts/theme-switch.sh " + n]; applyThemeProc.running = true; themePanelRoot.open = false }

    Process {
        id: listProc
        command: ["bash", "-c", "THEME=\$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin); if [ \"\$THEME\" = \"iris\" ] || [ \"\$THEME\" = \"matugen\" ]; then bash ~/.config/hypr/scripts/list-all-wallpapers.sh; else bash ~/.config/hypr/scripts/list-wallpapers.sh; fi"]
        stdout: StdioCollector { onStreamFinished: { try { themePanelRoot.wallpapers = JSON.parse(this.text) } catch(e) { themePanelRoot.wallpapers = [] } } }
    }

    Process {
        id: currentWallProc
        command: ["bash", "-c", "grep -oP '(?<=url\\(\")[^\"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1 || echo ''"]
        stdout: StdioCollector { onStreamFinished: { themePanelRoot.selectedPath = this.text.trim() } }
    }

    Process { id: applyWallProc }
    function applyWallpaper(p) {
        if (!p || p === "") return; themePanelRoot.selectedPath = p
        applyWallProc.command = ["bash", "-c", "THEME=\$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin); if [ \"\$THEME\" = \"iris\" ]; then bash ~/.config/hypr/scripts/iris-apply.sh " + p + "; elif [ \"\$THEME\" = \"matugen\" ]; then bash ~/.config/hypr/scripts/matugen-apply.sh " + p + "; else bash ~/.config/hypr/scripts/set-wallpaper.sh " + p + "; fi"]
        applyWallProc.running = true
    }

    Rectangle {
        id: sheetSurface; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; anchors.topMargin: 8
        width: 720; height: 480; radius: 28; color: themePanelRoot.colors.bg2; border.color: themePanelRoot.colors.surface2; border.width: 1; clip: true

        ScrollView {
            anchors.fill: parent; contentWidth: availableWidth; contentHeight: masterDashboardStack.implicitHeight + 36; clip: true
            ColumnLayout {
                id: masterDashboardStack; width: parent.width - 36; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; anchors.topMargin: 18; spacing: 16
                Text { text: "System Customizer"; color: themePanelRoot.colors.text; font.bold: true; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font" }

                GridLayout {
                    columns: 4; columnSpacing: 10; rowSpacing: 10; Layout.fillWidth: true
                    Repeater {
                        model: [{k:"catppuccin",l:"Catppuccin"},{k:"tokyonight",l:"Tokyo Night"},{k:"gruvbox",l:"Gruvbox"},{k:"gruvbox-material",l:"Gruvbox Material"},{k:"nord",l:"Nord"},{k:"rosepine",l:"Rosé Pine"},{k:"everforest",l:"Everforest"},{k:"onedark",l:"One Dark"},{k:"iris-theme",l:"Iris (Dynamic)"},{k:"matugen",l:"Matugen"}]
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 74; radius: 16; border.color: themePanelRoot.colors.surface2; border.width: 1
                            color: themePanelRoot.colors.theme === modelData.k ? themePanelRoot.colors.accent : themePanelRoot.colors.surface
                            
                            // 1. THEME SELECTION INDICATOR: Bumpy Flower Ring + Tiny Tick Inner Core Text Symbol
                            Item {
                                visible: themePanelRoot.colors.theme === modelData.k
                                anchors.top: parent.top; anchors.right: parent.right; anchors.topMargin: 4; anchors.rightMargin: 4
                                width: 20; height: 20
                                Repeater { model: 8; Rectangle { anchors.centerIn: parent; width: 4; height: 16; radius: 2; color: themePanelRoot.colors.bg; rotation: (index * 45) } }
                                Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: themePanelRoot.colors.bg }
                                Text { anchors.centerIn: parent; text: "✓"; font.bold: true; font.pixelSize: 9; color: themePanelRoot.colors.accent }
                            }

                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 10; spacing: 4
                                Row { spacing: 4; property var pal: themePanelRoot.palettes[modelData.k] || {}; Repeater { model: parent.pal.swatches || []; Rectangle { width: 12; height: 12; radius: 6; color: modelData; border.width: 1; border.color: "#00000015" } } }
                                Text { text: modelData.l; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"; color: themePanelRoot.colors.theme === modelData.k ? themePanelRoot.colors.bg : themePanelRoot.colors.text }
                            }
                            TapHandler { onTapped: themePanelRoot.applyTheme(modelData.k === "iris-theme" ? "iris" : modelData.k) }
                        }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: themePanelRoot.colors.surface2 }
                Text { text: "Wallpapers Gallery"; color: themePanelRoot.colors.text; font.bold: true; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }

                GridLayout {
                    columns: 5; columnSpacing: 10; rowSpacing: 10; Layout.fillWidth: true
                    Repeater {
                        model: themePanelRoot.wallpapers
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 12; border.color: themePanelRoot.colors.surface2; border.width: 1; clip: true
                            function getFile() { if(!modelData) return ""; if(typeof modelData === 'string') return modelData; if(modelData.path) return modelData.path; if(modelData.file) return modelData.file; return ""; }
                            color: themePanelRoot.selectedPath === getFile() && getFile() !== "" ? themePanelRoot.colors.accent : themePanelRoot.colors.surface
                            
                            Image {
                                anchors.fill: parent; anchors.margins: 4; fillMode: Image.PreserveAspectCrop; cache: true; asynchronous: true; sourceSize.width: 140; sourceSize.height: 90
                                source: { var f = parent.getFile(); if(!f || f==="") return ""; return f.startsWith("/") ? "file://" + f : "file:///" + f; }
                            }
                            
                            // 2. WALLPAPER GALLERY OVERLAY INDICATOR: Dark Overlay Tint + Centralized Bumpy Ring + Bold Accent Tick Core
                            Rectangle { 
                                visible: themePanelRoot.selectedPath === parent.getFile() && parent.getFile() !== ""
                                anchors.fill: parent; color: "#00000035" 
                                Item {
                                    anchors.centerIn: parent; width: 24; height: 24
                                    Repeater { model: 8; Rectangle { anchors.centerIn: parent; width: 6; height: 22; radius: 3; color: "#FFFFFF"; rotation: (index * 45) } }
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; color: "#FFFFFF" }
                                    Text { anchors.centerIn: parent; text: "✓"; font.bold: true; font.pixelSize: 11; color: themePanelRoot.colors.bg2 }
                                }
                            }
                            TapHandler { onTapped: { themePanelRoot.applyWallpaper(parent.getFile()); } }
                        }
                    }
                }
            }
        }
    }
}
