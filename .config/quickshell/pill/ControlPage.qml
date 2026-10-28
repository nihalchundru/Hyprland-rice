import QtQuick
import "ccLayout.js" as Lay

// The control center, drawn from the saved layout (Settings -> Control Center).
Item {
    id: root

    readonly property int cell: 64
    readonly property int gap: 12
    readonly property int pad: 20

    property int cols: 7
    property var layout: []
    readonly property int rows: Math.max(1, Lay.rowsOf(layout))

    // Settings changes on every slider anywhere, so only rebuild when the layout itself changes
    readonly property string sig: JSON.stringify([Settings.get("controlLayout"), Settings.get("controlCols")])
    onSigChanged: reload()

    function reload() {
        cols = Settings.get("controlCols");
        layout = Lay.sanitize(Settings.get("controlLayout"), cols);
    }

    width: cols * cell + (cols - 1) * gap + pad * 2
    height: rows * cell + (rows - 1) * gap + pad * 2

    onWidthChanged: Pill.setWidth("control", width)
    onHeightChanged: Pill.setHeight("control", height)
    Component.onCompleted: {
        reload();
        Pill.setWidth("control", width);
        Pill.setHeight("control", height);
    }

    Repeater {
        model: root.layout

        ControlItem {
            required property var modelData
            cid: modelData.id
            x: root.pad + modelData.x * (root.cell + root.gap)
            y: root.pad + modelData.y * (root.cell + root.gap)
            width: modelData.w * root.cell + (modelData.w - 1) * root.gap
            height: modelData.h * root.cell + (modelData.h - 1) * root.gap
        }
    }

    Text {
        visible: root.layout.length === 0
        anchors.centerIn: parent
        text: "No controls. Add some in Settings \u2192 Control Center."
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(14)
    }
}
