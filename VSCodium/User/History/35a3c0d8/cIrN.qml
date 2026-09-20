import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    anchors {top: true; left: true; right: true;}
    implicitHeight: 33
    color: "transparent"


    Poller{
        id:clock
        command: "date +%H:%M"
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

    RowLayout {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: 14
      spacing: 8

      Pill { icon: "volume_up"; label: vol.value + "%"; iconColor: colors.orange}
      //Pill { icon: "bluetooth"; label: bt.value + "%"; iconColor: colors.yellow}
      Pill { icon: "android_wifi_3_bar"; label: net.value; iconColor: colors.red}
              
    }
}

