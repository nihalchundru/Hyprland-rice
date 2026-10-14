pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Clock and date formatting. The 12/24-hour choice lives in the same file the
// rest of the rice uses (~/.config/hypr/themes/clock-format), so changing it
// here changes it everywhere. Everything else comes from Settings.
Singleton {
    id: root

    property bool use24: true
    readonly property bool seconds: !!Settings.get("showSeconds")

    readonly property string timeFormat: use24 ? (seconds ? "HH:mm:ss" : "HH:mm")
                                               : (seconds ? "h:mm:ss AP" : "h:mm AP")

    readonly property var dateFormats: [
        { value: "short",    fmt: "ddd, MMM d" },
        { value: "long",     fmt: "dddd, MMMM d" },
        { value: "dayMonth", fmt: "d MMM" },
        { value: "numeric",  fmt: "MM/dd" },
        { value: "iso",      fmt: "yyyy-MM-dd" }
    ]

    readonly property string dateFormat: {
        const k = Settings.get("dateFormat");
        const f = dateFormats.find(x => x.value === k);
        return f ? f.fmt : "ddd, MMM d";
    }

    function time(d) { return Qt.formatDateTime(d, timeFormat); }
    function date(d) { return Qt.formatDateTime(d, dateFormat); }

    function setUse24(v) {
        use24 = v;
        file.setText(v ? "24\n" : "12\n");
    }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/hypr/themes/clock-format"
        watchChanges: true
        printErrors: false
        onLoaded: {
            const t = text().trim();
            if (t.indexOf("12") === 0) root.use24 = false;
            else if (t.indexOf("24") === 0) root.use24 = true;
        }
        onFileChanged: reload()
    }
}
