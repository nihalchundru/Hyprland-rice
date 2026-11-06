import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// Full-screen Material 3 lock surface.
Item {
    id: root

    signal unlocked

    property string password: ""
    property bool error: false
    property bool busy: false

    readonly property string home: Quickshell.env("HOME")
    readonly property string user: {
        var segs = home.split("/").filter(s => s.length > 0)
        return segs.length ? segs[segs.length - 1] : "user"
    }

    // ---- colors from ~/.config/quickshell/topbar/colors.json ----------
    // Same FileView/JsonAdapter pattern as the topbar theme singleton:
    // async read, watched for changes, bindings update live.
    FileView {
        path: root.home + "/.config/quickshell/topbar/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: c
            property string bg: "#141218"
            property string bg2: "#1d1b20"
            property string surface: "#2b2930"
            property string surface2: "#36343b"
            property string text: "#e6e0e9"
            property string sub: "#938f99"
            property string accent: "#d0bcff"
            property string red: "#f2b8b5"
            property string teal: "#93d2a6"
            property string yellow: "#e5c07b"
        }
    }

    // ---- PAM ----------------------------------------------------------
    // Requires the setuid qs-pam helper (see README).
    PamContext {
        id: pam
        config: "login"

        // PAM asked for input (the password prompt) -> hand it what was typed
        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(root.password)
        }

        onCompleted: (result) => {
            root.busy = false
            if (result === PamResult.Success) {
                root.unlocked()
            } else {
                root.error = true
                root.password = ""
                pin.clear()
            }
        }

        onError: (err) => {
            root.busy = false
            root.error = true
            root.password = ""
            pin.clear()
            console.error("PAM error:", err)
        }
    }

    function submit() {
        if (root.password.length === 0 || root.busy) return
        root.busy = true
        pam.start()
    }

    // ---- weather: geojs.io IP geolocation -> Open-Meteo ---------------
    property var wx: ({ ok: false, icon: "", temp: "", desc: "" })
    readonly property string iconsDir: home + "/.config/quickshell/materiallock/icons/"

    // set-6 (outlined + gradient) icon names, day/night aware
    function wmoIcon(code, isDay) {
        if (code === 0) return isDay ? "sunny.svg" : "clear_night.svg"
        if (code === 1) return isDay ? "mostly_sunny.svg" : "mostly_clear_night.svg"
        if (code === 2) return isDay ? "partly_cloudy.svg" : "partly_cloudy_night.svg"
        if (code === 3) return "cloudy.svg"
        if (code === 45 || code === 48) return "cloudy.svg"
        if (code >= 51 && code <= 57) return "drizzle.svg"
        if (code === 66 || code === 67) return "sleet_hail.svg"
        if (code >= 61 && code <= 65) return "heavy_rain.svg"
        if (code === 71 || code === 73 || code === 77) return "flurries.svg"
        if (code === 75) return "heavy_snow.svg"
        if (code >= 80 && code <= 82) return "heavy_rain.svg"
        if (code === 85 || code === 86) return "heavy_snow.svg"
        if (code >= 95) return "strong_thunderstorms.svg"
        return "cloudy.svg"
    }

    function wmoDesc(code) {
        if (code === 0) return "Clear"
        if (code === 1) return "Mostly clear"
        if (code === 2) return "Partly cloudy"
        if (code === 3) return "Overcast"
        if (code === 45 || code === 48) return "Fog"
        if (code >= 51 && code <= 57) return "Drizzle"
        if (code >= 61 && code <= 67) return "Rain"
        if (code >= 71 && code <= 77) return "Snow"
        if (code >= 80 && code <= 82) return "Showers"
        if (code === 85 || code === 86) return "Snow showers"
        if (code >= 95) return "Thunderstorm"
        return "Weather"
    }

    function httpJson(url, cb) {
        var x = new XMLHttpRequest()
        x.open("GET", url, true)
        x.timeout = 6000
        x.onreadystatechange = function () {
            // only react once the response is fully received; status is
            // already 200 at HEADERS_RECEIVED while responseText is empty
            if (x.readyState !== XMLHttpRequest.DONE) return
            if (x.status === 200) {
                try { cb(null, JSON.parse(x.responseText)) } catch (e) { cb(e, null) }
            } else {
                cb(new Error("http " + x.status), null)
            }
        }
        x.send()
    }

    function fetchWeather() {
        httpJson("https://get.geojs.io/v1/ip/geo.json", function (err, geo) {
            if (err || !geo || !geo.latitude) {
                console.warn("qs-lock: geolocation failed:", err)
                return
            }
            httpJson("https://api.open-meteo.com/v1/forecast?latitude="
                     + encodeURIComponent(geo.latitude)
                     + "&longitude=" + encodeURIComponent(geo.longitude)
                     + "&current=temperature_2m,weather_code,is_day",
                     function (err2, w) {
                if (err2 || !w || !w.current) {
                    console.warn("qs-lock: weather fetch failed:", err2)
                    return
                }
                var code = w.current.weather_code
                var celsius = w.current.temperature_2m
                root.wx = {
                    ok: true,
                    icon: root.iconsDir + wmoIcon(code, w.current.is_day === 1),
                    temp: Math.round(celsius * 9 / 5 + 32) + "\u00B0F",
                    desc: wmoDesc(code)
                }
            })
        })
    }

    Component.onCompleted: fetchWeather()

    Timer {
        id: errorReset
        interval: 1800
        onTriggered: root.error = false
    }

    // ---- background: blurred wallpaper + dark scrim -------------------
    Rectangle {
        anchors.fill: parent
        color: c.bg
    }

    Image {
        id: bgImg
        anchors.fill: parent
        source: root.home + "/.config/rofi/images/a.png"
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }

    MultiEffect {
        anchors.fill: bgImg
        source: bgImg
        blurEnabled: true
        blur: 1.0
        blurMax: 48
        autoPaddingEnabled: false
        opacity: bgImg.status === Image.Ready ? 1.0 : 0.0
    }

    // scrim so text stays readable over the blurred image
    Rectangle {
        anchors.fill: parent
        color: c.bg
        opacity: bgImg.status === Image.Ready ? 0.55 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    // ---- shake feedback on auth failure --------------------------------
    // animated via a Translate transform: animating x directly would clash
    // with anchors
    property real shakeX: 0

    SequentialAnimation {
        id: shake
        NumberAnimation { target: root; property: "shakeX"; to: -12; duration: 45 }
        NumberAnimation { target: root; property: "shakeX"; to: 12; duration: 45 }
        NumberAnimation { target: root; property: "shakeX"; to: -7; duration: 45 }
        NumberAnimation { target: root; property: "shakeX"; to: 0; duration: 45 }
    }
    onErrorChanged: if (error) { shake.restart(); errorReset.restart() }

    // ---- layout --------------------------------------------------------
    Column {
        id: col
        anchors.centerIn: parent
        spacing: 36

        Clock {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(root.width, root.height) * 0.55
            height: width
            dialColor: c.surface
            hourColor: c.text
            minuteColor: c.red
            secondColor: c.accent
            hourDigitColor: c.teal
            minuteDigitColor: c.yellow
            meridiemColor: c.sub
            hubColor: c.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "dddd, d MMMM") + "  ·  " + root.user
            color: c.sub
            font.pixelSize: 16
            font.letterSpacing: 1
        }

        // ---- password field + circular enter button --------------------
        Row {
            id: fieldRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14
            transform: Translate { x: root.shakeX } // only the field shakes

            Rectangle {
                id: field
                width: Math.max(pin.implicitWidth + 96, 360)
                height: 64
                radius: 28
                color: c.surface2
                border.width: 1
                border.color: root.error ? c.red : c.sub
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: c.accent
                    opacity: root.busy ? 0.25 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                PinField {
                    id: pin
                    anchors.centerIn: parent
                    error: root.error
                    badgeColor: c.accent
                    errorColor: c.red
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 22
                    visible: pin.count === 0 && !root.busy
                    text: "Password"
                    color: c.sub
                    font.pixelSize: 16
                }
                // loading circle while PAM is verifying
                Canvas {
                    id: spinner
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    width: 26
                    height: 26
                    visible: root.busy
                    antialiasing: true

                    property real ang: 0
                    onAngChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = c.accent
                        ctx.lineWidth = 3
                        ctx.lineCap = "round"
                        ctx.beginPath()
                        ctx.arc(width / 2, height / 2, width / 2 - 2,
                                ang * Math.PI / 180, (ang + 270) * Math.PI / 180)
                        ctx.stroke()
                    }

                    NumberAnimation on ang {
                        running: spinner.visible
                        from: 0; to: 360
                        duration: 900
                        loops: Animation.Infinite
                    }
                }
            }

            // clickable circle with the sheet's Arrow shape, pointing right
            Rectangle {
                id: enterBtn
                width: field.height
                height: field.height
                radius: width / 2
                color: root.error ? c.red : c.accent
                scale: enterArea.containsMouse ? 1.06 : 1.0
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 200 } }

                ShapeBadge {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    shape: "arrow"
                    shapeColor: c.bg
                    rotation: 90
                }

                MouseArea {
                    id: enterArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submit()
                }
            }
        }
    }

    // weather chip: clock stays dead-centre, chip pushed out to its side.
    // Explicit x/y from the column geometry: anchoring a root child across
    // parents to a Column-managed item does not resolve.
    WeatherChip {
        id: weather
        x: Math.min(col.x + clock.x + clock.width + 56, root.width - width - 24)
        y: col.y + clock.y + clock.height / 2 - height / 2
        width: clock.width * 0.45
        height: width
        visible: root.wx.ok
        opacity: root.wx.ok ? 1.0 : 0.0
        chipColor: c.surface2
        textColor: c.text
        iconSource: root.wx.icon
        temp: root.wx.temp
        desc: root.wx.desc
    }

    // CPU/RAM/Battery cookie chips, right-aligned to the clock's left side
    SystemChip {
        id: sysmon
        chipSize: clock.width * 0.30
        x: Math.max(24, col.x + clock.x - 56 - implicitWidth)
        y: col.y + clock.y + clock.height / 2 - height / 2
        chipColor: c.surface2
        textColor: c.text
        subColor: c.sub
        iconsDir: root.iconsDir
        iconColor: c.bg
    }

    // ---- keyboard ------------------------------------------------------
    // Shapes are the display; the real chars live in root.password.
    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Backspace) {
                root.password = root.password.slice(0, -1)
                pin.release()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.submit()
                event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
                root.password = ""
                pin.clear()
                event.accepted = true
            } else if (event.text.length === 1 && event.text.charCodeAt(0) >= 0x20) {
                root.password += event.text
                pin.press()
                event.accepted = true
            }
        }
    }
}
