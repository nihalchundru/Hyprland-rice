import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../core"
import "../../shapes"
import "../../components"

PanelWindow {
    id: ccWindow

    property var modelData
    screen: modelData

    readonly property bool isOpen: StateStore.controlCenterOpen
    visible: isOpen || closeAnimTimer.running

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "m32-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Timer {
        id: closeAnimTimer
        interval: 320
    }

    Connections {
        target: StateStore
        function onControlCenterOpenChanged() {
            if (!StateStore.controlCenterOpen) {
                closeAnimTimer.restart();
            }
        }
    }

    Process {
        id: powerProc
        function runCmd(cmdStr) {
            powerProc.command = ["sh", "-c", cmdStr];
            powerProc.running = true;
        }
    }

    // Dismiss backdrop
    MouseArea {
        anchors.fill: parent
        enabled: ccWindow.isOpen
        onClicked: StateStore.controlCenterOpen = false
    }

    // ------------------------------------------------------------------------
    // Floating Right-Hand M3 Expressive Control Center Card
    // ------------------------------------------------------------------------
    Rectangle {
        id: drawerCard
        width: 392
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 58
        anchors.bottomMargin: 16
        anchors.rightMargin: ccWindow.isOpen ? 14 : -420

        radius: Motion.radiusExtraLarge
        color: Theme.withAlpha(Theme.surfaceContainer, 0.96)
        border.width: 1
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.5)
        opacity: ccWindow.isOpen ? 1.0 : 0.0
        clip: true

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: Motion.durationMedium3
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialDefault
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Motion.durationMedium1
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }

        // Prevent clicks inside card from closing backdrop
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // ----------------------------------------------------------------
            // HEADER: M3 Expressive Profile + Quick Power / Lock Actions
            // ----------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44

                    ShapeCanvas {
                        anchors.fill: parent
                        shapeName: "clover8"
                        color: Theme.primaryContainer

                        NumberAnimation on rotationAngle {
                            from: 0
                            to: 360
                            duration: 24000
                            loops: Animation.Infinite
                            running: ccWindow.isOpen
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "✦"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: Theme.onPrimaryContainer
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "m32 Control Center"
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: Theme.onSurface
                    }

                    Text {
                        text: "Theme: " + StateStore.currentTheme + "  ·  " + Services.time12
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 11
                        color: Theme.onSurfaceVariant
                    }
                }

                // Quick Lock Button
                MorphShapeButton {
                    size: 36
                    icon: "🔒"
                    iconSize: 13
                    idleShape: "cookie6"
                    hoverShape: "sunny"
                    pressedShape: "softBurst"
                    onClicked: {
                        StateStore.controlCenterOpen = false;
                        StateStore.lockscreenActive = true;
                    }
                }

                // Quick Reload Colors Button
                MorphShapeButton {
                    size: 36
                    icon: "↻"
                    iconSize: 15
                    idleShape: "cookie7"
                    hoverShape: "verySunny"
                    pressedShape: "burst"
                    spinOnHover: 90
                    onClicked: Theme.runStartupMatugen(StateStore.currentWallpaper)
                }

                // Close Button
                MorphShapeButton {
                    size: 36
                    icon: "✕"
                    iconSize: 13
                    idleShape: "circle"
                    hoverShape: "cookie4"
                    pressedShape: "softBurst"
                    onClicked: StateStore.controlCenterOpen = false
                }
            }

            // ----------------------------------------------------------------
            // QUICK TILES GRID (2x3 M3 Expressive Morphing Tiles)
            // ----------------------------------------------------------------
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                // 1. Wi-Fi Tile
                QuickTile {
                    Layout.fillWidth: true
                    title: "Wi-Fi"
                    subtitle: Services.wifiEnabled ? Services.wifiSsid : "Disabled"
                    iconText: ""
                    active: Services.wifiEnabled
                    idlePolygon: "cookie6"
                    activePolygon: "clover8"
                    onClicked: Services.toggleWifi()
                }

                // 2. Bluetooth Tile
                QuickTile {
                    Layout.fillWidth: true
                    title: "Bluetooth"
                    subtitle: Services.bluetoothEnabled ? "Enabled" : "Off"
                    iconText: ""
                    active: Services.bluetoothEnabled
                    idlePolygon: "cookie4"
                    activePolygon: "sunny"
                    onClicked: Services.toggleBluetooth()
                }

                // 3. Night Shift Tile
                QuickTile {
                    Layout.fillWidth: true
                    title: "Night Shift"
                    subtitle: StateStore.nightShiftState.toUpperCase()
                    iconText: "☾"
                    active: StateStore.nightShiftState !== "off"
                    idlePolygon: "cookie7"
                    activePolygon: "verySunny"
                    onClicked: StateStore.cycleNightShift()
                }

                // 4. Bar Layout Tile (pill / notch / islands)
                QuickTile {
                    Layout.fillWidth: true
                    title: "Bar Layout"
                    subtitle: StateStore.qsLayout.toUpperCase()
                    iconText: "⬡"
                    active: StateStore.qsLayout !== "pill"
                    idlePolygon: "gem"
                    activePolygon: "flower"
                    onClicked: StateStore.cycleLayout()
                }

                // 5. Do Not Disturb Tile
                QuickTile {
                    Layout.fillWidth: true
                    title: "Do Not Disturb"
                    subtitle: StateStore.dndEnabled ? "Silent" : "Alerts On"
                    iconText: StateStore.dndEnabled ? "⊘" : "🔔"
                    active: StateStore.dndEnabled
                    idlePolygon: "circle"
                    activePolygon: "cookie9"
                    onClicked: StateStore.dndEnabled = !StateStore.dndEnabled
                }

                // 6. Clock Format (12h / 24h)
                QuickTile {
                    Layout.fillWidth: true
                    title: "Clock Mode"
                    subtitle: StateStore.clockFormat === "24" ? "24-Hour" : "12-Hour"
                    iconText: "◷"
                    active: StateStore.clockFormat === "24"
                    idlePolygon: "pentagon"
                    activePolygon: "clover4"
                    onClicked: StateStore.toggleClockFormat()
                }
            }

            // ----------------------------------------------------------------
            // SLIDERS CARD: Morphing Volume & Brightness Sliders
            // ----------------------------------------------------------------
            M3Card {
                Layout.fillWidth: true
                implicitHeight: slidersCol.implicitHeight + 28
                level: 3
                radius: Motion.radiusLarge

                ColumnLayout {
                    id: slidersCol
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    // Volume Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MorphShapeButton {
                            size: 34
                            icon: Services.muted ? "✕" : "♪"
                            iconSize: 13
                            active: !Services.muted
                            idleShape: "burst"
                            activeShape: "cookie7"
                            hoverShape: "sunny"
                            onClicked: Services.toggleMute()
                        }

                        M3Slider {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: Services.muted ? 0 : Math.min(100, Services.volumePercent)
                            onMoved: (newVal) => Services.setVolume(Math.round(newVal))
                        }

                        Text {
                            Layout.preferredWidth: 42
                            horizontalAlignment: Text.AlignRight
                            text: Services.muted ? "Mute" : (Services.volumePercent + "%")
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Services.muted ? Theme.error : Theme.primary
                        }
                    }

                    // Brightness Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MorphShapeButton {
                            size: 34
                            icon: "☀"
                            iconSize: 14
                            active: true
                            idleShape: "cookie6"
                            activeShape: "verySunny"
                            hoverShape: "flower"
                            onClicked: Services.setBrightness(Services.brightnessPercent >= 80 ? 40 : 100)
                        }

                        M3Slider {
                            Layout.fillWidth: true
                            from: 5
                            to: 100
                            value: Services.brightnessPercent
                            activeColor: Theme.tertiary
                            thumbColor: Theme.tertiary
                            onThumbColor: Theme.onTertiary
                            onMoved: (newVal) => Services.setBrightness(Math.round(newVal))
                        }

                        Text {
                            Layout.preferredWidth: 42
                            horizontalAlignment: Text.AlignRight
                            text: Services.brightnessPercent + "%"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.tertiary
                        }
                    }
                }
            }

            // ----------------------------------------------------------------
            // LIVE SYSTEM TELEMETRY CARD (CPU / RAM / UPower)
            // ----------------------------------------------------------------
            M3Card {
                Layout.fillWidth: true
                implicitHeight: telemetryCol.implicitHeight + 26
                level: 3
                radius: Motion.radiusLarge

                ColumnLayout {
                    id: telemetryCol
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "SYSTEM TELEMETRY"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: Theme.onSurfaceVariant
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: Services.memUsedGb + " / " + Services.memTotalGb + " GiB"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Theme.tertiary
                        }
                    }

                    // CPU Meter
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            Layout.preferredWidth: 38
                            text: "CPU"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.onSurface
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 10
                            radius: 5
                            color: Theme.surfaceContainerHighest

                            Rectangle {
                                height: parent.height
                                width: parent.width * Math.min(1, Services.cpuPercent / 100.0)
                                radius: 5
                                color: Theme.primary
                                Behavior on width { NumberAnimation { duration: 300 } }
                            }
                        }

                        Text {
                            Layout.preferredWidth: 38
                            horizontalAlignment: Text.AlignRight
                            text: Services.cpuPercent + "%"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.primary
                        }
                    }

                    // RAM Meter
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            Layout.preferredWidth: 38
                            text: "RAM"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.onSurface
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 10
                            radius: 5
                            color: Theme.surfaceContainerHighest

                            Rectangle {
                                height: parent.height
                                width: parent.width * Math.min(1, Services.memPercent / 100.0)
                                radius: 5
                                color: Theme.tertiary
                                Behavior on width { NumberAnimation { duration: 300 } }
                            }
                        }

                        Text {
                            Layout.preferredWidth: 38
                            horizontalAlignment: Text.AlignRight
                            text: Services.memPercent + "%"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.tertiary
                        }
                    }
                }
            }

            // ----------------------------------------------------------------
            // NOTIFICATION CENTER LIST (with Test & Clear buttons)
            // ----------------------------------------------------------------
            M3Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                level: 2
                radius: Motion.radiusLarge

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "NOTIFICATIONS (" + Services.notificationCount + ")"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.onSurfaceVariant
                        }

                        Item { Layout.fillWidth: true }

                        // Send Test Notification button
                        Rectangle {
                            height: 24
                            width: testTxt.implicitWidth + 16
                            radius: 12
                            color: Theme.secondaryContainer

                            Text {
                                id: testTxt
                                anchors.centerIn: parent
                                text: "+ Test"
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.onSecondaryContainer
                            }

                            M3StateLayer {
                                anchors.fill: parent
                                cornerRadius: 12
                                onClicked: Services.pushNotification(
                                    "m32 Shell",
                                    "Material 3 Expressive Active",
                                    "CPU " + Services.cpuPercent + "% · RAM " + Services.memPercent + "% (" + Services.memUsedGb + " GiB)",
                                    "normal"
                                )
                            }
                        }

                        // Clear all notifications button
                        Rectangle {
                            visible: Services.notificationCount > 0
                            height: 24
                            width: clearTxt.implicitWidth + 16
                            radius: 12
                            color: Theme.surfaceContainerHighest

                            Text {
                                id: clearTxt
                                anchors.centerIn: parent
                                text: "Clear"
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.onSurfaceVariant
                            }

                            M3StateLayer {
                                anchors.fill: parent
                                cornerRadius: 12
                                onClicked: Services.clearNotifications()
                            }
                        }
                    }

                    // Empty State
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: Services.notificationCount === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Item {
                                width: 46
                                height: 46
                                anchors.horizontalCenter: parent.horizontalCenter

                                ShapeCanvas {
                                    anchors.fill: parent
                                    shapeName: "cookie9"
                                    color: Theme.surfaceContainerHighest
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✦"
                                    font.family: Theme.fontFamilyMono
                                    font.pixelSize: 18
                                    color: Theme.onSurfaceVariant
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "All caught up"
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: Theme.onSurfaceVariant
                            }
                        }
                    }

                    // Notification History ListView
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: Services.notificationCount > 0
                        clip: true
                        spacing: 8
                        model: Services.notificationModel

                        delegate: Rectangle {
                            required property string uid
                            required property string appName
                            required property string summary
                            required property string body
                            required property string timeStr

                            width: ListView.view.width
                            height: itemCol.implicitHeight + 20
                            radius: Motion.radiusMedium
                            color: Theme.surfaceContainerHigh

                            ColumnLayout {
                                id: itemCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: appName + " · " + timeStr
                                        font.family: Theme.fontFamilyMono
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: Theme.primary
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: "✕"
                                        font.family: Theme.fontFamilyMono
                                        font.pixelSize: 11
                                        color: Theme.onSurfaceVariant

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Services.dismissNotification(uid)
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: summary
                                    font.family: Theme.fontFamilySans
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: Theme.onSurface
                                    elide: Text.ElideRight
                                }

                                Text {
                                    visible: body !== ""
                                    Layout.fillWidth: true
                                    text: body
                                    font.family: Theme.fontFamilySans
                                    font.pixelSize: 11
                                    color: Theme.onSurfaceVariant
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            // ----------------------------------------------------------------
            // FOOTER POWER BAR: Suspend / Reboot / Power Off
            // ----------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 18
                    color: Theme.surfaceContainerHigh

                    Text {
                        anchors.centerIn: parent
                        text: "☾ Suspend"
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.onSurface
                    }

                    M3StateLayer {
                        anchors.fill: parent
                        cornerRadius: 18
                        onClicked: powerProc.runCmd("systemctl suspend")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 18
                    color: Theme.secondaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: "↻ Reboot"
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.onSecondaryContainer
                    }

                    M3StateLayer {
                        anchors.fill: parent
                        cornerRadius: 18
                        onClicked: powerProc.runCmd("systemctl reboot")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 18
                    color: Theme.errorContainer

                    Text {
                        anchors.centerIn: parent
                        text: "⏻ Power"
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.onErrorContainer
                    }

                    M3StateLayer {
                        anchors.fill: parent
                        cornerRadius: 18
                        onClicked: powerProc.runCmd("systemctl poweroff")
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------------
    // Reusable M3 Expressive Morphing Quick Tile Component
    // ------------------------------------------------------------------------
    component QuickTile: Rectangle {
        id: tile
        property string title: ""
        property string subtitle: ""
        property string iconText: "✦"
        property bool active: false
        property string idlePolygon: "cookie6"
        property string activePolygon: "sunny"
        signal clicked()

        implicitHeight: 62
        radius: tile.active ? 22 : 16
        color: tile.active ? Theme.primaryContainer : Theme.surfaceContainerHigh
        border.width: 1
        border.color: tile.active
            ? Theme.withAlpha(Theme.primary, 0.45)
            : Theme.withAlpha(Theme.outlineVariant, 0.35)

        Behavior on radius { NumberAnimation { duration: Motion.durationMedium1 } }
        Behavior on color { ColorAnimation { duration: Motion.durationColor } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Item {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36

                ShapeCanvas {
                    anchors.fill: parent
                    shapeName: {
                        if (tileState.pressed) return "softBurst";
                        if (tile.active) return tile.activePolygon;
                        if (tileState.hovered) return "verySunny";
                        return tile.idlePolygon;
                    }
                    color: tile.active ? Theme.primary : Theme.surfaceContainerHighest
                }

                Text {
                    anchors.centerIn: parent
                    text: tile.iconText
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: tile.active ? Theme.onPrimary : Theme.onSurfaceVariant
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: tile.title
                    font.family: Theme.fontFamilySans
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: tile.active ? Theme.onPrimaryContainer : Theme.onSurface
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: tile.subtitle
                    font.family: Theme.fontFamilySans
                    font.pixelSize: 10
                    color: tile.active ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                    opacity: 0.85
                    elide: Text.ElideRight
                }
            }
        }

        M3StateLayer {
            id: tileState
            anchors.fill: parent
            cornerRadius: tile.radius
            stateColor: tile.active ? Theme.onPrimaryContainer : Theme.onSurface
            onClicked: tile.clicked()
        }
    }
}
