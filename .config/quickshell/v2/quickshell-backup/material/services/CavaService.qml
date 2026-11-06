pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var barsData: [0, 0, 0, 0, 0, 0, 0, 0]

    Process {
        id: cavaProcess

        command: [
            "/usr/bin/cava",
            "-p",
            Quickshell.env("HOME")
                + "/.config/quickshell/material/services/cava.conf"
        ]

        running: true

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                const values = data.trim()
                    .split(";")
                    .filter(v => v.trim().length > 0)
                    .map(v => Number(v))

                if (values.length === 8 &&
                    values.every(v => Number.isFinite(v))) {
                    root.barsData = values
                }
            }
        }
    }
}