import QtQuick
import QtQuick.Layouts
import "../../core"
import "../../shapes"
import "../../components"

Item {
    id: root

    readonly property bool expanded: StateStore.notchExpanded
    readonly property bool isNotchMode: StateStore.qsLayout === "notch"
    readonly property bool is24h: StateStore.clockFormat === "24"

    implicitWidth: expanded ? 390 : (compactRow.implicitWidth + 28)
    implicitHeight: expanded ? 124 : 36

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Motion.durationMedium3
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.expressiveSpatialDefault
        }
    }
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Motion.durationMedium3
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.expressiveSpatialDefault
        }
    }

    Rectangle {
        id: notchCard
        anchors.fill: parent
        radius: root.expanded ? Motion.radiusExtraLarge : (height / 2)
        color: root.isNotchMode ? Theme.surfaceContainerLowest : Theme.surfaceContainerHigh
        border.width: 1
        border.color: root.expanded ? Theme.primary : Theme.withAlpha(Theme.outlineVariant, 0.5)
        clip: true

        Behavior on radius {
            NumberAnimation {
                duration: Motion.durationMedium2
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }
        Behavior on color { ColorAnimation { duration: Motion.durationColor } }
        Behavior on border.color { ColorAnimation { duration: Motion.durationShort4 } }

        // --------------------------------------------------------------------
        // COMPACT STATE: Morphing status badge + Clock + Date + Mini Media
        // --------------------------------------------------------------------
        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: 10
            visible: !root.expanded
            opacity: root.expanded ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            // Rotating / morphing M3 emblem
            Item {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                ShapeCanvas {
                    id: compactBadge
                    anchors.fill: parent
                    shapeName: {
                        if (Services.mediaPlaying) return "clover8";
                        if (notchHover.containsMouse) return "verySunny";
                        return "cookie9";
                    }
                    color: Services.mediaPlaying ? Theme.tertiary : Theme.primary

                    NumberAnimation on rotationAngle {
                        from: 0
                        to: 360
                        duration: 9000
                        loops: Animation.Infinite
                        running: Services.mediaPlaying
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Services.mediaPlaying ? "♪" : "✦"
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: Services.mediaPlaying ? Theme.onTertiary : Theme.onPrimary
                }
            }

            // Clock
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Text {
                    text: Services.formattedTime(root.is24h)
                    font.family: Theme.fontFamilySans
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: Theme.onSurface
                }

                Text {
                    visible: !root.is24h
                    text: Services.amPm
                    font.family: Theme.fontFamilySans
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: Theme.primary
                    anchors.baseline: parent.children[0].baseline
                }

                Text {
                    text: "·  " + Services.dateShort
                    font.family: Theme.fontFamilySans
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Theme.onSurfaceVariant
                }
            }

            // Mini playing track title when media is active
            Rectangle {
                visible: Services.mediaPlaying && Services.mediaTitle !== "Nothing Playing"
                height: 22
                width: Math.min(140, miniTrackText.implicitWidth + 16)
                radius: 11
                color: Theme.secondaryContainer
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: miniTrackText
                    anchors.centerIn: parent
                    width: parent.width - 14
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    text: Services.mediaTitle
                    font.family: Theme.fontFamilySans
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: Theme.onSecondaryContainer
                }
            }
        }

        // --------------------------------------------------------------------
        // EXPANDED STATE: Full M3 Expressive Media & System Island
        // --------------------------------------------------------------------
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            visible: root.expanded
            opacity: root.expanded ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 220 } }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Morphing Album / Emblem container
                Item {
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 52

                    ShapeCanvas {
                        anchors.fill: parent
                        shapeName: Services.mediaPlaying ? "sunny" : "cookie6"
                        color: Theme.primaryContainer

                        NumberAnimation on rotationAngle {
                            from: 0
                            to: 360
                            duration: 14000
                            loops: Animation.Infinite
                            running: Services.mediaPlaying && root.expanded
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Services.mediaPlaying ? "♫" : "◈"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: Theme.onPrimaryContainer
                    }
                }

                // Track & Clock Details
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: Services.mediaTitle !== "Nothing Playing" ? Services.mediaTitle : Services.dateLong
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: Theme.onSurface
                    }

                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: Services.mediaArtist !== ""
                            ? Services.mediaArtist
                            : ("Theme: " + StateStore.currentTheme + "  ·  Layout: " + StateStore.qsLayout)
                        font.family: Theme.fontFamilySans
                        font.pixelSize: 11
                        color: Theme.onSurfaceVariant
                    }
                }

                // Morphing Media Transport Controls
                Row {
                    spacing: 6

                    MorphShapeButton {
                        size: 32
                        icon: "⏮"
                        iconSize: 13
                        idleShape: "circle"
                        hoverShape: "cookie4"
                        pressedShape: "softBurst"
                        onClicked: Services.mediaPrevious()
                    }

                    MorphShapeButton {
                        size: 36
                        icon: Services.mediaPlaying ? "⏸" : "▶"
                        iconSize: 14
                        active: Services.mediaPlaying
                        idleShape: "cookie6"
                        hoverShape: "sunny"
                        activeShape: "square"
                        pressedShape: "burst"
                        onClicked: Services.mediaPlayPause()
                    }

                    MorphShapeButton {
                        size: 32
                        icon: "⏭"
                        iconSize: 13
                        idleShape: "circle"
                        hoverShape: "cookie4"
                        pressedShape: "softBurst"
                        onClicked: Services.mediaNext()
                    }
                }
            }

            // Bottom quick bar inside expanded notch: CPU / RAM / Layout / 12-24h toggle
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 14
                    color: Theme.surfaceContainerHighest

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: "CPU " + Services.cpuPercent + "%"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.primary
                        }

                        Text {
                            text: "RAM " + Services.memPercent + "%"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.tertiary
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.is24h ? "24H" : "12H"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.secondary

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: StateStore.toggleClockFormat()
                            }
                        }
                    }
                }

                // Quick layout switcher chip inside the Notch
                Rectangle {
                    height: 28
                    width: layoutChipText.implicitWidth + 20
                    radius: 14
                    color: Theme.secondaryContainer

                    Text {
                        id: layoutChipText
                        anchors.centerIn: parent
                        text: "⬡ " + StateStore.qsLayout.toUpperCase()
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: Theme.onSecondaryContainer
                    }

                    M3StateLayer {
                        anchors.fill: parent
                        cornerRadius: 14
                        stateColor: Theme.onSecondaryContainer
                        onClicked: StateStore.cycleLayout()
                    }
                }
            }
        }

        // Click on compact notch toggles expanded island
        MouseArea {
            id: notchHover
            anchors.fill: parent
            visible: !root.expanded
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    StateStore.toggleClockFormat();
                } else {
                    StateStore.notchExpanded = !StateStore.notchExpanded;
                }
            }
        }
    }
}
