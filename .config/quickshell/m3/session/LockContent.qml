import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.tokens
import qs.services
import qs.components

// Lock screen: blurred wallpaper, flower clock, date + weather, password as morphing shapes, media card.
Item {
    id: root
    anchors.fill: parent
    opacity: 0
    Component.onCompleted: { opacity = 1; input.forceActiveFocus() }
    FadeBehavior on opacity { time: M3Motion.long2 }

    // layout scale (designed around 1400x800)
    readonly property real sc: Math.max(0.55, Math.min(1.3, Math.min(width / 1400, height / 800)))
    readonly property real face: 300 * sc
    readonly property int pwLen: input.text.length
    readonly property string userName: { const u = Quickshell.env("USER") || "user"; return u.charAt(0).toUpperCase() + u.slice(1) }
    readonly property var latest: Notifs.count > 0 ? Notifs.all[Notifs.count - 1] : null
    readonly property var pwShapes: ["triangle", "square", "cookie9Sided", "pentagon", "softBurst", "flower", "sunny", "gem"]
    readonly property var pwColors: [M3Colors.primary, M3Colors.tertiary, M3Colors.primaryFixedDim, M3Colors.secondary]

    property real sec: 0
    property real min: 0
    property real hr: 0
    FrameAnimation {
        running: true
        onTriggered: {
            const d = new Date()
            root.sec = d.getSeconds() + d.getMilliseconds() / 1000
            root.min = d.getMinutes() + root.sec / 60
            root.hr = (d.getHours() % 12) + root.min / 60
        }
    }

    function iconFor(n) {
        if (!n) return ""
        if (n.image) return n.image
        if (!n.appIcon) return ""
        return n.appIcon.startsWith("/") ? "file://" + n.appIcon : Quickshell.iconPath(n.appIcon, "dialog-information")
    }
    function fmt(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }

    // ------------------------------------------------------------------ background
    Image {
        id: bg
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/.config/rofi/images/a.png"
        fillMode: Image.PreserveAspectCrop
        visible: false
    }
    MultiEffect { anchors.fill: parent; source: bg; blurEnabled: true; blur: 1.0; blurMax: 64; autoPaddingEnabled: false }
    Rectangle { anchors.fill: parent; color: M3Colors.scrim; opacity: 0.45 }
    Item {   // slow drifting color glow
        id: glow
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 64 }
        Rectangle {
            width: 520 * root.sc; height: width; radius: width / 2
            color: Qt.alpha(M3Colors.primary, 0.20)
            x: 80; y: 60
            SequentialAnimation on x { loops: Animation.Infinite; NumberAnimation { to: glow.width * 0.55; duration: 17000; easing.type: Easing.InOutSine } NumberAnimation { to: 40; duration: 17000; easing.type: Easing.InOutSine } }
            SequentialAnimation on y { loops: Animation.Infinite; NumberAnimation { to: glow.height * 0.45; duration: 13000; easing.type: Easing.InOutSine } NumberAnimation { to: 20; duration: 13000; easing.type: Easing.InOutSine } }
        }
        Rectangle {
            width: 420 * root.sc; height: width; radius: width / 2
            color: Qt.alpha(M3Colors.tertiary, 0.18)
            x: glow.width * 0.6; y: glow.height * 0.5
            SequentialAnimation on x { loops: Animation.Infinite; NumberAnimation { to: glow.width * 0.15; duration: 19000; easing.type: Easing.InOutSine } NumberAnimation { to: glow.width * 0.65; duration: 19000; easing.type: Easing.InOutSine } }
            SequentialAnimation on y { loops: Animation.Infinite; NumberAnimation { to: glow.height * 0.1; duration: 15000; easing.type: Easing.InOutSine } NumberAnimation { to: glow.height * 0.6; duration: 15000; easing.type: Easing.InOutSine } }
        }
    }
    MouseArea { anchors.fill: parent; onClicked: input.forceActiveFocus() }

    // hidden input that captures the password
    TextInput {
        id: input
        width: 1; height: 1; opacity: 0
        echoMode: TextInput.Password
        enabled: !LockCtx.busy
        onTextChanged: { LockCtx.password = text; if (text !== "") LockCtx.failed = false }
        Keys.onReturnPressed: LockCtx.submit()
        Keys.onEnterPressed: LockCtx.submit()
        Keys.onEscapePressed: text = ""
        Connections { target: LockCtx; function onPasswordChanged() { if (input.text !== LockCtx.password) input.text = LockCtx.password } }
    }

    // ------------------------------------------------------------------ center stack
    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 120 * root.sc
        spacing: 0

        LockReveal {
            delay: 0
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.face; Layout.preferredHeight: root.face
            Item {
                anchors.fill: parent
                SequentialAnimation on scale { loops: Animation.Infinite; NumberAnimation { to: 1.02; duration: 3600; easing.type: Easing.InOutSine } NumberAnimation { to: 1.0; duration: 3600; easing.type: Easing.InOutSine } }
                Item {
                    anchors.fill: parent
                    NumberAnimation on rotation { from: 0; to: 360; duration: 150000; loops: Animation.Infinite }
                    MorphShape { anchors.fill: parent; size: root.face; shape: "cookie12Sided"; color: Qt.alpha(M3Colors.surfaceContainerLowest, 0.94) }
                }
                Repeater {
                    model: 12
                    Item {
                        required property int index
                        anchors.centerIn: parent
                        width: 0; height: 0
                        rotation: index * 30
                        Rectangle { x: -1.5 * root.sc; y: -(root.face / 2 - 22 * root.sc); width: 3 * root.sc; height: (index % 3 === 0 ? 13 : 6) * root.sc; radius: 1.5; color: M3Colors.primaryFixedDim; opacity: 0.75 }
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: -root.face * 0.04
                    M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.hourDigits; role: ({ size: Math.round(root.face * 0.27), line: Math.round(root.face * 0.27), weight: Font.Bold, tracking: 0 }); color: Qt.alpha(M3Colors.primaryFixedDim, 0.92) }
                    M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.minuteDigits; role: ({ size: Math.round(root.face * 0.27), line: Math.round(root.face * 0.27), weight: Font.Bold, tracking: 0 }); color: Qt.alpha(M3Colors.primaryFixedDim, 0.92) }
                }
                M3Text { visible: Clock.ampm !== ""; anchors.horizontalCenter: parent.horizontalCenter; y: root.face * 0.74; text: Clock.ampm; role: ({ size: Math.round(root.face * 0.06), line: Math.round(root.face * 0.075), weight: Font.Bold, tracking: 1.5 }); color: Qt.alpha(M3Colors.primaryFixedDim, 0.6) }
                LockHand { angle: root.hr * 30; len: root.face * 0.24; thick: Math.max(5, root.face * 0.04); col: M3Colors.primaryFixed }
                LockHand { angle: root.min * 6; len: root.face * 0.37; thick: Math.max(4, root.face * 0.034); col: M3Colors.primaryFixed }
                LockHand { angle: root.sec * 6; len: root.face * 0.58; thick: Math.max(2, root.face * 0.008); tail: root.face * 0.1; col: M3Colors.primary }
                Rectangle { anchors.centerIn: parent; width: root.face * 0.045; height: width; radius: width / 2; color: M3Colors.primary }
            }
        }

        LockReveal {   // date + weather
            delay: 120
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 22 * root.sc
            Layout.preferredWidth: infoRow.implicitWidth + 44 * root.sc
            Layout.preferredHeight: 44 * root.sc
            LockPill {
                anchors.fill: parent
                RowLayout {
                    id: infoRow
                    anchors.centerIn: parent
                    spacing: 12 * root.sc
                    Rectangle { Layout.preferredWidth: 9 * root.sc; Layout.preferredHeight: 9 * root.sc; radius: width / 2; color: M3Colors.primary }
                    M3Text { text: Clock.dateLong; role: M3Type.titleSmall; color: M3Colors.primaryFixed }
                    Rectangle { visible: Weather.ready; Layout.preferredWidth: 1; Layout.preferredHeight: 18 * root.sc; color: Qt.alpha(M3Colors.outline, 0.6) }
                    Icon { visible: Weather.ready; name: Weather.icon; size: Math.round(22 * root.sc); fill: 1; color: M3Colors.primaryFixedDim }
                    M3Text { visible: Weather.ready; text: Weather.temp + "\u00b0" + M3Config.tempUnit; role: M3Type.titleSmall; color: M3Colors.primaryFixed }
                }
            }
        }

        LockReveal {   // password
            delay: 240
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 22 * root.sc
            Layout.preferredWidth: 540 * root.sc; Layout.preferredHeight: 84 * root.sc
            RowLayout {
                anchors.fill: parent
                spacing: 14 * root.sc
                LockPill {
                    id: pwPill
                    Layout.fillWidth: true; Layout.fillHeight: true
                    property real shake: 0
                    transform: Translate { x: pwPill.shake }
                    SequentialAnimation {
                        id: shaker
                        NumberAnimation { target: pwPill; property: "shake"; to: -16; duration: 50 }
                        NumberAnimation { target: pwPill; property: "shake"; to: 16; duration: 90 }
                        NumberAnimation { target: pwPill; property: "shake"; to: -9; duration: 80 }
                        NumberAnimation { target: pwPill; property: "shake"; to: 0; duration: 60 }
                    }
                    Connections { target: LockCtx; function onFailedChanged() { if (LockCtx.failed) shaker.restart() } }

                    Row {
                        visible: root.pwLen === 0
                        anchors.centerIn: parent
                        spacing: 10 * root.sc
                        Icon { name: "lock"; size: Math.round(22 * root.sc); color: M3Colors.fgSurfaceVariant; anchors.verticalCenter: parent.verticalCenter }
                        M3Text { text: LockCtx.failed ? "Wrong password" : "Type your password"; color: LockCtx.failed ? M3Colors.error : M3Colors.fgSurfaceVariant; role: M3Type.bodyLarge; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Item {
                        id: dots
                        anchors.fill: parent
                        readonly property int n: Math.min(root.pwLen, 11)
                        readonly property real step: 44 * root.sc
                        Repeater {
                            model: 11
                            Item {
                                id: dot
                                required property int index
                                readonly property bool on: index < dots.n
                                readonly property int gi: Math.max(0, root.pwLen - 11) + index
                                width: 36 * root.sc; height: width
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: LockCtx.busy ? Math.sin(root.sec * 9 + index * 0.8) * 5 * root.sc : 0
                                x: (dots.width - (dots.n * dots.step - 8 * root.sc)) / 2 + index * dots.step
                                scale: on ? 1 : 0
                                opacity: on ? 1 : 0
                                visible: opacity > 0.01
                                SpatialBehavior on x {}
                                SpatialBehavior on scale { eps: 0.002 }
                                FadeBehavior on opacity { time: M3Motion.short3 }
                                MorphShape {
                                    anchors.fill: parent
                                    size: parent.width
                                    shape: dot.on ? root.pwShapes[dot.gi % root.pwShapes.length] : "circle"
                                    color: LockCtx.failed ? M3Colors.error : root.pwColors[dot.gi % root.pwColors.length]
                                }
                            }
                        }
                    }
                }
                Item {   // submit
                    Layout.preferredWidth: 84 * root.sc; Layout.preferredHeight: 84 * root.sc
                    opacity: root.pwLen > 0 || LockCtx.busy ? 1 : 0.55
                    FadeBehavior on opacity {}
                    MorphShape { anchors.fill: parent; size: parent.width; shape: LockCtx.busy ? "softBurst" : "circle"; color: M3Colors.primary }
                    Icon { anchors.centerIn: parent; name: "arrow_forward"; size: Math.round(32 * root.sc); color: M3Colors.fgPrimary }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; enabled: !LockCtx.busy && root.pwLen > 0; onClicked: LockCtx.submit() }
                }
            }
        }
    }

    // ------------------------------------------------------------------ top-left: welcome
    LockReveal {
        delay: 360
        x: 40 * root.sc; y: 36 * root.sc
        width: welcomeRow.implicitWidth + 40 * root.sc; height: 66 * root.sc
        LockPill {
            anchors.fill: parent
            RowLayout {
                id: welcomeRow
                anchors.centerIn: parent
                spacing: 14 * root.sc
                Item {
                    Layout.preferredWidth: 46 * root.sc; Layout.preferredHeight: 46 * root.sc
                    property int k: 0
                    Timer { interval: 6000; repeat: true; running: true; onTriggered: parent.k = (parent.k + 1) % 4 }
                    MorphShape { anchors.fill: parent; size: parent.width; shape: ["cookie9Sided", "softBurst", "flower", "cookie12Sided"][parent.k]; color: M3Colors.primaryContainer }
                    M3Text { anchors.centerIn: parent; text: root.userName.charAt(0); role: M3Type.titleMedium; color: M3Colors.fgPrimaryContainer }
                }
                ColumnLayout {
                    spacing: 0
                    M3Text { text: "Welcome back,"; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant }
                    M3Text { text: root.userName; role: M3Type.titleMedium; color: M3Colors.primaryFixed }
                }
            }
        }
    }

    // ------------------------------------------------------------------ top-right: latest notification
    LockReveal {
        delay: 400
        visible: M3Config.lockNotifPreview && root.latest !== null
        x: parent.width - width - 40 * root.sc; y: 36 * root.sc
        width: 400 * root.sc; height: nrow.implicitHeight + 32 * root.sc
        Rectangle {
            anchors.fill: parent
            radius: 28 * root.sc
            color: Qt.alpha(M3Colors.surfaceContainer, 0.85)
            border.width: 1
            border.color: Qt.alpha(M3Colors.outlineVariant, 0.5)
            RowLayout {
                id: nrow
                x: 16 * root.sc; y: 16 * root.sc
                width: parent.width - 32 * root.sc
                spacing: 14 * root.sc
                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 46 * root.sc; Layout.preferredHeight: 46 * root.sc
                    radius: width / 2
                    color: M3Colors.primaryContainer
                    Image { visible: root.iconFor(root.latest) !== ""; anchors.fill: parent; anchors.margins: 7 * root.sc; source: root.iconFor(root.latest); fillMode: Image.PreserveAspectFit; sourceSize.width: 64; sourceSize.height: 64 }
                    Icon { visible: root.iconFor(root.latest) === ""; anchors.centerIn: parent; name: "notifications"; size: Math.round(24 * root.sc); fill: 1; color: M3Colors.fgPrimaryContainer }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: root.latest ? root.latest.summary : ""; role: M3Type.titleSmall; color: M3Colors.primaryFixed }
                    M3Text { Layout.fillWidth: true; visible: text !== ""; text: root.latest ? root.latest.body : ""; textFormat: Text.StyledText; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant }
                }
            }
        }
    }

    // ------------------------------------------------------------------ bottom-left: notification count
    LockReveal {
        delay: 480
        x: 40 * root.sc; y: parent.height - height - 40 * root.sc
        width: nc.implicitWidth + 44 * root.sc; height: 58 * root.sc
        LockPill {
            anchors.fill: parent
            RowLayout {
                id: nc
                anchors.centerIn: parent
                spacing: 10 * root.sc
                Icon { name: Notifs.count > 0 ? "notifications_unread" : "notifications"; size: Math.round(24 * root.sc); color: Notifs.count > 0 ? M3Colors.primary : M3Colors.fgSurfaceVariant; fill: Notifs.count > 0 ? 1 : 0 }
                M3Text { text: Notifs.count === 0 ? "No notifications" : Notifs.count + (Notifs.count === 1 ? " notification" : " notifications"); role: M3Type.titleSmall; color: M3Colors.fgSurfaceVariant }
            }
        }
    }

    // ------------------------------------------------------------------ bottom-center: media
    LockReveal {
        delay: 520
        visible: Media.has
        x: (parent.width - width) / 2; y: parent.height - height - 40 * root.sc
        width: 560 * root.sc; height: 150 * root.sc
        Rectangle {
            anchors.fill: parent
            radius: 40 * root.sc
            color: Qt.alpha(M3Colors.surfaceContainer, 0.85)
            border.width: 1
            border.color: Qt.alpha(M3Colors.outlineVariant, 0.5)
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20 * root.sc
                spacing: 20 * root.sc
                Item {
                    Layout.preferredWidth: 110 * root.sc; Layout.preferredHeight: 110 * root.sc
                    RoundedImage { id: lart; anchors.fill: parent; radius: 38 * root.sc; source: Media.art }
                    MorphShape { visible: !lart.ready; size: parent.width; shape: Media.playing ? "cookie9Sided" : "circle"; color: M3Colors.tertiaryContainer }
                    Icon { visible: !lart.ready; anchors.centerIn: parent; name: "music_note"; size: Math.round(40 * root.sc); fill: 1; color: M3Colors.fgTertiaryContainer }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2 * root.sc
                    M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: Media.title; role: M3Type.titleMedium; color: M3Colors.primaryFixed }
                    M3Progress { Layout.fillWidth: true; thickness: 5 * root.sc; amplitude: 3 * root.sc; wavelength: 34 * root.sc; wavy: Media.playing; value: Media.progress; showStop: false; activeColor: M3Colors.primary; trackColor: Qt.alpha(M3Colors.fgSurface, 0.18) }
                    RowLayout {
                        Layout.fillWidth: true
                        M3Text { text: root.fmt(Media.position); role: M3Type.labelSmall; color: M3Colors.fgSurfaceVariant }
                        Item { Layout.fillWidth: true }
                        M3Text { text: root.fmt(Media.length); role: M3Type.labelSmall; color: M3Colors.fgSurfaceVariant }
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10 * root.sc
                        M3Button { icon: "skip_previous"; variant: "text"; size: "s"; onClicked: Media.previous() }
                        Item {
                            Layout.preferredWidth: 52 * root.sc; Layout.preferredHeight: 52 * root.sc
                            MorphShape { anchors.fill: parent; size: parent.width; shape: Media.playing ? "softBurst" : "circle"; color: M3Colors.primary }
                            Icon { anchors.centerIn: parent; name: Media.playing ? "pause" : "play_arrow"; size: Math.round(26 * root.sc); fill: 1; color: M3Colors.fgPrimary }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Media.toggle() }
                        }
                        M3Button { icon: "skip_next"; variant: "text"; size: "s"; onClicked: Media.next() }
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------ bottom-right: power (reboot / shut down ask twice)
    LockReveal {
        delay: 560
        x: parent.width - width - 40 * root.sc; y: parent.height - height - 40 * root.sc
        width: pr.implicitWidth + 28 * root.sc; height: 66 * root.sc
        LockPill {
            anchors.fill: parent
            Row {
                id: pr
                anchors.centerIn: parent
                spacing: 6 * root.sc
                Repeater {
                    model: [
                        { icon: "bedtime", cmd: ["systemctl", "suspend"], confirm: false },
                        { icon: "restart_alt", cmd: ["systemctl", "reboot"], confirm: true },
                        { icon: "power_settings_new", cmd: ["systemctl", "poweroff"], confirm: true }
                    ]
                    M3Button {
                        id: pb
                        required property var modelData
                        property bool armed: false
                        icon: modelData.icon
                        size: "m"
                        variant: armed ? "filled" : "text"
                        onClicked: {
                            if (modelData.confirm && !armed) { armed = true; disarm.restart() }
                            else Quickshell.execDetached(modelData.cmd)
                        }
                        Timer { id: disarm; interval: 3000; onTriggered: pb.armed = false }
                    }
                }
            }
        }
    }
}
