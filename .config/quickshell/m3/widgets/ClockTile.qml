import QtQuick
import qs.tokens
import qs.services
import qs.components

// Clock widget with switchable styles (cfg.style): morph | numerals | flower.
// Analog hands run off a per-frame clock, so the seconds hand sweeps smoothly.
TileBase {
    id: t
    readonly property string style: cfg.style || "morph"
    readonly property bool secs: cfg.showSeconds !== false
    readonly property real face: Math.min(width, height) - 16
    readonly property color faceColor: customBg ? cfg.bgHex : Widgets.bg(cfg.color)
    readonly property var morphShapes: ["cookie12Sided", "softBurst", "cookie9Sided", "sunny", "cookie7Sided", "flower", "cookie6Sided", "clover8Leaf"]

    property real sec: 0      // seconds with milliseconds
    property real min: 0      // minutes with fraction
    property real hr: 0       // 12h hours with fraction

    // tile background: off for morph/flower by default, on for numerals; override with cfg.showBg
    readonly property bool bgOn: cfg.showBg !== undefined ? cfg.showBg : style === "numerals"
    color: bgOn ? (customBg ? cfg.bgHex : Widgets.bg(cfg.color)) : "transparent"

    FrameAnimation {
        running: t.style !== "morph" && t.visible
        onTriggered: {
            const d = new Date()
            t.sec = d.getSeconds() + d.getMilliseconds() / 1000
            t.min = d.getMinutes() + t.sec / 60
            t.hr = (d.getHours() % 12) + t.min / 60
        }
    }

    component Hand: Item {
        property real angle: 0
        property real len: 80
        property real thick: 6
        property real tail: 0
        property color col: "white"
        anchors.centerIn: parent
        width: 0; height: 0
        rotation: angle
        Rectangle { x: -thick / 2; y: -len; width: thick; height: len + tail; radius: thick / 2; color: col; antialiasing: true }
    }

    // ---------------------------------------------------------------- morph (digital)
    Item {
        id: mface
        visible: t.style === "morph"
        anchors.centerIn: parent
        width: t.face; height: width
        Item {
            anchors.fill: parent
            NumberAnimation on rotation { from: 0; to: 360; duration: 120000; loops: Animation.Infinite; running: t.style === "morph" }
            MorphShape {
                anchors.fill: parent
                size: parent.width
                shape: t.cfg.morph === false ? (t.cfg.shape || "cookie12Sided") : t.morphShapes[Clock.now.getMinutes() % t.morphShapes.length]
                color: t.accent
            }
        }
        Column {
            anchors.centerIn: parent
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.time; role: ({ size: Math.round(mface.width * 0.22), line: Math.round(mface.width * 0.25), weight: Font.Medium, tracking: -1 }); color: t.onAccent }
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.dateShort; role: M3Type.titleSmall; color: t.onAccent }
        }
    }

    // ---------------------------------------------------------------- numerals
    Item {
        id: nface
        visible: t.style === "numerals"
        anchors.centerIn: parent
        width: t.face; height: width

        // dial disc: faint when the tile background is on, solid theme color when it is off
        Rectangle { anchors.fill: parent; radius: width / 2; color: t.bgOn ? Qt.alpha(t.fg, 0.07) : t.faceColor }

        Repeater {
            model: 12
            Item {
                required property int index
                anchors.centerIn: parent
                width: 0; height: 0
                rotation: index * 30
                Rectangle { x: -1; y: -(nface.width / 2 - 7); width: 2; height: index % 3 === 0 ? 9 : 4; radius: 1; color: t.fg; opacity: 0.45 }
            }
        }
        Column {
            anchors.centerIn: parent
            spacing: -nface.width * 0.07
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.hourDigits; role: ({ size: Math.round(nface.width * 0.36), line: Math.round(nface.width * 0.36), weight: Font.Bold, tracking: 0 }); color: Qt.alpha(t.fg, 0.4) }
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.minuteDigits; role: ({ size: Math.round(nface.width * 0.36), line: Math.round(nface.width * 0.36), weight: Font.Bold, tracking: 0 }); color: Qt.alpha(t.fg, 0.4) }
        }
        M3Text { visible: Clock.ampm !== ""; anchors.horizontalCenter: parent.horizontalCenter; y: nface.width * 0.8; text: Clock.ampm; role: ({ size: Math.round(nface.width * 0.085), line: Math.round(nface.width * 0.1), weight: Font.Bold, tracking: 1 }); color: Qt.alpha(t.fg, 0.55) }
        Hand { angle: t.hr * 30; len: nface.width * 0.26; thick: Math.max(5, nface.width * 0.065); col: t.accent }
        Hand { angle: t.min * 6; len: nface.width * 0.38; thick: Math.max(4, nface.width * 0.05); col: t.fg }
        Rectangle { anchors.centerIn: parent; width: nface.width * 0.07; height: width; radius: width / 2; color: t.fg }
        Item {   // smooth orbiting seconds dot
            visible: t.secs
            anchors.centerIn: parent
            width: 0; height: 0
            rotation: t.sec * 6
            Rectangle { x: -4; y: -(nface.width / 2 - 20); width: 8; height: 8; radius: 4; color: t.accent }
        }
        Rectangle {   // top-left badge: month
            x: 0; y: 0
            width: nface.width * 0.22; height: width; radius: width * 0.3
            color: t.accent
            M3Text { anchors.centerIn: parent; text: String(Clock.now.getMonth() + 1).padStart(2, "0"); role: ({ size: Math.round(nface.width * 0.11), line: Math.round(nface.width * 0.13), weight: Font.Bold, tracking: 0 }); color: t.onAccent }
        }
        Rectangle {   // bottom-right bubble: day
            x: nface.width - width; y: nface.width - height
            width: nface.width * 0.22; height: width; radius: width / 2
            color: Qt.alpha(t.fg, 0.14)
            M3Text { anchors.centerIn: parent; text: String(Clock.now.getDate()).padStart(2, "0"); role: ({ size: Math.round(nface.width * 0.1), line: Math.round(nface.width * 0.12), weight: Font.Bold, tracking: 0 }); color: t.fg }
        }
    }

    // ---------------------------------------------------------------- flower (scalloped analog)
    Item {
        id: fface
        visible: t.style === "flower"
        anchors.centerIn: parent
        width: t.face; height: width

        MorphShape { anchors.fill: parent; size: parent.width; shape: "cookie12Sided"; color: t.faceColor }
        Repeater {
            model: 12
            Item {
                required property int index
                anchors.centerIn: parent
                width: 0; height: 0
                rotation: index * 30
                Rectangle { x: -1.25; y: -(fface.width / 2 - 16); width: 2.5; height: index % 3 === 0 ? 9 : 5; radius: 1.2; color: t.fg; opacity: 0.7 }
            }
        }
        Column {   // stacked time in the middle, same 12h/24h format as the setting
            anchors.centerIn: parent
            spacing: -fface.width * 0.05
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.hourDigits; role: ({ size: Math.round(fface.width * 0.24), line: Math.round(fface.width * 0.24), weight: Font.Bold, tracking: 0 }); color: Qt.alpha(t.fg, 0.4) }
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Clock.minuteDigits; role: ({ size: Math.round(fface.width * 0.24), line: Math.round(fface.width * 0.24), weight: Font.Bold, tracking: 0 }); color: Qt.alpha(t.fg, 0.4) }
        }
        M3Text { visible: Clock.ampm !== ""; anchors.horizontalCenter: parent.horizontalCenter; y: fface.width * 0.7; text: Clock.ampm; role: ({ size: Math.round(fface.width * 0.075), line: Math.round(fface.width * 0.09), weight: Font.Bold, tracking: 1 }); color: Qt.alpha(t.fg, 0.55) }
        Hand { angle: t.hr * 30; len: fface.width * 0.24; thick: Math.max(4, fface.width * 0.045); col: t.fg }
        Hand { angle: t.min * 6; len: fface.width * 0.36; thick: Math.max(3, fface.width * 0.032); col: t.fg }
        Hand { visible: t.secs; angle: t.sec * 6; len: fface.width * 0.40; thick: 2; tail: fface.width * 0.09; col: t.accent }
        Rectangle { anchors.centerIn: parent; width: 9; height: 9; radius: 4.5; color: t.accent }
    }
}
