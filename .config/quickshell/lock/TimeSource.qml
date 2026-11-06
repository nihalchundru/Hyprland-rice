pragma Singleton

import Quickshell
import QtQuick

// Single clock for every widget, so the analogue sweep, the digital readout and
// the seconds hand can never disagree.
//
// The timer only runs while a lock surface is actually visible -- this shell
// sits as a background daemon waiting to be locked, and there is no reason to
// wake up 60 times a second (or even once a second) while unlocked.
Singleton {
    id: root

    property bool active: false
    property real now: Date.now()

    onActiveChanged: {
        if (active) root.now = Date.now();
    }

    Timer {
        // 16ms is roughly one frame, which is what makes the seconds hand
        // sweep instead of tick.
        interval: 16
        running: root.active
        repeat: true
        onTriggered: root.now = Date.now()
    }

    readonly property date date: new Date(root.now)
}
