import QtQuick
import Quickshell

Item {
    id: root
    width: 560

    implicitHeight: head.height + 4 + col.implicitHeight + 20
    height: implicitHeight
    onImplicitHeightChanged: Pill.setHeight("display", implicitHeight)
    Component.onCompleted: Pill.setHeight("display", implicitHeight)

    PageHeader {
        id: head
        width: parent.width
        title: "Display"
        onBack: Pill.open("control", true)
    }

    Column {
        id: col
        anchors.top: head.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        Text {
            text: "Brightness"
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(12)
        }

        SliderRow {
            width: col.width
            icon: "sun"
            active: Brightness.available
            value: Brightness.value
            onMoved: v => Brightness.set(v)
        }

        Text {
            visible: !Brightness.available
            width: col.width
            text: "No backlight device found (brightnessctl). Desktop monitors usually need ddcutil instead."
            wrapMode: Text.WordWrap
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(12)
        }

        Text {
            text: "Monitors"
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(12)
            topPadding: 6
        }

        Repeater {
            model: Quickshell.screens

            DeviceRow {
                required property var modelData
                width: col.width
                icon: "monitor"
                label: modelData.name
                sub: modelData.width + " × " + modelData.height
                clickable: false
            }
        }
    }
}
