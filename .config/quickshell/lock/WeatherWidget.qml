import Quickshell
import Quickshell.Io
import QtQuick

// Current conditions in a Material 3 pill.
//
// Open-Meteo is used because it needs no API key. Data comes back through curl
// rather than a built-in HTTP client, so curl must be installed.
//
// The condition icon is itself an M3 shape, drawn from the WMO weather code --
// so the weather widget speaks the same visual language as everything else.
Item {
    id: root

    implicitWidth: row.implicitWidth + 44
    implicitHeight: 56

    property real temperature: NaN
    property int weatherCode: -1
    property bool isDay: true
    property bool loaded: false

    readonly property bool available: root.loaded

    function shapeForCode(code, day) {
        if (code < 0) return "circle";
        if (code === 0) return day ? "sunny" : "circle";
        if (code <= 2) return "very_sunny";
        if (code === 3) return "cookie12";
        if (code <= 48) return "pill";      // fog
        if (code <= 57) return "cookie9";   // drizzle
        if (code <= 67) return "cookie7";   // rain
        if (code <= 77) return "star12";    // snow
        if (code <= 82) return "cookie7";   // rain showers
        if (code <= 86) return "star12";    // snow showers
        return "star";                      // thunderstorm
    }

    function labelForCode(code) {
        if (code < 0) return "…";
        if (code === 0) return "Clear";
        if (code === 1) return "Mainly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Fog";
        if (code <= 55) return "Drizzle";
        if (code <= 57) return "Freezing drizzle";
        if (code <= 65) return "Rain";
        if (code <= 67) return "Freezing rain";
        if (code <= 75) return "Snow";
        if (code === 77) return "Snow grains";
        if (code <= 82) return "Rain showers";
        if (code <= 86) return "Snow showers";
        return "Thunderstorm";
    }

    M3Shape {
        anchors.fill: parent
        kind: "pill"
        fillColor: M3Theme.palette.tertiaryContainer
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 12

        M3Shape {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            kind: root.shapeForCode(root.weatherCode, root.isDay)
            fillColor: M3Theme.palette.onTertiaryContainer
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: root.available ? Math.round(root.temperature) + "°" : "—°"
                color: M3Theme.palette.onTertiaryContainer
                font.family: M3Theme.font
                font.pixelSize: 22
                font.weight: Font.Medium
            }

            Text {
                text: root.available
                    ? root.labelForCode(root.weatherCode)
                    : (Config.weatherEnabled ? "loading" : "disabled")
                color: M3Theme.palette.onTertiaryContainer
                opacity: 0.72
                font.family: M3Theme.font
                font.pixelSize: 11
            }
        }
    }

    Process {
        id: fetch

        command: [
            "curl", "-fsS", "--max-time", "10",
            "https://api.open-meteo.com/v1/forecast?latitude=" + Config.latitude
                + "&longitude=" + Config.longitude
                + "&current=temperature_2m,weather_code,is_day&timezone=auto"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data && data.current) {
                        root.temperature = data.current.temperature_2m;
                        root.weatherCode = data.current.weather_code;
                        root.isDay = data.current.is_day === 1;
                        root.loaded = true;
                    }
                } catch (e) {
                    // keep the last good reading rather than blanking out
                    console.warn("quickshell-lock: weather parse failed", e);
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("quickshell-lock: weather fetch exited", exitCode);
        }
    }

    Timer {
        interval: Math.max(1, Config.weatherRefreshMinutes) * 60000
        running: Config.weatherEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: fetch.running = true
    }
}
