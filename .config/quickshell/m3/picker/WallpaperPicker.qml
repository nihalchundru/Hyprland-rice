import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// qs -c m3 ipc call ui toggleWallpaper  (or the wallpaper button in quick settings). Arrows/wheel browse, Enter applies, Esc closes.
PanelWindow {
    id: win
    readonly property bool open: UiState.wallpaperOpen
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-wallpaper"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: card.opacity > 0.01

    property string folder: ""
    readonly property var folders: {
        const s = []
        for (const w of Wallpapers.all) if (w.folder && s.indexOf(w.folder) < 0) s.push(w.folder)
        return s
    }
    readonly property var items: Wallpapers.all.filter(w => folder === "" || w.folder === folder)

    onOpenChanged: if (open) { Wallpapers.refresh(); keys.forceActiveFocus() }

    Rectangle {
        anchors.fill: parent
        color: M3Colors.scrim
        opacity: win.open ? 0.25 : 0
        FadeBehavior on opacity { time: M3Motion.medium1 }
        MouseArea { anchors.fill: parent; onClicked: UiState.wallpaperOpen = false }
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 48, 1000)
        height: 300
        radius: 36
        color: M3Colors.surfaceContainer
        y: win.open ? parent.height - height - 72 : parent.height + 8
        opacity: win.open ? 1 : 0
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on y {}
        MouseArea { anchors.fill: parent }

        Item {
            id: keys
            focus: win.open
            Keys.onEscapePressed: UiState.wallpaperOpen = false
            Keys.onLeftPressed: list.decrementCurrentIndex()
            Keys.onRightPressed: list.incrementCurrentIndex()
            Keys.onReturnPressed: if (win.items.length > 0) Wallpapers.apply(win.items[list.currentIndex].path)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                M3Text { text: "Wallpaper"; role: M3Type.titleLarge }
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    contentWidth: chips.width
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    Row {
                        id: chips
                        spacing: 8
                        M3Chip { text: "All"; kind: "assist"; selected: win.folder === ""; onClicked: win.folder = "" }
                        Repeater {
                            model: win.folders
                            M3Chip { required property string modelData; text: modelData; kind: "assist"; selected: win.folder === modelData; onClicked: win.folder = modelData }
                        }
                    }
                }
                M3Button { icon: "shuffle"; variant: "tonal"; size: "s"; onClicked: Wallpapers.random() }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                spacing: 14
                clip: true
                model: win.items
                currentIndex: 0
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: width / 2 - 130
                preferredHighlightEnd: width / 2 + 130
                highlightMoveDuration: 260
                boundsBehavior: Flickable.StopAtBounds
                onModelChanged: currentIndex = 0

                WheelHandler { onWheel: e => { if (e.angleDelta.y > 0) list.decrementCurrentIndex(); else list.incrementCurrentIndex() } }

                delegate: Item {
                    id: d
                    required property var modelData
                    required property int index
                    readonly property bool current: ListView.isCurrentItem
                    readonly property bool applied: Wallpapers.applied === modelData.path
                    width: 260; height: list.height
                    scale: current ? 1 : 0.84
                    opacity: current ? 1 : 0.7
                    SpatialBehavior on scale { eps: 0.002 }
                    FadeBehavior on opacity {}

                    RoundedImage {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 24
                        source: "file://" + d.modelData.path
                    }
                    Rectangle {
                        anchors.fill: parent; anchors.margins: 6
                        radius: 24; color: "transparent"
                        border.width: d.applied ? 3 : 0
                        border.color: M3Colors.primary
                    }
                    Rectangle {
                        visible: d.applied
                        x: 16; y: 16; width: 28; height: 28; radius: 14
                        color: M3Colors.primary
                        Icon { anchors.centerIn: parent; name: "check"; size: 18; color: M3Colors.fgPrimary }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { list.currentIndex = d.index; Wallpapers.apply(d.modelData.path) }
                    }
                }
            }
        }
    }
}
