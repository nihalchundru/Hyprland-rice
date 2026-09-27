import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: expandedDashboard
    anchors.fill: parent
    anchors.margins: 14
    spacing: 12

    // 1. ALBUM TEXTURE BACKDROP & TITLE INFO HEADER
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Rectangle {
            id: albumArtFrame
            Layout.preferredWidth: 46
            Layout.preferredHeight: 46
            radius: 8
            color: barRoot.colors.surface
            border.color: barRoot.colors.surface2
            border.width: 1

            Canvas {
                anchors.centerIn: parent
                width: 16; height: 16
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.lineWidth = 1.5;
                    ctx.strokeStyle = barRoot.colors.sub;
                    ctx.arc(4, 12, 3, 0, 2*Math.PI);
                    ctx.moveTo(7, 12); ctx.lineTo(7, 2); ctx.lineTo(14, 4); ctx.lineTo(14, 10);
                    ctx.moveTo(14, 7); ctx.arc(11, 7, 3, 0, 2*Math.PI);
                    ctx.stroke();
                }
            }
        }

        Column {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: barRoot.trackDisplay !== "" ? barRoot.trackDisplay.split(" - ")[0] || "Unknown Track" : "No Media Active"
                color: barRoot.colors.text
                font.bold: true
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                width: 210
            }
            Text {
                text: barRoot.trackDisplay !== "" ? barRoot.trackDisplay.split(" - ")[1] || "Unknown Artist" : "Idle"
                color: barRoot.colors.sub
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                width: 210
            }
        }
    }

    // 2. TIMELINE SLIDER TRACK PROGRESS LINE
    // FIX: Using a root Item wrapper and anchoring elements internally relative to it
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 20

        // Background slider trough line
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 4
            radius: 2
            color: barRoot.colors.surface
        }

        // Active progressive sliding filler line
        Rectangle {
            id: sliderProgressLine
            anchors.verticalCenter: parent.verticalCenter
            height: 4
            radius: 2
            color: barRoot.colors.accent
            width: parent.width * 0.35 
        }

        // Interactive thumb slider head dot
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: sliderProgressLine.width - (width / 2) // Mathematical offset matching progress track width bounds safely
            width: 10; height: 10; radius: 5
            color: barRoot.colors.accent
        }
    }

    // 3. GEOMETRIC NATIVE ACCENT MEDIA CONTROLS
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 24

        Rectangle {
            width: 28; height: 28; radius: 14; color: "transparent"
            Canvas {
                anchors.centerIn: parent; width: 10; height: 10
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = barRoot.colors.text;
                    ctx.beginPath(); ctx.moveTo(10, 0); ctx.lineTo(3, 5); ctx.lineTo(10, 10); ctx.fill();
                    ctx.fillRect(0, 0, 2, 10);
                }
            }
            TapHandler { onTapped: skipPrevCmd.running = true }
        }

        Item {
            width: 32; height: 32

            Repeater {
                model: 8
                Rectangle {
                    anchors.centerIn: parent; width: 5; height: 30; radius: 25
                    color: barRoot.colors.accent; rotation: (index * 45)
                }
            }
            Rectangle {
                anchors.centerIn: parent; width: 22; height: 22; radius: 11
                color: barRoot.colors.accent
                Canvas {
                    id: expandedPlayVector
                    anchors.centerIn: parent; width: 10; height: 10
                    Connections { target: barRoot; onMusicPlayingChanged: () => expandedPlayVector.requestPaint() }
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = barRoot.colors.bg;
                        if (barRoot.musicPlaying) { ctx.fillRect(1, 0, 2, 10); ctx.fillRect(6, 0, 2, 10); }
                        else { ctx.beginPath(); ctx.moveTo(2, 0); ctx.lineTo(9, 5); ctx.lineTo(2, 10); ctx.closePath(); ctx.fill(); }
                    }
                }
                TapHandler { onTapped: toggleMediaCmd.running = true }
            }
        }

        Rectangle {
            width: 28; height: 28; radius: 14; color: "transparent"
            Canvas {
                anchors.centerIn: parent; width: 10; height: 10
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = barRoot.colors.text;
                    ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(7, 5); ctx.lineTo(0, 10); ctx.fill();
                    ctx.fillRect(8, 0, 2, 10);
                }
            }
            TapHandler { onTapped: skipNextCmd.running = true }
        }
    }

    Process { id: toggleMediaCmd; command: ["playerctl", "play-pause"]; running: false }
    Process { id: skipNextCmd; command: ["playerctl", "next"]; running: false }
    Process { id: skipPrevCmd; command: ["playerctl", "previous"]; running: false }
}
