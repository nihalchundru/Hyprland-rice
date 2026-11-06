import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "dock.js" as DockJs

Item {
    id: root
    width: Pill.geo.hover.w
    height: Media.hasPlayer ? Media.hoverH : 76     // natural content height; the Notch centres it

    // the focused window, shown at the top left
    readonly property var activeWin: ToplevelManager.activeToplevel
    readonly property var activeEntry: activeWin ? DockJs.findEntry(DesktopEntries.applications.values, activeWin.appId) : null
    readonly property string appName: activeWin ? (activeEntry ? activeEntry.name : (activeWin.appId || "")) : ""

    function appIconPath() {
        const names = [activeEntry ? activeEntry.icon : "", activeWin ? activeWin.appId : ""];
        for (let i = 0; i < names.length; i++) {
            if (!names[i]) continue;
            const p = Quickshell.iconPath(names[i], true);
            if (p) return p;
        }
        return "";
    }
    readonly property string iconPath: appIconPath()

    // click the hover state -> calendar (the right-hand column below overrides this on the right)
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Pill.open("calendar", false)
    }

    // ── left: the focused app, and the workspace dots ────────────────
    Column {
        id: leftCol
        x: Theme.pad + 14
        y: Math.max(14, (root.height - height) / 2)
        spacing: 10

        Row {
            spacing: 8

            // the app's icon (a letter badge if it has none), or a dot when no window is focused
            Item {
                visible: root.activeWin !== null
                width: 18
                height: 18
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    visible: root.iconPath !== ""
                    anchors.fill: parent
                    source: root.iconPath
                }
                Rectangle {
                    visible: root.iconPath === ""
                    anchors.fill: parent
                    radius: Theme.r(5)
                    color: Theme.accent
                    Text {
                        anchors.centerIn: parent
                        text: (root.appName || "?").charAt(0).toUpperCase()
                        color: Theme.onAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.px(11)
                        font.weight: Font.Bold
                    }
                }
            }
            Rectangle {
                visible: root.activeWin === null
                anchors.verticalCenter: parent.verticalCenter
                width: 6
                height: 6
                radius: 3
                color: Theme.accent
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 130)
                elide: Text.ElideRight
                text: root.activeWin ? root.appName : Pill.workspaceLabel
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(14)
                font.weight: Font.Medium
            }
        }

        WorkspaceDots { size: 18 }
    }

    // ── centre: time and date in a tile ──────────────────────────────
    Item {
        id: topRow
        y: 14
        width: parent.width
        height: 36

        Rectangle {
            id: timeTile
            anchors.centerIn: parent
            height: parent.height
            width: timeRow.implicitWidth + 36
            radius: Theme.r(18)
            color: tileHover.hovered ? Theme.tileHi : Theme.tile
            Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

            HoverHandler { id: tileHover }

            Row {
                id: timeRow
                anchors.centerIn: parent
                spacing: 12

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
                    font.pixelSize: Theme.px(14)
                }
            }
        }
    }

    // ── right: notification status, and the signal / battery icons ───
    Column {
        id: rightCol
        anchors.right: parent.right
        anchors.rightMargin: Theme.pad + 14
        y: Math.max(14, (root.height - height) / 2)
        spacing: 10

        Row {
            anchors.right: parent.right
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 150)
                elide: Text.ElideLeft
                text: Notifs.count === 0 ? "All caught up"
                    : Notifs.count + (Notifs.count === 1 ? " notification" : " notifications")
                color: Notifs.count === 0 ? Theme.text : Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(14)
                font.weight: Font.Medium
            }
            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "bell"
                size: 15
                color: Notifs.count === 0 ? Theme.dim : Theme.accent
            }
        }

        Row {
            id: cluster
            anchors.right: parent.right
            spacing: 10

            SignalBars {}
            BatteryIcon {}
        }
    }

    // the whole right-hand column opens the control center (where the notifications are)
    MouseArea {
        anchors.fill: rightCol
        anchors.margins: -10
        cursorShape: Qt.PointingHandCursor
        onClicked: Pill.open("control", true)
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

        // the music visualizer, left of the transport buttons (or at the right edge without them)
        VisualizerBars {
            id: viz
            visible: Media.showVisualizer
            anchors.right: transport.visible ? transport.left : parent.right
            anchors.rightMargin: transport.visible ? 12 : 14
            anchors.verticalCenter: parent.verticalCenter
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
