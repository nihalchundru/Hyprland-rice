import QtQuick
import qs.tokens

// Set anchors.fill: parent where you use it. Emits accepted/rejected and closes itself.
Item {
    id: root
    property bool open: false
    property string title: ""
    property string text: ""
    property string icon: ""
    property string acceptText: "OK"
    property string rejectText: "Cancel"
    signal accepted()
    signal rejected()
    visible: scrim.opacity > 0.01
    z: 2000

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: M3Colors.scrim
        opacity: root.open ? 0.32 : 0
        FadeBehavior on opacity { time: M3Motion.medium1 }
        MouseArea { anchors.fill: parent; onClicked: { root.open = false; root.rejected() } }
    }
    Rectangle {
        id: box
        anchors.centerIn: parent
        width: 312
        height: col.implicitHeight + 48
        radius: M3Shape.extraLarge
        color: M3Colors.surfaceContainerHigh
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.85
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
        MouseArea { anchors.fill: parent }
        Column {
            id: col
            x: 24; y: 24
            width: parent.width - 48
            spacing: 16
            Icon { visible: root.icon !== ""; name: root.icon; size: 24; color: M3Colors.secondary; anchors.horizontalCenter: parent.horizontalCenter }
            M3Text {
                width: parent.width
                text: root.title
                role: M3Type.headlineSmall
                horizontalAlignment: root.icon !== "" ? Text.AlignHCenter : Text.AlignLeft
            }
            M3Text { width: parent.width; text: root.text; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant; wrapMode: Text.Wrap; lineHeightMode: Text.FixedHeight; lineHeight: 20 }
            Item {
                width: parent.width
                height: 40
                Row {
                    anchors.right: parent.right
                    spacing: 8
                    M3Button { text: root.rejectText; variant: "text"; onClicked: { root.open = false; root.rejected() } }
                    M3Button { text: root.acceptText; variant: "text"; onClicked: { root.open = false; root.accepted() } }
                }
            }
        }
    }
}
