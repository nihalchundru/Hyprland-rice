import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../core"
import "../../shapes"
import "../../components"

PanelWindow {
    id: barWindow

    property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    readonly property string layoutMode: StateStore.qsLayout // "pill" | "notch" | "islands"
    readonly property bool notchOpen: StateStore.notchExpanded

    implicitHeight: notchOpen ? 138 : 48
    exclusiveZone: 46
    color: "transparent"

    WlrLayershell.namespace: "m32-topbar"
    WlrLayershell.layer: WlrLayer.Top

    // Close expanded notch when clicking empty bar area
    MouseArea {
        anchors.fill: parent
        enabled: barWindow.notchOpen
        onClicked: StateStore.notchExpanded = false
    }

    // ------------------------------------------------------------------------
    // Main Top Bar Container (Supports Pill, Notch, and Islands layouts)
    // ------------------------------------------------------------------------
    Item {
        id: barRoot
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: barWindow.layoutMode === "notch" ? 0 : 6
        anchors.leftMargin: barWindow.layoutMode === "notch" ? 0 : 12
        anchors.rightMargin: barWindow.layoutMode === "notch" ? 0 : 12
        height: 42

        Behavior on anchors.topMargin { NumberAnimation { duration: Motion.durationMedium1 } }
        Behavior on anchors.leftMargin { NumberAnimation { duration: Motion.durationMedium1 } }
        Behavior on anchors.rightMargin { NumberAnimation { duration: Motion.durationMedium1 } }

        // Full-bar background for "pill" and "notch" modes
        // ("islands" mode keeps this transparent so left/center/right float independently)
        Rectangle {
            id: barBackground
            anchors.fill: parent
            visible: barWindow.layoutMode !== "islands"
            radius: barWindow.layoutMode === "pill" ? 21 : 0
            color: barWindow.layoutMode === "notch"
                ? Theme.withAlpha(Theme.surfaceContainerLowest, 0.92)
                : Theme.barBg
            border.width: barWindow.layoutMode === "pill" ? 1 : 0
            border.color: Theme.withAlpha(Theme.outlineVariant, 0.45)

            Behavior on radius { NumberAnimation { duration: Motion.durationMedium2 } }
            Behavior on color { ColorAnimation { duration: Motion.durationColor } }
        }

        // --------------------------------------------------------------------
        // LEFT CLUSTER: Morphing App Launcher + Workspaces + Active Theme Pill
        // --------------------------------------------------------------------
        Row {
            id: leftCluster
            anchors.left: parent.left
            anchors.leftMargin: barWindow.layoutMode === "islands" ? 0 : 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // App Launcher Button (morphs Cookie6 -> VerySunny -> Clover8)
            MorphShapeButton {
                size: 34
                icon: "❖"
                iconSize: 16
                active: StateStore.launcherOpen
                idleShape: "cookie6"
                hoverShape: "verySunny"
                activeShape: "clover8"
                pressedShape: "softBurst"
                idleBg: Theme.primaryContainer
                idleFg: Theme.onPrimaryContainer
                hoverBg: Theme.primary
                hoverFg: Theme.onPrimary
                spinOnHover: 45
                onClicked: StateStore.launcherOpen = !StateStore.launcherOpen
                onRightClicked: StateStore.overviewOpen = !StateStore.overviewOpen
            }

            // Morphing Hyprland Workspaces Pill
            WorkspacesPill {
                anchors.verticalCenter: parent.verticalCenter
            }

            // Active Workspace & Current Theme Pill
            Rectangle {
                height: 34
                width: Math.min(220, windowRow.implicitWidth + 20)
                radius: 17
                color: Theme.surfaceContainerHigh
                border.width: 1
                border.color: Theme.withAlpha(Theme.outlineVariant, 0.4)
                anchors.verticalCenter: parent.verticalCenter

                Behavior on width {
                    NumberAnimation {
                        duration: Motion.durationMedium1
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Motion.emphasizedDecelerate
                    }
                }
                Behavior on color { ColorAnimation { duration: Motion.durationColor } }

                Row {
                    id: windowRow
                    anchors.centerIn: parent
                    spacing: 6

                    ShapeCanvas {
                        width: 14
                        height: 14
                        anchors.verticalCenter: parent.verticalCenter
                        shapeName: "gem"
                        color: Theme.tertiary
                    }

                    Text {
                        text: Hyprland.focusedWorkspace
                            ? ("WS " + Hyprland.focusedWorkspace.id + " · " + StateStore.currentTheme)
                            : ("m32 · " + StateStore.currentTheme)
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: Theme.onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }

                M3StateLayer {
                    anchors.fill: parent
                    cornerRadius: 17
                    onClicked: StateStore.themeSwitcherOpen = !StateStore.themeSwitcherOpen
                }
            }
        }

        // --------------------------------------------------------------------
        // CENTER CLUSTER: Dynamic Notch / Island (expands downward smoothly)
        // --------------------------------------------------------------------
        DynamicNotch {
            id: centerNotch
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: barWindow.notchOpen ? 2 : 3
            z: 10
        }

        // --------------------------------------------------------------------
        // RIGHT CLUSTER: System Tray + Audio/Network/Battery + Quick Actions
        // --------------------------------------------------------------------
        StatusCluster {
            id: rightCluster
            anchors.right: parent.right
            anchors.rightMargin: barWindow.layoutMode === "islands" ? 0 : 6
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
