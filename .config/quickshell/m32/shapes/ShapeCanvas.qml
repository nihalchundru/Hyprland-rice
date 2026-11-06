import QtQuick
import "shapes/morph.js" as Morph
import "material-shapes.js" as MaterialShapes

Canvas {
    id: root
    property color color: "#685496"
    property string shapeName: ""
    property var roundedPolygon: shapeName !== "" ? resolveNamedShape(shapeName) : MaterialShapes.getCircle()
    property bool polygonIsNormalized: true
    property real borderWidth: 0
    property color borderColor: color
    property bool debug: false
    property real xOffset: 0
    property real yOffset: 0
    property real rotationAngle: 0

    function resolveNamedShape(name) {
        switch (name) {
            case "circle": return MaterialShapes.getCircle();
            case "square": return MaterialShapes.getSquare();
            case "slanted": return MaterialShapes.getSlanted();
            case "arch": return MaterialShapes.getArch();
            case "fan": return MaterialShapes.getFan();
            case "arrow": return MaterialShapes.getArrow();
            case "semiCircle": return MaterialShapes.getSemiCircle();
            case "oval": return MaterialShapes.getOval();
            case "pill": return MaterialShapes.getPill();
            case "triangle": return MaterialShapes.getTriangle();
            case "diamond": return MaterialShapes.getDiamond();
            case "clamShell": return MaterialShapes.getClamShell();
            case "pentagon": return MaterialShapes.getPentagon();
            case "gem": return MaterialShapes.getGem();
            case "sunny": return MaterialShapes.getSunny();
            case "verySunny": return MaterialShapes.getVerySunny();
            case "cookie4":
            case "cookie4Sided": return MaterialShapes.getCookie4Sided();
            case "cookie6":
            case "cookie6Sided": return MaterialShapes.getCookie6Sided();
            case "cookie7":
            case "cookie7Sided": return MaterialShapes.getCookie7Sided();
            case "cookie9":
            case "cookie9Sided": return MaterialShapes.getCookie9Sided();
            case "cookie12":
            case "cookie12Sided": return MaterialShapes.getCookie12Sided();
            case "ghostish": return MaterialShapes.getGhostish();
            case "clover4":
            case "clover4Leaf": return MaterialShapes.getClover4Leaf();
            case "clover8":
            case "clover8Leaf": return MaterialShapes.getClover8Leaf();
            case "burst": return MaterialShapes.getBurst();
            case "softBurst": return MaterialShapes.getSoftBurst();
            case "boom": return MaterialShapes.getBoom();
            case "softBoom": return MaterialShapes.getSoftBoom();
            case "flower": return MaterialShapes.getFlower();
            case "puffy": return MaterialShapes.getPuffy();
            case "puffyDiamond": return MaterialShapes.getPuffyDiamond();
            case "pixelCircle": return MaterialShapes.getPixelCircle();
            case "pixelTriangle": return MaterialShapes.getPixelTriangle();
            case "bun": return MaterialShapes.getBun();
            case "heart": return MaterialShapes.getHeart();
            default: return MaterialShapes.getCircle();
        }
    }

    // Internals: size
    property var bounds: roundedPolygon ? roundedPolygon.calculateBounds() : [0, 0, 32, 32]
    implicitWidth: bounds[2] - bounds[0]
    implicitHeight: bounds[3] - bounds[1]

    // Internals: anim
    property var prevRoundedPolygon: null
    property double progress: 1
    property var morph: roundedPolygon ? new Morph.Morph(roundedPolygon, roundedPolygon) : null
    property Animation animation: NumberAnimation {
        duration: 380
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1] // Material 3 Expressive fast spatial
    }

    Behavior on color {
        ColorAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    onRoundedPolygonChanged: {
        if (!root.roundedPolygon) return;
        delete root.morph;
        root.morph = new Morph.Morph(root.prevRoundedPolygon ?? root.roundedPolygon, root.roundedPolygon);
        morphBehavior.enabled = false;
        root.progress = 0;
        morphBehavior.enabled = true;
        root.progress = 1;
        root.prevRoundedPolygon = root.roundedPolygon;
    }

    Behavior on progress {
        id: morphBehavior
        animation: root.animation
    }

    onProgressChanged: requestPaint()
    onColorChanged: requestPaint()
    onBorderWidthChanged: requestPaint()
    onBorderColorChanged: requestPaint()
    onDebugChanged: requestPaint()
    onXOffsetChanged: requestPaint()
    onYOffsetChanged: requestPaint()
    onRotationAngleChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.fillStyle = root.color;
        ctx.clearRect(0, 0, width, height);
        if (!root.morph)
            return;
        const cubics = root.morph.asCubics(root.progress);
        if (!cubics || cubics.length === 0)
            return;
        const size = Math.min(root.width, root.height);
        if (size <= 0)
            return;

        ctx.save();
        if (root.polygonIsNormalized) {
            ctx.translate((root.width - size) / 2, (root.height - size) / 2);
            if (root.rotationAngle !== 0) {
                ctx.translate(size / 2, size / 2);
                ctx.rotate(root.rotationAngle * Math.PI / 180);
                ctx.translate(-size / 2, -size / 2);
            }
            ctx.scale(size, size);
        }
        ctx.translate(root.xOffset, root.yOffset);

        ctx.beginPath();
        ctx.moveTo(cubics[0].anchor0X, cubics[0].anchor0Y);
        for (const cubic of cubics) {
            ctx.bezierCurveTo(cubic.control0X, cubic.control0Y, cubic.control1X, cubic.control1Y, cubic.anchor1X, cubic.anchor1Y);
        }
        ctx.closePath();
        ctx.fill();

        if (root.borderWidth > 0) {
            ctx.strokeStyle = root.borderColor;
            ctx.lineWidth = root.borderWidth / (root.polygonIsNormalized ? size : 1);
            ctx.stroke();
        }

        ctx.restore();
    }
}
