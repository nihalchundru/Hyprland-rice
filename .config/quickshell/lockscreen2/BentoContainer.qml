import QtQuick

// Central 3-column Bento Grid Dashboard Container
Rectangle {
    id: root

    required property var context

    implicitWidth: mainRow.implicitWidth + 36
    implicitHeight: mainRow.implicitHeight + 36
    radius: 28
    color: Qt.rgba(0.06, 0.09, 0.08, 0.72)
    border.width: 1.5
    border.color: Colors.cardBorder

    Row {
        id: mainRow
        anchors.centerIn: parent
        spacing: 20

        // ================= Left Column =================
        Column {
            spacing: 12
            anchors.verticalCenter: parent.verticalCenter

            WeatherCard { }

            FastfetchCard { }

            MediaCard { }
        }

        // ================= Center Column =================
        Column {
            width: 300
            spacing: 26
            anchors.verticalCenter: parent.verticalCenter

            CenterClock {
                anchors.horizontalCenter: parent.horizontalCenter
            }

            UserAvatar {
                anchors.horizontalCenter: parent.horizontalCenter
                size: 136
            }

            PasswordPill {
                anchors.horizontalCenter: parent.horizontalCenter
                context: root.context
            }
        }

        // ================= Right Column =================
        Column {
            spacing: 14
            anchors.verticalCenter: parent.verticalCenter

            GaugesCard { }

            NotifCard { }
        }
    }
}
