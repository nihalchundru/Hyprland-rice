import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

// System tray. Referencing the SystemTray singleton is what tells Quickshell
// to start tracking tray items.
Row {
    id: root

    // The PanelWindow this tray lives in — handed to us by Bar.qml.
    property var barWindow: null
    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: cell

            required property var modelData

            implicitWidth: 16
            implicitHeight: 16

            Image {
                anchors.fill: parent
                source: cell.modelData.icon
                sourceSize.width: 16
                sourceSize.height: 16
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            // PopupAnchor.item means the menu anchors to this cell's own
            // rectangle — no manual coordinate mapping needed, and it
            // re-anchors correctly on a top bar.
            QsMenuAnchor {
                id: menuAnchor
                anchor.item: cell
                menu: cell.modelData.menu
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        cell.modelData.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        cell.modelData.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (cell.modelData.hasMenu) menuAnchor.open();
                    }
                }

                // Some tray items (volume mixers, media keys) accept scroll.
                onWheel: (wheel) => {
                    cell.modelData.scroll(wheel.angleDelta.y > 0 ? 1 : -1, false);
                    wheel.accepted = true;
                }
            }
        }
    }
}
