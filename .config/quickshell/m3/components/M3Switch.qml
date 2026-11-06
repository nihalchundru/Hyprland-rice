import QtQuick
import qs.tokens

Item {
    id: root
    property bool checked: false
    signal toggled()
    implicitWidth: 52; implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? M3Colors.primary : M3Colors.surfaceContainerHighest
        border.width: root.checked ? 0 : 2
        border.color: M3Colors.outline
        ColorBehavior on color {}
    }
    Rectangle {
        id: thumb
        width: mouse.pressed ? 28 : (root.checked ? 24 : 16)
        height: width
        radius: width / 2
        y: (parent.height - height) / 2
        x: (root.checked ? 36 : 16) - width / 2
        color: root.checked ? M3Colors.fgPrimary : M3Colors.outline
        ColorBehavior on color {}
        SpatialBehavior on width {}
        SpatialBehavior on x {}
        Icon {
            anchors.centerIn: parent
            name: "check"; size: 16
            color: M3Colors.fgPrimaryContainer
            opacity: root.checked ? 1 : 0
            FadeBehavior on opacity {}
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.checked = !root.checked; root.toggled() }
    }
}
