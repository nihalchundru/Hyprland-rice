import QtQuick
import "../core"
import "../components"

Rectangle {
    id: b

    property string text: ""
    property bool primary: false
    property bool danger: false
    signal clicked()

    implicitWidth: label.implicitWidth + 28
    implicitHeight: 32
    radius: 12
    opacity: enabled ? 1 : 0.4

    color: primary ? Theme.accent
         : danger  ? Qt.alpha(Theme.danger, ma.containsMouse ? 0.30 : 0.18)
         : ma.containsMouse ? Qt.lighter(Theme.cardAlt, 1.15) : Theme.cardAlt
    Behavior on color { ColorAnimation { duration: 120 } }

    Txt {
        id: label
        anchors.centerIn: parent
        text: b.text
        font.pixelSize: 12
        font.weight: Font.Bold
        color: b.primary ? Theme.onAccent : b.danger ? Theme.danger : Theme.onSurface
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: b.clicked()
    }
}