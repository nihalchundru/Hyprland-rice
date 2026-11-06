import QtQuick
import "../core"
import "../components"

Item {
    id: root
    implicitHeight: col.implicitHeight

    property bool confirmDelete: false
    readonly property bool onlyOne: LayoutStore.profileNames.length <= 1
    readonly property var sty: wd?.style ?? ({})

    Component.onCompleted: ProfileIO.refresh()

    Timer { id: confirmTimer; interval: 3000; onTriggered: root.confirmDelete = false }

    Connections {
        target: LayoutStore
        function onActiveProfileChanged() { root.confirmDelete = false; }
    }

    Column {
        id: col
        width: parent.width
        spacing: 6

        // ---------- layouts ----------
        Section { width: col.width; text: "Layouts" }

        Repeater {
            model: LayoutStore.profileNames

            delegate: Rectangle {
                id: row
                required property string modelData
                readonly property bool active: modelData === LayoutStore.activeProfile

                width: col.width
                height: 48
                radius: 14
                color: active ? Qt.alpha(Theme.accent, 0.18)
                     : rowMa.containsMouse ? Qt.lighter(Theme.cardAlt, 1.12)
                     : Theme.cardAlt
                border.width: active ? 2 : 0
                border.color: Theme.accent
                Behavior on color { ColorAnimation { duration: 120 } }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.right: tag.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Txt {
                        width: parent.width
                        text: row.modelData
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    Txt {
                        text: LayoutStore.profileWidgets(row.modelData).length + " widgets"
                        color: Theme.onSurfaceDim
                        font.pixelSize: 11
                    }
                }

                Txt {
                    id: tag
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.active ? "Active" : ""
                    color: Theme.accent
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: rowMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: LayoutStore.switchProfile(row.modelData)
                }
            }
        }

        Item { width: 1; height: 6 }

        Field {
            width: col.width
            label: "Name of active layout"
            text: LayoutStore.activeProfile
            placeholder: "Layout name"
            onCommitted: v => LayoutStore.renameProfile(LayoutStore.activeProfile, v)
        }
                Section { width: col.width; text: "Appearance" }

        Swatches {
            width: col.width
            label: "Accent color"
            current: root.sty.accent ?? "accent"
            onPicked: r => LayoutStore.setWidgetStyle(root.wid, "accent", r === "accent" ? null : r)
        }
        Segmented {
            width: col.width
            label: "Background"
            options: ["card", "alt", "transparent"]
            current: root.sty.background ?? "card"
            onPicked: v => LayoutStore.setWidgetStyle(root.wid, "background", v === "card" ? null : v)
        }
        Toggle {
            width: col.width
            label: "Outline"
            checked: root.sty.outline ?? ((root.sty.background ?? "card") !== "transparent")
            onToggled: v => LayoutStore.setWidgetStyle(root.wid, "outline", v)
        }
        OverrideSlide {
            width: col.width
            visible: (root.sty.background ?? "card") !== "transparent"
            label: "Opacity"
            value: root.sty.opacity
            inherited: LayoutStore.cardOpacity
            from: 0.1; to: 1; step: 0.01
            displayScale: 100
            suffix: "%"
            onEdited: v => LayoutStore.setWidgetStyle(root.wid, "opacity", v)
        }
        OverrideSlide {
            width: col.width
            label: "Corner radius"
            value: root.sty.radius
            inherited: LayoutStore.radius
            from: 0; to: 40; step: 1
            suffix: " px"
            onEdited: v => LayoutStore.setWidgetStyle(root.wid, "radius", v)
        }
        OverrideSlide {
            width: col.width
            label: "Padding"
            value: root.sty.padding
            inherited: LayoutStore.padding
            from: 4; to: 32; step: 1
            suffix: " px"
            onEdited: v => LayoutStore.setWidgetStyle(root.wid, "padding", v)
        }
        Btn {
            text: "Reset appearance"
            enabled: Object.keys(root.sty).length > 0
            onClicked: LayoutStore.resetWidgetStyle(root.wid)
        }
        Row {
            spacing: 8

            Btn {
                text: "New"
                onClicked: LayoutStore.createProfile("New layout")
            }
            Btn {
                text: "Duplicate"
                onClicked: LayoutStore.duplicateProfile(LayoutStore.activeProfile)
            }
            Btn {
                text: root.confirmDelete ? "Click again" : "Delete"
                danger: true
                enabled: !root.onlyOne
                onClicked: {
                    if (!root.confirmDelete) {
                        root.confirmDelete = true;
                        confirmTimer.restart();
                    } else {
                        root.confirmDelete = false;
                        LayoutStore.deleteProfile(LayoutStore.activeProfile);
                    }
                }
            }
        }

        Txt {
            width: col.width
            wrapMode: Text.WordWrap
            text: "A layout stores which widgets you have and where. Style and grid are shared by all layouts."
            color: Theme.onSurfaceDim
            font.pixelSize: 11
        }

        // ---------- share ----------
        Section { width: col.width; text: "Share" }

        Btn {
            text: "Export active layout"
            onClicked: ProfileIO.exportProfile(LayoutStore.activeProfile)
        }
        Txt {
            width: col.width
            wrapMode: Text.WordWrap
            text: "Files live in " + ProfileIO.shownDir
            color: Theme.onSurfaceDim
            font.pixelSize: 11
        }

        Item {
            width: col.width
            height: 36

            Txt {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Import from that folder"
                font.pixelSize: 13
            }
            Btn {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Refresh"
                onClicked: ProfileIO.refresh()
            }
        }

        Txt {
            visible: ProfileIO.files.length === 0
            width: col.width
            wrapMode: Text.WordWrap
            text: "No layout files yet. Export one, or drop a layout .json into the folder."
            color: Theme.onSurfaceDim
            font.pixelSize: 12
        }

        Repeater {
            model: ProfileIO.files

            delegate: Rectangle {
                id: fileRow
                required property string modelData

                width: col.width
                height: 40
                radius: 12
                color: Theme.cardAlt

                Txt {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: importBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: fileRow.modelData.replace(/\.json$/, "")
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
                Btn {
                    id: importBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Import"
                    onClicked: ProfileIO.importFile(fileRow.modelData)
                }
            }
        }

        Txt {
            visible: ProfileIO.message !== ""
            width: col.width
            wrapMode: Text.WordWrap
            text: ProfileIO.message
            color: ProfileIO.isError ? Theme.danger : Theme.ok
            font.pixelSize: 12
        }

        // ---------- reset ----------
        Section { width: col.width; text: "Reset" }

        Row {
            spacing: 8

            Btn { text: "Reset layout"; onClicked: LayoutStore.resetLayout() }
            Btn { text: "Reset style & grid"; onClicked: LayoutStore.resetStyle() }
        }
        Txt {
            width: col.width
            wrapMode: Text.WordWrap
            text: "Both can be undone with Ctrl+Z."
            color: Theme.onSurfaceDim
            font.pixelSize: 11
        }
    }
}