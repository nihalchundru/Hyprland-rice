import QtQuick

Rectangle {
    id: workspacePill
    width: 125
    height: 38
    radius: height / 2
    
    // Smoothly morphs background color and size scales on cursor hover entries
    color: workspaceHoverZone.containsMouse ? barRoot.colors.surface : barRoot.colors.bg2
    border.color: workspaceHoverZone.containsMouse ? barRoot.colors.accent : barRoot.colors.surface2
    border.width: 1
    antialiasing: true

    // Hover transformations scale parameters
    scale: workspaceHoverZone.containsMouse ? 1.04 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // Integrated Background Interaction Surface Zone
    MouseArea {
        id: workspaceHoverZone
        anchors.fill: parent
        hoverEnabled: true
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: 5
            Item {
                id: bumpyDotWrapper
                property bool isCurrent: WorkspaceService.activeId === (index + 1)
                width: isCurrent ? 20 : 10
                height: 10
                
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                Repeater {
                    model: 8
                    Rectangle {
                        anchors.centerIn: parent
                        width: 3.5
                        height: parent.width 
                        radius: width / 2
                        color: bumpyDotWrapper.isCurrent ? barRoot.colors.accent : barRoot.colors.surface
                        rotation: (index * 45)
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 3.5
                    height: parent.height - 3.5
                    radius: height / 2
                    color: bumpyDotWrapper.isCurrent ? barRoot.colors.accent : barRoot.colors.surface
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                TapHandler {
                    onTapped: WorkspaceService.changeWorkspace(index + 1)
                }
            }
        }
    }
}
