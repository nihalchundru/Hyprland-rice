import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle{
    id: root

    FileView{
        id: colorsFile
        path: "/home/nihal/.config/quickshell/topbar/colors.json"
        blockLoading: true
    }

    property var colors: JSON.parse(colorsFile.text())
    property string icon:""
    property string label:""
    property color iconColor: colors.teal
    property int maxLabelWidth: 400

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 33
    radius: height / 2
    color: colors.bg

    RowLayout{
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text{
            text: root.icon
            color: root.iconColor
            font.family: "Material Symbols Rounded"
            font.pixelSize: 16
        }

        Text {
            text: root.label
            color: colors.text
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 16
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            visible: root.label !== ""

        }
    }

}
