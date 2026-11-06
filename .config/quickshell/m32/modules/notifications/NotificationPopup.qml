import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../core"
import "../../shapes"
import "../../components"

PanelWindow {
    id: notifWindow

    property var modelData
    screen: modelData

    visible: !StateStore.dndEnabled && Services.popupNotificationModel.count > 0

    anchors {
        top: true
        right: true
    }
    margins.top: 58
    margins.right: 14

    implicitWidth: 348
    implicitHeight: Math.min(440, notifColumn.implicitHeight + 12)
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "m32-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Column {
        id: notifColumn
        width: parent.width
        spacing: 10

        Repeater {
            model: Services.popupNotificationModel

            delegate: Rectangle {
                id: card
                required property string uid
                required property string appName
                required property string summary
                required property string body
                required property string urgency
                required property string timeStr

                width: notifColumn.width
                height: contentCol.implicitHeight + 26
                radius: Motion.radiusLarge
                color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.96)
                border.width: 1
                border.color: urgency === "critical"
                    ? Theme.error
                    : Theme.withAlpha(Theme.outlineVariant, 0.55)

                // Auto-dismiss after 5.5 seconds
                Timer {
                    interval: 5500
                    running: true
                    repeat: false
                    onTriggered: Services.dismissPopup(card.uid)
                }

                ColumnLayout {
                    id: contentCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 13
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Morphing M3 Icon Badge
                        Item {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32

                            ShapeCanvas {
                                anchors.fill: parent
                                shapeName: card.urgency === "critical" ? "boom" : "cookie7"
                                color: card.urgency === "critical"
                                    ? Theme.errorContainer
                                    : Theme.primaryContainer
                            }

                            Text {
                                anchors.centerIn: parent
                                text: card.urgency === "critical" ? "!" : "✦"
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: card.urgency === "critical"
                                    ? Theme.onErrorContainer
                                    : Theme.onPrimaryContainer
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: card.appName
                                    font.family: Theme.fontFamilyMono
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: Theme.primary
                                    elide: Text.ElideRight
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: card.timeStr
                                    font.family: Theme.fontFamilyMono
                                    font.pixelSize: 10
                                    color: Theme.onSurfaceVariant
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: card.summary
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: Theme.onSurface
                                elide: Text.ElideRight
                            }
                        }

                        MorphShapeButton {
                            size: 26
                            icon: "✕"
                            iconSize: 10
                            idleShape: "circle"
                            hoverShape: "cookie4"
                            pressedShape: "softBurst"
                            onClicked: Services.dismissPopup(card.uid)
                        }
                    }

                    Text {
                        visible: card.body !== ""
                        Layout.fillWidth: true
                        Layout.leftMargin: 42
                        text: card.body
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 12
                        color: Theme.onSurfaceVariant
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
