import QtQuick
import QtQuick.Effects

Item {
    id: root
    width: Pill.geo.hover.w
    height: Media.hasPlayer ? 124 : 76     // natural content height; the Notch centres it

    property real phase: 0

    // click the hover state -> calendar (cluster below overrides this on the right)
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Pill.open("calendar", false)
    }
    NumberAnimation on phase {
        from: 0
        to: Math.PI * 2
        duration: 1600
        loops: Animation.Infinite
        running: root.visible && Media.playing
    }

    // ── left: workspace name + dots ──────────────────────────────────
    Column {
        id: leftCol
        x: Theme.pad + 6
        y: Math.max(14, (root.height - height) / 2)
        spacing: 9

        Row {
            spacing: 8
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 6
                height: 6
                radius: 3
                color: Theme.accent
            }
            Text {
                text: Pill.workspaceLabel
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.Medium
            }
        }

        WorkspaceDots { size: 14 }
    }

    // ── top row: time + date centered, status cluster on the right ───
    Item {
        id: topRow
        y: 14
        width: parent.width
        height: 32

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(Pill.now, "HH:mm")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 24
                font.weight: Font.Medium
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(Pill.now, "ddd, MMM d")
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }
        }

        Row {
            id: cluster
            anchors.right: parent.right
            anchors.rightMargin: Theme.pad + 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            SignalBars {}
            BatteryIcon {}
        }

        // status cluster -> control center
        MouseArea {
            anchors.fill: cluster
            anchors.margins: -10
            cursorShape: Qt.PointingHandCursor
            onClicked: Pill.open("control", true)
        }
    }

    // ── media card ───────────────────────────────────────────────────
    Rectangle {
        id: card
        visible: Media.hasPlayer
        anchors.horizontalCenter: parent.horizontalCenter
        y: topRow.y + topRow.height + 10
        width: 300
        height: 54
        radius: 18
        color: Theme.tile

        // album art, rounded with a mask
        Item {
            id: art
            x: 9
            anchors.verticalCenter: parent.verticalCenter
            width: 38
            height: 38

            Rectangle {
                anchors.fill: parent
                radius: 11
                color: Theme.tileHi
            }

            Image {
                id: img
                anchors.fill: parent
                source: Media.art
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: artMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                }
            }

            Item {
                id: artMask
                anchors.fill: parent
                layer.enabled: true
                visible: false
                Rectangle {
                    anchors.fill: parent
                    radius: 11
                }
            }
        }

        Column {
            anchors.left: art.right
            anchors.leftMargin: 11
            anchors.right: viz.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: Media.title
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width
                text: Media.artist
                elide: Text.ElideRight
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }

        // dotted "visualizer" (decorative wave while playing)
        Row {
            id: viz
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Repeater {
                model: 10
                Rectangle {
                    required property int index
                    width: 3
                    height: 3
                    radius: 1.5
                    color: Theme.accent
                    opacity: Media.playing
                        ? 0.3 + 0.7 * (0.5 + 0.5 * Math.sin(root.phase + index * 0.7))
                        : 0.3
                }
            }
        }
    }
}
