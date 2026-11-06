import QtQuick
import Quickshell
import Quickshell.Io

// Top-Left: Weather Card for lockscreen2
Rectangle {
    id: root

    property string condition: "Overcast"
    property string humidity: "76%"
    property string temp: "21°C"

    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -s --max-time 4 'wttr.in/?format=%C|%h|%t' 2>/dev/null || echo ''"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s.includes("|")) {
                    const p = s.split("|");
                    if (p[0]) root.condition = p[0].trim();
                    if (p[1]) root.humidity = p[1].trim();
                    if (p[2]) root.temp = p[2].trim().replace("+", "");
                }
            }
        }
    }

    Timer {
        interval: 1200000 // 20m
        running: true
        repeat: true
        onTriggered: weatherProc.running = true
    }

    implicitWidth: 260
    implicitHeight: 110
    radius: 18
    color: Colors.cardBg
    border.width: 1
    border.color: Colors.cardBorder

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        Text {
            text: "Weather"
            color: Colors.accent
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        Row {
            spacing: 14

            // Weather Icon (Vector Cloud)
            Canvas {
                width: 38
                height: 38
                anchors.verticalCenter: parent.verticalCenter
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = Colors.text;
                    ctx.lineWidth = 2.2;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    // Cloud outline
                    ctx.beginPath();
                    ctx.moveTo(9, 26);
                    ctx.lineTo(29, 26);
                    ctx.arc(29, 21, 5, 0.5 * Math.PI, 1.5 * Math.PI, true);
                    ctx.arc(22, 14, 7, 0, Math.PI, true);
                    ctx.arc(13, 17, 6, 1.2 * Math.PI, 0.8 * Math.PI, true);
                    ctx.arc(9, 22, 4, 1.5 * Math.PI, 0.5 * Math.PI, true);
                    ctx.closePath();
                    ctx.stroke();
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Text {
                    text: root.condition
                    color: Colors.text
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Text {
                    text: "Humidity: " + root.humidity + "  •  " + root.temp
                    color: Colors.sub
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }
        }
    }
}
