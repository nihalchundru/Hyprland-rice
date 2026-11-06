import Quickshell
import QtQuick

Rectangle {
    id: testtoo

    implicitHeight: otherheight
    implicitWidth: otherwidth

    property int otherwidth: 700
    property int otherheight: 40

    radius: 20
    signal clicked(color Mycolor2)

    property color Mycolor2: "red"
    property bool isActive: false
    property color Mycolor3: "black"

    color: isActive ? "green" : "orange"

    function Mycolor3s(color Mycolor3) {
        Mycolor2 = Mycolor3
    }

    function toggleActiveState() {
        isActive = !isActive
    }

    function isActiveCheck() {
        if (isActive == true) {
            return "Active"
        } else {
            return "Inactive"
        }
    }

    MouseArea {
        anchors.fill: testtoo

        onClicked: {
            clicked(Mycolor2)
            isActive = !isActive
        }
    }
}