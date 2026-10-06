import QtQuick

// Thumbnail carousel. Left/Right to move, Enter to apply, Esc to close.
Item {
    id: root
    width: 1000
    height: 262

    readonly property real cardW: 190
    readonly property var walls: Wallpapers.list
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

    onWallsChanged: if (visible) jumpToCurrent()

    onVisibleChanged: {
        if (visible) {
            Wallpapers.reload();
            keys.forceActiveFocus();
            jumpToCurrent();
        }
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Left) { root.step(-1); event.accepted = true; }
            else if (event.key === Qt.Key_Right) { root.step(1); event.accepted = true; }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { root.apply(); event.accepted = true; }
            else if (event.key === Qt.Key_Escape) { Pill.back(); event.accepted = true; }
        }
    }

    Text {
        x: 24
        y: 18
        text: "Wallpaper"
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 17
        font.weight: Font.Medium
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 24
        y: 21
        text: Themes.current
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 13
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
        highlightMoveDuration: 260
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
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                RoundImage {
                    anchors.fill: parent
                    radius: 20
                    source: "file://" + encodeURI(card.modelData).replace(/#/g, "%23")
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 20
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
                    radius: 5
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
        text: "No wallpapers found for this theme"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 14
    }

    Text {
        x: 24
        y: 224
        width: root.width / 2
        elide: Text.ElideMiddle
        text: Wallpapers.nameOf(root.selected)
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 12
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 24
        y: 224
        text: (root.walls.length > 0 ? (lv.currentIndex + 1) + "/" + root.walls.length + "  ·  " : "") + "Enter to apply"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 12
    }
}
