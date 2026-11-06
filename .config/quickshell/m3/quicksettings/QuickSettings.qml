import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

// Open: status icons in the bar, or qs -c m3 ipc call ui toggleQuickSettings
PanelWindow {
    id: win
    readonly property bool open: UiState.quickSettingsOpen
    screen: Hypr.focusedScreen
    WlrLayershell.namespace: "m3-quick-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: panel.opacity > 0.01

    readonly property var schemes: ["tonal-spot", "content", "expressive", "fidelity", "fruit-salad", "monochrome", "neutral", "rainbow"]

    MouseArea { anchors.fill: parent; onClicked: UiState.quickSettingsOpen = false }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: M3Config.barFloating ? 64 : 56
        anchors.rightMargin: 12
        width: 400
        height: Math.min(win.height - anchors.topMargin - 16, col.implicitHeight + 32)
        radius: 28
        color: M3Colors.surfaceContainer
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.92
        transformOrigin: Item.TopRight
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
        SpatialBehavior on height {}
        MouseArea { anchors.fill: parent }

        Flickable {
            anchors.fill: parent
            anchors.margins: 16
            contentWidth: width
            contentHeight: col.implicitHeight
            clip: true
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: col
                width: parent.width
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    M3Text { text: "Quick settings"; role: M3Type.titleLarge; Layout.fillWidth: true }
                    M3Button { icon: "settings"; variant: "tonal"; size: "s"; onClicked: { UiState.quickSettingsOpen = false; UiState.settingsOpen = true } }
                    M3Button { icon: "wallpaper"; variant: "tonal"; size: "s"; onClicked: { UiState.quickSettingsOpen = false; UiState.wallpaperOpen = true } }
                    M3Button { icon: "power_settings_new"; variant: "tonal"; size: "s"; onClicked: { UiState.quickSettingsOpen = false; UiState.sessionOpen = true } }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 8
                    QsTile {
                        Layout.fillWidth: true
                        icon: Network.type === "ethernet" ? "lan" : (Network.wifiEnabled ? "wifi" : "wifi_off")
                        label: Network.type === "ethernet" ? "Ethernet" : "Wi-Fi"
                        sub: Network.connected ? Network.name : (Network.wifiEnabled ? "Not connected" : "Off")
                        checked: Network.connected || Network.wifiEnabled
                        onClicked: Network.toggleWifi()
                    }
                    QsTile {
                        Layout.fillWidth: true
                        enabled: Bt.available
                        icon: Bt.enabled ? "bluetooth" : "bluetooth_disabled"
                        label: "Bluetooth"
                        sub: !Bt.available ? "Unavailable" : Bt.connectedDevices.length > 0 ? Bt.connectedDevices[0].name : (Bt.enabled ? "On" : "Off")
                        checked: Bt.enabled
                        onClicked: Bt.toggle()
                    }
                    QsTile {
                        Layout.fillWidth: true
                        icon: Notifs.dnd ? "notifications_off" : "do_not_disturb_on"
                        label: "Do not disturb"
                        sub: Notifs.dnd ? "On" : "Off"
                        checked: Notifs.dnd
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }
                    QsTile {
                        Layout.fillWidth: true
                        icon: M3Config.mode === "dark" ? "dark_mode" : "light_mode"
                        label: "Theme"
                        sub: M3Config.mode === "dark" ? "Dark" : "Light"
                        checked: M3Config.mode === "dark"
                        onClicked: M3Config.mode = M3Config.mode === "dark" ? "light" : "dark"
                    }
                    QsTile {
                        Layout.fillWidth: true
                        icon: Audio.micMuted ? "mic_off" : "mic"
                        label: "Microphone"
                        sub: Audio.micMuted ? "Muted" : "On"
                        checked: !Audio.micMuted
                        onClicked: Audio.toggleMic()
                    }
                    QsTile {
                        Layout.fillWidth: true
                        icon: "call_to_action"
                        label: "Floating bar"
                        sub: M3Config.barFloating ? "On" : "Off"
                        checked: M3Config.barFloating
                        onClicked: M3Config.barFloating = !M3Config.barFloating
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 8
                    M3Button { icon: Audio.icon; variant: "text"; size: "s"; onClicked: Audio.toggleMute() }
                    M3Slider { id: volSlider; Layout.fillWidth: true; value: Audio.volume; onMoved: v => Audio.setVolume(v) }
                    Binding { target: volSlider; property: "value"; value: Audio.volume }
                    M3Text { Layout.preferredWidth: 40; text: Math.round(Audio.volume * 100) + "%"; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant; horizontalAlignment: Text.AlignRight }
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: Brightness.available
                    spacing: 8
                    Icon { Layout.preferredWidth: 40; name: Brightness.icon; size: 24; color: M3Colors.primary }
                    M3Slider { id: briSlider; Layout.fillWidth: true; value: Brightness.value; onMoved: v => Brightness.set(v) }
                    Binding { target: briSlider; property: "value"; value: Brightness.value }
                    M3Text { Layout.preferredWidth: 40; text: Math.round(Brightness.value * 100) + "%"; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant; horizontalAlignment: Text.AlignRight }
                }

                Rectangle {   // media card
                    Layout.fillWidth: true
                    visible: Media.has
                    implicitHeight: mcol.implicitHeight + 32
                    radius: 28
                    color: M3Colors.surfaceContainerHigh
                    ColumnLayout {
                        id: mcol
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 14
                            Item {
                                Layout.preferredWidth: 64; Layout.preferredHeight: 64
                                RoundedImage { id: art; anchors.fill: parent; radius: 20; source: Media.art }
                                MorphShape { visible: !art.ready; anchors.fill: parent; size: 64; shape: Media.playing ? "cookie9Sided" : "circle"; color: M3Colors.tertiaryContainer }
                                Icon { visible: !art.ready; anchors.centerIn: parent; name: "music_note"; size: 28; color: M3Colors.fgTertiaryContainer; fill: 1 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: Media.title; role: M3Type.titleMedium }
                                M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: Media.artist; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant }
                            }
                        }
                        M3Progress { Layout.fillWidth: true; Layout.preferredHeight: implicitHeight; value: Media.progress; wavy: Media.playing; showStop: false }
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8
                            M3Button { icon: "skip_previous"; variant: "tonal"; onClicked: Media.previous() }
                            M3Button { icon: Media.playing ? "pause" : "play_arrow"; variant: "filled"; size: "m"; round: !Media.playing; onClicked: Media.toggle() }
                            M3Button { icon: "skip_next"; variant: "tonal"; onClicked: Media.next() }
                        }
                    }
                }

                M3Text { Layout.topMargin: 4; text: "Color scheme"; role: M3Type.labelLarge; color: M3Colors.fgSurfaceVariant }
                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: win.schemes
                        M3Chip {
                            required property string modelData
                            text: modelData
                            kind: "assist"
                            selected: M3Config.scheme === modelData
                            onClicked: M3Config.scheme = modelData
                        }
                    }
                }
            }
        }
    }
}
