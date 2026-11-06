import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components
import qs.panel

// Bar button (right edge), or: qs -c m3 ipc call ui toggleSidebar | openWidgetEditor
PanelWindow {
    id: win
    readonly property bool open: UiState.sidebarOpen
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-sidebar"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: panel.opacity > 0.01
    readonly property bool editing: open && UiState.sidebarTab === 1
    mask: Region { item: win.editing ? panel : full }
    onOpenChanged: if (open) keys.forceActiveFocus()

    Item { id: full; anchors.fill: parent }
    MouseArea { anchors.fill: parent; onClicked: UiState.sidebarOpen = false }
    Item { id: keys; focus: win.open; Keys.onEscapePressed: UiState.sidebarOpen = false }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: M3Config.barFloating ? 72 : 64
        anchors.bottomMargin: 16
        anchors.rightMargin: win.open ? 12 : -(width + 24)
        width: 440
        radius: 32
        color: M3Colors.surfaceContainer
        border.width: 1
        border.color: M3Colors.outlineVariant
        opacity: win.open ? 1 : 0
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on anchors.rightMargin {}
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {   // menu selector
                Layout.fillWidth: true
                spacing: 8
                M3Button { Layout.fillWidth: true; text: "Sidebar"; icon: "view_sidebar"; variant: UiState.sidebarTab === 0 ? "filled" : "tonal"; onClicked: UiState.sidebarTab = 0 }
                M3Button { Layout.fillWidth: true; text: "Widgets"; icon: "widgets"; variant: UiState.sidebarTab === 1 ? "filled" : "tonal"; onClicked: UiState.sidebarTab = 1 }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                SidebarHome { index: 0; current: UiState.sidebarTab }
                WidgetsEditor { index: 1; current: UiState.sidebarTab }
            }
        }
    }
}
