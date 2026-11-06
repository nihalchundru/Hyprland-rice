import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: barRoot
    property var colors
    property string clockTime: "00:00:00 AM"
    property string clockDate: ""
    property string volDisplay: "50%"
    property string cpuDisplay: "10%"
    property string ramDisplay: "45%"
    property string windowTitleDisplay: ""
    property bool musicPlaying: false
    property string trackDisplay: ""
    
    property string wTemp: "19°C"
    property string wCond: "Cloudy"
    property string wWind: "12m/s"
    property string wHumid: "80%"

    property string alertSummary: ""
    property string alertBody: ""

    property bool clockExpanded: false
    property bool notificationActive: false
    property bool anyExpanded: clockExpanded || notificationActive

    // SIGNAL BRIDGE: Forces the bar to sprout downward instantly
    signal triggerNotificationDrop()
    onTriggerNotificationDrop: {
        clockExpanded = false
        notificationActive = true
        popupTimer.restart()
    }

    // Controls how long the sprout panel stays visible (6000ms = 6 seconds)
    Timer {
        id: popupTimer
        interval: 6000
        running: false
        repeat: false
        onTriggered: barRoot.notificationActive = false
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-material"
    anchors { top: true; left: true; right: true }
    
    // Dynamically grows the panel layout down to fit the dropdown sprout
    implicitHeight: clockExpanded ? 245 : (notificationActive ? 114 : 54)
    Behavior on implicitHeight { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    color: "transparent"
    exclusiveZone: 38

    function calendarDays() {
        var now = new Date(), year = now.getFullYear(), month = now.getMonth()
        var firstDay = new Date(year, month, 1).getDay()
        var daysInMonth = new Date(year, month + 1, 0).getDate()
        var today = now.getDate(), days = []
        for (var i = 0; i < firstDay; i++) days.push({ day: "", today: false })
        for (var d = 1; d <= daysInMonth; d++) days.push({ day: d.toString(), today: d === today })
        return days
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 8

        // ==========================================
        // [LEFT ZONE]
        // ==========================================
        Row {
            anchors.left: parent.left; anchors.leftMargin: 14; anchors.top: parent.top; spacing: 10
            WorkspacePill {}
            TitlePill {}
            MediaPill {} 
        }

        // ==========================================
        // [CENTER ZONE] (FORCES DOWNWARD SPROUT FLOW)
        // ==========================================
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            spacing: 8

            ClockPill {}

            // Notification Banner Box: Sprouts out directly underneath the time capsule!
            Rectangle {
                id: notificationSproutBox
                visible: barRoot.notificationActive && !barRoot.clockExpanded
                width: 260
                height: 52
                radius: 14
                color: barRoot.colors.bg2
                border.color: barRoot.colors.surface2
                border.width: 1
                clip: true
                anchors.horizontalCenter: parent.horizontalCenter

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 10; spacing: 2
                    Text {
                        text: barRoot.alertSummary !== "" ? barRoot.alertSummary : "Notification"
                        color: barRoot.colors.accent; font.bold: true; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true; elide: Text.ElideRight
                    }
                    Text {
                        text: barRoot.alertBody !== "" ? barRoot.alertBody : "New System Alert"
                        color: barRoot.colors.text; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true; elide: Text.ElideRight
                    }
                }
            }
        }

        // ==========================================
        // [RIGHT ZONE]
        // ==========================================
        Row {
            anchors.right: parent.right; anchors.rightMargin: 14; anchors.top: parent.top; spacing: 10
            SysStatsPill {}
            AudioPill {}
        }
    }
}
