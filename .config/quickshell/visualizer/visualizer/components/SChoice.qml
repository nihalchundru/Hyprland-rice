import QtQuick
import QtQuick.Layouts
import ".."
ColumnLayout {
    id: r
    property string label
    property var options: []
    property string current
    signal picked(string v)
    Layout.fillWidth: true
    spacing: 6
    Text { text: r.label; color: Colors.foreground; font.pixelSize: 12; visible: label !== "" }
    Flow {
        Layout.fillWidth: true; spacing: 6
        Repeater {
            model: r.options
            Rectangle {
                required property string modelData
                readonly property bool sel: modelData === r.current
                width: t.implicitWidth + 18; height: 26; radius: 13
                color: sel ? Colors.primary : (mm.containsMouse ? Qt.alpha(Colors.primary, 0.2) : "transparent")
                border.width: 1; border.color: sel ? Colors.primary : Colors.outline
                Behavior on color { ColorAnimation { duration: 100 } }
                Text { id: t; anchors.centerIn: parent; text: modelData; font.pixelSize: 11
                    color: parent.sel ? Colors.background : Colors.foreground }
                MouseArea { id: mm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: r.picked(modelData) }
            }
        }
    }
}
