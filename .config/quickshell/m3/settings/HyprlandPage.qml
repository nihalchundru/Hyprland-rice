import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    id: page
    readonly property var cur: Displays.monitors.find(m => m.name === Displays.selected) || null
    property bool dirty: false
    property string dMode: ""
    property int dX: 0
    property int dY: 0
    property int dScale: 100
    property int dRot: 0
    property bool dOn: true

    function load() {
        const m = cur
        if (!m) return
        let best = "", bd = 1e9
        for (const s of m.modes) {
            const p = s.split("@")
            if (p[0] !== m.width + "x" + m.height) continue
            const d = Math.abs(parseFloat(p[1]) - m.refresh)
            if (d < bd) { bd = d; best = s }
        }
        dMode = best !== "" ? best : m.width + "x" + m.height + "@" + m.refresh.toFixed(2) + "Hz"
        dX = m.x; dY = m.y; dScale = Math.round(m.scale * 100); dRot = m.transform; dOn = !m.disabled
        dirty = false
    }
    function apply() {
        Displays.apply({ name: cur.name, mode: dMode.replace("Hz", ""), x: dX, y: dY, scale: dScale / 100, transform: dRot, disabled: !dOn })
        dirty = false
    }
    Component.onCompleted: { Displays.refresh(); load() }
    onActiveChanged: if (active) Displays.refresh()
    Connections {
        target: Displays
        function onSelectedChanged() { page.load() }
        function onMonitorsChanged() { if (!page.dirty) page.load() }
    }

    SScroll {
        SCard {
            title: "Displays"
            Item {
                id: prev
                Layout.fillWidth: true
                implicitHeight: 190
                readonly property var b: {
                    const ms = Displays.monitors
                    if (ms.length === 0) return { x: 0, y: 0, f: 1, ox: 0, oy: 0 }
                    let x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9
                    for (const m of ms) {
                        const sw = (m.transform % 2 ? m.height : m.width) / m.scale, sh = (m.transform % 2 ? m.width : m.height) / m.scale
                        x0 = Math.min(x0, m.x); y0 = Math.min(y0, m.y); x1 = Math.max(x1, m.x + sw); y1 = Math.max(y1, m.y + sh)
                    }
                    const f = Math.min((width - 24) / (x1 - x0), (height - 24) / (y1 - y0))
                    return { x: x0, y: y0, f: f, ox: (width - (x1 - x0) * f) / 2, oy: (height - (y1 - y0) * f) / 2 }
                }
                Repeater {
                    model: Displays.monitors
                    Rectangle {
                        id: mr
                        required property var modelData
                        readonly property bool sel: Displays.selected === modelData.name
                        x: prev.b.ox + (modelData.x - prev.b.x) * prev.b.f
                        y: prev.b.oy + (modelData.y - prev.b.y) * prev.b.f
                        width: (modelData.transform % 2 ? modelData.height : modelData.width) / modelData.scale * prev.b.f - 4
                        height: (modelData.transform % 2 ? modelData.width : modelData.height) / modelData.scale * prev.b.f - 4
                        radius: 14
                        color: sel ? M3Colors.primaryContainer : M3Colors.surfaceContainerHigh
                        border.width: sel ? 2 : 0
                        border.color: M3Colors.primary
                        opacity: modelData.disabled ? 0.5 : 1
                        ColorBehavior on color {}
                        Column {
                            anchors.centerIn: parent
                            Icon { anchors.horizontalCenter: parent.horizontalCenter; name: "desktop_windows"; size: 22; color: mr.sel ? M3Colors.fgPrimaryContainer : M3Colors.fgSurfaceVariant }
                            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: mr.modelData.name; role: M3Type.labelLarge; color: mr.sel ? M3Colors.fgPrimaryContainer : M3Colors.fgSurface }
                            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: mr.modelData.width + "x" + mr.modelData.height; role: M3Type.labelSmall; color: mr.sel ? M3Colors.fgPrimaryContainer : M3Colors.fgSurfaceVariant }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Displays.selected = mr.modelData.name }
                    }
                }
            }
        }

        Rectangle {   // revert countdown
            Layout.fillWidth: true
            visible: Displays.confirming
            implicitHeight: 64
            radius: 24
            color: M3Colors.tertiaryContainer
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20; anchors.rightMargin: 12
                spacing: 12
                M3Text { Layout.fillWidth: true; text: "Keep these display settings? Reverting in " + Displays.secondsLeft + " s"; role: M3Type.titleSmall; color: M3Colors.fgTertiaryContainer }
                M3Button { text: "Revert"; variant: "text"; onClicked: Displays.revert() }
                M3Button { text: "Keep"; variant: "filled"; onClicked: Displays.keep() }
            }
        }

        SCard {
            visible: page.cur !== null
            title: page.cur ? page.cur.name + (page.cur.desc ? "  ·  " + page.cur.desc : "") : ""
            SwitchRow { icon: "monitor"; title: "Enabled"; checked: page.dOn; onToggled: v => { page.dOn = v; page.dirty = true } }
            DropdownRow {
                icon: "aspect_ratio"; title: "Resolution and refresh rate"
                options: page.cur ? page.cur.modes : []
                value: page.dMode
                onPicked: v => { page.dMode = v; page.dirty = true }
            }
            ChipsRow { icon: "screen_rotation"; title: "Orientation"; options: ["Normal", "90\u00b0", "180\u00b0", "270\u00b0"]; value: ["Normal", "90\u00b0", "180\u00b0", "270\u00b0"][page.dRot] || "Normal"; onPicked: v => { page.dRot = ["Normal", "90\u00b0", "180\u00b0", "270\u00b0"].indexOf(v); page.dirty = true } }
            StepperRow { icon: "zoom_in"; title: "Scale"; value: page.dScale; step: 5; min: 50; max: 400; suffix: "%"; onPicked: v => { page.dScale = v; page.dirty = true } }
            StepperRow { icon: "swap_horiz"; title: "Position X"; value: page.dX; step: 10; min: -10000; max: 10000; onPicked: v => { page.dX = v; page.dirty = true } }
            StepperRow { icon: "swap_vert"; title: "Position Y"; value: page.dY; step: 10; min: -10000; max: 10000; onPicked: v => { page.dY = v; page.dirty = true } }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                Layout.bottomMargin: 6
                spacing: 8
                Item { Layout.fillWidth: true }
                M3Button { text: "Reset"; variant: "text"; enabled: page.dirty; onClicked: page.load() }
                M3Button { text: "Apply"; icon: "check"; variant: "filled"; enabled: page.dirty; onClicked: page.apply() }
            }
        }

        SCard {
            title: "Hyprland"
            SRow { icon: "keyboard"; title: "Keybinds"; sub: "Searchable list of your binds"; M3Button { text: "Open"; variant: "tonal"; onClicked: { UiState.settingsOpen = false; UiState.mainPage = 3; UiState.calendarOpen = true } } }
            SRow { icon: "refresh"; title: "Reload Hyprland config"; M3Button { text: "Reload"; variant: "tonal"; onClicked: Quickshell.execDetached(["hyprctl", "reload"]) } }
        }
    }
}
