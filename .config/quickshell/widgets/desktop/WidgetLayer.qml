import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"
import "../editor"

PanelWindow {
    id: win

    readonly property bool editing: LayoutStore.editMode
    readonly property int step: LayoutStore.cell + LayoutStore.gap
    readonly property int cols: Math.max(1,
        Math.floor((width - 2 * LayoutStore.margin + LayoutStore.gap) / step))
    readonly property int rows: Math.max(1,
        Math.floor((height - 2 * LayoutStore.margin + LayoutStore.gap) / step))

    Binding { target: LayoutStore; property: "gridCols"; value: win.cols }
    Binding { target: LayoutStore; property: "gridRows"; value: win.rows }

    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }

    WlrLayershell.layer: editing ? WlrLayer.Overlay : WlrLayer.Bottom
    WlrLayershell.namespace: "qs-widgets"
    WlrLayershell.keyboardFocus: editing ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    // Normal mode: input only on the widget rectangles. Edit mode: everywhere.
    Region { id: normalMask; regions: maskRegions.instances }
    mask: editing ? null : normalMask

    Variants {
        id: maskRegions
        model: LayoutStore.widgets

        Region {
            required property var modelData
            x: LayoutStore.posX(modelData.x)
            y: LayoutStore.posY(modelData.y)
            width: LayoutStore.px(modelData.w)
            height: LayoutStore.px(modelData.h)
        }
    }

    // dim + grid, below the cards
    EditorBackdrop {
        z: -1
        cols: win.cols
        rows: win.rows
    }

    // cards: keyed by id so they update in place instead of being rebuilt
    Repeater {
        model: LayoutStore.idModel

        delegate: WidgetFrame {
            id: frame
            required property string itemId
            readonly property var wd: LayoutStore.find(itemId)

            ws: wd?.style ?? ({})

            x: LayoutStore.posX(wd?.x ?? 0)
            y: LayoutStore.posY(wd?.y ?? 0)
            width: LayoutStore.px(wd?.w ?? 1)
            height: LayoutStore.px(wd?.h ?? 1)
            opacity: LayoutStore.dragId === itemId ? 0.45 : 1

            Behavior on x      { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on y      { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on width  { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Loader {
                id: ld
                anchors.fill: parent
                source: frame.wd
                    ? Qt.resolvedUrl("../widgets/" + frame.wd.type + "/Widget.qml")
                    : ""

                onLoaded: {
                    item.cols     = Qt.binding(() => frame.wd?.w ?? 1);
                    item.rows     = Qt.binding(() => frame.wd?.h ?? 1);
                    item.settings = Qt.binding(() => frame.wd?.settings ?? ({}));
                    item.accent   = Qt.binding(() => frame.accents[0]);
                    item.accent2  = Qt.binding(() => frame.accents[1]);
                    item.accent3  = Qt.binding(() => frame.accents[2]);
                }
            }

            Text {
                visible: ld.status === Loader.Error
                anchors.centerIn: parent
                text: "Failed to load: " + (frame.wd?.type ?? "?")
                color: Theme.danger
                font.pixelSize: 12
            }
        }
    }

    // handles, ghost, toolbar, above the cards
    EditorOverlay {
        z: 10
    }
}