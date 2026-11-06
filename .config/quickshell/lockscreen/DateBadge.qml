import QtQuick
import Quickshell
import Quickshell.Io

// Material 3 Date Pill with Dynamic Google Weather Icon (set-6 dark)
Item {
    id: root

    property date now: new Date()

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property string formattedDate: {
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        return days[now.getDay()] + ", " + months[now.getMonth()] + " " + now.getDate();
    }

    // --- Weather Fetching & Mapping (set-6 dark) ---
    property string weatherCondition: ""
    property string temperature: ""
    property string weatherIcon: ""
    readonly property bool hasWeather: temperature.length > 0 && weatherIcon.length > 0

    function mapWeatherIcon(cond) {
        if (!cond) return "sunny.svg";
        const hr = new Date().getHours();
        const isNight = hr < 6 || hr >= 19;
        const c = cond.toLowerCase().trim();

        if (c.includes("thunder") || c.includes("lightning") || c.includes("storm")) return "strong_thunderstorms.svg";
        if (c.includes("drizzle") || c.includes("light rain") || c.includes("shower")) return "drizzle.svg";
        if (c.includes("heavy rain")) return "heavy_rain.svg";
        if (c.includes("rain")) return "heavy_rain.svg";
        if (c.includes("flurries") || c.includes("light snow")) return "flurries.svg";
        if (c.includes("heavy snow") || c.includes("blizzard")) return "heavy_snow.svg";
        if (c.includes("snow")) return "heavy_snow.svg";
        if (c.includes("sleet") || c.includes("hail")) return "sleet_hail.svg";
        if (c.includes("ice") || c.includes("icy") || c.includes("freezing")) return "icy.svg";
        if (c.includes("wind") || c.includes("breeze") || c.includes("gale")) return "windy.svg";
        if (c.includes("tornado")) return "tornado.svg";
        if (c.includes("hurricane")) return "hurricane.svg";
        if (c.includes("mostly sunny") || c.includes("mostly clear")) return isNight ? "mostly_clear_night.svg" : "mostly_sunny.svg";
        if (c.includes("partly") || c.includes("scattered")) return isNight ? "partly_cloudy_night.svg" : "partly_cloudy.svg";
        if (c.includes("mostly cloudy")) return isNight ? "mostly_cloudy_night.svg" : "partly_cloudy.svg";
        if (c.includes("cloud") || c.includes("overcast") || c.includes("fog") || c.includes("mist") || c.includes("haze")) return "cloudy.svg";
        if (c.includes("clear") || c.includes("sun")) return isNight ? "clear_night.svg" : "sunny.svg";
        return isNight ? "clear_night.svg" : "sunny.svg";
    }

    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s --max-time 4 'wttr.in/?format=%C|%t' 2>/dev/null || echo ''"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s.includes("|")) {
                    const parts = s.split("|");
                    const cond = parts[0].trim();
                    let temp = parts[1].trim().replace("+", "");
                    if (cond && temp) {
                        root.weatherCondition = cond;
                        root.temperature = temp;
                        root.weatherIcon = root.mapWeatherIcon(cond);
                    }
                }
            }
        }
    }

    // Refresh weather every 20 minutes
    Timer {
        interval: 1200000
        running: true
        repeat: true
        onTriggered: weatherProcess.running = true
    }

    implicitWidth: pill.width
    implicitHeight: pill.height

    Rectangle {
        id: pill
        width: row.implicitWidth + 28
        height: 38
        radius: height / 2
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.75)
        border.width: 1
        border.color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12)

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 10

            // Decorative Material 3 accent dot
            Rectangle {
                width: 7
                height: 7
                radius: 3.5
                color: Colors.accent
                anchors.verticalCenter: parent.verticalCenter
            }

            // Date Text
            Text {
                text: root.formattedDate
                color: Colors.text
                font.pixelSize: 14
                font.weight: Font.DemiBold
                font.letterSpacing: 0.2
                anchors.verticalCenter: parent.verticalCenter
            }

            // --- Weather Section (Google Weather set-6 dark) ---
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                visible: root.hasWeather

                // Subtle divider
                Rectangle {
                    width: 1
                    height: 14
                    color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.2)
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Dynamic Google Weather SVG Icon
                Image {
                    width: 22
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    source: root.weatherIcon ? "weather-icons/" + root.weatherIcon : ""
                    sourceSize.width: 44
                    sourceSize.height: 44
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }

                // Temperature
                Text {
                    text: root.temperature
                    color: Colors.text
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
