import QtQuick

// Analogue clock cased in the Material 3 "sunny" shape.
//
// The hands read straight off TimeSource.now, which ticks every frame, so the
// seconds hand sweeps instead of ticking. There is deliberately no Behaviour or
// NumberAnimation on `rotation`: because the angle is applied directly, taking
// it modulo 360 is invisible -- 359.99deg and 0.01deg are the same place on the
// dial, so the hand carries on through the top instead of snapping back.
Item {
    id: root

    property real diameter: 320

    implicitWidth: diameter
    implicitHeight: diameter

    readonly property real ms: TimeSource.now

    // ---- casing ------------------------------------------------------------
    M3Shape {
        anchors.fill: parent
        kind: "sunny"
        fillColor: M3Theme.palette.primaryContainer
    }

    // ---- dial --------------------------------------------------------------
    Item {
        id: face

        anchors.centerIn: parent
        width: root.diameter * 0.72
        height: width

        M3Shape {
            anchors.fill: parent
            kind: "circle"
            fillColor: M3Theme.palette.surfaceContainerHighest
        }

        // Hour markers.
        //
        // Each marker is a half-dial-tall item so that rotating it about
        // Item.Bottom pivots on the dial centre; only the small rectangle near
        // the rim is actually painted.
        //
        // `index` is read through the `marker` id rather than bare: QML puts a
        // property in scope only for the current type or the file's root type,
        // and this delegate is neither.
        Repeater {
            model: 12

            delegate: Item {
                id: marker

                required property int index

                readonly property bool major: marker.index % 3 === 0

                width: 6
                height: face.height / 2
                x: face.width / 2 - width / 2
                y: 0
                transformOrigin: Item.Bottom
                rotation: marker.index * 30

                Rectangle {
                    width: marker.major ? 4 : 2
                    height: marker.major ? face.height * 0.045 : face.height * 0.03
                    radius: width / 2
                    color: marker.major ? M3Theme.palette.onSurfaceVariant : M3Theme.palette.outline
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: face.height * 0.035
                    antialiasing: true
                }
            }
        }

        // ---- hands (declared after the markers so they paint on top) -------

        // hour
        Rectangle {
            width: Math.max(4, face.width * 0.032)
            height: face.height * 0.26
            x: face.width / 2 - width / 2
            y: face.height / 2 - height
            radius: width / 2
            color: M3Theme.palette.onSurface
            transformOrigin: Item.Bottom
            rotation: ((root.ms / 3600000) * 30) % 360
            antialiasing: true
        }

        // minute
        Rectangle {
            width: Math.max(3, face.width * 0.024)
            height: face.height * 0.36
            x: face.width / 2 - width / 2
            y: face.height / 2 - height
            radius: width / 2
            color: M3Theme.palette.onSurface
            transformOrigin: Item.Bottom
            rotation: ((root.ms / 60000) * 6) % 360
            antialiasing: true
        }

        // second -- tertiary coloured so it reads as the live element
        Rectangle {
            width: Math.max(2, face.width * 0.014)
            height: face.height * 0.42
            x: face.width / 2 - width / 2
            y: face.height / 2 - height
            radius: width / 2
            color: M3Theme.palette.tertiary
            transformOrigin: Item.Bottom
            rotation: ((root.ms / 1000) * 6) % 360
            antialiasing: true
        }

        // centre cap
        Rectangle {
            width: face.width * 0.05
            height: width
            radius: width / 2
            color: M3Theme.palette.tertiary
            anchors.centerIn: parent
            antialiasing: true
        }
    }
}
