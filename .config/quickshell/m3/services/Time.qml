pragma Singleton
import QtQuick
import Quickshell

// Clock. Reads 12/24 from ~/.config/hypr/themes/clock-format (via Config later); default 24.
Singleton {
    id: root
    property bool use24: true
    readonly property alias clock: sc
    readonly property date date: sc.date
    readonly property string time: Qt.formatDateTime(sc.date, use24 ? "HH:mm" : "h:mm AP")
    readonly property string timeSec: Qt.formatDateTime(sc.date, use24 ? "HH:mm:ss" : "h:mm:ss AP")
    readonly property string dateLong: Qt.formatDateTime(sc.date, "dddd, MMMM d")
    readonly property string dateShort: Qt.formatDateTime(sc.date, "ddd d MMM")
    property alias precision: sc.precision
    SystemClock { id: sc; precision: SystemClock.Seconds }
}
