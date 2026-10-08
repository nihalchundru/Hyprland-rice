import QtQuick
import Quickshell
import Quickshell.Widgets

// Compact notification toast. Click to dismiss it (it stays in the control center).
Item {
    id: root
    width: Settings.get("notifWidth")
    height: hasBody ? 90 : 72

    // keep the last values so the text doesn't blank out while the pill collapses
    property string app: ""
    property string summary: ""
    property string body: ""
    property string iconName: ""

    readonly property var n: Notifs.toast
    readonly property bool hasBody: body !== "" && !!Settings.get("notifShowBody")

    // 1 -> 0 while the toast counts down; full while hovered (countdown paused)
    property real progress: 1

    NumberAnimation {
        id: countdownAnim
        target: root
        property: "progress"
        from: 1
        to: 0
        duration: Notifs.duration
        easing.type: Easing.Linear
    }

    Connections {
        target: Notifs
        function onCountdownTickChanged() { countdownAnim.restart(); }
    }

    Connections {
        target: Pill
        function onHoveringChanged() {
            if (Notifs.toast !== null && Pill.hovering) {
                countdownAnim.stop();
                root.progress = 1;
            }
        }
    }

    onNChanged: {
        if (!n) return;
        countdownAnim.stop();
        progress = 1;
        app = n.appName || "";
        summary = n.summary || "";
        body = n.body || "";
        iconName = n.appIcon || "";
    }

    onHeightChanged: Pill.setHeight("notify", height)
    Component.onCompleted: Pill.setHeight("notify", height)

    readonly property string iconPath: iconName ? Quickshell.iconPath(iconName, true) : ""

    Rectangle {
        id: avatar
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -3
        width: 44
        height: 44
        radius: 22
        color: Theme.tile
        border.width: 1
        border.color: Theme.tileHi

        IconImage {
            visible: root.iconPath !== ""
            anchors.centerIn: parent
            implicitSize: 26
            source: root.iconPath
        }

        Text {
            visible: root.iconPath === ""
            anchors.centerIn: parent
            text: (root.app || root.summary || "?").charAt(0).toUpperCase()
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }
    }

    Column {
        anchors.left: avatar.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -3
        spacing: 1

        Text {
            width: parent.width
            text: root.app
            elide: Text.ElideRight
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
        Text {
            width: parent.width
            text: root.summary
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
        Text {
            width: parent.width
            visible: root.hasBody
            text: root.body
            elide: Text.ElideRight
            maximumLineCount: 1
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: 13
        }
    }

    // the auto-hide line: shrinks toward the left as time runs out
    Rectangle {
        x: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: (root.width - 48) * root.progress
        height: 3
        radius: 1.5
        color: Theme.accent
        opacity: Pill.hovering ? 0 : 0.85
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifs.dismissToast()
    }
}
