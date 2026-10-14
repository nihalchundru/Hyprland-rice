import QtQuick

// Renders one page from its Schema description: header card + groups of rows.
Item {
    id: root

    property var page: ({ title: "", subtitle: "", icon: "", groups: [] })
    signal dismissRequested()

    height: col.implicitHeight

    Column {
        id: col
        width: parent.width
        spacing: 18

        // header card
        Rectangle {
            width: parent.width
            height: 172
            radius: Theme.r(26)
            color: Theme.inset

            Column {
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64
                    height: 64
                    radius: Theme.r(32)
                    color: Theme.mix(Theme.body, Theme.accent, 0.22)

                    Icon {
                        anchors.centerIn: parent
                        name: root.page.icon
                        size: 28
                        color: Theme.accent
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.page.title
                    color: Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.px(22)
                    font.weight: Font.Medium
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.page.subtitle
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(14)
                }
            }
        }

        // pages without rows yet (or an empty search)
        Rectangle {
            visible: root.page.groups.length === 0 && !root.page.custom
            width: parent.width
            height: visible ? 76 : 0
            radius: Theme.r(22)
            color: Theme.inset

            Text {
                anchors.centerIn: parent
                text: root.page.emptyText || "This page arrives in a later stage."
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(14)
            }
        }

        // pages with their own editor instead of rows
        Loader {
            active: root.page.custom === "control"
            visible: active
            width: parent.width
            source: "ControlEditor.qml"
            onLoaded: item.dismissRequested.connect(root.dismissRequested)
        }

        Repeater {
            model: root.page.groups

            delegate: Column {
                id: grp
                required property var modelData
                width: col.width
                spacing: 8

                Text {
                    visible: grp.modelData.title !== ""
                    text: grp.modelData.upper ? grp.modelData.title.toUpperCase() : grp.modelData.title
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(11)
                    leftPadding: 4
                }

                Rectangle {
                    width: parent.width
                    height: rows.implicitHeight
                    radius: Theme.r(22)
                    color: Theme.inset

                    Column {
                        id: rows
                        width: parent.width

                        Repeater {
                            model: grp.modelData.rows

                            delegate: Item {
                                id: rowItem
                                required property var modelData
                                required property int index

                                function pick(t) {
                                    switch (t) {
                                    case "toggle": return toggleC;
                                    case "choice": return choiceC;
                                    case "nav": return navC;
                                    case "swatches": return swatchC;
                                    case "text": return textC;
                                    case "info": return infoC;
                                    case "action": return actionC;
                                    }
                                    return sliderC;
                                }
                                readonly property bool shown: (!modelData.hideWhen || !Settings.get(modelData.hideWhen))
                                                              && (!modelData.showIf || Settings.get(modelData.showIf[0]) === modelData.showIf[1])
                                visible: shown
                                width: rows.width
                                height: shown && loader.item ? loader.item.height : 0

                                Loader {
                                    id: loader
                                    width: parent.width
                                    sourceComponent: rowItem.pick(rowItem.modelData.type)
                                }

                                Component {
                                    id: toggleC
                                    SToggleRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                                Component {
                                    id: choiceC
                                    SChoiceRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                                Component {
                                    id: navC
                                    SNavRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                                Component {
                                    id: swatchC
                                    SSwatchRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                                Component {
                                    id: textC
                                    STextRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                                Component {
                                    id: infoC
                                    SInfoRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                                Component {
                                    id: actionC
                                    SActionRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                                Component {
                                    id: sliderC
                                    SSliderRow { def: rowItem.modelData; first: rowItem.index === 0 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
