import "./"
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root
    property var theme: Theme
    property string font: "JetBrainsMono Nerd Font"

    IpcHandler {
        target: "theme-picker"
        function toggle(): void {
            themePanel.visible = !themePanel.visible
            if (themePanel.visible) {
                searchInput.text = ""
                searchText = ""
                selectedIndex = 0
                for (var i = 0; i < filteredThemes.length; i++) {
                    if (filteredThemes[i].originalIndex === root.theme.currentIndex) {
                        selectedIndex = i; break
                    }
                }
                if (root.theme.wallpaperMode) paletteView.forceActiveFocus()
                else { themeList.positionViewAtIndex(selectedIndex, ListView.Center); searchInput.forceActiveFocus() }
            } else {
                root.theme.previewIndex = -1
            }
        }
    }

    property int selectedIndex: 0
    property string searchText: ""

    onSelectedIndexChanged: {
        if (themePanel.visible && !root.theme.wallpaperMode &&
            filteredThemes.length > 0 && selectedIndex >= 0 && selectedIndex < filteredThemes.length)
            root.theme.previewIndex = filteredThemes[selectedIndex].originalIndex
    }

    property var filteredThemes: {
        var query = searchText.toLowerCase()
        var result = []
        for (var i = 0; i < root.theme.themes.length; i++) {
            var t = root.theme.themes[i]
            if (query === "" || t.name.toLowerCase().indexOf(query) >= 0 || t.family.toLowerCase().indexOf(query) >= 0)
                result.push({ data: t, originalIndex: i, family: t.family })
        }
        return result
    }

    PanelWindow {
        id: themePanel
        visible: false
        focusable: true
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qs-theme-picker"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }

        MouseArea {
            anchors.fill: parent
            onClicked: { root.theme.previewIndex = -1; themePanel.visible = false }
            Rectangle { anchors.fill: parent; color: root.theme.bgOverlay }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 620; height: 520
            radius: 16
            color: root.theme.bgBase
            border.color: root.theme.bgBorder
            border.width: 1
            Behavior on color       { ColorAnimation { duration: 150 } }
            Behavior on border.color{ ColorAnimation { duration: 150 } }

            MouseArea { anchors.fill: parent; onClicked: event => event.accepted = true }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "  Theme Switcher"
                        color: root.theme.accentPrimary
                        font.pixelSize: 14; font.family: root.font; font.bold: true
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    Item { Layout.fillWidth: true }
                    // Wallpaper mode toggle
                    Rectangle {
                        implicitWidth: modeRow.implicitWidth + 6; implicitHeight: 26
                        radius: 8
                        color: root.theme.bgSurface
                        border.color: root.theme.bgBorder; border.width: 1
                        Behavior on color       { ColorAnimation { duration: 150 } }
                        RowLayout {
                            id: modeRow
                            anchors.fill: parent; anchors.margins: 3; spacing: 3
                            Rectangle {
                                Layout.fillHeight: true
                                implicitWidth: tLabel.implicitWidth + 20; radius: 6
                                color: !root.theme.wallpaperMode ? root.theme.bgSelected : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text { id: tLabel; anchors.centerIn: parent; text: "Themes"
                                    color: !root.theme.wallpaperMode ? root.theme.accentPrimary : root.theme.textMuted
                                    font.pixelSize: 11; font.family: root.font; font.bold: !root.theme.wallpaperMode
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.theme.previewIndex = -1; root.theme.setTheme(root.theme.currentIndex); searchInput.forceActiveFocus() }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                implicitWidth: wLabel.implicitWidth + 20; radius: 6
                                color: root.theme.wallpaperMode ? root.theme.bgSelected : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text { id: wLabel; anchors.centerIn: parent; text: "Wallpaper"
                                    color: root.theme.wallpaperMode ? root.theme.accentPrimary : root.theme.textMuted
                                    font.pixelSize: 11; font.family: root.font; font.bold: root.theme.wallpaperMode
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.theme.previewIndex = -1; root.theme.setWallpaperMode(); paletteView.forceActiveFocus() }
                                }
                            }
                        }
                    }
                }

                // Subtitle
                Text {
                    text: root.searchText !== ""
                        ? root.filteredThemes.length + " of " + root.theme.count + " themes"
                        : root.theme.wallpaperMode ? "Colors from current wallpaper"
                        : root.theme.count + " themes — " + root.theme.currentFamily + " / " + root.theme.currentName
                    color: root.theme.textMuted; font.pixelSize: 11; font.family: root.font
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                // Search
                Rectangle {
                    Layout.fillWidth: true; height: 36; radius: 8
                    visible: !root.theme.wallpaperMode
                    color: root.theme.bgSurface
                    border.color: searchInput.activeFocus ? root.theme.accentPrimary : root.theme.bgBorder
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8
                        Text { text: ""; color: root.theme.textMuted; font.pixelSize: 13; font.family: root.font; Layout.alignment: Qt.AlignVCenter }
                        Item {
                            Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; implicitHeight: searchInput.implicitHeight
                            TextInput {
                                id: searchInput
                                anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                color: root.theme.textPrimary; font.pixelSize: 13; font.family: root.font; clip: true; selectByMouse: true
                                onTextChanged: { root.searchText = text; root.selectedIndex = 0 }
                                Keys.onEscapePressed: { root.theme.previewIndex = -1; themePanel.visible = false }
                                Keys.onPressed: event => {
                                    if (root.theme.wallpaperMode) return
                                    if (event.key === Qt.Key_Down) {
                                        event.accepted = true
                                        root.selectedIndex = Math.min(root.selectedIndex + 1, themeList.count - 1)
                                        themeList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                    } else if (event.key === Qt.Key_Up) {
                                        event.accepted = true
                                        root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                                        themeList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        event.accepted = true
                                        if (root.filteredThemes.length > 0) {
                                            root.theme.previewIndex = -1
                                            root.theme.setTheme(root.filteredThemes[root.selectedIndex].originalIndex)
                                            themePanel.visible = false
                                        }
                                    }
                                }
                            }
                            Text { text: "Search themes..."; color: root.theme.textMuted; font.pixelSize: 13; font.family: root.font
                                anchors.verticalCenter: parent.verticalCenter; visible: searchInput.text === "" }
                        }
                    }
                }

                // Theme list
                ListView {
                    id: themeList
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: !root.theme.wallpaperMode
                    model: root.filteredThemes; clip: true; spacing: 2
                    boundsBehavior: Flickable.StopAtBounds
                    currentIndex: root.selectedIndex
                    highlightMoveDuration: 150; highlightMoveVelocity: -1
                    highlight: Rectangle {
                        radius: 8; color: root.theme.bgSelected
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Rectangle { width: 3; height: 24; radius: 2; color: root.theme.accentPrimary
                            anchors.left: parent.left; anchors.leftMargin: 2; anchors.verticalCenter: parent.verticalCenter }
                    }
                    section.property: "family"
                    section.delegate: Item {
                        required property string section
                        width: themeList.width; height: 28
                        Text { anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
                            text: section.toUpperCase(); color: root.theme.textMuted
                            font.pixelSize: 10; font.family: root.font; font.bold: true; font.letterSpacing: 1.5 }
                    }
                    delegate: Rectangle {
                        id: del
                        required property var modelData; required property int index
                        width: themeList.width; height: 44; radius: 8
                        color: hov.containsMouse && root.selectedIndex !== index ? root.theme.bgHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
                            Text {
                                text: del.modelData.data.name
                                color: root.selectedIndex === del.index ? root.theme.textPrimary : root.theme.textSecondary
                                font.pixelSize: 13; font.family: root.font; font.bold: root.selectedIndex === del.index
                                Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            Row {
                                spacing: 6; Layout.alignment: Qt.AlignVCenter
                                Repeater {
                                    model: [del.modelData.data.bgBase, del.modelData.data.accentPrimary,
                                            del.modelData.data.accentGreen, del.modelData.data.accentOrange, del.modelData.data.accentRed]
                                    Rectangle {
                                        required property var modelData
                                        width: 14; height: 14; radius: 7; color: modelData
                                        border.color: root.theme.bgBorder; border.width: 1
                                    }
                                }
                            }
                            Text { text: ""; color: root.theme.accentGreen; font.pixelSize: 14; font.family: root.font
                                visible: !root.theme.wallpaperMode && root.theme.currentIndex === del.modelData.originalIndex
                                Layout.alignment: Qt.AlignVCenter }
                        }
                        MouseArea {
                            id: hov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { root.theme.previewIndex = -1; root.theme.setTheme(del.modelData.originalIndex); themePanel.visible = false }
                            onEntered: root.selectedIndex = del.index
                        }
                    }
                    Text { anchors.centerIn: parent; text: "No themes found"; color: root.theme.textMuted
                        font.pixelSize: 13; font.family: root.font
                        visible: themeList.count === 0 && root.searchText !== "" }
                }

                // Wallpaper palette view
                Flickable {
                    id: paletteView
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: root.theme.wallpaperMode; clip: true
                    contentHeight: paletteFlow.implicitHeight
                    Keys.onEscapePressed: { root.theme.previewIndex = -1; themePanel.visible = false }
                    Flow {
                        id: paletteFlow; width: paletteView.width; spacing: 8
                        Repeater {
                            model: [
                                { label: "Base",     key: "bgBase" },     { label: "Surface",  key: "bgSurface" },
                                { label: "Text",     key: "textPrimary" },{ label: "Muted",    key: "textMuted" },
                                { label: "Accent",   key: "accentPrimary"},{ label: "Cyan",    key: "accentCyan" },
                                { label: "Green",    key: "accentGreen" }, { label: "Orange",  key: "accentOrange" },
                                { label: "Red",      key: "accentRed" }
                            ]
                            Rectangle {
                                id: swatch; required property var modelData
                                readonly property string hex: root.theme.wallpaperTheme[modelData.key] || "#000000"
                                width: (paletteFlow.width - paletteFlow.spacing * 2) / 3; height: 72
                                radius: 8; color: root.theme.bgSurface
                                border.color: root.theme.bgBorder; border.width: 1
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 10; spacing: 10
                                    Rectangle { Layout.preferredWidth: 44; Layout.preferredHeight: 44; radius: 6; color: swatch.hex; border.color: root.theme.bgBorder; border.width: 1 }
                                    ColumnLayout { Layout.fillWidth: true; spacing: 2
                                        Text { text: swatch.modelData.label; color: root.theme.textPrimary; font.pixelSize: 12; font.family: root.font; font.bold: true; Layout.fillWidth: true }
                                        Text { text: swatch.hex.toUpperCase(); color: root.theme.textMuted; font.pixelSize: 11; font.family: root.font; Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                    }
                }

                // Footer
                RowLayout {
                    Layout.fillWidth: true; spacing: 16
                    Repeater {
                        model: root.theme.wallpaperMode
                            ? [{ key: "esc", label: "close" }]
                            : [{ key: "↑↓", label: "navigate" }, { key: "⏎", label: "select" }, { key: "esc", label: "close" }]
                        Row { spacing: 4
                            Rectangle { width: kl.width + 8; height: 18; radius: 4; color: root.theme.bgSurface
                                Text { id: kl; anchors.centerIn: parent; text: modelData.key; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font }
                            }
                            Text { text: modelData.label; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
