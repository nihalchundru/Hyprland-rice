import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.tokens
import qs.services
import qs.components

Page {
    id: page
    property var view: new Date()
    readonly property string todayKey: Qt.formatDate(Clock.now, "yyyyMMdd")
    readonly property var cells: {
        const y = view.getFullYear(), m = view.getMonth(), first = new Date(y, m, 1).getDay(), out = []
        for (let i = 0; i < 42; i++) {
            const d = new Date(y, m, 1 - first + i)
            out.push({ day: d.getDate(), inMonth: d.getMonth() === m, today: Qt.formatDate(d, "yyyyMMdd") === todayKey })
        }
        return out
    }
    readonly property string greeting: {
        const h = Clock.now.getHours()
        return (h < 5 ? "Good night" : h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening") + ", " + Quickshell.env("USER")
    }
    function shift(n) { view = new Date(view.getFullYear(), view.getMonth() + n, 1) }
    function go(prop) { UiState.calendarOpen = false; UiState[prop] = true }
    onActiveChanged: if (active) view = new Date()

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Rectangle {   // calendar
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            radius: 28
            color: M3Colors.surfaceContainerHigh
            ColumnLayout {
                x: 16; y: 16
                width: parent.width - 32
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    M3Text { Layout.fillWidth: true; text: Qt.formatDate(page.view, "MMMM yyyy"); role: M3Type.titleLarge }
                    M3Button { icon: "today"; variant: "text"; size: "xs"; onClicked: page.view = new Date() }
                    M3Button { icon: "chevron_left"; variant: "text"; size: "xs"; onClicked: page.shift(-1) }
                    M3Button { icon: "chevron_right"; variant: "text"; size: "xs"; onClicked: page.shift(1) }
                }
                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    columns: 7
                    rowSpacing: 4; columnSpacing: 2
                    Repeater {
                        model: ["S", "M", "T", "W", "T", "F", "S"]
                        M3Text { required property string modelData; text: modelData; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant; horizontalAlignment: Text.AlignHCenter; Layout.preferredWidth: 42 }
                    }
                    Repeater {
                        model: page.cells
                        Item {
                            id: cell
                            required property var modelData
                            Layout.preferredWidth: 42; Layout.preferredHeight: 44
                            MorphShape { anchors.centerIn: parent; size: cell.modelData.today ? 40 : 28; shape: "cookie9Sided"; color: M3Colors.primary; opacity: cell.modelData.today ? 1 : 0; FadeBehavior on opacity {} }
                            M3Text { anchors.centerIn: parent; text: cell.modelData.day; role: M3Type.bodyMedium; color: cell.modelData.today ? M3Colors.fgPrimary : cell.modelData.inMonth ? M3Colors.fgSurface : M3Colors.outline }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 132
                radius: 28
                color: M3Colors.primaryContainer
                clip: true
                MorphShape { x: parent.width - 110; y: -36; size: 150; shape: "cookie12Sided"; color: M3Colors.primary; opacity: 0.3 }
                Column {
                    x: 22; anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    M3Text { text: Clock.time; role: M3Type.displaySmall; color: M3Colors.fgPrimaryContainer }
                    M3Text { text: Clock.dateLong; role: M3Type.titleSmall; color: M3Colors.fgPrimaryContainer }
                    M3Text { text: page.greeting + "  ·  up " + SysStats.uptime; role: M3Type.bodySmall; color: M3Colors.fgPrimaryContainer }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {   // weather
                    Layout.preferredWidth: 190
                    Layout.fillHeight: true
                    implicitHeight: 120
                    visible: Weather.ready
                    radius: 28
                    color: M3Colors.tertiaryContainer
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Icon { anchors.horizontalCenter: parent.horizontalCenter; name: Weather.icon; size: 44; fill: 1; color: M3Colors.fgTertiaryContainer }
                        M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Weather.temp + "\u00b0"; role: M3Type.headlineLarge; color: M3Colors.fgTertiaryContainer }
                        M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Weather.desc; role: M3Type.titleSmall; color: M3Colors.fgTertiaryContainer }
                        M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: Weather.city; role: M3Type.bodySmall; color: M3Colors.fgTertiaryContainer }
                    }
                }

                ColumnLayout {   // CPU / RAM / Battery, each in its own rounded card
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: [
                            { label: "CPU", icon: "speed", v: SysStats.cpu, show: true },
                            { label: "RAM", icon: "memory", v: SysStats.mem, show: true },
                            { label: "Battery", icon: Battery.icon, v: Battery.percentage, show: Battery.present }
                        ].filter(x => x.show)
                        Rectangle {
                            id: sc
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 60
                            radius: 22
                            color: M3Colors.surfaceContainerHigh
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16; anchors.rightMargin: 18
                                spacing: 12
                                Icon { name: sc.modelData.icon; size: 24; fill: 1; color: M3Colors.primary }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    RowLayout {
                                        Layout.fillWidth: true
                                        M3Text { Layout.fillWidth: true; text: sc.modelData.label; role: M3Type.labelLarge }
                                        M3Text { text: Math.round(sc.modelData.v * 100) + "%"; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant }
                                    }
                                    M3Progress { Layout.fillWidth: true; thickness: 8; value: sc.modelData.v; showStop: false }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {   // now playing mini card
                Layout.fillWidth: true
                implicitHeight: 84
                radius: 28
                color: M3Colors.surfaceContainerHigh
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: UiState.mainPage = 1 }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    spacing: 12
                    Item {
                        Layout.preferredWidth: 56; Layout.preferredHeight: 56
                        RoundedImage { id: miniArt; anchors.fill: parent; radius: 18; source: Media.art }
                        MorphShape { visible: !miniArt.ready; size: 56; shape: Media.playing ? "cookie9Sided" : "circle"; color: M3Colors.tertiaryContainer }
                        Icon { visible: !miniArt.ready; anchors.centerIn: parent; name: "music_note"; size: 24; color: M3Colors.fgTertiaryContainer; fill: 1 }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: Media.has ? Media.title : "Nothing playing"; role: M3Type.titleSmall }
                        M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: Media.has ? Media.artist : "Open the Media tab"; role: M3Type.bodySmall; color: M3Colors.fgSurfaceVariant }
                    }
                    M3Button { visible: Media.has; icon: "skip_previous"; variant: "text"; onClicked: Media.previous() }
                    M3Button { visible: Media.has; icon: Media.playing ? "pause" : "play_arrow"; variant: "filled"; round: !Media.playing; onClicked: Media.toggle() }
                    M3Button { visible: Media.has; icon: "skip_next"; variant: "text"; onClicked: Media.next() }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                M3Button { Layout.fillWidth: true; text: "Apps"; icon: "apps"; variant: "tonal"; onClicked: page.go("launcherOpen") }
                M3Button { Layout.fillWidth: true; text: "Wallpaper"; icon: "wallpaper"; variant: "tonal"; onClicked: page.go("wallpaperOpen") }
                M3Button { Layout.fillWidth: true; text: "Overview"; icon: "grid_view"; variant: "tonal"; onClicked: page.go("overviewOpen") }
                M3Button { Layout.fillWidth: true; text: "Lock"; icon: "lock"; variant: "tonal"; onClicked: page.go("locked") }
            }
        }
    }
}
