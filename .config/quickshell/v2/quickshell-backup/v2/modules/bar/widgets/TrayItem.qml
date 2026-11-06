import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.theme
import qs.components

Item {
    id: root
    required property SystemTrayItem modelData

    implicitWidth: 28
    implicitHeight: 28

    IconImage {
        anchors.centerIn: parent
        implicitSize: 18
        source: root.modelData.icon
    }

    StateLayer {
        anchors.fill: parent
        radius: M3.shape.full
        onClicked: {
            if (root.modelData.onlyMenu && root.modelData.hasMenu) menu.open()
            else root.modelData.activate()
        }
        onRightClicked: {
            if (root.modelData.hasMenu) menu.open()
            else root.modelData.secondaryActivate()
        }
        onMiddleClicked: root.modelData.secondaryActivate()
    }

    QsMenuAnchor {
        id: menu
        menu: root.modelData.menu
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }
}