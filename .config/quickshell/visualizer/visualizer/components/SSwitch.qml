import QtQuick
import QtQuick.Layouts
import ".."
RowLayout {
    property string label
    property bool checked
    signal toggled(bool v)
    Layout.fillWidth: true
    Text { text: label; color: Colors.foreground; font.pixelSize: 12; Layout.fillWidth: true }
    Rectangle {
        width: 36; height: 20; radius: 10; color: checked ? Colors.primary : Colors.outline
        Behavior on color { ColorAnimation { duration: 120 } }
        Rectangle { width: 14; height: 14; radius: 7; y: 3; x: checked ? 19 : 3; color: Colors.background
            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } } }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: toggled(!checked) }
    }
}
