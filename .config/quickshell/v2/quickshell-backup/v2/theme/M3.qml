pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property QtObject shape: QtObject {
        readonly property int none: 0
        readonly property int extraSmall: 4
        readonly property int small: 8
        readonly property int medium: 12
        readonly property int large: 16
        readonly property int extraLarge: 28
        readonly property int full: 9999
    }

    readonly property QtObject motion: QtObject {
        readonly property int short2: 100
        readonly property int short4: 200
        readonly property int medium1: 250
        readonly property int medium2: 300
        readonly property int medium4: 400
        readonly property int long2: 500
        // cubic-bezier control points as [x1,y1,x2,y2,1,1]
        readonly property var standard:             [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
        readonly property var emphasizedDecelerate: [0.05, 0.7, 0.1, 1.0, 1.0, 1.0]
        readonly property var emphasizedAccelerate: [0.3, 0.0, 0.8, 0.15, 1.0, 1.0]
    }

    readonly property QtObject stateLayer: QtObject {
        readonly property real hover: 0.08
        readonly property real focus: 0.10
        readonly property real pressed: 0.10
        readonly property real dragged: 0.16
        readonly property real disabledContent: 0.38
        readonly property real disabledContainer: 0.12
    }

    // M3 type scale (px)
    readonly property var type: ({
        headlineSmall: { size: 24, weight: Font.Normal, tracking: 0 },
        titleLarge:    { size: 22, weight: Font.Normal, tracking: 0 },
        titleMedium:   { size: 16, weight: Font.Medium, tracking: 0.15 },
        titleSmall:    { size: 14, weight: Font.Medium, tracking: 0.1 },
        bodyLarge:     { size: 16, weight: Font.Normal, tracking: 0.5 },
        bodyMedium:    { size: 14, weight: Font.Normal, tracking: 0.25 },
        bodySmall:     { size: 12, weight: Font.Normal, tracking: 0.4 },
        labelLarge:    { size: 14, weight: Font.Medium, tracking: 0.1 },
        labelMedium:   { size: 12, weight: Font.Medium, tracking: 0.5 },
        labelSmall:    { size: 11, weight: Font.Medium, tracking: 0.5 }
    })
}