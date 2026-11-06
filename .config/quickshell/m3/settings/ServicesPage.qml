import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    readonly property var sinkNames: Audio.sinks.map(n => n.description || n.nickname || n.name)
    SScroll {
        SCard {
            title: "Audio"
            DropdownRow {
                icon: "speaker"; title: "Output device"
                options: sinkNames
                value: Audio.sinkName
                onPicked: v => { const n = Audio.sinks.find(x => (x.description || x.nickname || x.name) === v); if (n) Audio.setDefaultSink(n) }
            }
            SliderRow { icon: Audio.icon; title: "Volume"; value: Audio.volume; displayScale: 100; suffix: "%"; onPicked: v => Audio.setVolume(v) }
            SwitchRow { icon: "volume_off"; title: "Mute output"; checked: Audio.muted; onToggled: v => { if (v !== Audio.muted) Audio.toggleMute() } }
            SwitchRow { icon: "mic_off"; title: "Mute microphone"; checked: Audio.micMuted; onToggled: v => { if (v !== Audio.micMuted) Audio.toggleMic() } }
        }
        SCard {
            title: "Network and Bluetooth"
            SwitchRow { icon: "wifi"; title: "Wi-Fi"; sub: Network.connected ? (Network.type === "ethernet" ? "Ethernet: " : "Connected to ") + Network.name : "Not connected"; checked: Network.wifiEnabled; onToggled: v => Network.setWifi(v) }
            SwitchRow { icon: "bluetooth"; title: "Bluetooth"; sub: !Bt.available ? "No adapter found" : (Bt.connectedDevices.length > 0 ? Bt.connectedDevices.map(d => d.name).join(", ") : "No devices connected"); enabled: Bt.available; checked: Bt.enabled; onToggled: v => { if (v !== Bt.enabled) Bt.toggle() } }
        }
        SCard {
            title: "Notifications"
            SwitchRow { icon: "do_not_disturb_on"; title: "Do not disturb"; checked: Notifs.dnd; onToggled: v => Notifs.dnd = v }
            SRow { icon: "clear_all"; title: "Clear all"; sub: Notifs.count + " notifications"; M3Button { text: "Clear"; variant: "tonal"; onClicked: Notifs.dismissAll() } }
        }
        SCard {
            title: "Music visualizer (cava)"
            ChipsRow { icon: "graphic_eq"; title: "Audio input backend"; options: ["pulse", "pipewire"]; value: M3Config.cavaMethod; onPicked: v => { M3Config.cavaMethod = v; Cava.restart() } }
            SRow { icon: "restart_alt"; title: "Restart cava"; sub: Cava.failed ? "cava did not start. Is it installed?" : (Cava.running ? "Running" : "Not running (no visualizer widget)"); M3Button { text: "Restart"; variant: "tonal"; onClicked: Cava.restart() } }
        }
        SCard {
            title: "Colors"
            SRow { icon: "palette"; title: "Re-run matugen"; sub: "Regenerate the palette from the current wallpaper"; M3Button { text: "Run"; variant: "tonal"; onClicked: Matugen.run() } }
        }
    }
}
