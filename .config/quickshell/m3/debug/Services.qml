import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.tokens
import qs.services
import qs.components

FloatingWindow {
    id: win
    title: "m3-services"
    color: M3Colors.surface
    implicitWidth: 820
    implicitHeight: 760

    function pct(v) { return Math.round(v * 100) + "%" }
    function names(list, key) { return list.map(x => x[key]).join(", ") }

    Process { id: notify; command: ["notify-send", "M3 test", "Hello from the M3 shell"] }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 6

        M3Text { text: "Services"; role: M3Type.headlineSmall }
        M3Text { text: "Clock      " + Clock.time + ":" + Clock.seconds + "   " + Clock.dateLong }
        M3Text { text: "Audio      " + (Audio.ready ? Audio.sinkName + "  " + win.pct(Audio.volume) + (Audio.muted ? "  [muted]" : "") + "   sinks: " + Audio.sinks.length : "n/a") }
        M3Text { text: "Battery    " + (Battery.present ? win.pct(Battery.percentage) + (Battery.charging ? " charging" : "") : "none (desktop/VM)") }
        M3Text { text: "Network    " + (Network.connected ? Network.type + " \"" + Network.name + "\"  signal " + Network.signal : "disconnected") + "   wifi radio: " + Network.wifiEnabled }
        M3Text { text: "Bluetooth  " + (Bt.available ? "enabled=" + Bt.enabled + "  connected: " + win.names(Bt.connectedDevices, "name") : "no adapter") }
        M3Text { text: "Brightness " + (Brightness.available ? win.pct(Brightness.value) : "n/a (no backlight / brightnessctl)") }
        M3Text { text: "System     cpu " + win.pct(SysStats.cpu) + "   mem " + SysStats.memUsedGb.toFixed(1) + "/" + SysStats.memTotalGb.toFixed(1) + " GB   up " + SysStats.uptime }
        M3Text { text: "Hyprland   ws " + Hypr.focusedId + "   existing: [" + Hypr.workspaceIds.join(",") + "]   \"" + Hypr.activeTitle + "\"" }
        M3Text { text: "Media      " + (Media.has ? (Media.playing ? "▶ " : "⏸ ") + Media.title + " - " + Media.artist + "  " + win.pct(Media.progress) : "no player") + "   players: " + Media.players.length }
        M3Text { text: "Notifs     " + Notifs.count + " tracked   dnd=" + Notifs.dnd }
        M3Text { text: "Tray       " + Tray.count + " items: " + win.names(Tray.items, "title") }

        M3Text { text: "Controls"; role: M3Type.titleLarge; Layout.topMargin: 12 }
        RowLayout {
            spacing: 12
            M3Text { text: "Volume" }
            M3Slider { Layout.preferredWidth: 240; value: Audio.volume; onMoved: v => Audio.setVolume(v) }
            M3Button { icon: Audio.muted ? "volume_off" : "volume_up"; variant: "tonal"; toggle: true; checked: Audio.muted; onClicked: Audio.toggleMute() }
        }
        RowLayout {
            spacing: 8
            M3Button { icon: "skip_previous"; variant: "tonal"; onClicked: Media.previous() }
            M3Button { icon: Media.playing ? "pause" : "play_arrow"; variant: "filled"; onClicked: Media.toggle() }
            M3Button { icon: "skip_next"; variant: "tonal"; onClicked: Media.next() }
            Item { Layout.preferredWidth: 24 }
            Repeater {
                model: [1, 2, 3, 4, 5]
                M3Button { required property int modelData; text: String(modelData); size: "xs"; variant: "tonal"; toggle: true; checked: Hypr.focusedId === modelData; onClicked: Hypr.goto(modelData) }
            }
        }
        RowLayout {
            spacing: 8
            M3Button { text: "Send test notification"; icon: "notifications"; variant: "outlined"; onClicked: notify.running = true }
            M3Button { text: "DND"; icon: "do_not_disturb_on"; variant: "tonal"; toggle: true; checked: Notifs.dnd; onClicked: Notifs.dnd = checked }
            M3Button { text: "Clear"; variant: "text"; onClicked: Notifs.dismissAll() }
            M3Button { text: "Wi-Fi"; icon: "wifi"; variant: "tonal"; toggle: true; checked: Network.wifiEnabled; onClicked: Network.toggleWifi() }
        }
        Item { Layout.fillHeight: true }
    }
}
