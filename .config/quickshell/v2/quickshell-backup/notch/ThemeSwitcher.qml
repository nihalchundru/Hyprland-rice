import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// ============================================================================
// ThemeSwitcher.qml — qs-theme
//
// Carousel layout matching the corrected reference: horizontally scrolling
// row of theme cards with neighboring cards peeking at the edges, each card
// showing a row of palette-color dots (not a single pill), selected card
// highlighted with a border, a "current/total" counter top-right of the
// search bar, and an "Enter to apply" footer hint. Fully keyboard
// navigable — search auto-focuses on open, Left/Right move the selection,
// Enter applies it, mouse wheel also scrolls the carousel.
// ============================================================================

PanelWindow {
    id: themeRoot

    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8"
    })
    function c(key) {
        return (themeRoot.colors && themeRoot.colors[key]) ? themeRoot.colors[key] : "#888888"
    }

    // Self-contained colors read (same pattern as Notch.qml) — this panel
    // is a single global instance, not tied to any one screen's Notch.
    FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"
        watchChanges: true
        onLoaded: {
            try { themeRoot.colors = JSON.parse(text()) }
            catch (e) { console.log("ThemeSwitcher: failed to parse colors.json, using fallback:", e) }
        }
        onLoadFailed: (error) => console.log("ThemeSwitcher: colors.json load failed, using fallback:", error)
        onFileChanged: reload()
    }

    property bool open: false
    property string currentTheme: "catppuccin" // ASSUMPTION: not read from colors.json's "theme" key yet
    property string searchText: ""

    // ASSUMPTION: these palette dots are my best representative guess per
    // theme name (5 colors each, loosely matching that theme's known
    // palette), NOT pulled from real generated theme data — I don't have
    // access to each theme's actual output, only colors.json for whichever
    // theme is CURRENTLY active. Treat these as placeholders; tell me the
    // real palette values if any look wrong and I'll swap them in.
    readonly property var allThemes: [
        { key: "catppuccin", label: "Catppuccin", dots: ["#f5c2e7","#cba6f7","#89b4fa","#94e2d5","#a6e3a1"] },
        { key: "tokyonight", label: "Tokyo Night", dots: ["#f7768e","#e0af68","#7aa2f7","#bb9af7","#9ece6a"] },
        { key: "gruvbox", label: "Gruvbox", dots: ["#fb4934","#fabd2f","#b8bb26","#83a598","#d3869b"] },
        { key: "gruvbox-material", label: "Gruvbox Material", dots: ["#ea6962","#d8a657","#a9b665","#7daea3","#d3869b"] },
        { key: "nord", label: "Nord", dots: ["#bf616a","#d08770","#ebcb8b","#88c0d0","#b48ead"] },
        { key: "rosepine", label: "Rosé Pine", dots: ["#eb6f92","#f6c177","#9ccfd8","#c4a7e7","#31748f"] },
        { key: "everforest", label: "Everforest", dots: ["#e67e80","#dbbc7f","#a7c080","#7fbbb3","#d699b6"] },
        { key: "onedark", label: "One Dark", dots: ["#e06c75","#e5c07b","#98c379","#61afef","#c678dd"] },
        { key: "everblush", label: "Everblush", dots: ["#e57474","#e5c76b","#8ccf7e","#67b0e8","#c47fd5"] },
        { key: "aozora", label: "Aozora Ink", dots: ["#8ec6f0","#a0d2eb","#c1e1ec","#dceefb","#5a9bd4"] },
        { key: "latte", label: "Latte", dots: ["#d20f39","#fe640b","#df8e1d","#40a02b","#1e66f5"] },
        { key: "astrabloom", label: "Astra Bloom", dots: ["#c792ea","#f07178","#ffcb6b","#82aaff","#c3e88d"] },
        { key: "crimson", label: "Crimson Twilight", dots: ["#dc143c","#8b0000","#ff6347","#b22222","#cd5c5c"] },
        // Iris/Matugen generate colors dynamically per-wallpaper, so there's
        // no fixed palette to hardcode — dots: [] signals "use live colors",
        // filled in by dotsFor() below from whatever's actually active now.
        { key: "iris", label: "Iris (Dynamic)", dots: [] },
        { key: "matugen", label: "Matugen (Material You)", dots: [] },
        { key: "solarized", label: "Solarized", dots: ["#dc322f","#b58900","#268bd2","#2aa198","#d33682"] }
    ]

    function dotsFor(theme) {
        if (theme.dots.length > 0) return theme.dots
        // Dynamic themes: pull whatever's actually in the live colors.json
        var live = [themeRoot.c("accent"), themeRoot.c("purple"), themeRoot.c("orange"), themeRoot.c("teal"), themeRoot.c("green")]
        return live
    }

    property var filteredThemes: {
        if (searchText.length === 0) return allThemes
        var q = searchText.toLowerCase()
        return allThemes.filter(function(t) { return t.label.toLowerCase().indexOf(q) !== -1 })
    }

    // Which card is highlighted/selected in the carousel right now — this
    // is navigation position, separate from `currentTheme` (the theme
    // actually applied). Arrow keys move this; Enter applies it.
    property int highlightIndex: 0
    onFilteredThemesChanged: highlightIndex = 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-theme"
    // Needed for keyboard input (search typing, arrow-key nav, Enter to
    // apply) to actually reach this panel instead of passing through to
    // whatever's focused underneath.
    WlrLayershell.keyboardFocus: themeRoot.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1
    height: 230
    visible: open

    function toggle() { open = !open }
    onOpenChanged: {
        if (open) {
            // Start the carousel on whichever theme is actually active,
            // not always the first card.
            var idx = allThemes.findIndex(function(t) { return t.key === currentTheme })
            highlightIndex = idx >= 0 ? idx : 0
            Qt.callLater(function() { searchInput.forceActiveFocus() })
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: themeRoot.open = false
    }

    Process { id: applyProc }
    function applyTheme(key) {
        applyProc.command = ["bash", "-c",
            "bash " + Quickshell.env("HOME") + "/.config/hypr/scripts/theme-switch.sh " + key]
        applyProc.running = true
        themeRoot.currentTheme = key
        closeTimer.start() // small delay so the selection highlight is visible before closing
    }
    Timer { id: closeTimer; interval: 300; onTriggered: themeRoot.open = false }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0
        width: 760
        height: themeRoot.open ? 190 : 0
        radius: 24 // fallback for older Qt without per-corner radius support
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: 24
        bottomRightRadius: 24
        color: "#000000"
        clip: true
        antialiasing: true

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: {} }

        // Keyboard nav — Left/Right move the highlight, Enter applies it.
        // Attached to the card so it works regardless of which child (the
        // search field or the list) technically has focus.
        Keys.onLeftPressed:  themeRoot.highlightIndex = Math.max(0, themeRoot.highlightIndex - 1)
        Keys.onRightPressed: themeRoot.highlightIndex = Math.min(themeRoot.filteredThemes.length - 1, themeRoot.highlightIndex + 1)
        Keys.onReturnPressed: {
            var t = themeRoot.filteredThemes[themeRoot.highlightIndex]
            if (t) themeRoot.applyTheme(t.key)
        }
        Keys.onEnterPressed: {
            var t = themeRoot.filteredThemes[themeRoot.highlightIndex]
            if (t) themeRoot.applyTheme(t.key)
        }
        focus: themeRoot.open

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Search bar + counter
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 10
                    color: "#000000"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6
                        //Text { text: "search"; color: themeRoot.c("sub"); font.pixelSize: 13 }
			
                        Text {
                            text: "search"
                            color: themeRoot.c("sub")
                            font.pixelSize: 20
                            font.family: "Material Symbols Rounded"
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: themeRoot.c("text")
                            font.pixelSize: 12
			    
                            font.family: "JetBrains Nerd Font Mono"
                            onTextChanged: themeRoot.searchText = text
                            Keys.forwardTo: [card]

                            Text {
                                visible: parent.text.length === 0
                                text: "Search themes..."
                                color: themeRoot.c("sub")
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }

                // "current/total" counter, matches reference
                Text {
                    text: (themeRoot.filteredThemes.length > 0 ? (themeRoot.highlightIndex + 1) : 0) + "/" + themeRoot.filteredThemes.length
                    color: themeRoot.c("sub")
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Carousel — ListView so neighboring cards can peek at the
            // edges and keyboard/wheel navigation can animate smoothly,
            // instead of the plain RowLayout-in-a-ScrollView from before
            // (which is why scrolling wasn't working).
            ListView {
                id: carousel
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                model: themeRoot.filteredThemes
                spacing: 12
                clip: false // deliberately NOT clipped — lets neighbor cards peek past the edges
                currentIndex: themeRoot.highlightIndex
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: (width - 150) / 2
                preferredHighlightEnd: (width - 150) / 2
                highlightMoveDuration: 200

                // Mouse wheel scrolls through themes one at a time
                WheelHandler {
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                            themeRoot.highlightIndex = Math.min(themeRoot.filteredThemes.length - 1, themeRoot.highlightIndex + 1)
                        else
                            themeRoot.highlightIndex = Math.max(0, themeRoot.highlightIndex - 1)
                    }
                }

                delegate: Item {
                    width: 150
                    height: carousel.height

                    Rectangle {
                        id: swatch
                        anchors.centerIn: parent
                        property bool selected: index === themeRoot.highlightIndex
                        width: 140
                        height: 100
                        radius: 18
                        color: themeRoot.c("surface")
                        border.color: swatch.selected ? "#5eead4" : "transparent" // teal-ish highlight matching reference
                        border.width: 2

                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            Item { Layout.fillHeight: true }

                            // Palette dots — multiple colors per card, not one pill
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 5
                                Repeater {
                                    model: themeRoot.dotsFor(modelData)
                                    Rectangle {
                                        width: 14; height: 14
                                        radius: 7
                                        color: modelData
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.label
                                color: swatch.selected ? themeRoot.c("text") : themeRoot.c("sub")
                                font.pixelSize: 11
                                font.bold: swatch.selected
                                font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                themeRoot.highlightIndex = index
                                themeRoot.applyTheme(modelData.key)
                            }
                        }
                    }
                }
            }

            // Footer hint, matches reference
            Text {
                Layout.alignment: Qt.AlignRight
                text: "Enter to apply"
                color: themeRoot.c("sub")
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
}
