
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "services" as Services

ColumnLayout {
    id: weatherSectionRoot

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
    spacing: 12

    // ==========================================
    // SECTION 1: CLOCK
    // ==========================================
    Column {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 1

        Text {
            text: barRoot.clockTime
            color: barRoot.colors.text
            font.bold: true
            font.pixelSize: 22
            font.family: "JetBrainsMono Nerd Font"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: barRoot.clockDate
            color: barRoot.colors.sub
            font.pixelSize: 10
            font.family: "JetBrainsMono Nerd Font"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // ==========================================
    // DIVIDER
    // ==========================================
    Rectangle {
        Layout.preferredWidth: parent.width - 40
        Layout.preferredHeight: 1
        Layout.alignment: Qt.AlignHCenter
        color: barRoot.colors.surface2
    }

    // ==========================================
    // SECTION 2: MEDIA PLAYER + VISUALIZER
    // ==========================================
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 14

        // ======================================
        // LEFT VISUALIZER: BARS 0-3
        // ======================================
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            Repeater {
                model: 4

                Item {
                    width: 5
                    height: 36

                    Rectangle {
                        width: parent.width
                        radius: 2.5
                        color: barRoot.colors.accent
                        anchors.bottom: parent.bottom

                        height: Math.max(
                            3,
                            Math.min(
                                36,
                                Number(Services.CavaService.barsData[index]) * 1.5
                            )
                        )

                        Behavior on height {
                            NumberAnimation {
                                duration: 70
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }

        // ======================================
        // CENTER MEDIA CONTROLS
        // ======================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                Text {
                    text: barRoot.trackDisplay !== ""
                        ? barRoot.trackDisplay
                        : "No Track Active"

                    color: barRoot.colors.text
                    font.bold: true
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"

                    horizontalAlignment: Text.AlignHCenter
                    width: 160
                    elide: Text.ElideRight
                }

                Text {
                    text: barRoot.musicPlaying ? "Playing" : "Paused"

                    color: barRoot.colors.sub
                    font.pixelSize: 9
                    font.family: "JetBrainsMono Nerd Font"

                    horizontalAlignment: Text.AlignHCenter
                    width: 160
                    elide: Text.ElideRight
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                // PREVIOUS
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: "transparent"

                    Canvas {
                        anchors.centerIn: parent
                        width: 8
                        height: 8

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = barRoot.colors.text
                            ctx.beginPath()
                            ctx.moveTo(8, 0)
                            ctx.lineTo(2, 4)
                            ctx.lineTo(8, 8)
                            ctx.fill()
                            ctx.fillRect(0, 0, 1.5, 8)
                        }
                    }

                    TapHandler {
                        onTapped: skipPrevCmd.running = true
                    }
                }

                // PLAY / PAUSE
                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    color: barRoot.colors.accent

                    Canvas {
                        id: centerDashPlayVector

                        anchors.centerIn: parent
                        width: 8
                        height: 8

                        Connections {
                            target: barRoot

                            function onMusicPlayingChanged() {
                                centerDashPlayVector.requestPaint()
                            }
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = barRoot.colors.bg

                            if (barRoot.musicPlaying) {
                                ctx.fillRect(1, 0, 2, 8)
                                ctx.fillRect(5, 0, 2, 8)
                            } else {
                                ctx.beginPath()
                                ctx.moveTo(2, 0)
                                ctx.lineTo(7, 4)
                                ctx.lineTo(2, 8)
                                ctx.closePath()
                                ctx.fill()
                            }
                        }
                    }

                    TapHandler {
                        onTapped: toggleMediaCmd.running = true
                    }
                }

                // NEXT
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: "transparent"

                    Canvas {
                        anchors.centerIn: parent
                        width: 8
                        height: 8

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = barRoot.colors.text
                            ctx.beginPath()
                            ctx.moveTo(0, 0)
                            ctx.lineTo(6, 4)
                            ctx.lineTo(0, 8)
                            ctx.fill()
                            ctx.fillRect(6.5, 0, 1.5, 8)
                        }
                    }

                    TapHandler {
                        onTapped: skipNextCmd.running = true
                    }
                }
            }
        }

        // ======================================
        // RIGHT VISUALIZER: BARS 4-7
        // ======================================
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            Repeater {
                model: 4

                Item {
                    width: 5
                    height: 36

                    Rectangle {
                        width: parent.width
                        radius: 2.5
                        color: barRoot.colors.accent
                        anchors.bottom: parent.bottom

                        height: Math.max(
                            3,
                            Math.min(
                                36,
                                Number(Services.CavaService.barsData[index + 4]) * 1.5
                            )
                        )

                        Behavior on height {
                            NumberAnimation {
                                duration: 70
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // MEDIA COMMANDS
    // ==========================================
    Process {
        id: toggleMediaCmd
        command: ["playerctl", "play-pause"]
        running: false
    }

    Process {
        id: skipNextCmd
        command: ["playerctl", "next"]
        running: false
    }

    Process {
        id: skipPrevCmd
        command: ["playerctl", "previous"]
        running: false
    }
}

