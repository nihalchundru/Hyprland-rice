import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    id: page
    readonly property var pins: Array.from(M3Config.pinned || [])
    SScroll {
        SCard {
            title: "Widgets"
            SwitchRow { icon: "widgets"; title: "Show desktop widgets"; checked: M3Config.widgetsEnabled; onToggled: v => M3Config.widgetsEnabled = v }
            SwitchRow { icon: "lock"; title: "Lock layout"; sub: "Stop widgets from being dragged"; checked: M3Config.widgetsLocked; onToggled: v => M3Config.widgetsLocked = v }
            SwitchRow { icon: "grid_on"; title: "Snap to grid"; checked: M3Config.widgetSnap; onToggled: v => M3Config.widgetSnap = v }
            SwitchRow { icon: "grid_4x4"; title: "Show grid while dragging"; checked: M3Config.widgetShowGrid; onToggled: v => M3Config.widgetShowGrid = v }
            StepperRow { icon: "straighten"; title: "Grid size"; value: M3Config.widgetGrid; step: 4; min: 8; max: 64; suffix: " px"; onPicked: v => M3Config.widgetGrid = v }
            SRow { icon: "edit"; title: "Edit widgets"; sub: "Add, remove and restyle widgets"; M3Button { text: "Open editor"; variant: "tonal"; onClicked: { UiState.settingsOpen = false; UiState.sidebarTab = 1; UiState.sidebarOpen = true } } }
        }
        SCard {
            title: "Dock"
            SwitchRow { icon: "visibility_off"; title: "Auto-hide"; sub: "Slide away until you hover the bottom edge"; checked: M3Config.dockAutoHide; onToggled: v => M3Config.dockAutoHide = v }
            SwitchRow { icon: "zoom_in"; title: "Magnification"; sub: "Enlarge the hovered icon"; checked: M3Config.dockMagnify; onToggled: v => M3Config.dockMagnify = v }
            M3Text { Layout.topMargin: 6; text: "Pinned apps (click one to unpin)"; role: M3Type.bodyLarge }
            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater { model: page.pins; M3Chip { required property string modelData; text: modelData; icon: "close"; onClicked: M3Config.pinned = page.pins.filter(x => x !== modelData) } }
            }
            TextRow { id: pinAdd; icon: "push_pin"; title: "Pin an app"; sub: "Desktop entry id, then press Enter"; placeholder: "org.gnome.Nautilus"; onEdited: v => { if (v !== "" && page.pins.indexOf(v) < 0) M3Config.pinned = page.pins.concat([v]) } }
        }
    }
}
