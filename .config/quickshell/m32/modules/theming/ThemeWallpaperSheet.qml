import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../core"
import "../../shapes"
import "../../components"

PanelWindow {
    id: sheetWindow

    property var modelData
    screen: modelData

    readonly property bool isOpen: StateStore.themeSwitcherOpen || StateStore.wallpaperPickerOpen
    visible: isOpen || closeAnimTimer.running

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    implicitWidth: screen ? screen.width : 1920
    implicitHeight: screen ? screen.height : 1080
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "m32-theming-sheet"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // "themes" | "wallpapers"
    property string activeTab: StateStore.wallpaperPickerOpen ? "wallpapers" : "themes"
    property var discoveredThemes: ["matugen", "iris", "catppuccin", "tokyonight", "gruvbox", "nord", "rosepine", "everforest", "kanagawa", "dracula", "aozora"]
    property var discoveredWallpapers: []

    readonly property var polygonBadges: [
        "cookie6", "sunny", "clover4", "cookie7", "gem", "flower", "cookie9", "verySunny"
    ]

    function closeSheet() {
        StateStore.themeSwitcherOpen = false;
        StateStore.wallpaperPickerOpen = false;
    }

    function refreshLists() {
        themeScannerProc.running = false;
        themeScannerProc.running = true;
        wallpaperScannerProc.running = false;
        wallpaperScannerProc.running = true;
    }

    Connections {
        target: StateStore
        function onThemeSwitcherOpenChanged() {
            if (StateStore.themeSwitcherOpen) {
                sheetWindow.activeTab = "themes";
                sheetWindow.refreshLists();
                keyFocusItem.forceActiveFocus();
            } else if (!StateStore.wallpaperPickerOpen) {
                closeAnimTimer.restart();
            }
        }
        function onWallpaperPickerOpenChanged() {
            if (StateStore.wallpaperPickerOpen) {
                sheetWindow.activeTab = "wallpapers";
                sheetWindow.refreshLists();
                keyFocusItem.forceActiveFocus();
            } else if (!StateStore.themeSwitcherOpen) {
                closeAnimTimer.restart();
            }
        }
        function onCurrentThemeChanged() {
            if (sheetWindow.isOpen) {
                wallpaperScannerProc.running = false;
                wallpaperScannerProc.running = true;
            }
        }
    }

    Timer {
        id: closeAnimTimer
        interval: 280
    }

    // Discover themes from ~/.config/hypr/themes/themes.sh + folder names
    Process {
        id: themeScannerProc
        command: [
            "sh", "-c",
            "{ printf 'matugen\\niris\\n'; " +
            "if [ -f \"$HOME/.config/hypr/themes/themes.sh\" ]; then " +
            "  awk '/^[[:space:]]*[a-zA-Z0-9_-]+\\)/ {gsub(/\\)|[[:space:]]/,\"\",$1); if($1!=\"*\") print $1}' \"$HOME/.config/hypr/themes/themes.sh\" 2>/dev/null; " +
            "fi; " +
            "if [ -d \"$HOME/.config/hypr/wallpapers\" ]; then " +
            "  ls -1 \"$HOME/.config/hypr/wallpapers\" 2>/dev/null; " +
            "fi; } | awk 'NF && !seen[$0]++'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = (this.text || "").trim();
                if (!txt) return;
                var lines = txt.split("\n").map(function(s) { return s.trim(); }).filter(function(s) { return s.length > 0; });
                if (lines.length > 0) {
                    sheetWindow.discoveredThemes = lines;
                }
            }
        }
    }

    // Discover wallpapers based on THEMING.md rules:
    // If currentTheme is matugen or iris -> scan all folders under ~/.config/hypr/wallpapers + ~/.config/rofi/images/a.png
    // Else -> scan ~/.config/hypr/wallpapers/<currentTheme> (fallback to all if folder missing)
    Process {
        id: wallpaperScannerProc
        command: [
            "sh", "-c",
            "THEME=\"" + StateStore.currentTheme + "\"; " +
            "WDIR=\"$HOME/.config/hypr/wallpapers\"; " +
            "{ " +
            "  if [ -f \"$HOME/.config/rofi/images/a.png\" ]; then printf '%s\\n' \"$HOME/.config/rofi/images/a.png\"; fi; " +
            "  if [ \"$THEME\" = \"matugen\" ] || [ \"$THEME\" = \"iris\" ] || [ ! -d \"$WDIR/$THEME\" ]; then " +
            "    find \"$WDIR\" -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null | sort; " +
            "  else " +
            "    find \"$WDIR/$THEME\" -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null | sort; " +
            "  fi; " +
            "} | awk 'NF && !seen[$0]++' | head -n 80"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = (this.text || "").trim();
                if (!txt) return;
                var lines = txt.split("\n").map(function(s) { return s.trim(); }).filter(function(s) { return s.length > 0; });
                sheetWindow.discoveredWallpapers = lines;
            }
        }
    }

    Item {
        id: keyFocusItem
        focus: true
        Keys.onEscapePressed: sheetWindow.closeSheet()
    }

    // Scrim backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.withAlpha(Theme.scrim, sheetBackdropOpacity)
        property real sheetBackdropOpacity: sheetWindow.isOpen ? 0.35 : 0.0
        Behavior on sheetBackdropOpacity { NumberAnimation { duration: Motion.durationMedium1 } }

        MouseArea {
            anchors.fill: parent
            enabled: sheetWindow.isOpen
            onClicked: sheetWindow.closeSheet()
        }
    }

    // ------------------------------------------------------------------------
    // Centered M3 Expressive Theme & Wallpaper Studio Sheet
    // ------------------------------------------------------------------------
    Rectangle {
        id: studioCard
        width: 720
        height: 540
        anchors.centerIn: parent

        radius: Motion.radiusExtraLargeInc
        color: Theme.withAlpha(Theme.surfaceContainer, 0.97)
        border.width: 1
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.55)
        opacity: sheetWindow.isOpen ? 1.0 : 0.0
        scale: sheetWindow.isOpen ? 1.0 : 0.93
        clip: true

        Behavior on opacity {
            NumberAnimation {
                duration: Motion.durationMedium1
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Motion.durationMedium2
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialDefault
            }
        }

        // Prevent clicks inside card from closing backdrop
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // ----------------------------------------------------------------
            // HEADER + SEGMENTED TAB SWITCHER ("Themes" / "Wallpapers")
            // ----------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42

                    ShapeCanvas {
                        anchors.fill: parent
                        shapeName: sheetWindow.activeTab === "themes" ? "flower" : "verySunny"
                        color: Theme.primaryContainer
                    }

                    Text {
                        anchors.centerIn: parent
                        text: sheetWindow.activeTab === "themes" ? "🎨" : "🖼"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 16
                        color: Theme.onPrimaryContainer
                    }
                }

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Theme & Wallpaper Studio"
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.onSurface
                    }

                    Text {
                        text: "Active Theme: " + StateStore.currentTheme + "  ·  Transition: " + StateStore.wallTransition + " (" + StateStore.wallTransitionDuration + "s)"
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 11
                        color: Theme.onSurfaceVariant
                    }
                }

                Item { Layout.fillWidth: true }

                // Segmented Pill Tab Control
                Rectangle {
                    height: 38
                    width: 244
                    radius: 19
                    color: Theme.surfaceContainerHigh
                    border.width: 1
                    border.color: Theme.withAlpha(Theme.outlineVariant, 0.4)

                    Row {
                        anchors.fill: parent
                        anchors.margins: 3
                        spacing: 4

                        Rectangle {
                            width: 116
                            height: 32
                            radius: 16
                            color: sheetWindow.activeTab === "themes" ? Theme.primary : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "🎨 Themes (" + sheetWindow.discoveredThemes.length + ")"
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: sheetWindow.activeTab === "themes" ? Theme.onPrimary : Theme.onSurfaceVariant
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: sheetWindow.activeTab = "themes"
                            }
                        }

                        Rectangle {
                            width: 118
                            height: 32
                            radius: 16
                            color: sheetWindow.activeTab === "wallpapers" ? Theme.primary : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "🖼 Walls (" + sheetWindow.discoveredWallpapers.length + ")"
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: sheetWindow.activeTab === "wallpapers" ? Theme.onPrimary : Theme.onSurfaceVariant
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: sheetWindow.activeTab = "wallpapers"
                            }
                        }
                    }
                }

                MorphShapeButton {
                    size: 36
                    icon: "✕"
                    iconSize: 13
                    idleShape: "circle"
                    hoverShape: "cookie4"
                    pressedShape: "softBurst"
                    onClicked: sheetWindow.closeSheet()
                }
            }

            // ----------------------------------------------------------------
            // TAB 1: THEMES GRID (Dynamic Matugen / Iris + Static Themes)
            // ----------------------------------------------------------------
            GridView {
                id: themesGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: sheetWindow.activeTab === "themes"
                clip: true
                cellWidth: Math.floor(width / 3)
                cellHeight: 92
                model: sheetWindow.discoveredThemes

                delegate: Item {
                    id: themeCell
                    required property string modelData
                    required property int index

                    readonly property bool isCurrent: StateStore.currentTheme === modelData
                    readonly property bool isDynamic: modelData === "matugen" || modelData === "iris"

                    width: themesGrid.cellWidth
                    height: themesGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        radius: themeCell.isCurrent ? 24 : 16
                        color: themeCell.isCurrent ? Theme.primaryContainer : Theme.surfaceContainerHigh
                        border.width: themeCell.isCurrent ? 2 : 1
                        border.color: themeCell.isCurrent
                            ? Theme.primary
                            : Theme.withAlpha(Theme.outlineVariant, 0.4)

                        Behavior on radius { NumberAnimation { duration: Motion.durationShort4 } }
                        Behavior on color { ColorAnimation { duration: Motion.durationColor } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Item {
                                Layout.preferredWidth: 44
                                Layout.preferredHeight: 44

                                ShapeCanvas {
                                    anchors.fill: parent
                                    shapeName: {
                                        if (themeMouse.pressed) return "softBurst";
                                        if (themeCell.isCurrent) return "verySunny";
                                        if (themeMouse.hovered) return "sunny";
                                        return sheetWindow.polygonBadges[themeCell.index % sheetWindow.polygonBadges.length];
                                    }
                                    color: themeCell.isCurrent ? Theme.primary : Theme.surfaceContainerHighest
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: themeCell.isDynamic ? "✦" : "◈"
                                    font.family: Theme.fontFamilyMono
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: themeCell.isCurrent ? Theme.onPrimary : Theme.primary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: themeCell.modelData
                                    font.family: Theme.fontFamilySans
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: themeCell.isCurrent ? Theme.onPrimaryContainer : Theme.onSurface
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: themeCell.modelData === "matugen"
                                        ? "Material You Dynamic"
                                        : (themeCell.modelData === "iris" ? "Perceptual Dynamic" : "Static Palette")
                                    font.family: Theme.fontFamilySans
                                    font.pixelSize: 10
                                    color: themeCell.isCurrent ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                                    opacity: 0.85
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        M3StateLayer {
                            id: themeMouse
                            anchors.fill: parent
                            cornerRadius: parent.radius
                            stateColor: themeCell.isCurrent ? Theme.onPrimaryContainer : Theme.onSurface
                            onClicked: StateStore.applyTheme(themeCell.modelData)
                        }
                    }
                }
            }

            // ----------------------------------------------------------------
            // TAB 2: WALLPAPERS THUMBNAIL GRID + TRANSITION CONTROLS
            // ----------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: sheetWindow.activeTab === "wallpapers"
                spacing: 10

                // Transition style & duration bar (from THEMING.md)
                M3Card {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    level: 3
                    radius: 16

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 6

                        Text {
                            text: "TRANSITION:"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: Theme.onSurfaceVariant
                        }

                        Repeater {
                            model: StateStore.transitionStyles

                            delegate: Rectangle {
                                required property string modelData
                                readonly property bool active: StateStore.wallTransition === modelData

                                height: 26
                                width: styleTxt.implicitWidth + 16
                                radius: 13
                                color: active ? Theme.primary : Theme.surfaceContainerHighest

                                Text {
                                    id: styleTxt
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.family: Theme.fontFamilyMono
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: active ? Theme.onPrimary : Theme.onSurfaceVariant
                                }

                                M3StateLayer {
                                    anchors.fill: parent
                                    cornerRadius: 13
                                    onClicked: StateStore.setTransitionStyle(modelData)
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "DURATION:"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: Theme.onSurfaceVariant
                        }

                        Repeater {
                            model: StateStore.transitionDurations

                            delegate: Rectangle {
                                required property string modelData
                                readonly property bool active: StateStore.wallTransitionDuration === modelData

                                height: 26
                                width: durTxt.implicitWidth + 14
                                radius: 13
                                color: active ? Theme.tertiary : Theme.surfaceContainerHighest

                                Text {
                                    id: durTxt
                                    anchors.centerIn: parent
                                    text: modelData + "s"
                                    font.family: Theme.fontFamilyMono
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: active ? Theme.onTertiary : Theme.onSurfaceVariant
                                }

                                M3StateLayer {
                                    anchors.fill: parent
                                    cornerRadius: 13
                                    onClicked: StateStore.setTransitionDuration(modelData)
                                }
                            }
                        }
                    }
                }

                // Wallpaper Image Grid
                GridView {
                    id: wallGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: Math.floor(width / 3)
                    cellHeight: 132
                    model: sheetWindow.discoveredWallpapers

                    delegate: Item {
                        id: wallCell
                        required property string modelData
                        required property int index

                        readonly property bool isCurrent: StateStore.currentWallpaper === modelData
                        readonly property string fileName: {
                            var parts = String(modelData).split("/");
                            return parts[parts.length - 1] || modelData;
                        }

                        width: wallGrid.cellWidth
                        height: wallGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: wallCell.isCurrent ? 22 : 14
                            color: Theme.surfaceContainerHigh
                            border.width: wallCell.isCurrent ? 2 : 1
                            border.color: wallCell.isCurrent
                                ? Theme.primary
                                : Theme.withAlpha(Theme.outlineVariant, 0.45)
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: "file://" + wallCell.modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                                sourceSize.width: 320
                                sourceSize.height: 180
                            }

                            // Bottom caption strip
                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 28
                                color: Theme.withAlpha(Theme.surfaceContainerLowest, 0.84)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 6

                                    ShapeCanvas {
                                        Layout.preferredWidth: 14
                                        Layout.preferredHeight: 14
                                        shapeName: wallCell.isCurrent ? "verySunny" : "circle"
                                        color: wallCell.isCurrent ? Theme.primary : Theme.secondary
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: wallCell.fileName
                                        font.family: Theme.fontFamilySans
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        color: Theme.onSurface
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            M3StateLayer {
                                anchors.fill: parent
                                cornerRadius: parent.radius
                                onClicked: StateStore.applyWallpaper(wallCell.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
