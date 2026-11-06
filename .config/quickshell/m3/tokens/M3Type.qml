pragma Singleton
import QtQuick
import Quickshell
import qs.services

// Usage: font.family: M3Type.family; font.pixelSize: M3Type.bodyMedium.size; font.weight: M3Type.bodyMedium.weight
Singleton {
    readonly property string family: M3Config.fontFamily
    readonly property string icons: "Material Symbols Rounded"
    readonly property string mono: "JetBrains Mono"

    readonly property var displayLarge:  ({ size: Math.round(57 * M3Config.fontScale), line: Math.round(64 * M3Config.fontScale), weight: Font.Normal, tracking: -0.25 })
    readonly property var displayMedium: ({ size: Math.round(45 * M3Config.fontScale), line: Math.round(52 * M3Config.fontScale), weight: Font.Normal, tracking: 0 })
    readonly property var displaySmall:  ({ size: Math.round(36 * M3Config.fontScale), line: Math.round(44 * M3Config.fontScale), weight: Font.Normal, tracking: 0 })
    readonly property var headlineLarge:  ({ size: Math.round(32 * M3Config.fontScale), line: Math.round(40 * M3Config.fontScale), weight: Font.Normal, tracking: 0 })
    readonly property var headlineMedium: ({ size: Math.round(28 * M3Config.fontScale), line: Math.round(36 * M3Config.fontScale), weight: Font.Normal, tracking: 0 })
    readonly property var headlineSmall:  ({ size: Math.round(24 * M3Config.fontScale), line: Math.round(32 * M3Config.fontScale), weight: Font.Normal, tracking: 0 })
    readonly property var titleLarge:  ({ size: Math.round(22 * M3Config.fontScale), line: Math.round(28 * M3Config.fontScale), weight: Font.Normal, tracking: 0 })
    readonly property var titleMedium: ({ size: Math.round(16 * M3Config.fontScale), line: Math.round(24 * M3Config.fontScale), weight: Font.Medium, tracking: 0.15 })
    readonly property var titleSmall:  ({ size: Math.round(14 * M3Config.fontScale), line: Math.round(20 * M3Config.fontScale), weight: Font.Medium, tracking: 0.1 })
    readonly property var bodyLarge:  ({ size: Math.round(16 * M3Config.fontScale), line: Math.round(24 * M3Config.fontScale), weight: Font.Normal, tracking: 0.5 })
    readonly property var bodyMedium: ({ size: Math.round(14 * M3Config.fontScale), line: Math.round(20 * M3Config.fontScale), weight: Font.Normal, tracking: 0.25 })
    readonly property var bodySmall:  ({ size: Math.round(12 * M3Config.fontScale), line: Math.round(16 * M3Config.fontScale), weight: Font.Normal, tracking: 0.4 })
    readonly property var labelLarge:  ({ size: Math.round(14 * M3Config.fontScale), line: Math.round(20 * M3Config.fontScale), weight: Font.Medium, tracking: 0.1 })
    readonly property var labelMedium: ({ size: Math.round(12 * M3Config.fontScale), line: Math.round(16 * M3Config.fontScale), weight: Font.Medium, tracking: 0.5 })
    readonly property var labelSmall:  ({ size: Math.round(11 * M3Config.fontScale), line: Math.round(16 * M3Config.fontScale), weight: Font.Medium, tracking: 0.5 })
}
