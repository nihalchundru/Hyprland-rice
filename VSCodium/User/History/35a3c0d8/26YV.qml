import Quickshell
import QtQuick

PanelWindow {
    id: bar

    anchors {top: true; left: true; right: true;}
    implicitHeight: 33
    color: "transparent"


    Pill{
        anchors.centerIn: parent
        icon: "󰥔"
        label:"9:41"
    }
}

