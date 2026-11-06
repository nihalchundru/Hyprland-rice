import QtQuick
import "../../core"
import "../../components"
import "../../services"

Item {
    id: root

    property int cols: 3
    property int rows: 1
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    Component.onCompleted: Weather.users++
    Component.onDestruction: Weather.users--

    Binding { target: Weather; property: "location"; value: root.settings.location ?? "auto" }
    Binding { target: Weather; property: "units";    value: root.settings.units ?? "metric" }

    function subLine() {
        if (Weather.failed && Weather.ready)
            return "offline · updated " + Math.round((Date.now() - Weather.updated) / 60000) + "m ago";
        if (Weather.failed) return "offline";
        return Weather.place;
    }

    Txt {
        id: temp
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: Weather.ready ? Math.round(Weather.temp) + "°" : "--"
        font.pixelSize: root.height * 0.8
        font.weight: Font.Bold
    }

    Column {
        visible: root.cols >= 2
        anchors.left: temp.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Txt {
            width: parent.width
            text: Weather.ready ? Weather.description : "Loading…"
            elide: Text.ElideRight
        }
        Txt {
            width: parent.width
            text: root.subLine()
            color: Theme.onSurfaceDim
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }
}