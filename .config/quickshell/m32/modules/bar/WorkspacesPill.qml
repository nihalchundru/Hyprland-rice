import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../core"
import "../../shapes"

Rectangle {
    id: root

    property int workspaceCount: 7
    readonly property int activeId: Services.activeWorkspaceId

    implicitHeight: 34
    implicitWidth: wsRow.implicitWidth + 16
    radius: height / 2
    color: Theme.surfaceContainerHigh
    border.width: 1
    border.color: Theme.withAlpha(Theme.outlineVariant, 0.45)

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Motion.durationMedium2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.expressiveSpatialDefault
        }
    }
    Behavior on color { ColorAnimation { duration: Motion.durationColor } }

    // Scroll wheel switches workspaces
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: (wheel) => {
            var next = root.activeId + (wheel.angleDelta.y > 0 ? -1 : 1);
            next = Math.max(1, Math.min(root.workspaceCount, next));
            Services.switchWorkspace(next);
        }
    }

    Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.workspaceCount

            delegate: Item {
                id: wsDelegate
                readonly property int wsId: index + 1
                readonly property bool isActive: root.activeId === wsId

                // Check if this workspace currently has windows in Hyprland
                readonly property bool isOccupied: {
                    var list = Hyprland.workspaces ? Hyprland.workspaces.values : [];
                    if (!list) return false;
                    for (var i = 0; i < list.length; i++) {
                        if (list[i] && list[i].id === wsId) return true;
                    }
                    return false;
                }

                // Expressive distinct M3 shapes for active workspaces
                readonly property var activeShapes: [
                    "cookie4", "sunny", "clover4", "cookie6", "gem", "flower", "cookie9"
                ]

                width: isActive ? 36 : (wsMouse.containsMouse ? 28 : 24)
                height: 26

                Behavior on width {
                    NumberAnimation {
                        duration: Motion.durationMedium2
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Motion.expressiveSpatialFast
                    }
                }

                ShapeCanvas {
                    id: wsShape
                    anchors.centerIn: parent
                    width: wsDelegate.isActive ? 26 : (wsMouse.containsMouse ? 22 : (wsDelegate.isOccupied ? 18 : 11))
                    height: width

                    Behavior on width {
                        NumberAnimation {
                            duration: Motion.durationMedium1
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Motion.expressiveSpatialFast
                        }
                    }

                    shapeName: {
                        if (wsMouse.pressed) return "softBurst";
                        if (wsDelegate.isActive) return wsDelegate.activeShapes[index % wsDelegate.activeShapes.length];
                        if (wsMouse.containsMouse) return "cookie7";
                        if (wsDelegate.isOccupied) return "diamond";
                        return "circle";
                    }

                    color: {
                        if (wsDelegate.isActive) return Theme.primary;
                        if (wsMouse.containsMouse) return Theme.secondaryContainer;
                        if (wsDelegate.isOccupied) return Theme.tertiaryContainer;
                        return Theme.surfaceContainerHighest;
                    }

                    rotationAngle: wsDelegate.isActive ? (wsMouse.containsMouse ? 45 : 0) : 0
                    Behavior on rotationAngle {
                        NumberAnimation {
                            duration: Motion.durationMedium3
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Motion.expressiveSpatialDefault
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: wsDelegate.wsId
                    visible: wsDelegate.isActive || wsMouse.containsMouse || wsDelegate.isOccupied
                    font.family: Theme.fontFamilySans
                    font.pixelSize: wsDelegate.isActive ? 11 : 10
                    font.weight: wsDelegate.isActive ? Font.Black : Font.DemiBold
                    color: {
                        if (wsDelegate.isActive) return Theme.onPrimary;
                        if (wsMouse.containsMouse) return Theme.onSecondaryContainer;
                        return Theme.onTertiaryContainer;
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.switchWorkspace(wsDelegate.wsId)
                }
            }
        }
    }
}
