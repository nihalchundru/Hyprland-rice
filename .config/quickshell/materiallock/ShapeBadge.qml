import QtQuick
import "shapes.js" as Shapes

Canvas {
    id: root

    property string shape: "oval"
    property color shapeColor: "#d0bcff"

    onShapeChanged: requestPaint()
    onShapeColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    antialiasing: true
    Component.onCompleted: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        Shapes.draw(ctx, shape, width / 2, height / 2,
                    Math.min(width, height) / 2 * 0.96, shapeColor)
    }
}
