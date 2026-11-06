import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../core"
import "../../shapes"
import "../../components"

PanelWindow {
    id: osdWindow

    property var modelData
    screen: modelData

    visible: Services.osdVisible || closeAnimTimer.running

    anchors {
        bottom: true
    }
    margins.bottom: 64

    implicitWidth: 320
    implicitHeight: 74
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "m32-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Timer {
        id: closeAnimTimer
        interval: 260
    }

    Connections {
        target: Services
        function onOsdVisibleChanged() {
            if (!Services.osdVisible) {
                closeAnimTimer.restart();
            }
        }
    }

    Item {
        id: osdContainer
        anchors.fill: parent
        opacity: Services.osdVisible ? 1.0 : 0.0
        scale: Services.osdVisible ? 1.0 : 0.88

        Behavior on opacity {
            NumberAnimation {
                duration: Motion.durationMedium1
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Motion.durationMedium2
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialDefault
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 33
            color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.96)
            border.width: 1
            border.color: Theme.withAlpha(Theme.outlineVariant, 0.55)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 18
                spacing: 14

                // Morphing M3 Polygon Badge
                Item {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44

                    ShapeCanvas {
                        anchors.fill: parent
                        shapeName: {
                            if (Services.osdKind === "brightness") {
                                if (Services.osdValue > 75) return "verySunny";
                                if (Services.osdValue > 40) return "sunny";
                                return "cookie7";
                            }
                            if (Services.osdMuted || Services.osdValue === 0) return "burst";
                            if (Services.osdValue > 80) return "clover8";
                            if (Services.osdValue > 40) return "sunny";
                            return "cookie6";
                        }
                        color: (Services.osdKind === "volume" && Services.osdMuted)
                            ? Theme.errorContainer
                            : Theme.primaryContainer

                        rotationAngle: Services.osdValue * 1.8
                        Behavior on rotationAngle {
                            NumberAnimation {
                                duration: Motion.durationMedium2
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Motion.expressiveSpatialDefault
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (Services.osdKind === "brightness") return "☀";
                            if (Services.osdMuted || Services.osdValue === 0) return "✕";
                            return "♪";
                        }
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 17
                        font.weight: Font.Bold
                        color: (Services.osdKind === "volume" && Services.osdMuted)
                            ? Theme.onErrorContainer
                            : Theme.onPrimaryContainer
                    }
                }

                // Label + Thick Pill Progress Track
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: Services.osdKind === "brightness"
                                ? "Brightness"
                                : (Services.osdMuted ? "Muted" : "Volume")
                            font.family: Theme.fontFamilySans
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: Theme.onSurface
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: (Services.osdKind === "volume" && Services.osdMuted)
                                ? "MUTE"
                                : (Services.osdValue + "%")
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: (Services.osdKind === "volume" && Services.osdMuted)
                                ? Theme.error
                                : Theme.primary
                        }
                    }

                    // Expressive Pill Track
                    Rectangle {
                        Layout.fillWidth: true
                        height: 12
                        radius: 6
                        color: Theme.surfaceContainerHighest
                        clip: true

                        Rectangle {
                            height: parent.height
                            width: {
                                if (Services.osdKind === "volume" && Services.osdMuted) return 0;
                                var maxVal = Services.osdKind === "volume" ? 100 : 100;
                                var ratio = Math.max(0, Math.min(1, Services.osdValue / maxVal));
                                return parent.width * ratio;
                            }
                            radius: 6
                            color: (Services.osdKind === "volume" && Services.osdMuted)
                                ? Theme.error
                                : Theme.primary

                            Behavior on width {
                                NumberAnimation {
                                    duration: Motion.durationShort4
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Motion.expressiveFastSpatial
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
