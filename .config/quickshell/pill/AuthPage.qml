import QtQuick

// Polkit password prompt. Enter submits, Esc cancels.
Item {
    id: root
    width: 460
    implicitHeight: col.implicitHeight + 40
    height: implicitHeight

    readonly property var flow: AuthState.flow
    readonly property string message: flow ? flow.message : ""
    readonly property string actionId: flow ? flow.actionId : ""
    readonly property bool failed: flow ? flow.failed : false
    readonly property bool showText: flow ? flow.responseVisible : false
    readonly property string prompt: {
        const p = flow ? (flow.inputPrompt || "") : "";
        const t = p.replace(/:\s*$/, "").trim();
        return t !== "" ? t : "Password";
    }

    onHeightChanged: Pill.setHeight("auth", height)
    Component.onCompleted: Pill.setHeight("auth", height)

    function submit() {
        if (field.text === "") return;
        AuthState.submit(field.text);
        field.text = "";
    }

    onVisibleChanged: {
        if (visible) {
            field.text = "";
            field.forceActiveFocus();
        }
    }

    Column {
        id: col
        x: 20
        y: 20
        width: parent.width - 40
        spacing: 14

        // header
        Row {
            spacing: 14

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: Theme.accent
                Icon {
                    anchors.centerIn: parent
                    name: "lock"
                    size: 18
                    color: Theme.onAccent
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Authentication required"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.weight: Font.Medium
            }
        }

        // what is being authorised
        Rectangle {
            width: parent.width
            height: msgCol.implicitHeight + 24
            radius: 18
            color: Theme.tile
            border.width: 1
            border.color: Theme.tileHi

            Column {
                id: msgCol
                x: 14
                y: 12
                width: parent.width - 28
                spacing: 3

                Text {
                    width: parent.width
                    text: root.message
                    wrapMode: Text.WordWrap
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    visible: root.actionId !== ""
                    text: root.actionId
                    elide: Text.ElideRight
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }
        }

        Text {
            text: root.prompt
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        // password field
        Rectangle {
            width: parent.width
            height: 52
            radius: 26
            color: Theme.inset
            border.width: 1.5
            border.color: root.failed ? Theme.red : (field.activeFocus ? Theme.accent : Theme.tileHi)
            Behavior on border.color { ColorAnimation { duration: Theme.fadeMs } }

            Rectangle {
                id: lockCirc
                x: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 36
                radius: 18
                color: Theme.tileHi
                Icon {
                    anchors.centerIn: parent
                    name: "lock"
                    size: 15
                }
            }

            TextInput {
                id: field
                anchors.left: lockCirc.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                echoMode: root.showText ? TextInput.Normal : TextInput.Password
                passwordCharacter: "•"
                color: Theme.text
                selectionColor: Theme.accent
                selectedTextColor: Theme.onAccent
                font.family: Theme.fontFamily
                font.pixelSize: 16

                onAccepted: root.submit()
                Keys.onEscapePressed: Pill.back()

                Text {
                    visible: field.text === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Enter your " + root.prompt.toLowerCase()
                    color: Theme.dim
                    font: field.font
                }
            }
        }

        Text {
            visible: root.failed
            width: parent.width
            text: "Authentication failed. Try again."
            color: Theme.red
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        // buttons
        Item {
            width: parent.width
            height: 42

            Rectangle {
                id: authBtn
                anchors.right: parent.right
                width: 132
                height: 42
                radius: 21
                color: authMa.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent
                Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

                Text {
                    anchors.centerIn: parent
                    text: "Authenticate"
                    color: Theme.onAccent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
                MouseArea {
                    id: authMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submit()
                }
            }

            Rectangle {
                anchors.right: authBtn.left
                anchors.rightMargin: 10
                width: 96
                height: 42
                radius: 21
                color: cancelMa.containsMouse ? Theme.tileHi : Theme.tile

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }
                MouseArea {
                    id: cancelMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AuthState.cancel()
                }
            }
        }
    }
}
