import QtQuick

Rectangle {
    id: mediaPill
    visible: true
    
    // Morph metrics bound tightly to the local hover interaction matrix
    width: playerHoverArea.containsMouse ? 290 : (barRoot.musicPlaying && barRoot.trackDisplay !== "" ? Math.min(220, trackNameText.implicitWidth + 64) : 42)
    height: playerHoverArea.containsMouse ? 146 : 38
    radius: playerHoverArea.containsMouse ? 22 : height / 2
    
    color: barRoot.colors.bg2
    border.color: barRoot.colors.surface2
    border.width: 1
    clip: true
    antialiasing: true

    Behavior on width  { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    MouseArea {
        id: playerHoverArea
        anchors.fill: parent
        hoverEnabled: true
        
        // FIX: Tell the root bar window wrapper that the media player is active to grow the window frame!
        onEntered: barRoot.mediaExpanded = true
        onExited: barRoot.mediaExpanded = false
    }

    Timer {
        id: audioWaveTimer
        interval: 60; running: barRoot.musicPlaying; repeat: true
        property real waveSyncValue: 0
        onTriggered: waveSyncValue += 0.4
    }

    // ==========================================
    // MODULE FLOW 1: COMPACT VIEW 
    // ==========================================
    Row {
        visible: !playerHoverArea.containsMouse
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Item {
            width: 26; height: 26
            anchors.verticalCenter: parent.verticalCenter

            Item {
                anchors.centerIn: parent; width: 26; height: 26
                Repeater {
                    model: 8
                    Rectangle {
                        anchors.centerIn: parent; width: 4
                        height: barRoot.musicPlaying ? (18 + Math.abs(Math.sin(audioWaveTimer.waveSyncValue + index)) * 8) : 22
                        radius: width / 2; color: barRoot.colors.accent; rotation: (index * 45)
                        Behavior on height { NumberAnimation { duration: 50 } }
                    }
                }
                RotationAnimation on rotation { loops: Animation.Infinite; from: 0; to: 360; duration: 16000; running: barRoot.musicPlaying }
            }

            Rectangle {
                anchors.centerIn: parent; width: 18; height: 18; radius: 9; color: barRoot.colors.accent
                Canvas {
                    id: playPauseVector
                    anchors.centerIn: parent; width: 8; height: 8
                    Connections { target: barRoot; onMusicPlayingChanged: () => playPauseVector.requestPaint() }
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = barRoot.colors.bg;
                        if (barRoot.musicPlaying) { ctx.fillRect(1, 0, 2, 8); ctx.fillRect(5, 0, 2, 8); }
                        else { ctx.beginPath(); ctx.moveTo(2, 0); ctx.lineTo(7, 4); ctx.lineTo(2, 8); ctx.closePath(); ctx.fill(); }
                    }
                }
            }
        }

        Text {
            id: trackNameText
            visible: barRoot.musicPlaying && barRoot.trackDisplay !== ""
            text: barRoot.trackDisplay
            color: barRoot.colors.text
            font.bold: true; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(10, mediaPill.width - 56)
            elide: Text.ElideRight
        }
    }

    // ==========================================
    // MODULE FLOW 2: EXPANDED SHEET VIEW 
    // ==========================================
    Item {
        visible: playerHoverArea.containsMouse
        anchors.fill: parent
        MediaExpanded {}
    }
}
