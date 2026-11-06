pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property bool use24h: M3Config.clock24
    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(now, use24h ? "HH:mm" : "h:mm AP")
    readonly property string hourDigits: use24h ? String(now.getHours()).padStart(2, "0") : String(now.getHours() % 12 || 12)
    readonly property string minuteDigits: String(now.getMinutes()).padStart(2, "0")
    readonly property string ampm: use24h ? "" : (now.getHours() >= 12 ? "PM" : "AM")
    readonly property string seconds: Qt.formatDateTime(now, "ss")
    readonly property string dateShort: Qt.formatDateTime(now, "ddd, MMM d")
    readonly property string dateLong: Qt.formatDateTime(now, "dddd, MMMM d")
    SystemClock { id: clock; precision: SystemClock.Seconds }
}
