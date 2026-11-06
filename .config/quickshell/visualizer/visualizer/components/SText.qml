import QtQuick
import QtQuick.Layouts
import ".."
RowLayout {
    property string label
    property string value
    signal edited(string v)
    Layout.fillWidth: true
    Text { text: label; color: Colors.foreground; font.pixelSize: 12; Layout.fillWidth: true }
    Rectangle {
        width: 120; height: 26; radius: 6; color: "transparent"; border.color: ti.activeFocus ? Colors.primary : Colors.outline
        TextInput { id: ti; anchors.fill: parent; anchors.margins: 6; text: value; color: Colors.foreground; font.pixelSize: 12
            font.family: "monospace"; clip: true; selectByMouse: true
            onEditingFinished: edited(text) }
    }
    Rectangle { width: 20; height: 20; radius: 4; color: value; border.color: Colors.outline }
}
