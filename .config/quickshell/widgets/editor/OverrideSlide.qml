import QtQuick
import "../core"
import "../components"

Item {
    id: o

    property string label: ""
    property var value                      // undefined/null = inherit the global value
    property real inherited: 0
    property real from: 0
    property real to: 1
    property real step: 0.01
    property real displayScale: 1
    property string suffix: ""
    signal edited(var v)                    // null means "go back to inheriting"

    readonly property bool custom: value !== undefined && value !== null

    implicitHeight: col.implicitHeight

    Column {
        id: col
        width: parent.width

        Toggle {
            width: col.width
            label: o.custom
                ? o.label
                : o.label + " · global " + Math.round(o.inherited * o.displayScale) + o.suffix
            checked: o.custom
            onToggled: v => o.edited(v ? o.inherited : null)
        }
        Slide {
            visible: o.custom
            width: col.width
            label: "Custom value"
            value: o.custom ? o.value : o.inherited
            from: o.from
            to: o.to
            step: o.step
            displayScale: o.displayScale
            suffix: o.suffix
            onEdited: v => o.edited(v)
        }
    }
}