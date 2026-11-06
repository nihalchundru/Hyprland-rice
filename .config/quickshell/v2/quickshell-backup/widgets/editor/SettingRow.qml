import QtQuick
import "../core"
import "../components"

Item {
    id: r

    property var spec: ({})
    property var value
    signal edited(var v)

    implicitHeight: spec.kind === "text" ? 58 : 34

    Toggle {
        visible: r.spec.kind === "toggle"
        anchors.fill: parent
        label: r.spec.label ?? ""
        checked: r.value === true
        onToggled: v => r.edited(v)
    }
    Segmented {
        visible: r.spec.kind === "choice"
        anchors.fill: parent
        label: r.spec.label ?? ""
        options: r.spec.options ?? []
        current: String(r.value)
        onPicked: v => r.edited(v)
    }
    Field {
        visible: r.spec.kind === "text"
        anchors.fill: parent
        label: r.spec.label ?? ""
        placeholder: r.spec.placeholder ?? ""
        text: String(r.value ?? "")
        onCommitted: v => r.edited(v)
    }
}