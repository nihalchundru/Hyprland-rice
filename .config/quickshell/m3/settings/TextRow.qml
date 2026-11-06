import QtQuick
import qs.tokens
import qs.components

SRow {
    id: root
    property string value: ""
    property string placeholder: ""
    property int fieldWidth: 200
    signal edited(string v)
    Rectangle {
        width: root.fieldWidth; height: 40
        radius: 20
        color: M3Colors.surfaceContainerHighest
        M3Text { visible: input.text === ""; x: 16; anchors.verticalCenter: parent.verticalCenter; text: root.placeholder; color: M3Colors.fgSurfaceVariant; role: M3Type.bodyMedium }
        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 16; anchors.rightMargin: 16
            verticalAlignment: TextInput.AlignVCenter
            text: root.value
            color: M3Colors.fgSurface
            font.family: M3Type.family
            font.pixelSize: 14
            clip: true
            onEditingFinished: root.edited(text.trim())
        }
    }
}
