pragma Singleton
import QtQuick

QtObject {
    id: root

    // ------------------------------------------------------------------------
    // Material 3 Expressive Cubic-Bezier Curves
    // Format: [x1, y1, x2, y2, 1.0, 1.0] for Easing.BezierSpline
    // ------------------------------------------------------------------------
    readonly property var standard:             [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
    readonly property var standardAccelerate:   [0.3, 0.0, 1.0, 1.0, 1.0, 1.0]
    readonly property var standardDecelerate:   [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]

    readonly property var emphasized:           [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
    readonly property var emphasizedDecelerate: [0.05, 0.7, 0.1, 1.0, 1.0, 1.0]
    readonly property var emphasizedAccelerate: [0.3, 0.0, 0.8, 0.15, 1.0, 1.0]

    // Expressive overshoot curves for shape morphing & pill expansion
    readonly property var expressiveSpatialFast:    [0.42, 1.67, 0.21, 0.90, 1.0, 1.0]
    readonly property var expressiveFastSpatial:    [0.42, 1.67, 0.21, 0.90, 1.0, 1.0]
    readonly property var expressiveSpatialDefault: [0.38, 1.21, 0.22, 1.00, 1.0, 1.0]
    readonly property var expressiveSpatialSlow:    [0.39, 1.29, 0.35, 0.98, 1.0, 1.0]

    // ------------------------------------------------------------------------
    // Material 3 Expressive Spring Constants (for SpringAnimation)
    // ------------------------------------------------------------------------
    readonly property real springFastStiffness:    6.0
    readonly property real springFastDamping:      0.62

    readonly property real springDefaultStiffness: 4.5
    readonly property real springDefaultDamping:   0.68

    readonly property real springSlowStiffness:    3.2
    readonly property real springSlowDamping:      0.74

    // ------------------------------------------------------------------------
    // Material 3 Duration Scale (ms)
    // ------------------------------------------------------------------------
    readonly property int durationShort1:  50
    readonly property int durationShort2:  100
    readonly property int durationShort3:  150
    readonly property int durationShort4:  200

    readonly property int durationMedium1: 250
    readonly property int durationMedium2: 300
    readonly property int durationMedium3: 350
    readonly property int durationMedium4: 400

    readonly property int durationLong1:   450
    readonly property int durationLong2:   500
    readonly property int durationLong3:   550
    readonly property int durationLong4:   600

    readonly property int durationMorph:   350
    readonly property int durationColor:   250

    // ------------------------------------------------------------------------
    // Material 3 Corner Radius Scale (dp / px)
    // ------------------------------------------------------------------------
    readonly property int radiusNone:              0
    readonly property int radiusExtraSmall:        4
    readonly property int radiusSmall:             8
    readonly property int radiusMedium:            12
    readonly property int radiusLarge:             16
    readonly property int radiusLargeIncreased:    20
    readonly property int radiusExtraLarge:        28
    readonly property int radiusExtraLargeInc:     32
    readonly property int radiusExtraExtraLarge:   48
    readonly property int radiusFull:              9999

    // ------------------------------------------------------------------------
    // Material 3 State Layer Opacities
    // ------------------------------------------------------------------------
    readonly property real stateHoverOpacity:    0.08
    readonly property real stateFocusOpacity:    0.10
    readonly property real statePressOpacity:    0.10
    readonly property real stateDraggedOpacity:  0.16
    readonly property real stateDisabledContent: 0.38
    readonly property real stateDisabledBg:      0.12

    // ------------------------------------------------------------------------
    // Material 3 Elevation Scale (px)
    // ------------------------------------------------------------------------
    readonly property int elevation0: 0
    readonly property int elevation1: 1
    readonly property int elevation2: 3
    readonly property int elevation3: 6
    readonly property int elevation4: 8
    readonly property int elevation5: 12
}
