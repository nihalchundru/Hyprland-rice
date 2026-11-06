pragma Singleton

import Quickshell
// Required for the `color` value type. Without it every `property color` here
// fails with "color is not a type", which then cascades and makes every
// singleton and component in the config unavailable.
import QtQuick

// Material 3 baseline DARK colour scheme.
//
// The colour roles live in a single `palette` object rather than as flat
// properties, for a specific reason: Material 3 names its roles "on-primary",
// "on-surface" and so on, and `on<Capital>` is QML's *reserved signal-handler
// syntax* ("the object definition should declare a signal handler named
// on<Signal>"). A flat declaration like
//
//     property color onSurfaceVariant: "#cac4d0"
//
// is therefore parsed as an assignment to a signal and fails with
// "Cannot assign a value to a signal (expecting a script to be run)".
// As object keys the same names are just strings, so the Material 3 vocabulary
// survives intact and stays 1:1 with the specification.
//
//     M3Theme.palette.onPrimary
//     M3Theme.palette.surfaceContainerHigh
//
// The shape, type and motion tokens below stay flat -- none of them collide
// with handler syntax.
Singleton {
    id: root

    // The parentheses matter: a binding whose first token is `{` is parsed as a
    // code block, not an object literal.
    readonly property var palette: ({
        // ---- key colours ----
        primary: "#d0bcff",
        onPrimary: "#381e72",
        primaryContainer: "#4f378b",
        onPrimaryContainer: "#eaddff",

        secondary: "#ccc2dc",
        onSecondary: "#332d41",
        secondaryContainer: "#4a4458",
        onSecondaryContainer: "#e8def8",

        tertiary: "#efb8c8",
        onTertiary: "#492532",
        tertiaryContainer: "#633b48",
        onTertiaryContainer: "#ffd8e4",

        error: "#f2b8b5",
        onError: "#601410",
        errorContainer: "#8c1d18",
        onErrorContainer: "#f9dedc",

        // ---- surfaces (the M3 surface-container ramp) ----
        surface: "#141218",
        onSurface: "#e6e0e9",
        surfaceVariant: "#49454f",
        onSurfaceVariant: "#cac4d0",
        surfaceContainerLowest: "#0f0d13",
        surfaceContainerLow: "#1d1b20",
        surfaceContainer: "#211f26",
        surfaceContainerHigh: "#2b2930",
        surfaceContainerHighest: "#36343b",
        surfaceDim: "#141218",
        surfaceBright: "#3b383e",
        inverseSurface: "#e6e0e9",
        inverseOnSurface: "#322f35",

        // ---- lines and overlays ----
        outline: "#938f99",
        outlineVariant: "#49454f",
        scrim: "#000000",
        shadow: "#000000"
    })

    // ---- shape scale (M3) --------------------------------------------------
    readonly property int shapeExtraSmall: 4
    readonly property int shapeSmall: 8
    readonly property int shapeMedium: 12
    readonly property int shapeLarge: 16
    readonly property int shapeExtraLarge: 28
    readonly property int shapeFull: 999

    // ---- type scale (M3), in px -------------------------------------------
    readonly property int displayLarge: 57
    readonly property int displayMedium: 45
    readonly property int displaySmall: 36
    readonly property int headlineLarge: 32
    readonly property int headlineMedium: 28
    readonly property int headlineSmall: 24
    readonly property int titleLarge: 22
    readonly property int titleMedium: 16
    readonly property int titleSmall: 14
    readonly property int bodyLarge: 16
    readonly property int bodyMedium: 14
    readonly property int bodySmall: 12
    readonly property int labelLarge: 14
    readonly property int labelMedium: 12
    readonly property int labelSmall: 11

    readonly property string font: "Inter"
    readonly property string fontMono: "JetBrainsMono Nerd Font"

    // ---- motion (M3 duration tokens) --------------------------------------
    readonly property int durationShort1: 50
    readonly property int durationShort2: 100
    readonly property int durationShort3: 150
    readonly property int durationShort4: 200
    readonly property int durationMedium1: 250
    readonly property int durationMedium2: 300
    readonly property int durationMedium3: 350
    readonly property int durationMedium4: 400
    readonly property int durationLong1: 450
    readonly property int durationLong2: 500
    readonly property int durationLong3: 550
    readonly property int durationLong4: 600

    // ---------------------------------------------------------------------
    // Dynamic colour
    //
    // Full M3 dynamic colour needs an HCT/CAM16 tonal palette, which is a lot
    // of maths to run in QML. Rather than approximate it badly, these are the
    // real baseline values. Retheming means editing the palette above (or
    // generating a scheme externally and pasting it in), which keeps the tonal
    // relationships exactly right.
    // ---------------------------------------------------------------------
    readonly property string sourceSeed: "#6750a4"
}
