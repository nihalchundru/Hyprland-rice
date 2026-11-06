import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// Click the clock, or: qs -c m3 ipc call ui toggleCalendar | toggleMedia | toggleKeybinds | openPage <0-4>
// Keys: 1-6 switch tabs, Esc closes.
PanelWindow {
    id: win
    readonly property bool open: UiState.calendarOpen
    readonly property int page: UiState.mainPage
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-main-panel"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: panel.opacity > 0.01

    readonly property var tabs: [
        { icon: "home", label: "Home" },
        { icon: "music_note", label: "Media" },
        { icon: "grid_view", label: "Spaces" },
        { icon: "keyboard", label: "Keys" },
        { icon: "notifications", label: "Inbox" },
        { icon: "settings", label: "Settings" }
    ]
    onOpenChanged: if (open) keys.forceActiveFocus()
    onPageChanged: keys.forceActiveFocus()

    MouseArea {
        id: outsideClick
        anchors.fill: parent
        onClicked: mouse => {
            const localPos = panel.mapFromItem(outsideClick, mouse.x, mouse.y)
            if (!panel.contains(localPos))
                UiState.calendarOpen = false
        }
    }
    Item {
        id: keys
        focus: win.open
        Keys.onEscapePressed: UiState.calendarOpen = false
        Keys.onPressed: e => { if (e.key >= Qt.Key_1 && e.key <= Qt.Key_6) { UiState.mainPage = e.key - Qt.Key_1; e.accepted = true } }
    }

    Rectangle {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: M3Config.barFloating ? 84 : 72
        width: Math.min(parent.width - 48, 1040)
        height: Math.min(parent.height - anchors.topMargin - 36, 640)
        radius: 36
        color: M3Colors.surfaceContainer
        border.width: 1
        border.color: M3Colors.outlineVariant
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.94
        transformOrigin: Item.Top
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
        MouseArea { anchors.fill: parent }

        Item {   // navigation rail
            x: 16; y: 20
            width: 72
            height: parent.height - 40
            Rectangle {
                width: 56; height: 32; radius: 16
                x: 8
                y: 4 + win.page * 80
                color: M3Colors.secondaryContainer
                SpatialBehavior on y {}
            }
            Repeater {
                model: win.tabs
                Item {
                    id: tab
                    required property var modelData
                    required property int index
                    readonly property bool current: win.page === index
                    y: index * 80; width: 72; height: 72
                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 8
                        name: tab.modelData.icon; size: 24; fill: tab.current ? 1 : 0
                        color: tab.current ? M3Colors.fgSecondaryContainer : M3Colors.fgSurfaceVariant
                    }
                    Rectangle {
                        visible: tab.index === 4 && Notifs.count > 0
                        x: 40; y: 6; width: 10; height: 10; radius: 5
                        color: M3Colors.error
                    }
                    M3Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 44
                        text: tab.modelData.label
                        role: M3Type.labelMedium
                        color: tab.current ? M3Colors.fgSurface : M3Colors.fgSurfaceVariant
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: UiState.mainPage = tab.index }
                }
            }
        }

        Item {
            id: pages
            x: 104; y: 20
            width: parent.width - 120
            height: parent.height - 40
            clip: true
            HomePage { index: 0; current: win.page }
            MediaPage { index: 1; current: win.page }
            WorkspacesPage { index: 2; current: win.page }
            KeybindsPage { index: 3; current: win.page }
            NotificationsPage { index: 4; current: win.page }
            SettingsPage { index: 5; current: win.page }
        }
    }
}
