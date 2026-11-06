import QtQuick
import QtQuick.Layouts
import qs.theme

Item {
    id: root
    property string icon: ""
    property string text: ""
    property color container: Qt.alpha(Colors.surface, 0)
    property color content: Colors.onSurface
    property int maxTextWidth: 160
    property bool iconFilled: false

    signal clicked()
    signal rightClicked()

    implicitHeight: 28
    implicitWidth: layout.implicitWidth + 20

    Surface {
        anchors.fill: parent
        radius: M3.shape.full
        color: root.container
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        M3Icon {
            visible: root.icon !== ""
            name: root.icon
            size: 18
            filled: root.iconFilled
            color: root.content
        }
        M3Text {
            visible: root.text !== ""
            text: root.text
            role: "labelLarge"
            color: root.content
            Layout.preferredWidth: Math.min(implicitWidth, root.maxTextWidth)
        }
    }

    StateLayer {
        anchors.fill: parent
        radius: M3.shape.full
        color: root.content
        onClicked: root.clicked()
        onRightClicked: root.rightClicked()
    }
}