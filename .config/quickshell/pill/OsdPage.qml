import QtQuick

// The OSD: icon, a level bar (thickness from settings) and the percentage.
Item {
    id: root
    width: Theme.idleW
    height: Math.max(Theme.idleH, 52)

    readonly property real level: Math.max(0, Math.min(1, Osd.level))
    readonly property int thickness: Settings.get("osdThickness")

    Icon {
        id: ic
        x: Theme.pad + 2
        anchors.verticalCenter: parent.verticalCenter
        name: Osd.icon
        size: 20
        color: Osd.muted ? Theme.dim : Theme.text
    }

    Item {
        anchors.left: ic.right
        anchors.leftMargin: 14
        anchors.right: pct.left
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        height: root.thickness

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.mix(Theme.body, Theme.text, 0.12)
        }

        Rectangle {
            width: parent.width * (Osd.muted ? 0 : root.level)
            height: parent.height
            radius: height / 2
            color: Theme.accent
            Behavior on width { NumberAnimation { duration: Theme.fadeMs * 0.6; easing.type: Easing.OutCubic } }
        }
    }

    Text {
        id: pct
        anchors.right: parent.right
        anchors.rightMargin: Theme.pad + 2
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        horizontalAlignment: Text.AlignRight
        text: Osd.muted ? "Mute" : Math.round(root.level * 100) + "%"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(13)
    }
}
