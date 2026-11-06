import QtQuick
import qs.tokens
// Spring for position/size/shape. eps = stop threshold (use 0.002 for scale/unit-range values).
// Usage: SpatialBehavior on x { preset: M3Motion.spatialFast }
Behavior {
    property var preset: M3Motion.spatialDefault
    property real eps: preset.epsilon
    SpringAnimation { spring: preset.spring; damping: preset.damping; epsilon: eps }
}
