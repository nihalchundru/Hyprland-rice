import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    SScroll {
        SCard {
            title: "Appearance"
            ChipsRow { icon: "contrast"; title: "Theme"; options: ["dark", "light"]; value: M3Config.mode; onPicked: v => M3Config.mode = v }
            ChipsRow { icon: "palette"; title: "Color scheme"; options: ["tonal-spot", "content", "expressive", "fidelity", "fruit-salad", "monochrome", "neutral", "rainbow"]; value: M3Config.scheme; onPicked: v => M3Config.scheme = v }
            SRow { icon: "wallpaper"; title: "Wallpaper"; sub: "Pick from your wallpaper folders"; M3Button { text: "Open picker"; variant: "tonal"; onClicked: { UiState.settingsOpen = false; UiState.wallpaperOpen = true } } }
        }
        SCard {
            title: "Toggles"
            SwitchRow { icon: "call_to_action"; title: "Floating bar"; checked: M3Config.barFloating; onToggled: v => M3Config.barFloating = v }
            SwitchRow { icon: "do_not_disturb_on"; title: "Do not disturb"; checked: Notifs.dnd; onToggled: v => Notifs.dnd = v }
            SwitchRow { icon: "wifi"; title: "Wi-Fi"; sub: Network.connected ? Network.name : "Not connected"; checked: Network.wifiEnabled; onToggled: v => Network.setWifi(v) }
            SwitchRow { icon: "bluetooth"; title: "Bluetooth"; sub: Bt.available ? "" : "No adapter"; enabled: Bt.available; checked: Bt.enabled; onToggled: v => { if (v !== Bt.enabled) Bt.toggle() } }
        }
        SCard {
            title: "Sound and light"
            SliderRow { icon: Audio.icon; title: "Volume"; value: Audio.volume; displayScale: 100; suffix: "%"; onPicked: v => Audio.setVolume(v) }
            SliderRow { visible: Brightness.available; icon: "brightness_6"; title: "Brightness"; value: Brightness.value; displayScale: 100; suffix: "%"; onPicked: v => Brightness.set(v) }
        }
    }
}
