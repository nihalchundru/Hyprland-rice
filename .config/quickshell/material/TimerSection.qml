import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: rightPanelContainer
    Layout.preferredWidth: 140
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    spacing: 12

    // LAYER A: WEATHER CONDITIONS (FIXED METRIC BINDINGS)
    Column {
        Layout.fillWidth: true
        spacing: 1
        // Reads directly from our clean, parsed properties passed down from shell variables
        Text { text: barRoot.wTemp ? barRoot.wTemp : "19°C"; color: barRoot.colors.text; font.bold: true; font.pixelSize: 22; font.family: "JetBrainsMono Nerd Font" }
        Text { text: barRoot.wCond ? barRoot.wCond : "Cloudy"; color: barRoot.colors.sub; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
    }

    // LAYER B: INTERACTIVE TIMER CHIP CAPSULE
    MouseArea {
        id: timerInteractiveHitbox
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        
        Timer {
            id: countdownTimerLoop
            interval: 1000; running: false; repeat: true
            property int secondsRemaining: 60
            onTriggered: { if (secondsRemaining > 0) secondsRemaining--; else running = false; }
        }

        onClicked: {
            if (countdownTimerLoop.running) {
                countdownTimerLoop.running = false;
                countdownTimerLoop.secondsRemaining = 60;
            } else {
                countdownTimerLoop.running = true;
            }
            circularProgressRing.requestPaint();
        }

        RowLayout {
            anchors.fill: parent; spacing: 8

            Item {
                width: 30; height: 30; Layout.alignment: Qt.AlignVCenter
                Canvas {
                    id: circularProgressRing; anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset();
                        ctx.lineWidth = 2.5; ctx.strokeStyle = barRoot.colors.surface;
                        ctx.beginPath(); ctx.arc(15, 15, 11, 0, 2*Math.PI); ctx.stroke();
                        
                        ctx.strokeStyle = barRoot.colors.accent2; ctx.beginPath();
                        var pct = countdownTimerLoop.secondsRemaining / 60.0;
                        ctx.arc(15, 15, 11, -Math.PI/2, (-Math.PI/2) + (2*Math.PI*pct)); ctx.stroke();
                    }
                    Connections { target: countdownTimerLoop; onTriggered: circularProgressRing.requestPaint() }
                }
                Text {
                    anchors.centerIn: parent; text: countdownTimerLoop.secondsRemaining.toString()
                    color: barRoot.colors.text; font.bold: true; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"
                }
            }
            Text {
                text: countdownTimerLoop.running ? "Reset" : "Start 1m"
                color: barRoot.colors.sub; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // LAYER C: TELEMETRY metric CHIPS
    GridLayout {
        columns: 2; columnSpacing: 6; rowSpacing: 6; Layout.fillWidth: true

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 22; radius: 5; color: barRoot.colors.surface
            Row { anchors.centerIn: parent; spacing: 4
                Text { text: "💨"; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                Text { text: barRoot.wWind ? barRoot.wWind : "12m/s"; color: barRoot.colors.text; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 22; radius: 5; color: barRoot.colors.surface
            Row { anchors.centerIn: parent; spacing: 4
                Text { text: "💧"; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                Text { text: barRoot.wHumid ? barRoot.wHumid : "80%"; color: barRoot.colors.text; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }
}
