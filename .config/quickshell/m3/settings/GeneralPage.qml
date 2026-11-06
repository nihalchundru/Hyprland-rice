import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    SScroll {
        SCard {
            title: "Clock and weather"
            SwitchRow { icon: "schedule"; title: "24-hour clock"; sub: "Used by the bar, widgets and lock screen"; checked: M3Config.clock24; onToggled: v => M3Config.clock24 = v }
            ChipsRow { icon: "thermostat"; title: "Temperature unit"; options: ["F", "C"]; value: M3Config.tempUnit; onPicked: v => M3Config.tempUnit = v }
            TextRow { icon: "location_on"; title: "Weather location"; sub: "Empty = detect by IP address"; placeholder: "e.g. Fremont"; value: M3Config.weatherLocation; onEdited: v => M3Config.weatherLocation = v }
            SRow { icon: "cloud_sync"; title: "Refresh weather"; M3Button { text: "Refresh"; variant: "tonal"; onClicked: Weather.refresh() } }
        }
        SCard {
            title: "Launcher"
            TextRow { icon: "terminal"; title: "Terminal"; sub: "Used by  >  commands in the launcher"; placeholder: "kitty"; value: M3Config.terminal; onEdited: v => { if (v !== "") M3Config.terminal = v } }
        }
        SCard {
            title: "Lock screen"
            SwitchRow { icon: "lock"; title: "Notification previews"; sub: "Show the latest notification text while locked"; checked: M3Config.lockNotifPreview; onToggled: v => M3Config.lockNotifPreview = v }
        }
    }
}
