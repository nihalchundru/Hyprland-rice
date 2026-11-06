import Quickshell
import QtQuick

PanelWindow {

    Something {
        id: testthree
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        anchors.bottomMargin: 50
        anchors.rightMargin: 100

        otherheight: 600
        otherwidth: 500

        Mycolor2: "red"
        onClicked: function(colors) {
            test.Mycolor = colors
        }
    }

    Rectangle {
        id: gh
        implicitHeight: 100
        implicitWidth: 300

        anchors.top: parent.top
        anchors.right: parent.right
        property color H: "blue"
        property string Activeresponse: "Inactive"
        radius: 20 
        color: H

        MouseArea {
            onClicked: {
                testthree.toggleActiveState()
                testthree.Mycolor3s("yellow")
                Activeresponse = testthree.isActiveCheck();
            }
        }

        Text {
            text: Activeresponse
        }
    }

    Rectangle {
        id: test

        implicitHeight: 100
        implicitWidth: 300

        anchors.top: parent.top
        anchors.left: parent.left

        anchors.leftMargin: 50
        anchors.topMargin: 100

        property color Mycolor: "blue"

        radius: 20
        color: Mycolor

        MouseArea {
            anchors.fill: test

            onClicked: {
                if (Mycolor == "blue") {
                    Mycolor = "gray"
                } else {
                    Mycolor = "blue"
                }
            }
        }
    }
}