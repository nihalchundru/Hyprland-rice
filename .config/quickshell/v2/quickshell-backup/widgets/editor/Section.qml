import QtQuick
import "../core"
import "../components"

Item {
    id: s
    property string text: ""
    implicitHeight: 30

    Txt {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        text: s.text.toUpperCase()
        color: Theme.onSurfaceDim
        font.pixelSize: 10
        font.weight: Font.Bold
        font.letterSpacing: 1
    }
}