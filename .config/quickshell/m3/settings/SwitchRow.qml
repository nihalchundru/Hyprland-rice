import QtQuick
import qs.components

SRow {
    id: root
    property bool checked: false
    signal toggled(bool value)
    M3Switch { id: sw; onToggled: root.toggled(sw.checked) }
    Binding { target: sw; property: "checked"; value: root.checked }
}
