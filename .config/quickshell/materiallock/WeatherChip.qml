import QtQuick
import "shapes.js" as Shapes

// Weather chip: 12-sided cookie shape holding a dynamic Google weather
// icon + temperature. Fades in once the fetch succeeds.
Item {
    id: root

    property color chipColor: "#2b2930"
    property color textColor: "#e6e0e9"
    property string iconSource: ""
    property string temp: ""
    property string desc: ""

    implicitWidth: size
    implicitHeight: size
    property real size: Math.min(width, height)

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 500 } }

    onVisibleChanged: bg.requestPaint()
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
            Shapes.draw(ctx, "cookie12", width / 2, height / 2,
                        Math.min(width, height) / 2 * 0.99, root.chipColor)
        }
        Component.onCompleted: requestPaint()
    }

    Column {
        anchors.centerIn: parent
        spacing: 6

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.size * 0.34
            height: width
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.temp
            color: root.textColor
            font.pixelSize: root.size * 0.155
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.desc
            color: Qt.alpha(root.textColor, 0.65)
            font.pixelSize: root.size * 0.08
            font.letterSpacing: 1
        }
    }
}
