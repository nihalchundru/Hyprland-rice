import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle{
    id: root

    FileView{
        id: colorsFile
        path: "/home/nihal/.config/quickshell/topbar/colors.json"

    }

    property var colors: JSON.parse(colorsFile.text())
    property string icon:""
    property string label:""

}