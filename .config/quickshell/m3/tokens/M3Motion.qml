pragma Singleton
import QtQuick
import Quickshell
import qs.services

// Durations (ms), easings (BezierSpline arrays), spring presets (for SpringAnimation).
// Spring values are Qt-unit approximations of M3 Expressive tokens; tune in the stage-2 gallery.
Singleton {
    readonly property int short1: Math.round(50 * M3Config.motionScale)
    readonly property int short2: Math.round(100 * M3Config.motionScale)
    readonly property int short3: Math.round(150 * M3Config.motionScale)
    readonly property int short4: Math.round(200 * M3Config.motionScale)
    readonly property int medium1: Math.round(250 * M3Config.motionScale)
    readonly property int medium2: Math.round(300 * M3Config.motionScale)
    readonly property int medium3: Math.round(350 * M3Config.motionScale)
    readonly property int medium4: Math.round(400 * M3Config.motionScale)
    readonly property int long1: Math.round(450 * M3Config.motionScale)
    readonly property int long2: Math.round(500 * M3Config.motionScale)
    readonly property int long3: Math.round(550 * M3Config.motionScale)
    readonly property int long4: Math.round(600 * M3Config.motionScale)
    readonly property int extraLong1: Math.round(700 * M3Config.motionScale)
    readonly property int extraLong2: Math.round(800 * M3Config.motionScale)

    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property var standardDecel: [0, 0, 0, 1, 1, 1]
    readonly property var standardAccel: [0.3, 0, 1, 1, 1, 1]
    readonly property var emphasized: [0.2, 0, 0, 1, 1, 1]
    readonly property var emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]

    // spatial = slight overshoot (position/size/shape); effects = no overshoot (color/opacity)
    readonly property var spatialFast: ({ spring: 4.5, damping: 0.34, epsilon: 0.25 })
    readonly property var spatialDefault: ({ spring: 3.0, damping: 0.28, epsilon: 0.25 })
    readonly property var spatialSlow: ({ spring: 2.0, damping: 0.25, epsilon: 0.25 })
    readonly property var effectsFast: ({ spring: 4.5, damping: 0.7, epsilon: 0.01 })
    readonly property var effectsDefault: ({ spring: 3.0, damping: 0.7, epsilon: 0.01 })
    readonly property var effectsSlow: ({ spring: 2.0, damping: 0.7, epsilon: 0.01 })
}
