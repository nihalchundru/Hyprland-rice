import QtQuick
import "../core"
import "../components"

Item {
    id: s

    property string label: ""
    property real value: 0
    property real from: -1000000
    property real to: 1000000
    property real step: 1
    property bool incEnabled: true
    property bool decEnabled: true
    property real displayScale: 1
    property int decimals: 0
    property string suffix: ""
    signal edited(real v)

    readonly property bool canDec: decEnabled && value - step >= from - 1e-6
    readonly property bool canInc: incEnabled && value + step <= to + 1e-6

    function round(v) { return Math.round(v * 1000) / 1000; }

    implicitHeight: 34

    component Pad: Rectangle {
        id: pad
        property string glyph: ""
        property bool active: true
        signal clicked()

        width: 28
        height: 28
        radius: 9
        color: ma.containsMouse && active ? Qt.lighter(Theme.cardAlt, 1.2) : Theme.cardAlt
        opacity: active ? 1 : 0.35

        Txt {
            anchors.centerIn: parent
            text: pad.glyph
            font.pixelSize: 16
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            enabled: pad.active
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pad.clicked()
        }
    }

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        text: s.label
        color: Theme.onSurfaceDim
        font.pixelSize: 12
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Pad { glyph: "−"; active: s.canDec; onClicked: s.edited(s.round(s.value - s.step)) }
        Item {
            width: 60
            height: 28
            Txt {
                anchors.centerIn: parent
                text: (s.value * s.displayScale).toFixed(s.decimals) + s.suffix
                font.weight: Font.Bold
                font.pixelSize: 13
            }
        }
        Pad { glyph: "+"; active: s.canInc; onClicked: s.edited(s.round(s.value + s.step)) }
    }
}