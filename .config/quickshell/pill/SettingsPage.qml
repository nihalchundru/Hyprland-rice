import QtQuick

// Renders one page from its Schema description: header card + groups of rows.
Item {
    id: root

    property var page: ({ title: "", subtitle: "", icon: "", groups: [] })

    height: col.implicitHeight

    Column {
        id: col
        width: parent.width
        spacing: 18

        // header card
        Rectangle {
            width: parent.width
            height: 172
            radius: 26
            color: Theme.inset

            Column {
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64
                    height: 64
                    radius: 32
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
                    font.family: Theme.fontFamily
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.page.subtitle
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                }
            }
        }

        // pages without rows yet (or an empty search)
        Rectangle {
            visible: root.page.groups.length === 0
            width: parent.width
            height: visible ? 76 : 0
            radius: 22
            color: Theme.inset

            Text {
                anchors.centerIn: parent
                text: root.page.emptyText || "This page arrives in a later stage."
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 14
            }
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
                    text: grp.modelData.title.toUpperCase()
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    leftPadding: 4
                }

                Rectangle {
                    width: parent.width
                    height: rows.implicitHeight
                    radius: 22
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
                                width: rows.width
                                height: loader.item ? loader.item.height : 0

                                Loader {
                                    id: loader
                                    width: parent.width
                                    sourceComponent: rowItem.modelData.type === "toggle" ? toggleC : sliderC
                                }

                                Component {
                                    id: toggleC
                                    SToggleRow { def: rowItem.modelData; first: rowItem.index === 0 }
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
