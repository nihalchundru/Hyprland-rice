import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "."

// Bottom-Left Status Pill for Deck lockscreen:
// Weather, Battery & Network glanceables
Rectangle {
    id: root

    property string weatherTemp: "24°C"
    property string weatherCond: "Cloudy"

    // Live weather check
    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -s --max-time 3 'wttr.in/?format=%C|%t' 2>/dev/null || echo ''"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s.includes("|")) {
                    const parts = s.split("|");
                    if (parts[0]) root.weatherCond = parts[0].trim();
                    if (parts[1]) root.weatherTemp = parts[1].trim().replace("+", "");
                }
            }
        }
    }

    // Battery
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery !== null && battery.isRechargeable
    readonly property int batteryPct: hasBattery ?
        Math.round(battery.percentage <= 1.0 ? battery.percentage * 100 : battery.percentage) : 100

    implicitHeight: 44
    implicitWidth: pillRow.implicitWidth + 32
    radius: 22
    color: Colors.cardBg
    border.width: 1
    border.color: Colors.cardBorder

    Row {
        id: pillRow
        anchors.centerIn: parent
        spacing: 12

        // Weather
        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "☁"
                color: Colors.text
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.weatherTemp
                color: Colors.text
                font.pixelSize: 13
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            text: "•"
            color: Colors.sub
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        // Battery
        Row {
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "⚡"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.batteryPct + "%"
                color: Colors.teal
                font.pixelSize: 13
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            text: "•"
            color: Colors.sub
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        // WiFi
        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "󰤨"
                color: Colors.text
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Online"
                color: Colors.text
                font.pixelSize: 13
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
