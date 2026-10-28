import QtQuick
import Quickshell
import Quickshell.Wayland

// The settings app: an overlay window with a sidebar, search, history arrows
// and one page at a time. Pages come from Schema.qml.
PanelWindow {
    id: win

    signal closeRequested()

    implicitWidth: 1040
    implicitHeight: 760
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "pill-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    // on demand, so the launcher / password prompt can still take the keyboard
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // ── navigation ──────────────────────────────────────────────────────
    property var history: ["motion"]
    property int pos: 0
    property string query: ""

    readonly property string currentId: history[pos]
    readonly property var results: Schema.search(query)
    readonly property var searchPage: ({
        id: "search", title: "Search", icon: "search",
        subtitle: results.length + (results.length === 1 ? " setting" : " settings") + " matching \u201c" + query.trim() + "\u201d",
        emptyText: "Nothing matches that.",
        groups: results.length > 0 ? [{ title: "", rows: results }] : []
    })
    readonly property var page: query.trim() !== "" ? searchPage : Schema.byId(currentId)

    function go(id) {
        clearSearch();
        if (id === currentId) return;
        const h = history.slice(0, pos + 1);
        h.push(id);
        history = h;
        pos = h.length - 1;
    }
    function back() { if (pos > 0) pos--; }
    function forward() { if (pos < history.length - 1) pos++; }
    function clearSearch() { searchInput.text = ""; }

    function dismiss() {
        if (query !== "") clearSearch();
        else closeRequested();
    }

    function takeRequestedPage() {
        if (Settings.requestedPage !== "") {
            go(Settings.requestedPage);
            Settings.requestedPage = "";
        }
    }

    Component.onCompleted: takeRequestedPage()

    Connections {
        target: Settings
        function onRequestedPageChanged() { win.takeRequestedPage(); }
        function onCloseTickChanged() { Qt.callLater(function () { win.closeRequested(); }); }
    }

    onPageChanged: {
        flick.contentY = 0;
        fadeIn.restart();
    }

    // ── window ──────────────────────────────────────────────────────────
    Rectangle {
        id: frame
        anchors.fill: parent
        radius: Theme.r(30)
        color: Theme.body
        border.width: 1
        border.color: Theme.tileHi
        clip: true
        opacity: 0
        scale: 0.97

        ParallelAnimation {
            running: true
            NumberAnimation { target: frame; property: "opacity"; to: 1; duration: Theme.fadeMs }
            NumberAnimation { target: frame; property: "scale"; to: 1; duration: Theme.animMs > 0 ? 260 : 0; easing.type: Easing.OutCubic }
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: win.dismiss()
        }

        // ── sidebar ─────────────────────────────────────────────────────
        Rectangle {
            id: searchBox
            x: 16
            y: 16
            width: 230
            height: 40
            radius: Theme.r(14)
            color: Theme.inset

            Icon {
                id: sIcon
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                name: "search"
                size: 15
                color: Theme.dim
            }

            TextInput {
                id: searchInput
                anchors.left: sIcon.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                color: Theme.text
                selectionColor: Theme.accent
                selectedTextColor: Theme.onAccent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(14)
                onTextChanged: win.query = text
                Keys.onEscapePressed: win.dismiss()

                Text {
                    visible: searchInput.text === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search Settings"
                    color: Theme.dim
                    font: searchInput.font
                }
            }
        }

        Column {
            x: 16
            y: 72
            width: 230
            spacing: 4

            Repeater {
                model: Schema.pages

                SidebarItem {
                    required property var modelData
                    width: 230
                    icon: modelData.icon
                    label: modelData.title
                    selected: win.query.trim() === "" && win.currentId === modelData.id
                    onClicked: win.go(modelData.id)
                }
            }
        }

        // ── content ─────────────────────────────────────────────────────
        Item {
            id: content
            x: 262
            width: parent.width - 262 - 18
            height: parent.height

            // history arrows + close
            Row {
                y: 16
                spacing: 8

                Repeater {
                    model: [
                        { icon: "arrow-left", go: -1 },
                        { icon: "arrow-right", go: 1 }
                    ]

                    Rectangle {
                        required property var modelData
                        readonly property bool enabledNav: modelData.go < 0 ? win.pos > 0 : win.pos < win.history.length - 1
                        width: 40
                        height: 32
                        radius: Theme.r(12)
                        color: navMa.containsMouse && enabledNav ? Theme.tileHi : Theme.tile
                        opacity: enabledNav ? 1 : 0.35
                        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

                        Icon {
                            anchors.centerIn: parent
                            name: modelData.icon
                            size: 15
                        }
                        MouseArea {
                            id: navMa
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: parent.enabledNav
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.go < 0 ? win.back() : win.forward()
                        }
                    }
                }
            }

            Rectangle {
                anchors.right: parent.right
                y: 16
                width: 32
                height: 32
                radius: Theme.r(16)
                color: closeMa.containsMouse ? Theme.tileHi : Theme.tile
                Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

                Icon {
                    anchors.centerIn: parent
                    name: "x"
                    size: 14
                }
                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: win.closeRequested()
                }
            }

            Flickable {
                id: flick
                y: 62
                width: parent.width
                height: parent.height - 62 - 16
                clip: true
                contentWidth: width
                contentHeight: pageView.height
                boundsBehavior: Flickable.StopAtBounds

                SettingsPage {
                    id: pageView
                    width: flick.width - 14
                    page: win.page
                    onDismissRequested: win.dismiss()

                    NumberAnimation {
                        id: fadeIn
                        target: pageView
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.fadeMs
                    }
                }
            }

            // thin scroll indicator
            Rectangle {
                visible: flick.visibleArea.heightRatio < 0.999
                x: parent.width - 4
                y: flick.y + flick.visibleArea.yPosition * flick.height
                width: 3
                height: Math.max(24, flick.visibleArea.heightRatio * flick.height)
                radius: Theme.r(1.5)
                color: Theme.tileHi
            }
        }
    }
}
