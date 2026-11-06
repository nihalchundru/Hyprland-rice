import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.tokens
import qs.components
import qs.services

// Run: qs -c m3 -p tests/stage3.qml  — prints every service's state live; logs to console once per 5s.
FloatingWindow {
    id: win
    title: "m3-stage3"
    color: M3Colors.surface
    implicitWidth: 760
    implicitHeight: 700

    Component.onCompleted: { SysStats.watch = true; Weather.watch = true; Network.scan() }

    function row(k, v) { return { k: k, v: String(v) } }
    readonly property var rows: [
        row("Time", Time.timeSec + "  " + Time.dateLong),
        row("Audio", Math.round(Audio.volume * 100) + "%  muted=" + Audio.muted + "  icon=" + Audio.icon),
        row("Brightness", Brightness.available ? Math.round(Brightness.value * 100) + "%" : "n/a (brightnessctl?)"),
        row("Battery", Power.hasBattery ? Math.round(Power.percent * 100) + "% charging=" + Power.charging : "no battery"),
        row("Profile", Power.profileName),
        row("Network", Network.type + " " + Network.ssid + " " + Network.signal + "%  wifi=" + Network.wifiEnabled + "  scan=" + Network.networks.length),
        row("Bluetooth", Bluetooth.available ? Bluetooth.summary : "no adapter"),
        row("Media", Media.active ? Media.artist + " — " + Media.title + (Media.playing ? " ▶" : " ⏸") : "no player"),
        row("Notifs", Notifs.count + " tracked, " + Notifs.popups.length + " popups, dnd=" + Notifs.dnd),
        row("Tray", Tray.count + " items"),
        row("Hyprland", "ws " + Hypr.activeId + " | " + Hypr.windowTitle),
        row("CPU/RAM", Math.round(SysStats.cpu * 100) + "% / " + SysStats.ramUsedGb.toFixed(1) + "G of " + SysStats.ramTotalGb.toFixed(1) + "G  disk " + Math.round(SysStats.disk * 100) + "%  " + SysStats.temp.toFixed(0) + "°C"),
        row("Weather", Weather.ready ? Weather.city + " " + Weather.tempC + "°C " + Weather.desc + " (" + Weather.icon + ")" : "loading…")
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 8
        M3Text { text: "Stage 3 — services"; font: Type.headlineSmall }
        Repeater {
            model: win.rows
            RowLayout {
                spacing: 16
                M3Text { text: modelData.k; Layout.preferredWidth: 110; color: M3Colors.primary }
                M3Text { text: modelData.v; Layout.fillWidth: true; elide: Text.ElideRight }
            }
        }
        RowLayout {
            spacing: 8
            M3Button { text: "Vol +"; variant: "tonal"; onClicked: Audio.setVolume(Audio.volume + 0.1) }
            M3Button { text: "Vol −"; variant: "tonal"; onClicked: Audio.setVolume(Audio.volume - 0.1) }
            M3Button { text: "Mute"; variant: "tonal"; onClicked: Audio.toggleMute() }
            M3Button { text: "Bright +"; variant: "tonal"; onClicked: Brightness.set(Brightness.value + 0.1) }
            M3Button { text: "Profile"; variant: "tonal"; onClicked: Power.cycleProfile() }
            M3Button { text: "Play/Pause"; variant: "tonal"; onClicked: Media.toggle() }
            M3Button { text: "Notify"; variant: "outlined"; onClicked: Quickshell.execDetached(["notify-send", "m3 test", "Hello from stage 3"]) }
        }
        Item { Layout.fillHeight: true }
    }
}
