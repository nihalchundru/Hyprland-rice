import QtQuick

// The pill. Every state is this one rectangle changing width/height/radius,
// with the content for each state cross-fading inside it.
Item {
    id: root

    readonly property alias body: bodyRect

    Rectangle {
        id: bodyRect

        // Animated copies of the targets. With Bounce above 0 the animation
        // overshoots, so the clamps below keep size and radius from ever going
        // negative while it does.
        property real aw: Pill.targetW
        property real ah: Pill.targetH
        property real ar: Pill.targetR

        Behavior on aw { NumberAnimation { duration: Theme.animMs; easing.type: Theme.easing; easing.overshoot: Theme.overshoot } }
        Behavior on ah { NumberAnimation { duration: Theme.animMs; easing.type: Theme.easing; easing.overshoot: Theme.overshoot } }
        Behavior on ar { NumberAnimation { duration: Theme.animMs; easing.type: Theme.easing; easing.overshoot: Theme.overshoot } }

        // stage lift: the pill rises toward the screen edge while hovered
        property real topOff: Pill.mode === "hover" ? -Settings.get("stageLift") : 0
        Behavior on topOff { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutCubic } }

        anchors.top: parent.top
        anchors.topMargin: Math.max(0, Theme.margin + topOff)
        anchors.horizontalCenter: parent.horizontalCenter

        width: Math.max(8, aw)
        height: Math.max(8, ah)
        radius: Math.max(0, Math.min(ar, Math.min(width, height) / 2))
        color: Theme.body
        clip: true

        // notch mode: square off the top corners so the pill hangs from the screen edge
        Rectangle {
            visible: Theme.notch
            x: 0
            y: 0
            width: parent.width
            height: Math.min(parent.height, parent.radius + 1)
            color: Theme.body
        }

        // ── content per state (sized to the TARGET, so nothing reflows) ──
        IdleContent {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "idle" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        HoverContent {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max(0, (Pill.targetH - height) / 2)
            opacity: Pill.mode === "hover" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        CalendarPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "calendar" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        ControlPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "control" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        SoundPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "sound" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        DisplayPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "display" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        WifiPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "wifi" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        BluetoothPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "bluetooth" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        LauncherPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "launcher" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        ThemesPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "themes" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        WallpapersPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "wallpaper" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        PowerPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "power" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        NotifyPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "notify" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        AuthPage {
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: Pill.mode === "auth" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        // placeholder for any state without content
        Text {
            anchors.centerIn: parent
            visible: opacity > 0.01
            opacity: Pill.built.indexOf(Pill.mode) < 0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
            text: Pill.mode + "  \u00b7  coming in a later stage"
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }

        // ── hover logic ──────────────────────────────────────────────
        HoverHandler {
            id: hover
            onHoveredChanged: {
                Pill.hovering = hovered;
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
