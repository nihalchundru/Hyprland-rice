import QtQuick

// Accent colour: the theme's own accent, then one swatch per palette colour.
Item {
    id: root

    property var def: ({})
    property bool first: false

    readonly property string choice: String(Settings.get("accentChoice"))
    readonly property bool custom: String(Settings.get("accentCustom")) !== ""

    width: parent ? parent.width : 0
    height: 56

    Rectangle {
        visible: !root.first
        x: 16
        width: parent.width - 32
        height: 1
        color: Theme.mix(Theme.body, Theme.text, 0.07)
    }

    Text {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        text: root.def.label || ""
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Repeater {
            model: ["default", "red", "green", "yellow", "blue", "purple", "teal"]

            Rectangle {
                id: sw
                required property string modelData
                readonly property bool cur: !root.custom && root.choice === modelData

                width: 26
                height: 26
                radius: Theme.r(13)
                color: Theme.swatch(modelData)
                border.width: cur ? 2 : 0
                border.color: Theme.text

                Rectangle {
                    visible: sw.cur
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: Theme.r(4)
                    color: Theme.body
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Settings.set("accentCustom", "");
                        Settings.set("accentChoice", sw.modelData);
                    }
                }
            }
        }
    }
}
