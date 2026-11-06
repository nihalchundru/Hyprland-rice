import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.tokens
import qs.services
import qs.components

// Toggle: qs -c m3 ipc call ui toggleLauncher    Prefixes: "=" calculator (or just type math), ">" run command
PanelWindow {
    id: win
    readonly property bool open: UiState.launcherOpen
    readonly property var focusedScreen: {
        const m = Hyprland.focusedMonitor
        const s = m ? Quickshell.screens.find(x => x.name === m.name) : null
        return s ? s : Quickshell.screens[0]
    }
    screen: focusedScreen
    WlrLayershell.namespace: "m3-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: card.opacity > 0.01

    property var results: Apps.search(input.text)

    function activate(r) {
        if (!r) return
        UiState.launcherOpen = false
        if (r.kind === "app") r.entry.execute()
        else if (r.kind === "calc") Quickshell.clipboardText = r.value
        else if (r.kind === "run") Quickshell.execDetached(r.term ? Apps.terminalCmd(r.cmd) : ["sh", "-c", r.cmd])
    }

    onOpenChanged: if (open) { input.text = ""; list.currentIndex = 0; focusTimer.restart() }
    Timer { id: focusTimer; interval: 60; onTriggered: input.forceActiveFocus() }

    Rectangle {
        anchors.fill: parent
        color: M3Colors.scrim
        opacity: win.open ? 0.32 : 0
        FadeBehavior on opacity { time: M3Motion.medium1 }
        MouseArea { anchors.fill: parent; onClicked: UiState.launcherOpen = false }
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.16
        width: 640
        readonly property int rows: Math.min(win.results.length, 8)
        height: 12 + 56 + (rows > 0 ? 8 + rows * 56 : 0) + 12
        radius: M3Shape.extraLarge
        color: M3Colors.surfaceContainerHigh
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.92
        transformOrigin: Item.Top
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on scale { eps: 0.002 }
        SpatialBehavior on height {}
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 28
                color: M3Colors.surfaceContainerHighest
                Icon { id: sIcon; name: "search"; size: 24; color: M3Colors.fgSurfaceVariant; x: 18; anchors.verticalCenter: parent.verticalCenter }
                M3Text {
                    visible: input.text === ""
                    x: 54; anchors.verticalCenter: parent.verticalCenter
                    text: "Search apps    =  calculate    >  terminal    !  run"
                    color: M3Colors.fgSurfaceVariant
                    role: M3Type.bodyLarge
                }
                TextInput {
                    id: input
                    anchors.left: sIcon.right; anchors.leftMargin: 12
                    anchors.right: parent.right; anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    color: M3Colors.fgSurface
                    selectionColor: M3Colors.primary
                    selectedTextColor: M3Colors.fgPrimary
                    font.family: M3Type.family
                    font.pixelSize: 18
                    clip: true
                    onTextChanged: list.currentIndex = 0
                    Keys.onPressed: e => {
                        const ctrl = e.modifiers & Qt.ControlModifier
                        if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab || (ctrl && e.key === Qt.Key_J)) { list.incrementCurrentIndex(); e.accepted = true }
                        else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab || (ctrl && e.key === Qt.Key_K)) { list.decrementCurrentIndex(); e.accepted = true }
                        else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { win.activate(win.results[list.currentIndex]); e.accepted = true }
                        else if (e.key === Qt.Key_Escape) { UiState.launcherOpen = false; e.accepted = true }
                    }
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: win.results
                currentIndex: 0
                property bool mouseNav: false
                onCurrentIndexChanged: if (!mouseNav) positionViewAtIndex(currentIndex, ListView.Contain)
                boundsBehavior: Flickable.StopAtBounds
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 160
                highlightMoveVelocity: -1
                highlight: Rectangle { radius: 20; color: M3Colors.secondaryContainer }

                Rectangle {   // scroll indicator
                    parent: list
                    anchors.right: parent.right
                    width: 4; radius: 2
                    visible: list.contentHeight > list.height + 1
                    height: Math.max(24, list.height * list.height / Math.max(1, list.contentHeight))
                    y: list.contentHeight > 0 ? list.height * list.contentY / list.contentHeight : 0
                    color: M3Colors.outlineVariant
                }

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool current: ListView.isCurrentItem
                    width: list.width
                    height: 56

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14; anchors.rightMargin: 16
                        spacing: 14
                        Item {
                            Layout.preferredWidth: 36; Layout.preferredHeight: 36
                            Image {
                                visible: row.modelData.kind === "app"
                                anchors.fill: parent
                                sourceSize.width: 72; sourceSize.height: 72
                                source: row.modelData.kind === "app" ? Quickshell.iconPath(row.modelData.entry.icon, "application-x-executable") : ""
                            }
                            Icon {
                                visible: row.modelData.kind !== "app"
                                anchors.centerIn: parent
                                size: 28
                                name: row.modelData.kind === "calc" ? "calculate" : "terminal"
                                color: row.current ? M3Colors.fgSecondaryContainer : M3Colors.primary
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            M3Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: row.modelData.name
                                role: M3Type.titleSmall
                                color: row.current ? M3Colors.fgSecondaryContainer : M3Colors.fgSurface
                            }
                            M3Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                elide: Text.ElideRight
                                text: row.modelData.sub || ""
                                role: M3Type.bodySmall
                                color: M3Colors.fgSurfaceVariant
                            }
                        }
                        Icon { visible: row.current; name: "keyboard_return"; size: 18; color: M3Colors.fgSecondaryContainer }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: { list.mouseNav = true; list.currentIndex = row.index; list.mouseNav = false }
                        onClicked: win.activate(row.modelData)
                    }
                }
            }
        }
    }
}
