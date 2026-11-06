import QtQuick

// Renders a list of 0..1 values as a modern, smooth, gradient bar spectrum.
//
// Visual features:
//   * rounded "pill" bars with a vertical gradient
//   * per-bar height easing (Behavior on height) so motion looks fluid, not steppy
//   * optional center-mirrored layout ([a,b,c] -> [a,b,c,c,b,a])
//   * floating "peak caps" that fall slowly behind the bars (Winamp-style)
//   * optional translucent rounded backdrop panel
Item {
    id: root

    // ── data ─────────────────────────────────────────────────────────────
    property var values: []
    property bool mirrored: true

    // ── appearance ───────────────────────────────────────────────────────
    property color gradientTop: "#7ee7c7"
    property color gradientBottom: "#5b8cff"
    property color peakColor: "#39e7b2"
    property color panelColor: "#0e1116"
    property real panelOpacity: 0.45
    property bool showPanel: true
    property real barSpacing: 3
    property real barRadius: 6
    property real minBarHeight: 3
    // Bars use at most this fraction of the available height.
    property real maxBarScale: 0.9
    property real contentPadding: 14

    // ── motion (ms) ──────────────────────────────────────────────────────
    property int barSmoothing: 110   // bar height easing
    property int peakFall: 420       // peak cap fall easing
    property bool peakCaps: true

    // Mirrored layout duplicates the spectrum reversed around the center.
    readonly property var displayValues: {
        const v = root.values || [];
        if (!root.mirrored)
            return v;
        const r = v.slice();
        r.reverse();
        return v.concat(r);
    }
    readonly property int count: root.displayValues.length
    readonly property real barWidth: count > 0
        ? Math.max(1, (barsArea.width - barSpacing * (count - 1)) / count)
        : 1

    Rectangle {
        id: panel
        visible: root.showPanel
        anchors.fill: parent
        radius: 16
        color: root.panelColor
        opacity: root.panelOpacity
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)
    }

    Item {
        id: barsArea
        anchors.fill: parent
        anchors.margins: root.contentPadding

        Row {
            id: barsRow
            anchors.fill: parent
            spacing: root.barSpacing

            Repeater {
                model: root.count

                delegate: Item {
                    id: cell
                    required property int index
                    width: root.barWidth
                    height: barsRow.height

                    Rectangle {
                        id: bar
                        width: parent.width
                        anchors.bottom: parent.bottom
                        radius: Math.min(width / 2, root.barRadius)
                        height: Math.max(root.minBarHeight,
                                         (root.displayValues[cell.index] || 0)
                                             * parent.height * root.maxBarScale)
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: root.gradientTop }
                            GradientStop { position: 1.0; color: root.gradientBottom }
                        }
                        Behavior on height {
                            NumberAnimation { duration: root.barSmoothing; easing.type: Easing.OutCubic }
                        }
                    }

                    // Peak cap: tracks the bar top but eases far more slowly, so
                    // it appears to float and fall behind the bar.
                    Rectangle {
                        visible: root.peakCaps
                        width: parent.width
                        height: Math.max(2, root.barRadius * 0.6)
                        radius: height / 2
                        color: root.peakColor
                        opacity: 0.95
                        y: bar.y - height - 2
                        Behavior on y {
                            NumberAnimation { duration: root.peakFall; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }
}
