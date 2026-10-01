import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit
import Quickshell.Io

PanelWindow {
    id: polkitRoot

    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8"
    })

    // ============================================================
    // Dynamic theme colors
    // ============================================================

    FileView {
        id: colorsLoaderPolkit

        path: Quickshell.env("HOME")
              + "/.config/quickshell/topbar/colors.json"

        watchChanges: true

        onLoaded: {
            try {
                // IMPORTANT: text() must have parentheses
                var parsed = JSON.parse(text())
                polkitRoot.colors = parsed
            } catch (e) {
                console.log(
                    "PolkitAuth: failed to parse colors.json:",
                    e
                )
            }
        }

        onLoadFailed: {
            console.log(
                "PolkitAuth: colors.json fallback used:",
                error
            )
        }

        onFileChanged: reload()
    }

    function c(key) {
        return (
            polkitRoot.colors &&
            polkitRoot.colors[key]
        )
            ? polkitRoot.colors[key]
            : "#888888"
    }

    readonly property color colorBg: c("bg")
    readonly property color colorSurface: c("surface")
    readonly property color colorAccent: c("accent")
    readonly property color colorText: c("text")
    readonly property color colorSub: c("sub")
    readonly property color colorAccentText: c("bg")
    readonly property color colorBorder: c("sub")

    // ============================================================
    // Polkit state
    // ============================================================

    property var currentPolkitRequest: null
    property bool open: false
    property string openPolkitMessage: ""

    // ============================================================
    // Layer
    // ============================================================

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-polkit-auth"

    WlrLayershell.keyboardFocus:
        polkitRoot.open
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"
    exclusiveZone: -1
    visible: polkitRoot.open

    // ============================================================
    // Polkit Agent
    // ============================================================

    PolkitAgent {
        id: systemPolkitAgent

        onAuthenticationRequestStarted: {
            console.log("POLKIT: request started")

            var flow = systemPolkitAgent.flow

            if (!flow) {
                console.log("POLKIT: no active flow")
                return
            }

            polkitRoot.currentPolkitRequest = flow
            polkitRoot.open = true

            authPopup.visible = true

            passwordField.text = ""
            passwordField.forceActiveFocus()

            var prompt = flow.inputPrompt || ""
            var message = flow.message || ""
            var supplementary = flow.supplementaryMessage || ""

            if (prompt.length > 0)
                polkitRoot.openPolkitMessage = prompt
            else if (supplementary.length > 0)
                polkitRoot.openPolkitMessage = supplementary
            else if (message.length > 0)
                polkitRoot.openPolkitMessage = message
            else
                polkitRoot.openPolkitMessage = "Authentication required"

            console.log(
                "POLKIT Active Prompt Message:",
                polkitRoot.openPolkitMessage
            )
        }
    }

    // ============================================================
    // Polkit request signals
    // ============================================================

    Connections {
        target: polkitRoot.currentPolkitRequest

        function onInputPromptChanged() {
            var flow = polkitRoot.currentPolkitRequest
            if (!flow)
                return

            console.log(
                "POLKIT prompt changed:",
                flow.inputPrompt
            )

            var prompt = flow.inputPrompt || ""
            var supplementary = flow.supplementaryMessage || ""
            var message = flow.message || ""

            if (message.length > 0)
                polkitRoot.openPolkitMessage = message
            else if (supplementary.length > 0)
                polkitRoot.openPolkitMessage = supplementary
            else if (prompt.length > 0)
                polkitRoot.openPolkitMessage = prompt

            if (flow.isResponseRequired)
                passwordField.forceActiveFocus()
        }

        function onSupplementaryMessageChanged() {
            var flow = polkitRoot.currentPolkitRequest
            if (!flow)
                return

            var supplementary =
                flow.supplementaryMessage || ""

            if (supplementary.length > 0)
                polkitRoot.openPolkitMessage = supplementary
        }

        function onAuthenticationSucceeded() {
            console.log(
                "POLKIT: authentication succeeded"
            )
            console.log(
                "!!!!!!!! POLKIT SUCCESS SIGNAL FIRED !!!!!!!!"
            )

            authPopup.visible = false
            passwordField.text = ""

            Qt.callLater(function() {
                if (!authPopup.visible) {
                    polkitRoot.currentPolkitRequest = null
                    polkitRoot.openPolkitMessage = ""
                    polkitRoot.open = false
                }
            })
        }

        function onAuthenticationFailed() {
            console.log(
                "POLKIT: authentication failed"
            )

            passwordField.text = ""
            passwordField.forceActiveFocus()

            var flow = polkitRoot.currentPolkitRequest

            if (!flow) {
                polkitRoot.openPolkitMessage =
                    "Authentication failed"
                return
            }

            var supplementary =
                flow.supplementaryMessage || ""

            var prompt =
                flow.inputPrompt || ""

            var message =
                flow.message || ""

            if (supplementary.length > 0)
                polkitRoot.openPolkitMessage = supplementary
            else if (prompt.length > 0)
                polkitRoot.openPolkitMessage = prompt
            else if (message.length > 0)
                polkitRoot.openPolkitMessage = message
            else
                polkitRoot.openPolkitMessage =
                    "Authentication failed"
        }

        function onAuthenticationRequestCancelled() {
            console.log(
                "POLKIT: authentication request cancelled"
            )

            authPopup.visible = false
            passwordField.text = ""

            polkitRoot.currentPolkitRequest = null
            polkitRoot.openPolkitMessage = ""
            polkitRoot.open = false
        }
    }

    // ============================================================
    // Top-center notch
    // ============================================================

    Item {
        id: notchContainer

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: 580
        height: authPopup.visible
                ? authPopup.height
                : 34

        Rectangle {
            id: authPopup

            visible: false

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            width: 580
            height: authContent.implicitHeight + 48

            // Flat against the top of the screen
            radius: 0
            bottomLeftRadius: 30
            bottomRightRadius: 30

            color: "#000000"

            z: 10

            // ====================================================
            // Close
            // ====================================================

            function closeAndClear() {
                if (polkitRoot.currentPolkitRequest) {
                    console.log("POLKIT: cancelling")

                    polkitRoot.currentPolkitRequest
                        .cancelAuthenticationRequest()

                    return
                }

                authPopup.visible = false
                passwordField.text = ""

                polkitRoot.currentPolkitRequest = null
                polkitRoot.openPolkitMessage = ""
                polkitRoot.open = false
            }

            // ====================================================
            // Content
            // ====================================================

            ColumnLayout {
                id: authContent

                anchors.fill: parent
                anchors.margins: 24

                spacing: 16

                // ------------------------------------------------
                // Header
                // ------------------------------------------------

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        radius: 20
                        color: polkitRoot.colorAccent

                        Text {
                            anchors.centerIn: parent

                            text: "󰌾"

                            color:
                                polkitRoot.colorAccentText

                            font.pixelSize: 17
                            font.family:
                                "JetBrainsMono Nerd Font"
                        }
                    }

                    Text {
                        text: "Authentication required"

                        color:
                            polkitRoot.colorText

                        font.pixelSize: 17
                        font.bold: true
                        font.family:
                            "JetBrainsMono Nerd Font"
                    }
                }

                // ------------------------------------------------
                // Info
                // ------------------------------------------------

                Rectangle {
                    Layout.fillWidth: true

                    Layout.preferredHeight:
                        infoCol.implicitHeight + 24

                    radius: 18

                    color:
                        polkitRoot.colorSurface

                    ColumnLayout {
                        id: infoCol

                        anchors.fill: parent
                        anchors.margins: 14

                        spacing: 4

                        Text {
                            Layout.fillWidth: true

                            text:
                                polkitRoot.openPolkitMessage.length > 0
                                    ? polkitRoot.openPolkitMessage
                                    : "Authentication required"

                            color:
                                polkitRoot.colorText

                            font.pixelSize: 13
                            font.bold: true
                            font.family:
                                "JetBrainsMono Nerd Font"

                            wrapMode:
                                Text.WordWrap
                        }

                        Text {
                            Layout.fillWidth: true

                            visible:
                                polkitRoot.currentPolkitRequest &&
                                (
                                    polkitRoot.currentPolkitRequest.actionId
                                    || ""
                                ).length > 0

                            text:
                                polkitRoot.currentPolkitRequest
                                    ? (
                                        polkitRoot.currentPolkitRequest.actionId
                                        || ""
                                      )
                                    : ""

                            color:
                                polkitRoot.colorSub

                            font.pixelSize: 11
                            font.family:
                                "JetBrainsMono Nerd Font"

                            elide:
                                Text.ElideRight
                        }
                    }
                }

                // ------------------------------------------------
                // Password
                // ------------------------------------------------

                ColumnLayout {
                    Layout.fillWidth: true

                    spacing: 6

                    Text {
                        text: "Response"

                        color:
                            polkitRoot.colorSub

                        font.pixelSize: 11
                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52

                        radius: 26

                        color: "#000000"

                        border.color:
                            passwordField.activeFocus
                                ? polkitRoot.colorAccent
                                : polkitRoot.colorBorder

                        border.width: 1.5

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 6
                            anchors.rightMargin: 16

                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36

                                radius: 18

                                color:
                                    polkitRoot.colorAccent

                                Text {
                                    anchors.centerIn: parent

                                    text: "󰌾"

                                    color:
                                        polkitRoot.colorAccentText

                                    font.pixelSize: 14
                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                }
                            }

                            TextInput {
                                id: passwordField

                                Layout.fillWidth: true

                                echoMode:
                                    polkitRoot.currentPolkitRequest
                                        ? (
                                            polkitRoot.currentPolkitRequest.responseVisible
                                                ? TextInput.Normal
                                                : TextInput.Password
                                          )
                                        : TextInput.Password

                                color:
                                    polkitRoot.colorText

                                font.pixelSize: 14
                                font.family:
                                    "JetBrainsMono Nerd Font"

                                verticalAlignment:
                                    TextInput.AlignVCenter

                                onAccepted: {
                                    var flow =
                                        polkitRoot.currentPolkitRequest

                                    if (!flow) {
                                        console.log(
                                            "POLKIT Error: No active authentication request."
                                        )
                                        return
                                    }

                                    console.log(
                                        "POLKIT: Submitting password..."
                                    )

                                    flow.submit(
                                        passwordField.text
                                    )

                                    passwordField.text = ""
                                }
                            }
                        }
                    }
                }

                // ------------------------------------------------
                // Buttons
                // ------------------------------------------------

                RowLayout {
                    Layout.fillWidth: true

                    spacing: 10

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Cancel"

                        color:
                            polkitRoot.colorSub

                        font.pixelSize: 13
                        font.family:
                            "JetBrainsMono Nerd Font"

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                authPopup.closeAndClear()
                        }
                    }

                    Rectangle {
                        id: authConfirmBtn

                        Layout.preferredWidth:
                            authBtnText.implicitWidth + 36

                        Layout.preferredHeight: 40

                        radius: 20

                        color:
                            polkitRoot.colorAccent

                        signal clicked()

                        onClicked: {
                            var flow =
                                polkitRoot.currentPolkitRequest

                            if (!flow) {
                                console.log(
                                    "POLKIT Error: No active authentication request."
                                )
                                return
                            }

                            console.log(
                                "POLKIT: submitting response"
                            )

                            flow.submit(
                                passwordField.text
                            )

                            passwordField.text = ""
                        }

                        Text {
                            id: authBtnText

                            anchors.centerIn: parent

                            text: "Authenticate"

                            color:
                                polkitRoot.colorAccentText

                            font.pixelSize: 13
                            font.bold: true
                            font.family:
                                "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                authConfirmBtn.clicked()
                        }
                    }
                }
            }
        }
    }
}