import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Wayland

PanelWindow {
    id: bar
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-island"
    anchors {top: true; left: true; right: true;}
    margins { top: 13; left: 20; right: 20;}
    implicitHeight: 33
    color: "transparent"


    Poller{
        id:clock
        command: "date '+%I:%M %p'"
        interval: 60000
    }

    Poller{
        id:vol
        command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf\"%d\", $2*100}'"
        interval: 1000
    }

    Poller {
        id: bt
        command: "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"
        interval: 5000
    }

    Poller {
        id: net
        command: "nmcli -t -f NAME connection show --active | head -n1"
        interval: 5000
    }

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    
    RowLayout {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        spacing: 8

        Pill {
            icon: "music_note"
            maxLabelWidth: 200
            label: bar.player ? `${bar.player.trackArtist || "Unknown"} - ${bar.player.trackTitle || ""}` : "Nothing Playing"
        }
    }
    RowLayout {
      id: centerGroup
      anchors.centerIn: parent
      spacing: 8

      Pill { icon: "nest_clock_farsight_analog"; label: clock.value}
      Workspaces {}
    }

    RowLayout {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: 14
      spacing: 8

      Pill { icon: "volume_up"; label: vol.value + "%"; iconColor: colors.accent}
      Pill { icon: "bluetooth"; label: bt.value; iconColor: colors.yellow}
      Pill { icon: "android_wifi_3_bar"; label: net.value; iconColor: colors.red}
              
    }
}

