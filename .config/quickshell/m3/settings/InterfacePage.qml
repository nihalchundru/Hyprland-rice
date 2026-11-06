import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    id: page
    property string query: ""
    readonly property var filtered: {
        const q = query.toLowerCase().trim()
        return q === "" ? Fonts.families : Fonts.families.filter(f => f.toLowerCase().includes(q))
    }
    SScroll {
        SCard {
            title: "Interface font"
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 112
                radius: 20
                color: M3Colors.surfaceContainerHighest
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: M3Config.fontFamily; role: M3Type.headlineSmall; color: M3Colors.primary }
                    M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: "The quick brown fox jumps over the lazy dog"; role: M3Type.bodyLarge }
                    M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: "0123456789  ABCDEFG  abcdefg"; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 22
                color: M3Colors.surfaceContainerHighest
                Icon { id: si; x: 14; anchors.verticalCenter: parent.verticalCenter; name: "search"; size: 20; color: M3Colors.fgSurfaceVariant }
                M3Text { visible: search.text === ""; x: 44; anchors.verticalCenter: parent.verticalCenter; text: "Search " + Fonts.families.length + " fonts"; color: M3Colors.fgSurfaceVariant; role: M3Type.bodyMedium }
                TextInput {
                    id: search
                    anchors.left: si.right; anchors.leftMargin: 10
                    anchors.right: parent.right; anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: M3Colors.fgSurface
                    font.family: M3Type.family
                    font.pixelSize: 14
                    clip: true
                    onTextChanged: page.query = text
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                radius: 20
                color: M3Colors.surfaceContainerHighest
                clip: true
                ListView {
                    id: flist
                    anchors.fill: parent
                    anchors.margins: 4
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: page.filtered
                    delegate: Item {
                        id: fr
                        required property string modelData
                        readonly property bool current: modelData === M3Config.fontFamily
                        width: flist.width; height: 44
                        StateLayer { anchors.fill: parent; radius: 14; hovered: fma.containsMouse; pressed: fma.pressed }
                        Rectangle { anchors.fill: parent; radius: 14; color: M3Colors.secondaryContainer; opacity: fr.current ? 1 : 0 }
                        M3Text { x: 16; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 60; elide: Text.ElideRight; text: fr.modelData; font.family: fr.modelData; color: fr.current ? M3Colors.fgSecondaryContainer : M3Colors.fgSurface }
                        Icon { visible: fr.current; anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; name: "check"; size: 20; color: M3Colors.fgSecondaryContainer }
                        MouseArea { id: fma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: M3Config.fontFamily = fr.modelData }
                    }
                }
            }
            SRow { icon: "restart_alt"; title: "Default font"; sub: "Roboto Flex"; M3Button { text: "Reset"; variant: "tonal"; onClicked: M3Config.fontFamily = "Roboto Flex" } }
        }
        SCard {
            title: "Size and motion"
            SliderRow { icon: "format_size"; title: "Text size"; from: 0.8; to: 1.3; step: 0.05; value: M3Config.fontScale; displayScale: 100; suffix: "%"; onPicked: v => M3Config.fontScale = v }
            SliderRow { icon: "speed"; title: "Animation duration"; sub: "Lower is faster"; from: 0.25; to: 2; step: 0.05; value: M3Config.motionScale; decimals: 2; suffix: "x"; onPicked: v => M3Config.motionScale = v }
        }
    }
}
