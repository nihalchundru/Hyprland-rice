import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// ============================================================================
// Launcher.qml — qs-launcher
//
// App launcher matching the reference: plain search row (no bordered box),
// divider, vertical scrolling list of apps — icon, bold name, muted
// description, selected row gets a left accent bar + highlighted background.
//
// App list comes from parsing .desktop files directly (no desktop-entry
// service assumed available). Icons are resolved via Quickshell.iconPath()
// — ASSUMPTION: this is the right API for icon-theme lookup in this
// Quickshell version; if icons don't load, tell me and I'll adjust.
// ============================================================================

PanelWindow {
    id: launcherRoot

    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8"
    })
    function c(key) {
        return (launcherRoot.colors && launcherRoot.colors[key]) ? launcherRoot.colors[key] : "#888888"
    }

    FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"
        watchChanges: true
        onLoaded: {
            try { launcherRoot.colors = JSON.parse(text()) }
            catch (e) { console.log("Launcher: failed to parse colors.json, using fallback:", e) }
        }
        onLoadFailed: (error) => console.log("Launcher: colors.json load failed, using fallback:", error)
        onFileChanged: reload()
    }

    property bool open: false
    property string searchText: ""
    property var allApps: []     // [{ name, comment, icon, exec }]
    property int highlightIndex: 0

    property var filteredApps: {
        if (searchText.length === 0) return allApps
        var q = searchText.toLowerCase()
        return allApps.filter(function(a) {
            return a.name.toLowerCase().indexOf(q) !== -1 || a.comment.toLowerCase().indexOf(q) !== -1
        })
    }
    onFilteredAppsChanged: highlightIndex = 0

    function toggle() {
        open = !open
        if (open) {
            searchText = ""
            scanProc.running = true
            Qt.callLater(function() { searchInput.forceActiveFocus() })
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-launcher"
    WlrLayershell.keyboardFocus: launcherRoot.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1
    height: 560
    visible: open

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: launcherRoot.open = false
    }

    // ------------------------------------------------------------------
    // Scan .desktop files. Field extraction via grep/cut rather than a
    // real desktop-entry parser — this is a simplification, so entries
    // with quoted/multi-line/localized fields may not parse perfectly.
    // Fields are separated with \x1f (unit separator) since app names
    // and comments can contain almost any other character, making a
    // simple delimiter like "|" or "," unsafe.
    // ------------------------------------------------------------------
    Process {
        id: scanProc
        command: ["bash", "-c", "for f in /usr/share/applications/*.desktop " +
            "$HOME/.local/share/applications/*.desktop; do " +
            "[ -f \"$f\" ] || continue; " +
            "nd=$(grep -m1 '^NoDisplay=' \"$f\" | cut -d= -f2); " +
            "[ \"$nd\" = \"true\" ] && continue; " +
            "name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); " +
            "[ -z \"$name\" ] && continue; " +
            "comment=$(grep -m1 '^Comment=' \"$f\" | cut -d= -f2-); " +
            "icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-); " +
            "execline=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2- | sed -E 's/%[fFuUdDnNickvm]//g'); " +
            "printf '%s\\x1f%s\\x1f%s\\x1f%s\\n' \"$name\" \"$comment\" \"$icon\" \"$execline\"; " +
            "done"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.split("\n")
                var apps = []
                var seen = {}
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].length === 0) continue
                    var parts = lines[i].split("\u001f")
                    if (parts.length < 4) continue
                    var name = parts[0].trim()
                    if (name.length === 0 || seen[name]) continue
                    seen[name] = true
                    apps.push({ name: name, comment: parts[1].trim(), icon: parts[2].trim(), exec: parts[3].trim() })
                }
                apps.sort(function(a, b) { return a.name.localeCompare(b.name, undefined, { sensitivity: "base" }) })
                launcherRoot.allApps = apps
            }
        }
    }

    Process { id: launchProc }
    function launchApp(app) {
        if (!app) return
        // nohup+& detaches the app so it survives independent of the
        // launcher's own process lifecycle.
        launchProc.command = ["bash", "-c", "nohup " + app.exec + " >/dev/null 2>&1 &"]
        launchProc.running = true
        launcherRoot.open = false
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8 // floating pill, detached from the bezel
        width: 560
        height: launcherRoot.open ? 520 : 0
        color: "#000000"
        radius: 26 // full pill, all corners rounded
        clip: true
        antialiasing: true

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: {} }

        Keys.onUpPressed:   launcherRoot.highlightIndex = Math.max(0, launcherRoot.highlightIndex - 1)
        Keys.onDownPressed: launcherRoot.highlightIndex = Math.min(launcherRoot.filteredApps.length - 1, launcherRoot.highlightIndex + 1)
        Keys.onReturnPressed: launcherRoot.launchApp(launcherRoot.filteredApps[launcherRoot.highlightIndex])
        Keys.onEnterPressed:  launcherRoot.launchApp(launcherRoot.filteredApps[launcherRoot.highlightIndex])
        Keys.onEscapePressed: launcherRoot.open = false
        focus: launcherRoot.open

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Search row — plain, no bordered box, matches reference
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Text { text: "\u26b2"; color: launcherRoot.c("sub"); font.pixelSize: 16 }
                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: launcherRoot.c("text")
                    font.pixelSize: 15
                    font.family: "JetBrainsMono Nerd Font"
                    onTextChanged: launcherRoot.searchText = text
                    Keys.forwardTo: [card]

                    Text {
                        visible: parent.text.length === 0
                        text: "Search..."
                        color: launcherRoot.c("sub")
                        font.pixelSize: 15
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1, 1, 1, 0.1) }

            // App list
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: launcherRoot.filteredApps
                currentIndex: launcherRoot.highlightIndex
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                // A single highlight item that SLIDES between rows, instead
                // of each row independently fading its own background in/out.
                // This is ListView's built-in mechanism for exactly this —
                // it auto-animates position/size to match whichever row is
                // current, using highlightMoveDuration below.
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 160
                highlightResizeDuration: 100
                highlight: Rectangle {
                    radius: 12
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        width: 3
                        radius: 2
                        color: launcherRoot.c("accent")
                    }
                }

                delegate: Item {
                    width: appList.width
                    height: 58
                    property bool selected: index === launcherRoot.highlightIndex

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 14
                        spacing: 14

                        // Icon — resolved via Quickshell.iconPath(), with a
                        // generic fallback glyph if that fails or the icon
                        // name doesn't resolve to anything.
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: 10
                            color: launcherRoot.c("surface")
                            clip: true

                            IconImage {
                                id: appIcon
                                anchors.fill: parent
                                source: modelData.icon.length > 0 ? Quickshell.iconPath(modelData.icon, true) : ""
                                asynchronous: true
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: appIcon.status !== Image.Ready
                                text: "\u26f6" // generic fallback glyph, safe
                                color: launcherRoot.c("sub")
                                font.pixelSize: 16
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: launcherRoot.c("text")
                                font.pixelSize: 14
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: modelData.comment.length > 0
                                text: modelData.comment
                                color: launcherRoot.c("sub")
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: launcherRoot.highlightIndex = index
                        onClicked: launcherRoot.launchApp(modelData)
                    }
                }
            }
        }
    }
}
