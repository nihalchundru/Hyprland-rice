import QtQuick
import "../core"
import "../shapes"

Item {
    id: root

    property bool checked: false
    property string checkedIcon: "✓"
    property string uncheckedIcon: ""

    signal toggled(bool value)

    implicitWidth: 52
    implicitHeight: 32

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.primary : Theme.surfaceContainerHighest
        border.width: root.checked ? 0 : 2
        border.color: Theme.outline

        Behavior on color {
            ColorAnimation { duration: Motion.durationShort4; easing.type: Easing.OutCubic }
        }
        Behavior on border.color {
            ColorAnimation { duration: Motion.durationShort4; easing.type: Easing.OutCubic }
        }

        Item {
            id: thumbContainer
            width: mouse.pressed ? 28 : (root.checked ? 24 : 18)
            height: width
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? (parent.width - width - 4) : (mouse.pressed ? 2 : 6)

            Behavior on x {
                NumberAnimation {
                    duration: Motion.durationMedium2
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Motion.expressiveSpatialFast
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: Motion.durationShort4
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Motion.expressiveSpatialFast
                }
            }

            ShapeCanvas {
                anchors.fill: parent
                shapeName: mouse.pressed ? "cookie6" : (root.checked ? "sunny" : "circle")
                color: root.checked ? Theme.onPrimary : Theme.outline
            }

            Text {
                anchors.centerIn: parent
                text: root.checked ? root.checkedIcon : root.uncheckedIcon
                font.family: Theme.fontFamilySans
                font.pixelSize: 11
                font.weight: Font.Bold
                color: root.checked ? Theme.primary : Theme.surfaceContainerHighest
                opacity: (root.checked && root.checkedIcon !== "") || (!root.checked && root.uncheckedIcon !== "") ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
