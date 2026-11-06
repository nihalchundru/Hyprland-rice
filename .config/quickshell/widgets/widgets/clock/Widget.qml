import QtQuick
import Quickshell
import "../../core"
import "../../components"

Item {
    id: root

    property int cols: 2
    property int rows: 2
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    readonly property bool h24: (settings.format ?? "24h") === "24h"
    readonly property bool showDate: settings.showDate ?? true
    readonly property bool accentMinutes: settings.accentMinutes ?? false

    SystemClock { id: clock; precision: SystemClock.Minutes }

    readonly property string hh: Qt.formatDateTime(clock.date, h24 ? "HH" : "h")
    readonly property string mm: Qt.formatDateTime(clock.date, "mm")
    readonly property string dateStr: Qt.formatDateTime(clock.date, "ddd d MMM")

    // stacked variant
    Column {
        visible: root.rows >= 2
        anchors.centerIn: parent

        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.hh
            font.pixelSize: root.height * 0.34
            font.weight: Font.Bold
            lineHeight: 0.85
        }
        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.mm
            color: root.accentMinutes ? root.accent : Theme.onSurface
            font.pixelSize: root.height * 0.34
            font.weight: Font.Bold
            lineHeight: 0.85
        }
        Txt {
            visible: root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: root.height * 0.06
            text: root.dateStr
            color: Theme.onSurfaceDim
            font.pixelSize: Math.max(11, root.height * 0.085)
        }
    }

    // single-row variant
    Row {
        visible: root.rows < 2
        anchors.centerIn: parent
        spacing: 12

        Txt {
            text: root.hh + ":" + root.mm
            font.pixelSize: root.height * 0.6
            font.weight: Font.Bold
        }
        Txt {
            visible: root.cols >= 3 && root.showDate
            anchors.verticalCenter: parent.verticalCenter
            text: root.dateStr
            color: Theme.onSurfaceDim
        }
    }
}