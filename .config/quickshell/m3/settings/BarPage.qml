import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    SScroll {
        SCard {
            title: "Style"
            SwitchRow { icon: "call_to_action"; title: "Floating bar"; sub: "Rounded bar detached from the screen edges"; checked: M3Config.barFloating; onToggled: v => M3Config.barFloating = v }
            StepperRow { icon: "tag"; title: "Workspaces shown"; value: M3Config.workspaceCount; min: 1; max: 10; onPicked: v => M3Config.workspaceCount = v }
        }
        SCard {
            title: "Items"
            SwitchRow { icon: "title"; title: "Window title"; checked: M3Config.barTitle; onToggled: v => M3Config.barTitle = v }
            SwitchRow { icon: "calendar_today"; title: "Date next to the clock"; checked: M3Config.barDate; onToggled: v => M3Config.barDate = v }
            SwitchRow { icon: "music_note"; title: "Media pill"; checked: M3Config.barMedia; onToggled: v => M3Config.barMedia = v }
            SwitchRow { icon: "apps"; title: "System tray"; checked: M3Config.barTray; onToggled: v => M3Config.barTray = v }
        }
    }
}
