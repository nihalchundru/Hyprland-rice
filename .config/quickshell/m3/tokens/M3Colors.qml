pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// All M3 roles. Loads m3/colors.json (written by matugen) and cross-fades between palettes.
Singleton {
    id: root
    property var prev: ({})
    property var next: ({})
    property real t: 1

    function c(k, fb) {
        const b = next[k] !== undefined ? Qt.color(next[k]) : Qt.color(fb)
        const a = prev[k] !== undefined ? Qt.color(prev[k]) : b
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1)
    }

    readonly property color primary: c("primary", "#d0bcff")
    readonly property color fgPrimary: c("on_primary", "#381e72")
    readonly property color primaryContainer: c("primary_container", "#4f378b")
    readonly property color fgPrimaryContainer: c("on_primary_container", "#eaddff")
    readonly property color secondary: c("secondary", "#ccc2dc")
    readonly property color fgSecondary: c("on_secondary", "#332d41")
    readonly property color secondaryContainer: c("secondary_container", "#4a4458")
    readonly property color fgSecondaryContainer: c("on_secondary_container", "#e8def8")
    readonly property color tertiary: c("tertiary", "#efb8c8")
    readonly property color fgTertiary: c("on_tertiary", "#492532")
    readonly property color tertiaryContainer: c("tertiary_container", "#633b48")
    readonly property color fgTertiaryContainer: c("on_tertiary_container", "#ffd8e4")
    readonly property color error: c("error", "#f2b8b5")
    readonly property color fgError: c("on_error", "#601410")
    readonly property color errorContainer: c("error_container", "#8c1d18")
    readonly property color fgErrorContainer: c("on_error_container", "#f9dedc")
    readonly property color surface: c("surface", "#141218")
    readonly property color surfaceDim: c("surface_dim", "#141218")
    readonly property color surfaceBright: c("surface_bright", "#3b383e")
    readonly property color surfaceContainerLowest: c("surface_container_lowest", "#0f0d13")
    readonly property color surfaceContainerLow: c("surface_container_low", "#1d1b20")
    readonly property color surfaceContainer: c("surface_container", "#211f26")
    readonly property color surfaceContainerHigh: c("surface_container_high", "#2b2930")
    readonly property color surfaceContainerHighest: c("surface_container_highest", "#36343b")
    readonly property color fgSurface: c("on_surface", "#e6e0e9")
    readonly property color fgSurfaceVariant: c("on_surface_variant", "#cac4d0")
    readonly property color outline: c("outline", "#938f99")
    readonly property color outlineVariant: c("outline_variant", "#49454f")
    readonly property color inverseSurface: c("inverse_surface", "#e6e0e9")
    readonly property color inverseOnSurface: c("inverse_on_surface", "#322f35")
    readonly property color inversePrimary: c("inverse_primary", "#6750a4")
    readonly property color scrim: c("scrim", "#000000")
    readonly property color shadow: c("shadow", "#000000")
    readonly property color surfaceTint: c("surface_tint", "#d0bcff")
    readonly property color background: c("background", "#141218")
    readonly property color fgBackground: c("on_background", "#e6e0e9")
    readonly property color primaryFixed: c("primary_fixed", "#eaddff")
    readonly property color primaryFixedDim: c("primary_fixed_dim", "#d0bcff")
    readonly property color fgPrimaryFixed: c("on_primary_fixed", "#21005d")
    readonly property color fgPrimaryFixedVariant: c("on_primary_fixed_variant", "#4f378b")

    NumberAnimation {
        id: fade
        target: root; property: "t"; from: 0; to: 1
        duration: M3Motion.long2
        easing.type: Easing.BezierSpline
        easing.bezierCurve: M3Motion.standard
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/m3/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const j = JSON.parse(text())
                root.t = 0
                root.prev = root.next
                root.next = j
                fade.restart()
            } catch (e) { console.warn("[m3] bad colors.json:", e) }
        }
    }
}
