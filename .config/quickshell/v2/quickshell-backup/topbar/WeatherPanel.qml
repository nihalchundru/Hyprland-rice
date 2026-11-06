import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// ============================================================================
// WeatherPanel.qml — qs-weather
//
// Opens when the notch's weather arrow is clicked (Notch.weatherExpandRequested
// → wired up in shell.qml). Unlike the notch's own quick glance (which just
// wants current temp/condition), this panel pulls the richer wttr.in JSON
// endpoint for a full current-conditions + hourly + multi-day forecast view.
//
// Fetched lazily — only when the panel actually opens — rather than polling
// in the background the whole time, since this is a much heavier request
// than the notch's simple current-weather one-liner.
// ============================================================================

PanelWindow {
    id: panelRoot

    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8"
    })
    function c(key) {
        return (panelRoot.colors && panelRoot.colors[key]) ? panelRoot.colors[key] : "#888888"
    }

    property bool open: false
    // Auto-detected from the VM's public IP, same as Notch.qml's quick
    // glance — no city hardcoded here. `location` starts out as whatever
    // shell.qml initially binds it to (Notch's own detected location), then
    // gets overwritten with a more precise "City, Region" once this panel's
    // own richer JSON fetch resolves.
    property string location: "Locating…"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-weather"

    anchors { top: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1
    height: 560
    visible: open

    onOpenChanged: if (open) fetchProc.running = true

    // Click outside the card closes the panel.
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: panelRoot.open = false
    }

    // ------------------------------------------------------------------
    // Data
    // ------------------------------------------------------------------
    property bool loading: false
    property string curTemp: "--"
    property string curFeelsLike: "--"
    property string curDesc: "--"
    property string curIcon: "󰖙"
    property string curHumidity: "--"
    property string curWind: "--"
    property var hourly: []   // [{ time: "3 PM", temp: "71°", icon: "..." }, ...]
    property var daily: []    // [{ day: "Fri", high: "78°", low: "58°", icon: "..." }, ...]

    function weatherIconFor(desc) {
        var d = desc.toLowerCase()
        if (d.indexOf("thunder") !== -1) return "󰖓"
        if (d.indexOf("snow") !== -1)     return "󰖘"
        if (d.indexOf("rain") !== -1 || d.indexOf("drizzle") !== -1) return "󰖗"
        if (d.indexOf("cloud") !== -1 || d.indexOf("overcast") !== -1) return "󰖐"
        if (d.indexOf("clear") !== -1 || d.indexOf("sunny") !== -1) return "󰖙"
        return "󰖕"
    }

    function formatHour(militaryStr) {
        var h = Math.floor(parseInt(militaryStr, 10) / 100)
        var suffix = h >= 12 ? "PM" : "AM"
        var h12 = h % 12
        if (h12 === 0) h12 = 12
        return h12 + " " + suffix
    }

    function dayName(dateStr) {
        var d = new Date(dateStr)
        return Qt.formatDate(d, "ddd")
    }

    Process {
        id: fetchProc
        // No city in the path → wttr.in geolocates by request IP.
        command: ["bash", "-c", "curl -s 'wttr.in/?format=j1'"]
        stdout: StdioCollector {
            onStreamFinished: {
                panelRoot.loading = false
                try {
                    var data = JSON.parse(text)
                    var cur = data.current_condition[0]

                    if (data.nearest_area && data.nearest_area[0]) {
                        var area = data.nearest_area[0]
                        var areaName = area.areaName && area.areaName[0] ? area.areaName[0].value : ""
                        var region = area.region && area.region[0] ? area.region[0].value : ""
                        panelRoot.location = region.length > 0 ? (areaName + ", " + region) : areaName
                    }
                    panelRoot.curTemp = cur.temp_F + "°"
                    panelRoot.curFeelsLike = cur.FeelsLikeF + "°"
                    panelRoot.curDesc = cur.weatherDesc[0].value
                    panelRoot.curIcon = panelRoot.weatherIconFor(panelRoot.curDesc)
                    panelRoot.curHumidity = cur.humidity + "%"
                    panelRoot.curWind = cur.windspeedMiles + " mph"

                    // Today's remaining hourly forecast (up to 8 entries)
                    var hrs = []
                    if (data.weather && data.weather[0] && data.weather[0].hourly) {
                        var todaysHourly = data.weather[0].hourly
                        for (var i = 0; i < todaysHourly.length && hrs.length < 8; i++) {
                            var h = todaysHourly[i]
                            hrs.push({
                                time: panelRoot.formatHour(h.time),
                                temp: h.tempF + "°",
                                icon: panelRoot.weatherIconFor(h.weatherDesc[0].value)
                            })
                        }
                    }
                    panelRoot.hourly = hrs

                    // Next few days
                    var days = []
                    if (data.weather) {
                        for (var j = 0; j < data.weather.length; j++) {
                            var wd = data.weather[j]
                            days.push({
                                day: j === 0 ? "Today" : panelRoot.dayName(wd.date),
                                high: wd.maxtempF + "°",
                                low: wd.mintempF + "°",
                                icon: panelRoot.weatherIconFor(wd.hourly[4] ? wd.hourly[4].weatherDesc[0].value : "")
                            })
                        }
                    }
                    panelRoot.daily = days
                } catch (e) {
                    console.log("WeatherPanel: failed to parse forecast:", e)
                }
            }
        }
        onRunningChanged: if (running) panelRoot.loading = true
    }

    // ====================================================================
    // CARD
    // ====================================================================
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8 // floating pill, detached from the bezel
        width: 440
        height: panelRoot.open ? 520 : 0
        radius: 26 // full pill, all corners rounded
        color: panelRoot.c("bg")
        clip: true
        antialiasing: true

        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: {} } // swallow clicks, don't close-on-outside

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16

            // Header: location + close
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: panelRoot.location
                    color: panelRoot.c("sub")
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "\uf00d"
                    color: panelRoot.c("sub")
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelRoot.open = false
                    }
                }
            }

            // Current conditions
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    Text {
                        text: panelRoot.curIcon
                        font.pixelSize: 44
                        color: panelRoot.c("text")
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: panelRoot.curTemp
                        font.pixelSize: 44
                        font.bold: true
                        color: panelRoot.c("text")
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: panelRoot.curDesc
                    font.pixelSize: 15
                    color: panelRoot.c("sub")
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Feels like " + panelRoot.curFeelsLike + "  ·  Humidity " + panelRoot.curHumidity + "  ·  Wind " + panelRoot.curWind
                    font.pixelSize: 11
                    color: panelRoot.c("sub")
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Divider
            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.08) }

            // Hourly strip
            Text {
                text: "TODAY"
                font.pixelSize: 10
                font.bold: true
                color: panelRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                clip: true
                RowLayout {
                    spacing: 18
                    Repeater {
                        model: panelRoot.hourly
                        ColumnLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter
                            Text { Layout.alignment: Qt.AlignHCenter; text: modelData.time; font.pixelSize: 10; color: panelRoot.c("sub"); font.family: "JetBrainsMono Nerd Font" }
                            Text { Layout.alignment: Qt.AlignHCenter; text: modelData.icon; font.pixelSize: 18; color: panelRoot.c("text"); font.family: "JetBrainsMono Nerd Font" }
                            Text { Layout.alignment: Qt.AlignHCenter; text: modelData.temp; font.pixelSize: 12; font.bold: true; color: panelRoot.c("text"); font.family: "JetBrainsMono Nerd Font" }
                        }
                    }
                }
            }

            // Divider
            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.08) }

            // Multi-day forecast
            Text {
                text: "FORECAST"
                font.pixelSize: 10
                font.bold: true
                color: panelRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: panelRoot.daily
                    RowLayout {
                        Layout.fillWidth: true
                        Text { Layout.preferredWidth: 70; text: modelData.day; font.pixelSize: 13; color: panelRoot.c("text"); font.family: "JetBrainsMono Nerd Font" }
                        Text { Layout.fillWidth: true; text: modelData.icon; font.pixelSize: 16; color: panelRoot.c("text"); font.family: "JetBrainsMono Nerd Font" }
                        Text { text: modelData.low; font.pixelSize: 12; color: panelRoot.c("sub"); font.family: "JetBrainsMono Nerd Font" }
                        Text { text: modelData.high; font.pixelSize: 12; font.bold: true; color: panelRoot.c("text"); font.family: "JetBrainsMono Nerd Font"; Layout.leftMargin: 8 }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: panelRoot.loading
                text: "Loading forecast…"
                font.pixelSize: 11
                color: panelRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
}
