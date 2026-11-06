pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// wttr.in (IP-based location). Unit via tempUnit in config.json ("F" or "C").
Singleton {
    id: root
    property bool ready: false
    property int code: 113
    property string desc: ""
    property string city: ""
    property real tempC: 0
    readonly property int temp: Math.round(M3Config.tempUnit === "F" ? tempC * 9 / 5 + 32 : tempC)
    readonly property string icon: {
        const c = code
        if (c === 113) return "wb_sunny"
        if (c === 116) return "partly_cloudy_day"
        if (c === 119 || c === 122) return "cloud"
        if ([143, 248, 260].includes(c)) return "foggy"
        if ([200, 386, 389, 392, 395].includes(c)) return "thunderstorm"
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(c)) return "weather_snowy"
        if ([182, 185, 281, 284, 311, 314, 317, 320, 350, 362, 365, 374, 377].includes(c)) return "weather_mix"
        return "rainy"
    }

    function refresh() { if (!proc.running) proc.running = true }

    Process {
        id: proc
        command: ["curl", "-sf", "-m", "10", "wttr.in/" + encodeURIComponent(M3Config.weatherLocation) + "?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text), c = j.current_condition[0]
                    root.tempC = parseFloat(c.temp_C)
                    root.code = parseInt(c.weatherCode)
                    root.desc = c.weatherDesc[0].value
                    root.city = j.nearest_area[0].areaName[0].value
                    root.ready = true
                } catch (e) {}
            }
        }
    }
    Connections { target: M3Config; function onWeatherLocationChanged() { relocate.restart() } }
    Timer { id: relocate; interval: 800; onTriggered: root.refresh() }
    Timer { interval: 1800000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refresh() }
}
