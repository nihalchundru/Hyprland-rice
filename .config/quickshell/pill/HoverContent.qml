import QtQuick
import QtQuick.Effects

Item {
    id: root
    width: Pill.geo.hover.w
    height: Media.hasPlayer ? Media.hoverH : 76     // natural content height; the Notch centres it

    property real phase: 0

    // click the hover state -> calendar (cluster below overrides this on the right)
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Pill.open("calendar", false)
    }
    NumberAnimation on phase {
        from: 0
        to: Math.PI * 2
        duration: 1600
        loops: Animation.Infinite
        running: root.visible && Media.playing && !Theme.reduce
    }

    // ── left: workspace name + dots ──────────────────────────────────
    Column {
        id: leftCol
        x: Theme.pad + 6
        y: Math.max(14, (root.height - height) / 2)
        spacing: 9

        Row {
            spacing: 8
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 6
                height: 6
                radius: Theme.r(3)
                color: Theme.accent
            }
            Text {
                text: Pill.workspaceLabel
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(14)
                font.weight: Font.Medium
            }
        }

        WorkspaceDots { size: 14 }
    }

    // ── top row: time + date centered, status cluster on the right ───
    Item {
        id: topRow
        y: 14
        width: parent.width
        height: 32

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ClockFmt.time(Pill.now)
                color: Theme.text
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.px(24)
                font.weight: Font.Medium
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: !!Settings.get("showDate")
                text: ClockFmt.date(Pill.now)
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(15)
            }
        }

        Row {
            id: cluster
            anchors.right: parent.right
            anchors.rightMargin: Theme.pad + 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            SignalBars {}
            BatteryIcon {}
        }

        // status cluster -> control center
        MouseArea {
            anchors.fill: cluster
            anchors.margins: -10
            cursorShape: Qt.PointingHandCursor
            onClicked: Pill.open("control", true)
        }
    }

    // ── media card ───────────────────────────────────────────────────
    Rectangle {
        id: card
        visible: Media.hasPlayer
        anchors.horizontalCenter: parent.horizontalCenter
        y: topRow.y + topRow.height + 10
        width: Media.cardW
        height: Media.cardH
        radius: Theme.r(18)
        color: Theme.tile

        // album art, rounded with a mask
        Item {
            id: art
            x: 9
            anchors.verticalCenter: parent.verticalCenter
            width: Media.artSize
            height: Media.artSize

            Rectangle {
                anchors.fill: parent
                radius: Theme.r(Media.artSize * 0.29)
                color: Theme.tileHi
            }

            Image {
                id: img
                anchors.fill: parent
                source: Media.art
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: artMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                }
            }

            Item {
                id: artMask
                anchors.fill: parent
                layer.enabled: true
                visible: false
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.r(Media.artSize * 0.29)
                }
            }
        }

        Column {
            anchors.left: art.right
            anchors.leftMargin: 11
            width: Media.songW
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: Media.title
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(14)
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width
                visible: Media.showArtist && text !== ""
                text: Media.artist
                elide: Text.ElideRight
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
            }
            Text {
                width: parent.width
                visible: Media.showAlbum && text !== ""
                text: Media.album
                elide: Text.ElideRight
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
            }
            Text {
                width: parent.width
                visible: Media.showLyrics && text !== ""
                text: Lyrics.current
                elide: Text.ElideRight
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
            }
        }

        // transport buttons (or, with those off, the decorative wave)
        Row {
            id: transport
            visible: Media.showTransport
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            CircleButton { size: 30; iconSize: 13; icon: "skip-back"; onClicked: Media.previous() }
            CircleButton {
                size: 30
                iconSize: 13
                icon: Media.playing ? "pause" : "play"
                active: Media.playing
                onClicked: Media.toggle()
            }
            CircleButton { size: 30; iconSize: 13; icon: "skip-forward"; onClicked: Media.next() }
        }

        Row {
            id: viz
            visible: !Media.showTransport
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Repeater {
                model: 10
                Rectangle {
                    required property int index
                    width: 3
                    height: 3
                    radius: Theme.r(1.5)
                    color: Theme.accent
                    opacity: Media.playing
                        ? 0.3 + 0.7 * (0.5 + 0.5 * Math.sin(root.phase + index * 0.7))
                        : 0.3
                }
            }
        }

        // scroll over the card to change track (one step per flick)
        MouseArea {
            id: wheelArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            enabled: Media.scrollSkip

            property bool locked: false

            Timer {
                id: wheelLock
                interval: 450
                onTriggered: wheelArea.locked = false
            }

            onWheel: wheel => {
                if (locked) return;
                locked = true;
                wheelLock.restart();
                if (wheel.angleDelta.y < 0) Media.next();
                else if (wheel.angleDelta.y > 0) Media.previous();
            }
        }
    }
}
