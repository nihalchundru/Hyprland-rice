import QtQuick

// Header bar for the Lock Screen Switcher
Item {
    id: root

    property string styleName: "Veil"
    property string styleTag: "Default"

    signal closeRequested()
    signal applyRequested()

    implicitHeight: 64

    // Palette (Dark mauve / Iris aesthetic matching the screenshot)
    readonly property color colAccent: "#f3b3c8"      // Soft pink/mauve highlight
    readonly property color colAccentDark: "#26151c"  // Text on accent
    readonly property color colSurface: Qt.rgba(0.14, 0.12, 0.14, 0.85)
    readonly property color colBorder: Qt.rgba(0.95, 0.70, 0.78, 0.16)
    readonly property color colText: "#fcebf0"
    readonly property color colSub: "#b39aa3"

    // ================= Left: Title & Icon =================
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Text {
            text: "🔒"
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "Lock screen style"
            color: root.colText
            font.pixelSize: 15
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ================= Right: Style Badge, Close & Apply =================
    Row {
        id: actionRow
        anchors.right: parent.right
        anchors.rightMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        spacing: 18

        // Current Style Badge
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root.styleName
                color: root.colAccent
                font.pixelSize: 14
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.styleTag
                color: root.colSub
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Close Button (✕)
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: closeMouse.containsMouse ? Qt.rgba(0.24, 0.20, 0.24, 0.95) : root.colSurface
            border.width: 1
            border.color: root.colBorder
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: root.colText
                font.pixelSize: 13
                font.weight: Font.Bold
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()
            }
        }

        // Apply Button (✓)
        Rectangle {
            width: applyRow.implicitWidth + 24
            height: 36
            radius: 18
            color: applyMouse.containsMouse ? Qt.lighter(root.colAccent, 1.08) : root.colAccent
            anchors.verticalCenter: parent.verticalCenter

            Row {
                id: applyRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "✓"
                    color: root.colAccentDark
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }

                Text {
                    text: "Apply"
                    color: root.colAccentDark
                    font.pixelSize: 13
                    font.weight: Font.Bold
                }
            }

            MouseArea {
                id: applyMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.applyRequested()
            }
        }
    }
}
