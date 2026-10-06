import QtQuick

// Horizontal carousel of themes. Type to filter, Left/Right to move, Enter to apply.
Item {
    id: root
    width: 880
    height: 236

    readonly property real cardW: 138
    readonly property string q: search.text.trim().toLowerCase()
    readonly property var filtered: Themes.list.filter(t => q === "" || t.name.toLowerCase().indexOf(q) >= 0)

    function step(d) {
        lv.currentIndex = Math.max(0, Math.min(filtered.length - 1, lv.currentIndex + d));
    }

    function apply() {
        const t = filtered[lv.currentIndex];
        if (!t) return;
        Themes.apply(t.name);
        Pill.close();
    }

    function jumpToCurrent() {
        const i = filtered.findIndex(t => t.name === Themes.current);
        lv.currentIndex = i >= 0 ? i : 0;
        lv.positionViewAtIndex(lv.currentIndex, ListView.Center);
    }

    onFilteredChanged: {
        if (q === "") jumpToCurrent();
        else {
            lv.currentIndex = 0;
            lv.positionViewAtBeginning();
        }
    }

    onVisibleChanged: {
        if (visible) {
            Themes.reload();
            search.clear();
            search.focusInput();
            jumpToCurrent();
        }
    }

    SearchField {
        id: search
        x: 22
        y: 14
        width: root.width - 44
        placeholder: "Search themes…"
        trailing: root.filtered.length > 0 ? (lv.currentIndex + 1) + "/" + root.filtered.length : "0/0"
        horizontalKeys: true
        onNavLeft: root.step(-1)
        onNavRight: root.step(1)
        onAccepted: root.apply()
    }

    ListView {
        id: lv
        y: 62
        width: root.width
        height: 128
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
        model: root.filtered

        delegate: Item {
            id: card
            required property var modelData
            required property int index
            readonly property bool sel: ListView.isCurrentItem

            width: root.cardW
            height: lv.height

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 108
                radius: 20
                color: card.modelData.bg
                border.width: card.sel ? 2 : 1
                border.color: card.sel ? Theme.accent
                    : Theme.mix(Qt.color(card.modelData.bg), Qt.color(card.modelData.text), 0.15)
                scale: card.sel ? 1.0 : 0.9
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 30
                    spacing: 6

                    Repeater {
                        model: [card.modelData.accent, card.modelData.accent2, card.modelData.green,
                                card.modelData.yellow, card.modelData.red, card.modelData.teal]
                        Rectangle {
                            required property string modelData
                            width: 14
                            height: 14
                            radius: 7
                            color: modelData
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    text: card.modelData.name
                    color: card.modelData.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: card.sel ? Font.DemiBold : Font.Normal
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
        visible: root.filtered.length === 0
        anchors.centerIn: lv
        text: Themes.list.length === 0 ? "Couldn't read ~/.config/hypr/themes/themes.sh" : "No matching themes"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 14
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 24
        y: 204
        text: "Enter to apply"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 12
    }
}
