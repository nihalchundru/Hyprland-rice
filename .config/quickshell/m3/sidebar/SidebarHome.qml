import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.tokens
import qs.services
import qs.components
import qs.notifications
import qs.panel

Page {
    id: page
    readonly property var todos: Array.from(M3Config.todos || [])
    function saveTodos(a) { M3Config.todos = a }

    component QToggle: M3Button {
        id: self
        property bool on: false
        signal act()
        Layout.fillWidth: true
        variant: "tonal"
        toggle: true
        onClicked: act()
        Binding { target: self; property: "checked"; value: self.on }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: col.implicitHeight + 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: col
            width: parent.width
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 92
                radius: 28
                color: M3Colors.primaryContainer
                clip: true
                MorphShape { x: parent.width - 96; y: -30; size: 130; shape: "cookie12Sided"; color: M3Colors.primary; opacity: 0.3 }
                Column {
                    x: 20; anchors.verticalCenter: parent.verticalCenter
                    M3Text { text: Clock.time; role: M3Type.headlineLarge; color: M3Colors.fgPrimaryContainer }
                    M3Text { text: Clock.dateLong; role: M3Type.bodyMedium; color: M3Colors.fgPrimaryContainer }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                QToggle { icon: Network.wifiEnabled ? "wifi" : "wifi_off"; on: Network.wifiEnabled; onAct: Network.toggleWifi() }
                QToggle { icon: Bt.enabled ? "bluetooth" : "bluetooth_disabled"; on: Bt.enabled; enabled: Bt.available; onAct: Bt.toggle() }
                QToggle { icon: Notifs.dnd ? "notifications_off" : "do_not_disturb_on"; on: Notifs.dnd; onAct: Notifs.dnd = !Notifs.dnd }
                QToggle { icon: M3Config.mode === "dark" ? "dark_mode" : "light_mode"; on: M3Config.mode === "dark"; onAct: M3Config.mode = M3Config.mode === "dark" ? "light" : "dark" }
                QToggle { icon: Audio.micMuted ? "mic_off" : "mic"; on: !Audio.micMuted; onAct: Audio.toggleMic() }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 8
                M3Button { icon: Audio.icon; variant: "text"; size: "s"; onClicked: Audio.toggleMute() }
                M3Slider { id: vol; Layout.fillWidth: true; value: Audio.volume; onMoved: v => Audio.setVolume(v) }
                Binding { target: vol; property: "value"; value: Audio.volume }
            }
            RowLayout {
                Layout.fillWidth: true
                visible: Brightness.available
                spacing: 8
                Icon { Layout.preferredWidth: 40; name: Brightness.icon; size: 24; color: M3Colors.primary }
                M3Slider { id: bri; Layout.fillWidth: true; value: Brightness.value; onMoved: v => Brightness.set(v) }
                Binding { target: bri; property: "value"; value: Brightness.value }
            }

            Rectangle {   // to-do
                Layout.fillWidth: true
                implicitHeight: tcol.implicitHeight + 28
                radius: 28
                color: M3Colors.surfaceContainerHigh
                ColumnLayout {
                    id: tcol
                    x: 16; y: 14
                    width: parent.width - 32
                    spacing: 6
                    M3Text { text: "To-do"; role: M3Type.titleMedium; color: M3Colors.primary }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 44
                            radius: 22
                            color: M3Colors.surfaceContainerHighest
                            M3Text { visible: todoIn.text === ""; x: 16; anchors.verticalCenter: parent.verticalCenter; text: "Add a task"; color: M3Colors.fgSurfaceVariant }
                            TextInput {
                                id: todoIn
                                anchors.fill: parent
                                anchors.leftMargin: 16; anchors.rightMargin: 16
                                verticalAlignment: TextInput.AlignVCenter
                                color: M3Colors.fgSurface
                                font.family: M3Type.family
                                font.pixelSize: 14
                                clip: true
                                onAccepted: addBtn.clicked()
                            }
                        }
                        M3Button {
                            id: addBtn
                            icon: "add"; variant: "filled"
                            onClicked: {
                                const t = todoIn.text.trim()
                                if (t !== "") page.saveTodos(page.todos.concat([{ text: t, done: false }]))
                                todoIn.text = ""
                            }
                        }
                    }
                    Repeater {
                        model: page.todos
                        RowLayout {
                            id: tr
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            spacing: 4
                            M3Button { icon: tr.modelData.done ? "check_circle" : "radio_button_unchecked"; variant: "text"; size: "xs"; onClicked: page.saveTodos(page.todos.map((t, i) => i === tr.index ? { text: t.text, done: !t.done } : t)) }
                            M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: tr.modelData.text; font.strikeout: tr.modelData.done; color: tr.modelData.done ? M3Colors.fgSurfaceVariant : M3Colors.fgSurface }
                            M3Button { icon: "close"; variant: "text"; size: "xs"; onClicked: page.saveTodos(page.todos.filter((t, i) => i !== tr.index)) }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                M3Text { Layout.fillWidth: true; text: "Recent notifications"; role: M3Type.titleMedium; color: M3Colors.primary }
                M3Button { text: "Inbox"; icon: "inbox"; variant: "text"; size: "xs"; onClicked: { UiState.sidebarOpen = false; UiState.mainPage = 4; UiState.calendarOpen = true } }
            }
            M3Text { visible: Notifs.count === 0; text: "All caught up"; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant }
            Repeater {
                model: Notifs.all.slice().reverse().slice(0, 3)
                NotificationCard {
                    required property var modelData
                    Layout.fillWidth: true
                    notif: modelData
                    onCloseRequested: modelData.dismiss()
                    onActivated: modelData.dismiss()
                }
            }
        }
    }
}
