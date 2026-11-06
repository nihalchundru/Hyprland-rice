import QtQuick
import QtQuick.Effects
import "shapes.js" as Shapes

// One stat tile: 6-sided cookie casing, a small white cookie4 badge with a
// dark icon inside, big %, label below.
Item {
    id: root

    property string iconSource: ""
    property color iconColor: "#1d1b20"
    property string value: ""
    property string label: ""
    property color chipColor: "#2b2930"
    property color textColor: "#e6e0e9"
    property color subColor: "#938f99"

    readonly property real size: Math.min(width, height)

    onChipColorChanged: bg.requestPaint()

    Canvas {
        id: bg
        anchors.fill: parent
        antialiasing: true
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            Shapes.draw(ctx, "cookie6", width / 2, height / 2,
                        Math.min(width, height) / 2 * 0.99, root.chipColor)
        }
        Component.onCompleted: requestPaint()
    }

    Column {
        anchors.centerIn: parent
        spacing: root.size * 0.04

        // white 4-sided cookie badge carrying the dark icon
        Item {
            id: badge
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.size * 0.28
            height: width

            ShapeBadge {
                anchors.fill: parent
                shape: "cookie4"
                shapeColor: root.textColor
            }

            Image {
                anchors.centerIn: parent
                width: badge.width * 0.54
                height: width
                source: root.iconSource
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorizationEnabled: true
                    colorizationColor: root.iconColor
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.value
            color: root.textColor
            font.pixelSize: root.size * 0.16
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: root.subColor
            font.pixelSize: root.size * 0.075
            font.letterSpacing: 2
        }
    }
}
