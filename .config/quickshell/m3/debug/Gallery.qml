import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.tokens
import qs.components

FloatingWindow {
    id: win
    title: "m3-gallery"
    color: M3Colors.surface
    implicitWidth: 1000
    implicitHeight: 820

    readonly property var shapeNames: ["circle","square","slanted","arch","fan","arrow","semiCircle","oval","pill","triangle","diamond","clamShell","pentagon","gem","sunny","verySunny","cookie4Sided","cookie6Sided","cookie7Sided","cookie9Sided","cookie12Sided","ghostish","clover4Leaf","clover8Leaf","burst","softBurst","boom","softBoom","flower","puffy","puffyDiamond","pixelCircle","pixelTriangle","bun","heart"]
    property int sel: 0
    property real demo: 0
    Timer { interval: 700; running: true; repeat: true; onTriggered: win.demo = win.demo >= 1 ? 0 : Math.min(1, win.demo + 0.25) }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: col.implicitHeight + 48
        clip: true

        ColumnLayout {
            id: col
            x: 24; y: 24
            width: parent.width - 48
            spacing: 16

            M3Text { text: "Variants"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 12
                M3Button { text: "Filled"; variant: "filled" }
                M3Button { text: "Tonal"; variant: "tonal" }
                M3Button { text: "Elevated"; variant: "elevated" }
                M3Button { text: "Outlined"; variant: "outlined" }
                M3Button { text: "Text"; variant: "text" }
                M3Button { text: "With icon"; icon: "add"; variant: "filled" }
            }

            M3Text { text: "Sizes (press to see corner morph)"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 12
                Repeater {
                    model: ["xs", "s", "m", "l", "xl"]
                    M3Button { required property string modelData; text: modelData.toUpperCase(); size: modelData; variant: "tonal"; Layout.alignment: Qt.AlignVCenter }
                }
            }

            M3Text { text: "Toggle + icon-only"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 12
                M3Button { text: "Wi-Fi"; icon: "wifi"; variant: "tonal"; toggle: true; checked: true }
                M3Button { text: "Bluetooth"; icon: "bluetooth"; variant: "tonal"; toggle: true }
                M3Button { text: "Mute"; icon: "volume_off"; variant: "filled"; toggle: true }
                M3Button { icon: "settings"; variant: "filled"; toggle: true }
                M3Button { icon: "favorite"; variant: "outlined"; toggle: true; round: false }
                M3Button { icon: "more_vert"; variant: "text" }
                M3Switch {}
                M3Switch { checked: true }
            }

            M3Text { text: "Slider + progress"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 32
                M3Slider { Layout.preferredWidth: 280; value: 0.4 }
                M3Slider { Layout.preferredWidth: 280; from: 0; to: 100; stepSize: 10; value: 30 }
            }
            RowLayout {
                spacing: 24
                M3Progress { Layout.preferredWidth: 150; value: 0.6 }
                M3Progress { Layout.preferredWidth: 150; value: 0.6; wavy: true }
                M3Progress { Layout.preferredWidth: 150; value: win.demo; wavy: true }
                M3Progress { Layout.preferredWidth: 150; indeterminate: true }
                M3CircularProgress { value: win.demo }
                M3CircularProgress { indeterminate: true }
            }

            M3Text { text: "Chips + cards"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 8
                M3Chip { text: "Assist"; icon: "event" }
                M3Chip { text: "Filter"; kind: "filter" }
                M3Chip { text: "Filter on"; kind: "filter"; selected: true }
                M3Chip { text: "Input"; kind: "input"; icon: "person" }
                M3Card { variant: "filled"; clickable: true; Layout.preferredWidth: 200; Layout.preferredHeight: 80; M3Text { text: "Filled card"; role: M3Type.titleMedium } }
                M3Card { variant: "elevated"; clickable: true; Layout.preferredWidth: 200; Layout.preferredHeight: 80; M3Text { text: "Elevated card"; role: M3Type.titleMedium } }
                M3Card { variant: "outlined"; clickable: true; Layout.preferredWidth: 200; Layout.preferredHeight: 80; M3Text { text: "Outlined card"; role: M3Type.titleMedium } }
            }

            M3Text { text: "Tooltip, menu, dialog"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 16
                z: 100
                M3Button { id: tb; text: "Hover me"; variant: "outlined"; M3Tooltip { text: "I am a tooltip"; shown: tb.hovered } }
                Item {
                    implicitWidth: mb.implicitWidth; implicitHeight: mb.implicitHeight
                    M3Button { id: mb; text: "Menu"; icon: "arrow_drop_down"; variant: "tonal"; onClicked: menu.open = !menu.open }
                    M3Menu {
                        id: menu
                        y: mb.height + 4
                        model: [{ text: "Copy", icon: "content_copy" }, { text: "Paste", icon: "content_paste" }, { text: "Delete", icon: "delete" }]
                    }
                }
                M3Button { text: "Dialog"; variant: "filled"; onClicked: dlg.open = true }
            }

            M3Text { text: "Loading indicator"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 24
                LoadingIndicator { size: 96 }
                LoadingIndicator { size: 48 }
                LoadingIndicator { size: 32; contained: false }
            }

            M3Text { text: "Shapes (click to morph the big one)"; role: M3Type.titleLarge }
            RowLayout {
                spacing: 24
                MorphShape { size: 160; shape: win.shapeNames[win.sel]; color: M3Colors.primaryContainer }
                M3Text { text: win.shapeNames[win.sel]; role: M3Type.headlineSmall }
            }
            Flow {
                Layout.fillWidth: true
                spacing: 12
                Repeater {
                    model: win.shapeNames
                    MorphShape {
                        id: cell
                        required property string modelData
                        required property int index
                        size: 56
                        shape: modelData
                        color: win.sel === index ? M3Colors.primary : M3Colors.secondaryContainer
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.sel = cell.index }
                    }
                }
            }
        }
    }

    M3Dialog {
        id: dlg
        anchors.fill: parent
        icon: "delete"
        title: "Discard draft?"
        text: "Your draft will be deleted and cannot be recovered."
        acceptText: "Discard"
    }
}
