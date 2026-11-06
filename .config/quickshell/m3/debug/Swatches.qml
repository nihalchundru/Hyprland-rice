import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.tokens
import qs.services

FloatingWindow {
    id: win
    title: "m3-swatches"
    color: M3Colors.surface
    implicitWidth: 960
    implicitHeight: 760

    readonly property var keys: ["primary","fgPrimary","primaryContainer","fgPrimaryContainer","secondary","fgSecondary","secondaryContainer","fgSecondaryContainer","tertiary","fgTertiary","tertiaryContainer","fgTertiaryContainer","error","fgError","errorContainer","fgErrorContainer","surface","surfaceDim","surfaceBright","surfaceContainerLowest","surfaceContainerLow","surfaceContainer","surfaceContainerHigh","surfaceContainerHighest","fgSurface","fgSurfaceVariant","outline","outlineVariant","inverseSurface","inverseOnSurface","inversePrimary","scrim","shadow","surfaceTint","background","fgBackground","primaryFixed","primaryFixedDim","fgPrimaryFixed","fgPrimaryFixedVariant"]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: M3Shape.s4
        spacing: M3Shape.s3

        Text {
            color: M3Colors.fgSurface
            font.family: M3Type.family
            font.pixelSize: M3Type.titleMedium.size
            text: "mode: " + M3Config.mode + "  scheme: " + M3Config.scheme
                  + (Matugen.busy ? "  [matugen running]" : "")
        }
        Text {
            visible: Matugen.lastError !== ""
            color: M3Colors.error
            font.pixelSize: M3Type.bodySmall.size
            text: "matugen error: " + Matugen.lastError
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        GridLayout {
            columns: 6
            rowSpacing: M3Shape.s2
            columnSpacing: M3Shape.s2
            Layout.fillWidth: true
            Repeater {
                model: win.keys
                Rectangle {
                    required property string modelData
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: M3Shape.medium
                    color: M3Colors[modelData]
                    border.color: M3Colors.outlineVariant
                    Text {
                        anchors.centerIn: parent
                        text: parent.modelData
                        font.pixelSize: 10
                        color: parent.color.hslLightness > 0.55 ? "#000000" : "#ffffff"
                    }
                }
            }
        }

        // Motion test: click either box. Left = emphasized bezier, right = spring.
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            property bool on: false
            MouseArea { anchors.fill: parent; onClicked: parent.on = !parent.on }

            Rectangle {
                id: bez
                y: 20; width: 80; height: 80
                x: parent.on ? parent.width / 2 - 100 : 20
                radius: parent.on ? M3Shape.full : M3Shape.large
                color: M3Colors.primaryContainer
                Behavior on x { NumberAnimation { duration: M3Motion.medium4; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Motion.emphasizedDecel } }
                Behavior on radius { NumberAnimation { duration: M3Motion.medium4; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Motion.emphasized } }
            }
            Rectangle {
                id: spr
                y: 20; width: 80; height: 80
                x: parent.on ? parent.width - 100 : parent.width / 2 + 20
                radius: parent.on ? M3Shape.full : M3Shape.large
                color: M3Colors.tertiaryContainer
                Behavior on x { SpringAnimation { spring: M3Motion.spatialDefault.spring; damping: M3Motion.spatialDefault.damping; epsilon: M3Motion.spatialDefault.epsilon } }
                Behavior on radius { SpringAnimation { spring: M3Motion.spatialDefault.spring; damping: M3Motion.spatialDefault.damping; epsilon: M3Motion.spatialDefault.epsilon } }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
