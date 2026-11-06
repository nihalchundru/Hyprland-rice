pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // set by widgets
    property int users: 0
    property string location: "auto"     // "auto" or a city name
    property string units: "metric"      // "metric" or "imperial"

    // state
    property bool ready: false
    property bool failed: false
    property real temp: 0
    property int code: 0
    property string place: ""
    property double updated: 0

    property real lat: 0
    property real lon: 0
    property string geoKey: ""           // what lat/lon currently correspond to
    property double geoTime: 0
    property string geoRequest: ""

    readonly property string description: describe(code)

    function describe(c) {
        if (c === 0) return "Clear sky";
        if (c === 1) return "Mainly clear";
        if (c === 2) return "Partly cloudy";
        if (c === 3) return "Overcast";
        if (c === 45 || c === 48) return "Fog";
        if (c >= 51 && c <= 57) return "Drizzle";
        if (c >= 61 && c <= 65) return "Rain";
        if (c === 66 || c === 67) return "Freezing rain";
        if (c >= 71 && c <= 77) return "Snow";
        if (c >= 80 && c <= 82) return "Rain showers";
        if (c === 85 || c === 86) return "Snow showers";
        if (c >= 95) return "Thunderstorm";
        return "Unknown";
    }

    function refresh() {
        if (users <= 0 || geo.running) return;
        const needGeo = geoKey !== location
            || (location === "auto" && Date.now() - geoTime > 86400000);
        if (needGeo) resolve(); else fetchWeather();
    }

    function resolve() {
        geoRequest = location;
        if (location === "auto")
            geo.command = ["curl", "-fsS", "--max-time", "10", "https://ipwho.is/"];
        else
            geo.command = ["curl", "-fsS", "--max-time", "10",
                "https://geocoding-api.open-meteo.com/v1/search?count=1&name="
                + encodeURIComponent(location)];
        geo.running = true;
    }

    function fetchWeather() {
        if (wx.running) return;
        const unit = units === "imperial" ? "fahrenheit" : "celsius";
        wx.command = ["curl", "-fsS", "--max-time", "10",
            "https://api.open-meteo.com/v1/forecast?latitude=" + lat
            + "&longitude=" + lon
            + "&current=temperature_2m,weather_code&temperature_unit=" + unit];
        wx.running = true;
    }

    function handleGeo(text) {
        try {
            const j = JSON.parse(text);
            let la, lo, name;
            if (geoRequest === "auto") {
                la = j.latitude; lo = j.longitude; name = j.city ?? "";
            } else {
                const r = j.results[0];
                la = r.latitude; lo = r.longitude; name = r.name;
            }
            if (typeof la !== "number" || typeof lo !== "number")
                throw new Error("no coordinates");
            lat = la; lon = lo; place = name;
            geoKey = geoRequest;
            geoTime = Date.now();
            fetchWeather();
        } catch (e) {
            failed = true;
            console.warn("Weather: location lookup failed:", e);
        }
    }

    function handleWeather(text) {
        try {
            const j = JSON.parse(text);
            temp = j.current.temperature_2m;
            code = j.current.weather_code;
            updated = Date.now();
            ready = true;
            failed = false;
        } catch (e) {
            failed = true;
            console.warn("Weather: fetch failed:", e);
        }
    }

    onLocationChanged: refresh()
    onUnitsChanged: refresh()

    Process {
        id: geo
        stdout: StdioCollector { onStreamFinished: root.handleGeo(text) }
    }

    Process {
        id: wx
        stdout: StdioCollector { onStreamFinished: root.handleWeather(text) }
    }

    Timer {
        interval: 20 * 60 * 1000
        repeat: true
        running: root.users > 0
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}