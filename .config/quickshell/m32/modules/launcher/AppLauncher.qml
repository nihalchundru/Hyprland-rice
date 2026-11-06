import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../core"
import "../../shapes"
import "../../components"

PanelWindow {
    id: launcherWindow

    property var modelData
    screen: modelData

    readonly property bool isOpen: StateStore.launcherOpen
    visible: isOpen || closeAnimTimer.running

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    implicitWidth: screen ? screen.width : 1920
    implicitHeight: screen ? screen.height : 1080
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "m32-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string searchQuery: ""
    property int selectedIndex: 0

    readonly property var polygonBadges: [
        "cookie6", "sunny", "clover4", "cookie7", "gem", "flower", "cookie9", "verySunny"
    ]

    // Filtered list of DesktopEntries.applications
    readonly property var filteredApps: {
        var raw = DesktopEntries.applications ? DesktopEntries.applications.values : [];
        if (!raw) return [];
        var q = searchQuery.trim().toLowerCase();
        var results = [];
        for (var i = 0; i < raw.length; i++) {
            var entry = raw[i];
            if (!entry || !entry.name) continue;
            if (entry.noDisplay) continue;
            var nameL = String(entry.name || "").toLowerCase();
            var genericL = String(entry.genericName || "").toLowerCase();
            var commentL = String(entry.comment || "").toLowerCase();
            var idL = String(entry.id || "").toLowerCase();
            if (q === "" || nameL.indexOf(q) !== -1 || genericL.indexOf(q) !== -1 || commentL.indexOf(q) !== -1 || idL.indexOf(q) !== -1) {
                results.push(entry);
            }
        }
        results.sort(function(a, b) {
            var an = String(a.name || "").toLowerCase();
            var bn = String(b.name || "").toLowerCase();
            if (q !== "") {
                var aStarts = an.indexOf(q) === 0 ? 0 : 1;
                var bStarts = bn.indexOf(q) === 0 ? 0 : 1;
                if (aStarts !== bStarts) return aStarts - bStarts;
            }
            return an < bn ? -1 : (an > bn ? 1 : 0);
        });
        return results.slice(0, 40);
    }

    onSearchQueryChanged: {
        selectedIndex = 0;
        appListView.currentIndex = 0;
    }

    function launchEntry(entry) {
        if (!entry) return;
        StateStore.launcherOpen = false;
        searchInput.text = "";
        try {
            if (typeof entry.execute === "function") {
                entry.execute();
                return;
            }
        } catch (e) {}

        if (entry.command && entry.command.length > 0) {
            appRunner.command = entry.command;
            appRunner.running = true;
        } else if (entry.id) {
            appRunner.command = ["gtk-launch", entry.id];
            appRunner.running = true;
        }
    }

    function launchSelected() {
        if (filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            launchEntry(filteredApps[selectedIndex]);
        } else if (searchQuery.trim().indexOf("!") === 0) {
            var rawCmd = searchQuery.trim().substring(1).trim();
            if (rawCmd !== "") {
                StateStore.launcherOpen = false;
                searchInput.text = "";
                appRunner.command = ["sh", "-c", rawCmd];
                appRunner.running = true;
            }
        }
    }

    Process {
        id: appRunner
    }

    Timer {
        id: closeAnimTimer
        interval: 280
    }

    Connections {
        target: StateStore
        function onLauncherOpenChanged() {
            if (StateStore.launcherOpen) {
                launcherWindow.searchQuery = "";
                searchInput.text = "";
                launcherWindow.selectedIndex = 0;
                focusTimer.restart();
            } else {
                closeAnimTimer.restart();
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 40
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    // Scrim backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.withAlpha(Theme.scrim, ccBackdropOpacity)
        property real ccBackdropOpacity: launcherWindow.isOpen ? 0.32 : 0.0
        Behavior on ccBackdropOpacity { NumberAnimation { duration: Motion.durationMedium1 } }

        MouseArea {
            anchors.fill: parent
            enabled: launcherWindow.isOpen
            onClicked: StateStore.launcherOpen = false
        }
    }

    // ------------------------------------------------------------------------
    // Centered M3 Expressive Search & App Sheet
    // ------------------------------------------------------------------------
    Rectangle {
        id: sheetCard

        // Keep the card inside the VM/display bounds with 16 px side margins.
        width: Math.min(560, Math.max(0, launcherWindow.width - 32))
        height: Math.min(520, Math.max(0, launcherWindow.height - 100))

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: launcherWindow.isOpen ? 82 : 52

        radius: Motion.radiusExtraLargeInc
        color: Theme.withAlpha(Theme.surfaceContainer, 0.97)
        border.width: 1
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.55)
        opacity: launcherWindow.isOpen ? 1.0 : 0.0
        scale: launcherWindow.isOpen ? 1.0 : 0.94
        clip: true

        Behavior on anchors.topMargin {
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
        Behavior on scale {
            NumberAnimation {
                duration: Motion.durationMedium2
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialDefault
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
            // EXPRESSIVE SEARCH BAR PILL
            // ----------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.minimumHeight: 54
                radius: 27
                color: Theme.surfaceContainerHigh
                border.width: 2
                border.color: searchInput.activeFocus
                    ? Theme.primary
                    : Theme.withAlpha(Theme.outlineVariant, 0.45)

                Behavior on border.color { ColorAnimation { duration: Motion.durationShort4 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 14
                    spacing: 12

                    // Morphing Search Emblem
                    Item {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34

                        ShapeCanvas {
                            anchors.fill: parent
                            shapeName: {
                                if (launcherWindow.searchQuery.length > 0) return "verySunny";
                                if (searchInput.activeFocus) return "cookie7";
                                return "cookie6";
                            }
                            color: Theme.primaryContainer
                            rotationAngle: launcherWindow.searchQuery.length * 25
                            Behavior on rotationAngle {
                                NumberAnimation {
                                    duration: Motion.durationMedium2
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Motion.expressiveSpatialDefault
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "❖"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            color: Theme.onPrimaryContainer
                        }
                    }

                    // TextInput
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 0

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: searchInput.text === ""
                            text: "Search applications or type !cmd to run..."
                            font.family: Theme.fontFamilySans
                            font.pixelSize: 14
                            color: Theme.onSurfaceVariant
                            opacity: 0.75
                        }

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: Theme.fontFamilySans
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: Theme.onSurface
                            selectionColor: Theme.primaryContainer
                            selectedTextColor: Theme.onPrimaryContainer
                            clip: true

                            onTextChanged: launcherWindow.searchQuery = text

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Escape) {
                                    StateStore.launcherOpen = false;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
                                    if (launcherWindow.filteredApps.length > 0) {
                                        launcherWindow.selectedIndex = (launcherWindow.selectedIndex + 1) % launcherWindow.filteredApps.length;
                                        appListView.currentIndex = launcherWindow.selectedIndex;
                                        appListView.positionViewAtIndex(launcherWindow.selectedIndex, ListView.Contain);
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_Backtab)) {
                                    if (launcherWindow.filteredApps.length > 0) {
                                        launcherWindow.selectedIndex = (launcherWindow.selectedIndex - 1 + launcherWindow.filteredApps.length) % launcherWindow.filteredApps.length;
                                        appListView.currentIndex = launcherWindow.selectedIndex;
                                        appListView.positionViewAtIndex(launcherWindow.selectedIndex, ListView.Contain);
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    launcherWindow.launchSelected();
                                    event.accepted = true;
                                }
                            }
                        }
                    }

                    // Result count chip
                    Rectangle {
                        height: 24
                        width: countLabel.implicitWidth + 14
                        radius: 12
                        color: Theme.secondaryContainer

                        Text {
                            id: countLabel
                            anchors.centerIn: parent
                            text: launcherWindow.filteredApps.length + " apps"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: Theme.onSecondaryContainer
                        }
                    }

                    MorphShapeButton {
                        size: 32
                        icon: "✕"
                        iconSize: 12
                        idleShape: "circle"
                        hoverShape: "cookie4"
                        pressedShape: "softBurst"
                        onClicked: StateStore.launcherOpen = false
                    }
                }
            }

            // ----------------------------------------------------------------
            // QUICK ACTION CHIPS (Theme Switcher, Wallpapers, Control Center)
            // ----------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                Layout.minimumHeight: 28
                spacing: 8

                QuickChip {
                    label: "🎨 Themes & Wallpapers"
                    onClicked: {
                        StateStore.launcherOpen = false;
                        StateStore.themeSwitcherOpen = true;
                    }
                }

                QuickChip {
                    label: "⚙ Control Center"
                    onClicked: {
                        StateStore.launcherOpen = false;
                        StateStore.controlCenterOpen = true;
                    }
                }

                QuickChip {
                    label: "⬡ Layout: " + StateStore.qsLayout.toUpperCase()
                    onClicked: StateStore.cycleLayout()
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: sheetCard.width >= 700
                    text: "↑↓ Navigate  ·  ↵ Launch  ·  Esc Close"
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 10
                    color: Theme.onSurfaceVariant
                }
            }

            // ----------------------------------------------------------------
            // APPLICATION LIST VIEW
            // ----------------------------------------------------------------
            ListView {
                id: appListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 120
                clip: true
                spacing: 6
                model: launcherWindow.filteredApps

                delegate: Rectangle {
                    id: appRow
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: index === launcherWindow.selectedIndex || rowState.hovered

                    width: ListView.view.width
                    height: 58
                    radius: isSelected ? 22 : 14
                    color: isSelected ? Theme.primaryContainer : Theme.surfaceContainerHigh
                    border.width: index === launcherWindow.selectedIndex ? 1 : 0
                    border.color: Theme.primary

                    Behavior on radius { NumberAnimation { duration: Motion.durationShort4 } }
                    Behavior on color { ColorAnimation { duration: Motion.durationShort4 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 16
                        spacing: 12

                        // Morphing M3 App Badge + real app icon (initial as fallback)
                        Item {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40

                            ShapeCanvas {
                                anchors.fill: parent
                                shapeName: {
                                    if (rowState.pressed) return "softBurst";
                                    if (appRow.isSelected) return "sunny";
                                    return launcherWindow.polygonBadges[appRow.index % launcherWindow.polygonBadges.length];
                                }
                                color: appRow.isSelected ? Theme.primary : Theme.surfaceContainerHighest
                            }

                            Image {
                                id: appIcon
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                sourceSize.width: 52
                                sourceSize.height: 52
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                source: Quickshell.iconPath(String(appRow.modelData.icon || "application-x-executable"), "")
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !appIcon.visible
                                text: {
                                    var n = String(appRow.modelData.name || "A").trim();
                                    return n.length > 0 ? n.charAt(0).toUpperCase() : "A";
                                }
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 15
                                font.weight: Font.Bold
                                color: appRow.isSelected ? Theme.onPrimary : Theme.primary
                            }
                        }

                        // App Name & Description
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: appRow.modelData.name || "Application"
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: appRow.isSelected ? Theme.onPrimaryContainer : Theme.onSurface
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: appRow.modelData.comment || appRow.modelData.genericName || appRow.modelData.id || ""
                                font.family: Theme.fontFamilySans
                                font.pixelSize: 11
                                color: appRow.isSelected ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                                opacity: 0.85
                                elide: Text.ElideRight
                            }
                        }

                    }

                    M3StateLayer {
                        id: rowState
                        anchors.fill: parent
                        cornerRadius: appRow.radius
                        stateColor: appRow.isSelected ? Theme.onPrimaryContainer : Theme.onSurface
                        onClicked: {
                            launcherWindow.selectedIndex = appRow.index;
                            launcherWindow.launchEntry(appRow.modelData);
                        }
                    }
                }
            }
        }
    }

    component QuickChip: Rectangle {
        id: chip
        property string label: ""
        signal clicked()

        height: 28
        width: chipTxt.implicitWidth + 20
        radius: 14
        color: Theme.surfaceContainerHigh
        border.width: 1
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.4)

        Text {
            id: chipTxt
            anchors.centerIn: parent
            text: chip.label
            font.family: Theme.fontFamilySans
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: Theme.onSurface
        }

        M3StateLayer {
            anchors.fill: parent
            cornerRadius: 14
            onClicked: chip.clicked()
        }
    }
}