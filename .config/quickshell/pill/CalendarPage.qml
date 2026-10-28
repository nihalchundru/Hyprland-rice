import QtQuick

Item {
    id: root
    width: 430
    height: 340

    property date view: new Date()

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate();
    }

    // 6 weeks, Sunday first
    readonly property int weekStart: Settings.get("weekStart")
    readonly property var weekdays: ["S", "M", "T", "W", "T", "F", "S"].map((_, i, a) => a[(i + weekStart) % 7])

    function buildCells(v, now, ws) {
        const y = v.getFullYear(), m = v.getMonth();
        const first = new Date(y, m, 1);
        const off = (first.getDay() - ws + 7) % 7;
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(y, m, 1 - off + i);
            out.push({ day: d.getDate(), inMonth: d.getMonth() === m, today: sameDay(d, now) });
        }
        return out;
    }

    function shift(delta) {
        view = new Date(view.getFullYear(), view.getMonth() + delta, 1);
    }

    readonly property var cells: buildCells(view, Pill.now, weekStart)

    // always open on the current month
    Connections {
        target: Pill
        function onModeChanged() {
            if (Pill.mode === "calendar") root.view = new Date(Pill.now);
        }
    }

    // header
    Item {
        id: head
        x: 20
        y: 16
        width: parent.width - 40
        height: 36

        CircleButton {
            anchors.left: parent.left
            size: 34
            iconSize: 16
            icon: "arrow-left"
            onClicked: root.shift(-1)
        }

        Text {
            anchors.centerIn: parent
            text: Qt.formatDate(root.view, "MMMM yyyy")
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(16)
            font.weight: Font.DemiBold
        }

        CircleButton {
            anchors.right: parent.right
            size: 34
            iconSize: 16
            icon: "arrow-right"
            onClicked: root.shift(1)
        }
    }

    // weekday row
    Row {
        id: week
        x: 20
        y: head.y + head.height + 10
        Repeater {
            model: root.weekdays
            Text {
                required property string modelData
                width: (root.width - 40) / 7
                height: 20
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
            }
        }
    }

    // day grid
    Grid {
        x: 20
        y: week.y + week.height + 4
        columns: 7

        Repeater {
            model: root.cells

            Item {
                required property var modelData
                width: (root.width - 40) / 7
                height: 38

                Rectangle {
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    radius: Theme.r(16)
                    color: Theme.accent
                    visible: parent.modelData.today
                }

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.day
                    color: parent.modelData.today ? Theme.onAccent
                         : parent.modelData.inMonth ? Theme.text : Theme.faint
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(14)
                    font.weight: parent.modelData.today ? Font.DemiBold : Font.Normal
                }
            }
        }
    }

    // scroll wheel changes month
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => root.shift(wheel.angleDelta.y > 0 ? -1 : 1)
    }
}
