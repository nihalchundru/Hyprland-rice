import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// Full settings app. Open: quick settings gear, or  qs -c m3 ipc call ui toggleSettings . Esc closes, 1-8 jump to a section.
PanelWindow {
    id: win
    readonly property bool open: UiState.settingsOpen
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: card.opacity > 0.01

    property int page: 0
    readonly property var nav: [
        { icon: "tune", label: "Quick" },
        { icon: "dashboard", label: "General" },
        { icon: "call_to_action", label: "Bar" },
        { icon: "wallpaper", label: "Desktop" },
        { icon: "text_fields", label: "Interface" },
        { icon: "settings", label: "Services" },
        { icon: "layers", label: "Hyprland" },
        { icon: "info", label: "About" }
    ]
    onOpenChanged: if (open) keys.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        color: M3Colors.scrim
        opacity: win.open ? 0.3 : 0
        FadeBehavior on opacity { time: M3Motion.medium1 }
        MouseArea { anchors.fill: parent; onClicked: UiState.settingsOpen = false }
    }
    Item {
        id: keys
        focus: win.open
        Keys.onEscapePressed: UiState.settingsOpen = false
        Keys.onPressed: e => { if (e.key >= Qt.Key_1 && e.key <= Qt.Key_8) { win.page = e.key - Qt.Key_1; e.accepted = true } }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 1180)
        height: Math.min(parent.height - 80, 780)
        radius: 36
        color: Qt.alpha(M3Colors.surfaceContainer, 0.97)
        border.width: 1
        border.color: M3Colors.outlineVariant
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.94
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
        MouseArea { anchors.fill: parent }

        Rectangle {   // sidebar
            x: 14; y: 14
            width: 250; height: parent.height - 28
            radius: 28
            color: Qt.alpha(M3Colors.surfaceContainerLow, 0.95)

            Item {
                x: 16; y: 16
                width: parent.width - 32; height: 52
                Item {
                    width: 48; height: 48
                    MorphShape { size: 48; shape: "cookie9Sided"; color: M3Colors.primaryContainer }
                    M3Text { anchors.centerIn: parent; text: (Quickshell.env("USER") || "?").charAt(0).toUpperCase(); role: M3Type.titleMedium; color: M3Colors.fgPrimaryContainer }
                }
                Column {
                    x: 60; anchors.verticalCenter: parent.verticalCenter
                    M3Text { text: Quickshell.env("USER"); role: M3Type.titleSmall }
                    M3Text { text: "Material 3 shell"; role: M3Type.bodySmall; color: M3Colors.fgSurfaceVariant }
                }
            }
            M3Button {
                x: 16; y: 84
                text: "Config file"; icon: "edit"; variant: "tonal"
                onClicked: Quickshell.execDetached(["xdg-open", Quickshell.env("HOME") + "/.config/quickshell/m3/config.json"])
            }
            Item {
                x: 10; y: 148
                width: parent.width - 20; height: win.nav.length * 60
                Rectangle {
                    width: parent.width; height: 52; radius: 26
                    y: win.page * 60
                    color: M3Colors.secondaryContainer
                    SpatialBehavior on y {}
                }
                Repeater {
                    model: win.nav
                    Item {
                        id: ni
                        required property var modelData
                        required property int index
                        readonly property bool current: win.page === index
                        y: index * 60; width: parent.width; height: 52
                        Row {
                            x: 20; anchors.verticalCenter: parent.verticalCenter
                            spacing: 14
                            Icon { name: ni.modelData.icon; size: 24; fill: ni.current ? 1 : 0; color: ni.current ? M3Colors.fgSecondaryContainer : M3Colors.fgSurfaceVariant; anchors.verticalCenter: parent.verticalCenter }
                            M3Text { text: ni.modelData.label; role: M3Type.labelLarge; color: ni.current ? M3Colors.fgSecondaryContainer : M3Colors.fgSurface; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.page = ni.index }
                    }
                }
            }
        }

        Item {   // content
            x: 278; y: 18
            width: parent.width - 296; height: parent.height - 36

            RowLayout {
                id: head
                width: parent.width; height: 48
                spacing: 12
                Item {
                    Layout.preferredWidth: 44; Layout.preferredHeight: 44
                    MorphShape { size: 44; shape: "cookie9Sided"; color: M3Colors.secondaryContainer }
                    Icon { anchors.centerIn: parent; name: win.nav[win.page].icon; size: 22; fill: 1; color: M3Colors.fgSecondaryContainer }
                }
                M3Text { Layout.fillWidth: true; text: win.nav[win.page].label; role: M3Type.headlineSmall }
                M3Button { icon: "close"; variant: "tonal"; size: "s"; onClicked: UiState.settingsOpen = false }
            }
            Item {
                y: 60
                width: parent.width; height: parent.height - 60
                clip: true
                QuickPage { index: 0; current: win.page }
                GeneralPage { index: 1; current: win.page }
                BarPage { index: 2; current: win.page }
                DesktopPage { index: 3; current: win.page }
                InterfacePage { index: 4; current: win.page }
                ServicesPage { index: 5; current: win.page }
                HyprlandPage { index: 6; current: win.page }
                AboutPage { index: 7; current: win.page }
            }
        }
    }
}
