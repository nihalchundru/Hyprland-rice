import QtQuick
import "../core"
import "../components"

Item {
    id: root
    implicitHeight: wd ? col.implicitHeight : emptyText.implicitHeight

    readonly property var wd: LayoutStore.find(LayoutStore.selectedId)
    readonly property string wid: wd?.id ?? ""
    readonly property string wtype: wd?.type ?? ""
    readonly property int wx: wd?.x ?? 0
    readonly property int wy: wd?.y ?? 0
    readonly property int ww: wd?.w ?? 1
    readonly property int wh: wd?.h ?? 1
    readonly property var info: WidgetRegistry.info(wtype)
    readonly property var lim: LayoutStore.limits(wtype)

    property string notice: ""
    onWidChanged: notice = ""

    function ok(x, y, w, h) { return LayoutStore.fits(wid, x, y, w, h); }
    function tryRect(x, y, w, h) {
        if (wd && ok(x, y, w, h)) LayoutStore.setRect(wid, x, y, w, h);
    }

    Txt {
        id: emptyText
        visible: !root.wd
        width: parent.width
        wrapMode: Text.WordWrap
        text: "Select a widget on the desktop to edit its position, size and settings."
        color: Theme.onSurfaceDim
        font.pixelSize: 12
    }

    Column {
        id: col
        visible: root.wd !== null
        width: parent.width
        spacing: 4

        Txt {
            text: root.info?.name ?? ""
            font.pixelSize: 18
            font.weight: Font.Bold
        }
        Txt {
            text: root.wid
            color: Theme.onSurfaceDim
            font.pixelSize: 11
        }

        Section { width: col.width; text: "Position" }
        Stepper {
            width: col.width
            label: "X"
            value: root.wx
            decEnabled: root.ok(root.wx - 1, root.wy, root.ww, root.wh)
            incEnabled: root.ok(root.wx + 1, root.wy, root.ww, root.wh)
            onEdited: v => root.tryRect(v, root.wy, root.ww, root.wh)
        }
        Stepper {
            width: col.width
            label: "Y"
            value: root.wy
            decEnabled: root.ok(root.wx, root.wy - 1, root.ww, root.wh)
            incEnabled: root.ok(root.wx, root.wy + 1, root.ww, root.wh)
            onEdited: v => root.tryRect(root.wx, v, root.ww, root.wh)
        }

        Section { width: col.width; text: "Size (cells)" }
        Stepper {
            width: col.width
            label: "Width"
            value: root.ww
            from: root.lim.minW
            to: root.lim.maxW
            incEnabled: root.ok(root.wx, root.wy, root.ww + 1, root.wh)
            onEdited: v => root.tryRect(root.wx, root.wy, v, root.wh)
        }
        Stepper {
            width: col.width
            label: "Height"
            value: root.wh
            from: root.lim.minH
            to: root.lim.maxH
            incEnabled: root.ok(root.wx, root.wy, root.ww, root.wh + 1)
            onEdited: v => root.tryRect(root.wx, root.wy, root.ww, v)
        }

        Section {
            width: col.width
            text: "Settings"
            visible: (root.info?.settings?.length ?? 0) > 0
        }
        Repeater {
            model: root.info?.settings ?? []

            delegate: SettingRow {
                required property var modelData
                width: col.width
                spec: modelData
                value: root.wd?.settings?.[modelData.key] ?? modelData.def
                onEdited: v => LayoutStore.setSetting(root.wid, modelData.key, v)
            }
        }

        Item { width: col.width; height: 14 }

        Row {
            spacing: 8
            Btn {
                text: "Duplicate"
                onClicked: root.notice = LayoutStore.duplicateWidget(root.wid) !== ""
                    ? "" : "No free space to duplicate."
            }
            Btn {
                text: "Delete"
                danger: true
                onClicked: LayoutStore.removeWidget(root.wid)
            }
        }
        Txt {
            visible: root.notice !== ""
            width: col.width
            wrapMode: Text.WordWrap
            text: root.notice
            color: Theme.danger
            font.pixelSize: 12
        }
    }
}