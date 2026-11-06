import QtQuick

// Rotating clock hand: origin at the parent's center, `angle` in degrees (0 = 12 o'clock).
Item {
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
