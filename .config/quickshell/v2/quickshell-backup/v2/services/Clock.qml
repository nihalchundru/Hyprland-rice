pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool is24h: true

    readonly property string timeText: Qt.formatDateTime(clock.date, is24h ? "HH:mm" : "h:mm AP")
    readonly property string dateText: Qt.formatDateTime(clock.date, "ddd, d MMM")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    FileView {
        path: Config.clockFormatPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.is24h = text().trim() !== "12"
    }
}