import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.components

// Label + switch row. Bind `checked` to your setting and handle toggled(value).
RowLayout {
    id: root
    property string title: ""
    property string sub: ""
    property bool checked: false
    signal toggled(bool value)
    Layout.fillWidth: true
    spacing: 12
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        M3Text { text: root.title; role: M3Type.bodyLarge }
        M3Text { visible: root.sub !== ""; text: root.sub; role: M3Type.bodySmall; color: M3Colors.fgSurfaceVariant }
    }
    M3Switch { id: sw; onToggled: root.toggled(sw.checked) }
    Binding { target: sw; property: "checked"; value: root.checked }
}
