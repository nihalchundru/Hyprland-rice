import QtQuick
import Quickshell
import Quickshell.Io

// Mid-Left: Fastfetch System Info Card for lockscreen2
Rectangle {
    id: root

    property string osName: "Arch Linux"
    property string wmName: "Hyprland"
    property string userName: Quickshell.env("USER") || "user"
    property string uptime: "25 minutes"

    Process {
        id: infoProc
        command: ["sh", "-c", "echo \"$(grep -E '^NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"' || echo 'Linux')|${XDG_CURRENT_DESKTOP:-Hyprland}|${USER:-user}|$(uptime -p 2>/dev/null | sed 's/up //' || echo 'active')\""]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s.includes("|")) {
                    const parts = s.split("|");
                    if (parts[0]) root.osName = parts[0];
                    if (parts[1]) root.wmName = parts[1];
                    if (parts[2]) root.userName = parts[2];
                    if (parts[3]) root.uptime = parts[3];
                }
            }
        }
    }

    implicitWidth: 260
    implicitHeight: 165
    radius: 18
    color: Colors.cardBg
    border.width: 1
    border.color: Colors.cardBorder

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Header chip: > fastfetch
        Rectangle {
            height: 22
            width: headRow.implicitWidth + 14
            radius: 6
            color: Qt.rgba(0.32, 0.85, 0.72, 0.12)

            Row {
                id: headRow
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: ">"
                    color: Colors.accent
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "monospace"
                }

                Text {
                    text: "fastfetch"
                    color: Colors.text
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.family: "monospace"
                }
            }
        }

        // Body: Logo + Info Table
        Row {
            width: parent.width
            spacing: 16

            // Arch Linux Vector Logo
            Canvas {
                width: 46
                height: 52
                anchors.verticalCenter: parent.verticalCenter
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Colors.accent;

                    // Arch A silhouette
                    ctx.beginPath();
                    ctx.moveTo(23, 4);
                    ctx.lineTo(43, 46);
                    ctx.lineTo(33, 46);
                    ctx.lineTo(29, 37);
                    ctx.bezierCurveTo(24, 39, 18, 41, 13, 46);
                    ctx.lineTo(3, 46);
                    ctx.closePath();

                    // Inner curve cutout
                    ctx.moveTo(23, 15);
                    ctx.lineTo(15, 34);
                    ctx.bezierCurveTo(20, 31, 26, 30, 31, 34);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            // Specs Column
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                component SpecRow: Row {
                    property string label: ""
                    property string value: ""
                    spacing: 8

                    Text {
                        width: 36
                        text: label
                        color: Colors.sub
                        font.pixelSize: 11
                        font.family: "monospace"
                    }
                    Text {
                        text: ":"
                        color: Colors.sub
                        font.pixelSize: 11
                    }
                    Text {
                        text: value
                        color: Colors.text
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.family: "monospace"
                        elide: Text.ElideRight
                    }
                }

                SpecRow { label: "OS"; value: root.osName }
                SpecRow { label: "WM"; value: root.wmName }
                SpecRow { label: "USER"; value: root.userName }
                SpecRow { label: "UP"; value: root.uptime }
            }
        }

        // Color Palette Dots
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: Colors.paletteDots
                Rectangle {
                    required property string modelData
                    width: 13
                    height: 13
                    radius: 4
                    color: modelData
                }
            }
        }
    }
}
