import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.components

ColumnLayout {
    id: root
    property string icon: ""
    property string title: ""
    property var options: []
    property string value: ""
    signal picked(string v)
    Layout.fillWidth: true
    spacing: 8
    RowLayout {
        spacing: 14
        Layout.topMargin: 4
        Icon { visible: root.icon !== ""; name: root.icon; size: 22; color: M3Colors.fgSurfaceVariant }
        M3Text { text: root.title; role: M3Type.bodyLarge }
    }
    Flow {
        Layout.fillWidth: true
        Layout.bottomMargin: 4
        spacing: 8
        Repeater {
            model: root.options
            M3Chip { required property string modelData; text: modelData; selected: root.value === modelData; onClicked: root.picked(modelData) }
        }
    }
}
