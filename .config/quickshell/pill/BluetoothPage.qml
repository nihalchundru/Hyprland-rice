import QtQuick
import Quickshell.Bluetooth

Item {
    id: root
    width: 560

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devs: Bluetooth.devices.values
    readonly property var saved: devs.filter(d => d.paired || d.bonded)
    readonly property var nearby: devs.filter(d => !(d.paired || d.bonded) && (d.name || d.deviceName))

    readonly property real maxH: 640
    implicitHeight: Math.min(maxH, head.height + 4 + col.implicitHeight + 16)
    height: implicitHeight
    onImplicitHeightChanged: Pill.setHeight("bluetooth", implicitHeight)
    Component.onCompleted: Pill.setHeight("bluetooth", implicitHeight)

    function iconFor(d) {
        const i = (d.icon || "").toLowerCase();
        if (i.indexOf("head") >= 0 || i.indexOf("audio") >= 0) return "headphones";
        return "bluetooth";
    }

    // scan only while this page is open
    function syncScan() {
        if (root.adapter) root.adapter.discovering = (Pill.mode === "bluetooth") && root.adapter.enabled;
    }
    Connections {
        target: Pill
        function onModeChanged() { root.syncScan(); }
    }

    PageHeader {
        id: head
        width: parent.width
        title: "Bluetooth"
        onBack: Pill.open("control", true)

        trailing: [
            PillSwitch {
                checked: !!root.adapter && root.adapter.enabled
                onToggled: v => {
                    if (root.adapter) {
                        root.adapter.enabled = v;
                        root.syncScan();
                    }
                }
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
                visible: !root.adapter
                text: "No Bluetooth adapter found"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 14
                topPadding: 8
                bottomPadding: 8
            }

            // ── saved ────────────────────────────────────────────
            Text {
                visible: !!root.adapter && root.saved.length > 0
                text: "Saved"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
            Repeater {
                model: root.adapter ? root.saved : []

                DeviceRow {
                    id: savedRow
                    required property var modelData
                    width: col.width
                    icon: root.iconFor(modelData)
                    label: modelData.name || modelData.deviceName
                    sub: modelData.connected ? "Connected" : (modelData.connecting ? "Connecting…" : "Saved")
                    selected: modelData.connected
                    clickable: false

                    trailing: [
                        PillButton {
                            primary: true
                            label: savedRow.modelData.connected ? "Disconnect" : "Connect"
                            onClicked: {
                                if (savedRow.modelData.connected) savedRow.modelData.disconnect();
                                else savedRow.modelData.connect();
                            }
                        }
                    ]
                }
            }

            // ── nearby ───────────────────────────────────────────
            Item {
                visible: !!root.adapter && root.adapter.enabled
                width: col.width
                height: 22

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Nearby"
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    visible: !!root.adapter && root.adapter.discovering

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        height: 6
                        radius: 3
                        color: Theme.accent
                    }
                    Text {
                        text: "Scanning"
                        color: Theme.dim
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                }
            }

            Repeater {
                model: (root.adapter && root.adapter.enabled) ? root.nearby : []

                DeviceRow {
                    id: nearRow
                    required property var modelData
                    width: col.width
                    icon: root.iconFor(modelData)
                    label: modelData.name || modelData.deviceName
                    sub: "Nearby"
                    clickable: false

                    trailing: [
                        PillButton {
                            primary: true
                            label: "Pair"
                            onClicked: {
                                if (typeof nearRow.modelData.pair === "function") nearRow.modelData.pair();
                                else nearRow.modelData.connect();
                            }
                        }
                    ]
                }
            }

            Text {
                visible: !!root.adapter && root.adapter.enabled && root.nearby.length === 0
                width: col.width
                text: "Looking for devices…  put the device in pairing mode"
                wrapMode: Text.WordWrap
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 13
                topPadding: 4
            }

            Text {
                visible: !!root.adapter && !root.adapter.enabled
                text: "Bluetooth is off"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 13
                topPadding: 4
            }
        }
    }
}
