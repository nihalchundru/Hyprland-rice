import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// Lock Screen Style Switcher Window
// Run with: qs -p ~/.config/quickshell/lockscreen-switcher/shell.qml
ShellRoot {
    id: root

    property string selectedStyleId: "veil"
    property string activeStyleId: "veil"
    property bool showToast: false
    property string toastText: ""

    // Style Metadata map
    readonly property var stylesInfo: ({
        "veil":    { name: "Veil",    tag: "Default" },
        "tessera": { name: "Tessera", tag: "Bento Grid" },
        "bloom":   { name: "Bloom",   tag: "Digits" },
        "orbit":   { name: "Orbit",   tag: "Dial" },
        "darkroom":{ name: "Darkroom",tag: "Polaroid" },
        "deck":    { name: "Deck",    tag: "Media Island" }
    })

    // Available style keys in cycle order
    readonly property var availableList: ["veil", "tessera", "deck"]

    function selectNext() {
        const idx = availableList.indexOf(selectedStyleId);
        const nextIdx = (idx + 1) % availableList.length;
        selectedStyleId = availableList[nextIdx];
    }

    function selectPrev() {
        const idx = availableList.indexOf(selectedStyleId);
        const prevIdx = (idx - 1 + availableList.length) % availableList.length;
        selectedStyleId = availableList[prevIdx];
    }

    // 1. Read currently active style from lockscreen.json on startup
    Process {
        id: readActiveProc
        command: ["sh", "-c", "cat ~/.config/quickshell/lockscreen.json 2>/dev/null | grep -o '\"current_style\": *\"[^\"]*\"' | cut -d'\"' -f4 || (readlink ~/.config/quickshell/current_lockscreen 2>/dev/null | grep -q lockscreen3 && echo deck || (readlink ~/.config/quickshell/current_lockscreen 2>/dev/null | grep -q lockscreen2 && echo tessera || echo veil))"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s === "tessera" || s === "veil" || s === "deck") {
                    root.activeStyleId = s;
                    root.selectedStyleId = s;
                }
            }
        }
    }

    // 2. Apply script execution
    Process {
        id: applyProc
        running: false
        onExited: exitCode => {
            root.activeStyleId = root.selectedStyleId;
            root.toastText = "Applied " + (root.stylesInfo[root.selectedStyleId]?.name || "style") + " lockscreen!";
            root.showToast = true;
            closeTimer.restart();
        }
    }

    function applySelected() {
        applyProc.command = [
            "sh", "-c",
            "bash " + Quickshell.env("HOME") + "/.config/quickshell/lockscreen-switcher/apply_style.sh " + root.selectedStyleId
        ];
        applyProc.running = true;
    }

    Timer {
        id: closeTimer
        interval: 900
        repeat: false
        onTriggered: Qt.quit()
    }

    PanelWindow {
        id: win
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        // Keyboard navigation
        Item {
            focus: true
            anchors.fill: parent

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    Qt.quit();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    root.selectPrev();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right) {
                    root.selectNext();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.applySelected();
                    event.accepted = true;
                }
            }
        }

        // Fullscreen Blurred Background
        Rectangle {
            anchors.fill: parent
            color: "#120e14"

            Image {
                id: bgWall
                anchors.fill: parent
                source: "file://" + Quickshell.env("HOME") + "/.config/rofi/images/a.png"
                fillMode: Image.PreserveAspectCrop
                visible: false
                asynchronous: true
            }

            MultiEffect {
                source: bgWall
                anchors.fill: parent
                visible: bgWall.status === Image.Ready
                blurEnabled: true
                blur: 1.0
                blurMax: 64
                scale: 1.05
            }

            // Dark Scrim
            Rectangle {
                anchors.fill: parent
                color: "#0a070c"
                opacity: 0.65
            }
        }

        // Main Layout Container
        Item {
            anchors.fill: parent

            // 1. Top Header
            SwitcherHeader {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                styleName: root.stylesInfo[root.selectedStyleId]?.name || "Style"
                styleTag: root.stylesInfo[root.selectedStyleId]?.tag || ""
                onCloseRequested: Qt.quit()
                onApplyRequested: root.applySelected()
            }

            // 2. Center Preview Stage
            PreviewStage {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -38
                selectedStyleId: root.selectedStyleId
                onPreviousRequested: root.selectPrev()
                onNextRequested: root.selectNext()
            }

            // 3. Bottom Carousel
            StylesCarousel {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 32
                anchors.horizontalCenter: parent.horizontalCenter
                selectedStyleId: root.selectedStyleId
                activeStyleId: root.activeStyleId
                onStyleSelected: id => root.selectedStyleId = id
            }

            // Toast Alert Overlay
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: 80
                anchors.horizontalCenter: parent.horizontalCenter
                height: 38
                width: toastRow.implicitWidth + 28
                radius: 19
                color: "#f3b3c8"
                opacity: root.showToast ? 1.0 : 0.0
                scale: root.showToast ? 1.0 : 0.8
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                Row {
                    id: toastRow
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "✓"; color: "#241219"; font.pixelSize: 14; font.bold: true }
                    Text { text: root.toastText; color: "#241219"; font.pixelSize: 13; font.weight: Font.Bold }
                }
            }
        }
    }
}
