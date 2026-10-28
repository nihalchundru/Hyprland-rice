import QtQuick

Item {
    id: root
    width: 560

    readonly property real maxH: 640
    implicitHeight: Math.min(maxH, head.height + 4 + col.implicitHeight + 16)
    height: implicitHeight
    onImplicitHeightChanged: Pill.setHeight("wifi", implicitHeight)
    Component.onCompleted: Pill.setHeight("wifi", implicitHeight)

    PageHeader {
        id: head
        width: parent.width
        title: "Wi-Fi"
        onBack: Pill.open("control", true)

        trailing: [
            PillSwitch {
                checked: Net.radioOn
                onToggled: v => Net.setRadio(v)
            }
        ]
    }

    Flickable {
        id: flick
        anchors.top: head.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        clip: true
        contentWidth: width
        contentHeight: col.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: flick.width
            spacing: 8

            Text {
                visible: !Net.hasWifi
                text: "No Wi-Fi adapter found"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(14)
                topPadding: 8
                bottomPadding: 8
            }

            // connected card
            Rectangle {
                visible: Net.hasWifi && Net.connected
                width: col.width
                height: visible ? 76 : 0
                radius: Theme.r(22)
                color: Theme.tile

                Rectangle {
                    id: bigCirc
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 48
                    height: 48
                    radius: Theme.r(24)
                    color: Theme.accent
                    Icon {
                        anchors.centerIn: parent
                        name: "wifi"
                        size: 22
                        color: Theme.onAccent
                    }
                }

                Column {
                    anchors.left: bigCirc.right
                    anchors.leftMargin: 14
                    anchors.right: discBtn.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        width: parent.width
                        text: Net.ssid
                        elide: Text.ElideRight
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.px(16)
                        font.weight: Font.DemiBold
                    }
                    Text {
                        width: parent.width
                        text: "Connected  ·  " + (Net.security || "Open") + "  ·  " + Net.signal + "% signal"
                        elide: Text.ElideRight
                        color: Theme.dim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.px(12)
                    }
                }

                PillButton {
                    id: discBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    label: "Disconnect"
                    onClicked: Net.disconnect()
                }
            }

            Text {
                visible: Net.hasWifi
                text: "Networks"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
                topPadding: 4
            }

            Repeater {
                model: Net.hasWifi && Net.radioOn ? Net.networks : []

                DeviceRow {
                    id: netRow
                    required property var modelData
                    width: col.width
                    icon: "wifi"
                    label: modelData.ssid
                    sub: Net.busy === modelData.ssid ? "Connecting…" : (modelData.security || "Open")
                    onClicked: Net.connectTo(modelData.ssid)

                    trailing: [
                        Icon {
                            visible: netRow.modelData.security !== ""
                            name: "lock"
                            size: 14
                            color: Theme.dim
                        },
                        Text {
                            text: netRow.modelData.signal + "%"
                            color: Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(12)
                        }
                    ]
                }
            }

            Text {
                visible: Net.hasWifi && (!Net.radioOn || Net.networks.length === 0)
                text: !Net.radioOn ? "Wi-Fi is off" : "Scanning for networks…"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(13)
                topPadding: 4
            }

            Text {
                visible: Net.error !== ""
                width: col.width
                text: Net.error
                wrapMode: Text.WordWrap
                color: Theme.red
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
            }
        }
    }
}
