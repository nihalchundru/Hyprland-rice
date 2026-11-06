import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../../core"
import "../../shapes"
import "../../components"

Row {
    id: root
    spacing: 8

    // ------------------------------------------------------------------------
    // System Tray Pill (auto-hides if no tray items exist)
    // ------------------------------------------------------------------------
    Rectangle {
        id: trayPill
        visible: trayRepeater.count > 0
        height: 34
        width: trayRow.implicitWidth + 14
        radius: 17
        color: Theme.surfaceContainerHigh
        border.width: 1
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.45)

        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                id: trayRepeater
                model: SystemTray.items

                delegate: Item {
                    required property var modelData
                    width: 24
                    height: 24

                    ShapeCanvas {
                        anchors.fill: parent
                        shapeName: trayMouse.containsMouse ? "cookie6" : "circle"
                        color: trayMouse.containsMouse ? Theme.secondaryContainer : Theme.surfaceContainerHighest
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        source: modelData.icon || ""
                        sourceSize.width: 32
                        sourceSize.height: 32
                        smooth: true
                    }

                    MouseArea {
                        id: trayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                                modelData.display(root, mouse.x, mouse.y);
                            } else {
                                modelData.activate();
                            }
                        }
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------------
    // Consolidated Telemetry & Audio/Network/RAM/Battery Pill
    // ------------------------------------------------------------------------
    Rectangle {
        id: statusPill
        height: 34
        width: statusRow.implicitWidth + 18
        radius: 17
        color: Theme.surfaceContainerHigh
        border.width: 1
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.45)

        Behavior on width {
            NumberAnimation {
                duration: Motion.durationMedium1
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialDefault
            }
        }
        Behavior on color { ColorAnimation { duration: Motion.durationColor } }

        Row {
            id: statusRow
            anchors.centerIn: parent
            spacing: 10

            // Volume indicator (scroll to adjust, click to mute)
            Item {
                height: 26
                width: volRow.implicitWidth + 4
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: volRow
                    anchors.centerIn: parent
                    spacing: 5

                    Item {
                        width: 22
                        height: 22
                        anchors.verticalCenter: parent.verticalCenter

                        ShapeCanvas {
                            anchors.fill: parent
                            shapeName: {
                                if (Services.muted) return "burst";
                                if (Services.volumePercent > 75) return "sunny";
                                if (Services.volumePercent > 35) return "cookie7";
                                return "circle";
                            }
                            color: Services.muted ? Theme.errorContainer : Theme.primaryContainer
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Services.muted ? "✕" : "♪"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Services.muted ? Theme.onErrorContainer : Theme.onPrimaryContainer
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Services.muted ? "Mute" : (Services.volumePercent + "%")
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Services.muted ? Theme.error : Theme.onSurface
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.toggleMute()
                    onWheel: (wheel) => Services.adjustVolume(wheel.angleDelta.y > 0 ? 5 : -5)
                }
            }

            // CPU + RAM Telemetry Chip (or Battery if physical laptop battery exists)
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    width: 22
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter

                    ShapeCanvas {
                        anchors.fill: parent
                        shapeName: {
                            if (Services.hasBattery) {
                                if (Services.batteryCharging) return "verySunny";
                                if (Services.batteryPercent <= 20) return "boom";
                                return "cookie6";
                            }
                            if (Services.cpuPercent > 75) return "verySunny";
                            if (Services.cpuPercent > 40) return "sunny";
                            return "cookie6";
                        }
                        color: {
                            if (Services.hasBattery && Services.batteryPercent <= 20)
                                return Theme.errorContainer;
                            return Theme.tertiaryContainer;
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Services.hasBattery ? (Services.batteryCharging ? "⚡" : "●") : "◈"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: {
                            if (Services.hasBattery && Services.batteryPercent <= 20)
                                return Theme.onErrorContainer;
                            return Theme.onTertiaryContainer;
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.hasBattery
                        ? (Services.batteryPercent + "%")
                        : (Services.cpuPercent + "% · " + Services.memPercent + "%")
                    font.family: Theme.fontFamilySans
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: (Services.hasBattery && Services.batteryPercent <= 20) ? Theme.error : Theme.onSurface
                }

                MouseArea {
                    width: parent.width
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    onClicked: StateStore.controlCenterOpen = !StateStore.controlCenterOpen
                }
            }

            // Network badge
            Item {
                height: 26
                width: 24
                anchors.verticalCenter: parent.verticalCenter

                ShapeCanvas {
                    anchors.fill: parent
                    shapeName: Services.wifiEnabled ? "clover4" : "diamond"
                    color: Services.wifiEnabled ? Theme.secondaryContainer : Theme.surfaceContainerHighest
                }

                Text {
                    anchors.centerIn: parent
                    text: Services.wifiEnabled ? "" : "×"
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 11
                    color: Services.wifiEnabled ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: StateStore.controlCenterOpen = !StateStore.controlCenterOpen
                }
            }
        }
    }

    // ------------------------------------------------------------------------
    // Morphing Theme Switcher Trigger + Control Center Trigger
    // ------------------------------------------------------------------------
    MorphShapeButton {
        size: 34
        icon: "🎨"
        iconSize: 14
        active: StateStore.themeSwitcherOpen
        idleShape: "cookie7"
        hoverShape: "flower"
        activeShape: "verySunny"
        pressedShape: "softBurst"
        spinOnHover: 35
        onClicked: StateStore.themeSwitcherOpen = !StateStore.themeSwitcherOpen
        onRightClicked: StateStore.wallpaperPickerOpen = !StateStore.wallpaperPickerOpen
    }

    MorphShapeButton {
        size: 34
        icon: "⚙"
        iconSize: 15
        active: StateStore.controlCenterOpen
        idleShape: "cookie4"
        hoverShape: "sunny"
        activeShape: "clover8"
        pressedShape: "burst"
        spinOnHover: 60
        onClicked: StateStore.controlCenterOpen = !StateStore.controlCenterOpen
        onRightClicked: StateStore.cycleLayout()
    }
}
