import QtQuick
import Quickshell.Bluetooth

// One control, drawn at whatever size it is given. Used by the real control
// center and by the settings editor's preview.
Item {
    id: root

    property string cid: ""
    property bool loaded: true

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var btConnected: Bluetooth.devices.values.find(d => d.connected) ?? null

    function pick(id) {
        switch (id) {
        case "wifi": return wifiC;
        case "focus": return focusC;
        case "lock": return lockC;
        case "bluetooth": return btC;
        case "game": return gameC;
        case "night": return nightC;
        case "sound": return soundC;
        case "display": return displayC;
        case "notifs": return notifsC;
        case "playing": return playingC;
        }
        return null;
    }

    Loader {
        anchors.fill: parent
        active: root.loaded && root.cid !== ""
        sourceComponent: root.pick(root.cid)
    }

    Component {
        id: wifiC
        ControlTile {
            icon: "wifi"
            title: "Wi-Fi"
            subtitle: !Net.hasWifi ? "No adapter" : !Net.radioOn ? "Off"
                    : Net.connected ? Net.ssid : "Not connected"
            active: Net.hasWifi && Net.radioOn
            onClicked: Pill.open("wifi", true)
            onToggled: Net.setRadio(!Net.radioOn)
        }
    }

    Component {
        id: focusC
        ControlTile {
            icon: "focus"
            title: "Focus"
            subtitle: Toggles.focus ? "On" : "Off"
            active: Toggles.focus
            onClicked: Toggles.focus = !Toggles.focus
            onToggled: Toggles.focus = !Toggles.focus
        }
    }

    Component {
        id: lockC
        ControlTile {
            icon: "lock"
            title: "Lock"
            subtitle: "Lock screen"
            onClicked: Toggles.lock()
            onToggled: Toggles.lock()
        }
    }

    Component {
        id: btC
        ControlTile {
            icon: "bluetooth"
            title: "Bluetooth"
            subtitle: !root.adapter ? "No adapter" : !root.adapter.enabled ? "Off"
                    : root.btConnected ? (root.btConnected.name || root.btConnected.deviceName) : "On"
            active: !!root.adapter && root.adapter.enabled
            onClicked: Pill.open("bluetooth", true)
            onToggled: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
        }
    }

    Component {
        id: gameC
        ControlTile {
            icon: "gamepad"
            title: "Game Mode"
            subtitle: Toggles.gameMode ? "On" : "Off"
            active: Toggles.gameMode
            onClicked: Toggles.setGameMode(!Toggles.gameMode)
            onToggled: Toggles.setGameMode(!Toggles.gameMode)
        }
    }

    Component {
        id: nightC
        ControlTile {
            icon: "moon"
            title: "Night Light"
            subtitle: NightLight.label
            active: NightLight.active
            onClicked: NightLight.cycle()
            onToggled: NightLight.toggle()
        }
    }

    Component {
        id: soundC
        SliderCard {
            title: "Sound"
            icon: Audio.mutedOf(Audio.sink) ? "volume-mute" : "volume"
            active: !!Audio.sink
            value: Audio.volumeOf(Audio.sink)
            onMoved: v => Audio.setVolume(Audio.sink, v)
            onOpened: Pill.open("sound", true)
        }
    }

    Component {
        id: displayC
        SliderCard {
            title: "Display"
            icon: "sun"
            active: Brightness.available
            value: Brightness.value
            onMoved: v => Brightness.set(v)
            onOpened: Pill.open("display", true)
        }
    }

    Component {
        id: notifsC
        NotifCard {}
    }

    Component {
        id: playingC
        NowPlayingCard {}
    }
}
