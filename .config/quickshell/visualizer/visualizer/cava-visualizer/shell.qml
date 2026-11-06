// cava-visualizer — a modern cava-style audio visualizer for Quickshell + Hyprland.
//
//   qs -c cava-visualizer
//
// It spawns `cava` (see cava.ini), streams the spectrum, and draws a smooth,
// gradient, center-mirrored bar visualizer as a click-through layer-shell strip
// docked to the bottom of every monitor.
//
// Everything you'd normally want to tweak lives in the block below.

import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: shellRoot

    // ─────────────────────────────── tunables ───────────────────────────────
    // Bar colours are taken from your topbar palette by default:
    //   ~/.config/quickshell/topbar/colors.json
    // Set followTopbar: false to use the fixed fallback colours instead.
    property bool followTopbar: true
    property color fixedGradientTop: "#7ee7c7"      // mint
    property color fixedGradientBottom: "#5b8cff"   // periwinkle
    property color fixedPeakColor: "#39e7b2"  // vivid, not white

    readonly property color gradientTop: followTopbar ? theme.gradientTop : fixedGradientTop
    readonly property color gradientBottom: followTopbar ? theme.gradientBottom : fixedGradientBottom
    readonly property color peakColor: followTopbar ? theme.peakColor : fixedPeakColor

    property color panelColor: "#0e1116"
    property real panelOpacity: 0.45

    // Strip geometry.
    property int stripHeight: 150
    property int sideMargin: 48
    property int bottomMargin: 28

    // Look & motion.
    property bool mirrored: true        // symmetric, center-out spectrum
    property bool showPanel: false      // translucent rounded backdrop (false = fully transparent)
    property bool peakCaps: true        // floating falling peak dots
    property real barSpacing: 3
    property real barRadius: 6
    property int barSmoothing: 110      // ms
    property int peakFall: 420          // ms

    // Show the strip on every monitor, or only the first one.
    property bool showOnAllScreens: true
    // false = bottom layer: sits on the desktop, BEHIND normal windows, so it
    // only shows where the wallpaper is visible. true = overlaps windows.
    property bool aboveWindows: false
    // ─────────────────────────────────────────────────────────────────────────

    // Palette bridge to the topbar theme.
    Theme { id: theme }

    // One shared cava process for the whole shell (never one per monitor).
    Cava { id: cava }

    Variants {
        // Built explicitly (rather than .slice) since QML list properties are
        // not guaranteed to behave like JS arrays.
        model: {
            const screens = Quickshell.screens;
            if (shellRoot.showOnAllScreens)
                return screens;
            return screens.length > 0 ? [screens[0]] : [];
        }

        delegate: PanelWindow {
            id: win
            property var modelData   // populated by Variants per screen
            screen: modelData

            anchors {
                left: true
                right: true
                bottom: true
            }
            margins {
                left: shellRoot.sideMargin
                right: shellRoot.sideMargin
                bottom: shellRoot.bottomMargin
            }
            implicitHeight: shellRoot.stripHeight
            exclusiveZone: 0            // overlay, don't reserve space
            aboveWindows: shellRoot.aboveWindows
            focusable: false
            color: "transparent"
            // Empty input region => every click passes straight through.
            mask: Region {}

            Visualizer {
                anchors.fill: parent

                values: cava.values
                mirrored: shellRoot.mirrored
                peakCaps: shellRoot.peakCaps
                showPanel: shellRoot.showPanel
                gradientTop: shellRoot.gradientTop
                gradientBottom: shellRoot.gradientBottom
                peakColor: shellRoot.peakColor
                panelColor: shellRoot.panelColor
                panelOpacity: shellRoot.panelOpacity
                barSpacing: shellRoot.barSpacing
                barRadius: shellRoot.barRadius
                barSmoothing: shellRoot.barSmoothing
                peakFall: shellRoot.peakFall
            }
        }
    }
}
