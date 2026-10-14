import QtQuick
import "wallcolor.js" as WC

// Thumbnail carousel. Left/Right to move, Enter to apply, Esc to close.
Item {
    id: root
    width: 1000
    height: 262

    readonly property real cardW: 190
    property string colorFilter: ""
    readonly property string q: search.text.trim().toLowerCase()

    // folder + file name, lower-case ("matugen/forest.jpg"), so you can search by folder too
    function relName(p) {
        const i = p.indexOf("/wallpapers/");
        return (i >= 0 ? p.slice(i + 12) : p).toLowerCase();
    }

    function matches(p) {
        if (q !== "" && relName(p).indexOf(q) < 0) return false;
        if (colorFilter !== "") {
            const c = Wallpapers.colorsRev >= 0 ? Wallpapers.colors[p] : null;
            if (!c || c.indexOf(colorFilter) < 0) return false;
        }
        return true;
    }

    readonly property var walls: Wallpapers.list.filter(p => matches(p))

    // how many wallpapers have each colour (dots with none are dimmed)
    readonly property var counts: {
        const out = {};
        WC.BUCKETS.forEach(b => { out[b] = 0; });
        if (Wallpapers.colorsRev >= 0)
            Wallpapers.list.forEach(p => (Wallpapers.colors[p] || []).forEach(b => { out[b]++; }));
        return out;
    }
    readonly property string selected: walls[lv.currentIndex] || ""

    function step(d) {
        lv.currentIndex = Math.max(0, Math.min(walls.length - 1, lv.currentIndex + d));
    }

    function apply() {
        if (!selected) return;
        Wallpapers.apply(selected);
        Pill.close();
    }

    function jumpToCurrent() {
        const i = walls.indexOf(Wallpapers.current);
        lv.currentIndex = i >= 0 ? i : 0;
        lv.positionViewAtIndex(lv.currentIndex, ListView.Center);
    }

    onWallsChanged: {
        if (!visible) return;
        if (q === "" && colorFilter === "") jumpToCurrent();
        else {
            lv.currentIndex = 0;
            lv.positionViewAtBeginning();
        }
    }

    onVisibleChanged: {
        if (visible) {
            Wallpapers.reload();
            search.clear();
            root.colorFilter = "";
            search.focusInput();
            jumpToCurrent();
        }
    }

    SearchField {
        id: search
        x: 24
        y: 11
        width: 340
        placeholder: "Search wallpapers\u2026"
        horizontalKeys: true
        onNavLeft: root.step(-1)
        onNavRight: root.step(1)
        onAccepted: root.apply()
    }

    Text {
        visible: Wallpapers.analysing
        x: 380
        y: 22
        text: "reading colours\u2026"
        color: Theme.faint
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(12)
    }

    // colour filter: click a dot to show only wallpapers with that colour, click again to clear
    Row {
        id: dots
        anchors.right: themeText.left
        anchors.rightMargin: 18
        y: 19
        spacing: 6

        Repeater {
            model: WC.BUCKETS

            Rectangle {
                id: dot
                required property string modelData
                readonly property bool on: root.colorFilter === modelData
                readonly property int n: root.counts[modelData] || 0

                width: 16
                height: 16
                radius: 8
                color: WC.COLORS[modelData]
                border.width: on ? 2 : ((modelData === "dark" || modelData === "light") ? 1 : 0)
                border.color: on ? Theme.text : Theme.tileHi
                opacity: (n > 0 || on) ? 1 : 0.3
                scale: on ? 1.2 : 1
                Behavior on scale { NumberAnimation { duration: Theme.ms(120) } }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -3
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.colorFilter = dot.on ? "" : dot.modelData
                }
            }
        }
    }

    Text {
        id: themeText
        anchors.right: parent.right
        anchors.rightMargin: 24
        y: 21
        text: Themes.current
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(13)
    }

    ListView {
        id: lv
        y: 54
        width: root.width
        height: 136
        orientation: ListView.Horizontal
        spacing: 14
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        leftMargin: width / 2 - root.cardW / 2
        rightMargin: leftMargin
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: width / 2 - root.cardW / 2
        preferredHighlightEnd: width / 2 + root.cardW / 2
        highlightMoveDuration: Theme.ms(260)
        model: root.walls

        delegate: Item {
            id: card
            required property string modelData
            required property int index
            readonly property bool sel: ListView.isCurrentItem

            width: root.cardW
            height: lv.height

            Item {
                anchors.centerIn: parent
                width: parent.width
                height: 114
                scale: card.sel ? 1.0 : 0.9
                Behavior on scale { NumberAnimation { duration: Theme.ms(160); easing.type: Easing.OutCubic } }

                RoundImage {
                    anchors.fill: parent
                    radius: Theme.r(20)
                    source: "file://" + encodeURI(card.modelData).replace(/#/g, "%23")
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.r(20)
                    color: "transparent"
                    border.width: card.sel ? 2 : 0
                    border.color: Theme.accent
                }

                // marks the wallpaper that is currently set
                Rectangle {
                    visible: card.modelData === Wallpapers.current
                    x: parent.width - 20
                    y: 10
                    width: 10
                    height: 10
                    radius: Theme.r(5)
                    color: Theme.accent
                    border.width: 2
                    border.color: Theme.body
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    lv.currentIndex = card.index;
                    root.apply();
                }
            }
        }
    }

    WheelHandler {
        target: null
        onWheel: event => root.step(event.angleDelta.y > 0 ? -1 : 1)
    }

    Text {
        visible: root.walls.length === 0
        anchors.centerIn: lv
        text: (root.q !== "" || root.colorFilter !== "") ? "No wallpapers match" : "No wallpapers found for this theme"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(14)
    }

    Text {
        x: 24
        y: 224
        width: root.width / 2
        elide: Text.ElideMiddle
        text: Wallpapers.nameOf(root.selected)
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(12)
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 24
        y: 224
        text: (root.walls.length > 0 ? (lv.currentIndex + 1) + "/" + root.walls.length + "  ·  " : "") + "Enter to apply"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(12)
    }
}
