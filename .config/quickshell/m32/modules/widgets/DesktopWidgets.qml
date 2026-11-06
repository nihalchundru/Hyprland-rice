import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../core"
import "../../shapes"
import "../../components"

PanelWindow {
    id: widgetWindow

    property var modelData
    screen: modelData

    visible: StateStore.desktopWidgetsVisible

    anchors {
        bottom: true
        right: true
    }
    margins.bottom: 24
    margins.right: 24

    implicitWidth: 288
    implicitHeight: 204
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "m32-desktop-widgets"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property int polygonIndex: 0
    readonly property var widgetPolygons: [
        "clover8", "sunny", "cookie9", "verySunny", "flower", "cookie6", "gem"
    ]

    Rectangle {
        anchors.fill: parent
        radius: Motion.radiusExtraLarge
        color: Theme.withAlpha(Theme.surfaceContainerLow, 0.84)
        border.width: 1
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.42)

        Behavior on color { ColorAnimation { duration: Motion.durationColor } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // ----------------------------------------------------------------
            // TOP ROW: Expressive Hero Clock + Rotating M3 Polygon Emblem
            // ----------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Row {
                        spacing: 6

                        Text {
                            id: clockText
                            text: Services.formattedTime(StateStore.clockFormat === "24")
                            font.family: Theme.fontFamily
                            font.pixelSize: 34
                            font.weight: Font.Bold
                            color: Theme.onSurface
                        }

                        Text {
                            visible: StateStore.clockFormat !== "24"
                            text: Services.amPm
                            font.family: Theme.fontFamilySans
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: Theme.primary
                            anchors.bottom: clockText.bottom
                            anchors.bottomMargin: 6
                        }
                    }

                    Text {
                        text: Services.dateLong
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: Theme.onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }

                // Interactive Morphing M3 Emblem (click to morph polygon!)
                Item {
                    Layout.preferredWidth: 58
                    Layout.preferredHeight: 58

                    ShapeCanvas {
                        anchors.fill: parent
                        shapeName: emblemMouse.pressed
                            ? "softBurst"
                            : widgetWindow.widgetPolygons[widgetWindow.polygonIndex % widgetWindow.widgetPolygons.length]
                        color: Theme.primaryContainer

                        NumberAnimation on rotationAngle {
                            from: 0
                            to: 360
                            duration: 28000
                            loops: Animation.Infinite
                            running: widgetWindow.visible
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Services.seconds
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: Theme.onPrimaryContainer
                    }

                    MouseArea {
                        id: emblemMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: widgetWindow.polygonIndex = (widgetWindow.polygonIndex + 1) % widgetWindow.widgetPolygons.length
                    }
                }
            }

            // ----------------------------------------------------------------
            // BOTTOM ROW: Telemetry Pills (CPU / RAM / Theme)
            // ----------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // CPU Card
                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: 16
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.88)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "CPU"
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Theme.onSurfaceVariant
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Services.cpuPercent + "%"
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Theme.primary
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: Theme.surfaceContainerHighest

                            Rectangle {
                                height: parent.height
                                width: parent.width * Math.min(1, Services.cpuPercent / 100.0)
                                radius: 3
                                color: Theme.primary
                                Behavior on width { NumberAnimation { duration: 300 } }
                            }
                        }
                    }
                }

                // RAM Card
                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: 16
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.88)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "RAM"
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Theme.onSurfaceVariant
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Services.memPercent + "%"
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Theme.tertiary
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: Theme.surfaceContainerHighest

                            Rectangle {
                                height: parent.height
                                width: parent.width * Math.min(1, Services.memPercent / 100.0)
                                radius: 3
                                color: Theme.tertiary
                                Behavior on width { NumberAnimation { duration: 300 } }
                            }
                        }
                    }
                }
            }
        }
    }
}
