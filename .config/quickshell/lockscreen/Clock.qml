import QtQuick

// Analog clock inside a 9-sided cookie.
//  - the cookie is static; only the hands move
//  - 12 ticks, stacked bold 12h digits (teal), hour/minute hands (text),
//    smooth seconds hand (accent) that extends past the cookie edge
// Layer order: cookie, ticks, digits, hands.
Item {
    id: root

    property real size: 320

    implicitWidth: size
    implicitHeight: size

    // Updated every frame: drives the smooth seconds hand and everything else.
    // Reading the real time each frame means it can't drift.
    property date now: new Date()
    FrameAnimation {
        running: root.visible
        onTriggered: root.now = new Date()
    }

    readonly property real secs: now.getSeconds() + now.getMilliseconds() / 1000
    readonly property real mins: now.getMinutes() + secs / 60
    readonly property real hours: (now.getHours() % 12) + mins / 60

    readonly property int hour12: now.getHours() % 12 === 0 ? 12 : now.getHours() % 12
    readonly property string minuteText: now.getMinutes().toString().padStart(2, "0")

    // --- Cookie ---
    MShape {
        id: cookie
        anchors.centerIn: parent
        size: root.size
        shape: "Cookie9Sided"
        color: Colors.surface
    }

    // --- Ticks ---
    Repeater {
        model: 12
        Item {
            required property int index
            readonly property bool major: index % 3 === 0
            anchors.centerIn: root
            width: 0
            height: 0
            rotation: index * 30

            Rectangle {
                // Sits at the top of the circle, pointing at the center.
                x: -width / 2
                y: -root.size * 0.37
                width: major ? 4 : 3
                height: major ? root.size * 0.065 : root.size * 0.04
                radius: width / 2
                color: Colors.text
                opacity: major ? 1.0 : 0.6
            }
        }
    }

    // --- Digital time: stacked, bold, own color ---
    Column {
        anchors.centerIn: root
        spacing: -root.size * 0.04

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.hour12
            color: Colors.teal
            font.pixelSize: root.size * 0.26
            font.weight: Font.Black
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.minuteText
            color: Colors.teal
            font.pixelSize: root.size * 0.26
            font.weight: Font.Black
        }
    }

    // --- Hands ---
    // A hand is a 0x0 item at the center that rotates; its child rectangle
    // extends upward from the pivot (plus an optional tail below it).
    component Hand: Item {
        id: hand
        property real angle: 0
        property real length: 100
        property real tail: 0
        property real thickness: 6
        property color color: "white"

        anchors.centerIn: root
        width: 0
        height: 0
        rotation: angle

        Rectangle {
            x: -hand.thickness / 2
            y: -hand.length
            width: hand.thickness
            height: hand.length + hand.tail
            radius: hand.thickness / 2
            color: hand.color
        }
    }

    Hand { // hour
        angle: root.hours * 30
        length: root.size * 0.22
        thickness: root.size * 0.03
        color: Colors.text
    }

    Hand { // minute
        angle: root.mins * 6
        length: root.size * 0.33
        thickness: root.size * 0.022
        color: Colors.text
    }

    Hand { // seconds: longer than the cookie radius so it pokes out
        angle: root.secs * 6
        length: root.size * 0.56
        tail: root.size * 0.09
        thickness: Math.max(2, root.size * 0.01)
        color: Colors.accent
    }

    // Center cap
    Rectangle {
        anchors.centerIn: root
        width: root.size * 0.045
        height: width
        radius: width / 2
        color: Colors.accent
    }
}
