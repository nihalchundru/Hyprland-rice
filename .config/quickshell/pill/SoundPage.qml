import QtQuick

Item {
    id: root
    width: 560

    readonly property real maxH: 740
    implicitHeight: Math.min(maxH, head.height + 4 + col.implicitHeight + 16)
    height: implicitHeight
    onImplicitHeightChanged: Pill.setHeight("sound", implicitHeight)
    Component.onCompleted: Pill.setHeight("sound", implicitHeight)

    PageHeader {
        id: head
        width: parent.width
        title: "Sound"
        onBack: Pill.open("control", true)
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

            // ── output ──────────────────────────────────────────
            Text {
                text: "Output"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
            Repeater {
                model: Audio.sinks
                DeviceRow {
                    required property var modelData
                    width: col.width
                    icon: Audio.iconFor(modelData)
                    label: Audio.nameOf(modelData)
                    selected: !!Audio.sink && modelData.id === Audio.sink.id
                    showCheck: selected
                    onClicked: Audio.selectSink(modelData)
                }
            }
            SliderRow {
                width: col.width
                icon: Audio.mutedOf(Audio.sink) ? "volume-mute" : "volume"
                active: !!Audio.sink
                value: Audio.volumeOf(Audio.sink)
                onMoved: v => Audio.setVolume(Audio.sink, v)
            }

            // ── input ───────────────────────────────────────────
            Text {
                text: "Input"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 12
                topPadding: 6
            }
            Repeater {
                model: Audio.sources
                DeviceRow {
                    required property var modelData
                    width: col.width
                    icon: "mic"
                    label: Audio.nameOf(modelData)
                    selected: !!Audio.source && modelData.id === Audio.source.id
                    showCheck: selected
                    onClicked: Audio.selectSource(modelData)
                }
            }
            SliderRow {
                width: col.width
                icon: "mic"
                active: !!Audio.source
                value: Audio.volumeOf(Audio.source)
                onMoved: v => Audio.setVolume(Audio.source, v)
            }

            // ── apps ────────────────────────────────────────────
            Text {
                visible: Audio.apps.length > 0
                text: "Apps"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 12
                topPadding: 6
            }
            Repeater {
                model: Audio.apps
                Rectangle {
                    required property var modelData
                    width: col.width
                    height: 76
                    radius: 18
                    color: Theme.tile

                    Text {
                        x: 14
                        y: 10
                        text: Audio.appName(modelData)
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    SliderRow {
                        x: 12
                        y: 38
                        width: parent.width - 24
                        icon: Audio.mutedOf(modelData) ? "volume-mute" : "volume"
                        value: Audio.volumeOf(modelData)
                        onMoved: v => Audio.setVolume(modelData, v)
                    }
                }
            }
        }
    }
}
