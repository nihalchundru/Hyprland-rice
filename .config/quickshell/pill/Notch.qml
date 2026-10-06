import QtQuick

// The pill. Every state is this one rectangle changing width/height/radius,
// with the content for each state cross-fading inside it.
Item {
    id: root

    readonly property alias body: bodyRect

    Rectangle {
        id: bodyRect
        anchors.top: parent.top
        anchors.topMargin: Theme.margin
        anchors.horizontalCenter: parent.horizontalCenter

        width: Pill.targetW
        height: Pill.targetH
        radius: Pill.targetR
        color: Theme.body
        clip: true

        Behavior on width  { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutQuint } }
        Behavior on height { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutQuint } }
        Behavior on radius { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutQuint } }

        // ── content per state (sized to the TARGET, so nothing reflows) ──
        IdleContent {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "idle" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 160 } }
        }

        HoverContent {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "hover" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        CalendarPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "calendar" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        ControlPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "control" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        SoundPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "sound" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        DisplayPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "display" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        WifiPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "wifi" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        BluetoothPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "bluetooth" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        LauncherPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "launcher" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        ThemesPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "themes" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        WallpapersPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "wallpaper" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        PowerPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "power" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // placeholder for states that arrive in later stages
        Text {
            anchors.centerIn: parent
            visible: opacity > 0.01
            opacity: Pill.built.indexOf(Pill.mode) < 0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 180 } }
            text: Pill.mode + "  ·  coming in a later stage"
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }

        // ── hover logic ──────────────────────────────────────────────
        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) {
                    outTimer.stop();
                    if (Pill.mode === "idle") inTimer.start();
                } else {
                    inTimer.stop();
                    if (!Pill.sticky && Pill.mode !== "idle") outTimer.start();
                }
            }
        }

        Timer {
            id: inTimer
            interval: Theme.hoverInMs
            onTriggered: if (hover.hovered && Pill.mode === "idle") Pill.open("hover", false)
        }

        Timer {
            id: outTimer
            interval: Theme.hoverOutMs
            onTriggered: if (!hover.hovered && !Pill.sticky && Pill.mode !== "idle") Pill.close()
        }
    }
}
