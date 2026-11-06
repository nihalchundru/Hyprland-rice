import QtQuick

Item {
    id: root
    width: 600
    height: 500

    // ── theme colors (all from colors.json via Theme) ─────────────
    // if your Theme names the accent differently, change only this line
    readonly property color accent: Theme.accent

    // Theme.text at a given opacity, used for highlights, buttons and dividers
    function tint(a) {
        return Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, a);
    }
    function accentTint(a) {
        return Qt.rgba(accent.r, accent.g, accent.b, a);
    }

    property int sel: 0
    readonly property var list: ClipboardService.filtered

    onListChanged: if (sel >= list.length) sel = Math.max(0, list.length - 1)

    function copySel() {
        if (list.length === 0) return;
        ClipboardService.copy(list[Math.min(sel, list.length - 1)].id);
        Pill.close();
    }

    // "[[ binary data 12 KiB png 800x600 ]]" -> "12 KiB png 800x600"
    function imageInfo(preview) {
        const m = preview.match(/^\[\[ binary data (.*) \]\]$/);
        return m ? m[1] : "Image";
    }

    // when the page opens: fresh list, empty search, keyboard goes to the search box
    Connections {
        target: Pill
        function onModeChanged() {
            if (Pill.mode === "clipboard") {
                ClipboardService.refresh();
                search.text = "";
                root.sel = 0;
                focusTimer.restart();
            }
        }
    }
    Timer { id: focusTimer; interval: 80; onTriggered: search.forceActiveFocus() }

    // ── search header ─────────────────────────────────────────────
    Canvas {
        id: magnifier
        x: 30
        y: 27
        width: 22
        height: 22
        property color fg: Theme.dim
        onFgChanged: requestPaint()
        Component.onCompleted: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = fg;
            ctx.lineWidth = 1.8;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(9.5, 9.5, 6.2, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(14.2, 14.2);
            ctx.lineTo(19, 19);
            ctx.stroke();
        }
    }

    TextInput {
        id: search
        x: 70
        y: 16
        width: root.width - 70 - 28 - 76 - 12
        height: 44
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.text
        selectionColor: root.accentTint(0.35)
        selectByMouse: true
        clip: true
        renderType: Text.NativeRendering
        font.family: Theme.fontFamily
        font.pixelSize: Math.round(Theme.px(20))

        onTextChanged: {
            ClipboardService.filter = text;
            root.sel = 0;
        }

        Keys.onEscapePressed: Pill.back()
        Keys.onPressed: (event) => {
            const n = root.list.length;
            if (event.key === Qt.Key_Down) {
                root.sel = Math.min(root.sel + 1, Math.max(0, n - 1));
                listView.positionViewAtIndex(root.sel, ListView.Contain);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.sel = Math.max(root.sel - 1, 0);
                listView.positionViewAtIndex(root.sel, ListView.Contain);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.copySel();
                event.accepted = true;
            }
        }

        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: search.text.length === 0
            text: "Search..."
            color: Theme.dim
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.pixelSize: Math.round(Theme.px(20))
        }
    }

    // clear all
    Rectangle {
        x: root.width - 28 - 76
        y: 22
        width: 76
        height: 32
        radius: 16
        color: root.tint(clearMa.containsMouse ? 0.14 : 0.07)
        scale: clearMa.pressed ? 0.96 : 1
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

        Text {
            anchors.centerIn: parent
            text: "Clear"
            color: Theme.text
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.pixelSize: Math.round(Theme.px(13))
            font.weight: Font.Medium
        }
        MouseArea {
            id: clearMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ClipboardService.wipe()
        }
    }

    // divider
    Rectangle {
        x: 28
        y: 76
        width: root.width - 56
        height: 1
        color: root.tint(0.10)
    }

    // ── history list ──────────────────────────────────────────────
    ListView {
        id: listView
        x: 16
        y: 88
        width: root.width - 32
        height: root.height - 88 - 44
        clip: true
        spacing: 4
        model: root.list
        currentIndex: root.sel

        // we move the highlight ourselves so it can glide with an easing curve
        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            width: listView.width
            height: 64
            radius: 18
            visible: listView.currentItem !== null
            y: listView.currentItem ? listView.currentItem.y : 0
            color: root.tint(0.08)

            Behavior on y { NumberAnimation { duration: 230; easing.type: Easing.OutCubic } }

            // accent bar rides along with the highlight
            Rectangle {
                x: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 3.5
                height: 30
                radius: 1.75
                color: root.accent
            }
        }

        delegate: Item {
            id: rowItem
            required property var modelData
            required property int index
            readonly property bool selected: index === root.sel

            width: listView.width
            height: 64

            // only real mouse movement moves the selection (not content scrolling under the pointer)
            MouseArea {
                id: rowMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: root.sel = rowItem.index
                onClicked: {
                    ClipboardService.copy(rowItem.modelData.id);
                    Pill.close();
                }
            }

            // icon tile with a clipboard icon, tinted by the accent
            Rectangle {
                id: tile
                x: 22
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48
                radius: 14
                color: root.accentTint(rowItem.selected ? 0.20 : 0.12)
                Behavior on color { ColorAnimation { duration: 180 } }

                Canvas {
                    id: clipIcon
                    anchors.fill: parent
                    property bool isImage: rowItem.modelData.isImage
                    property color board: Theme.text
                    property color clip: root.accent
                    property color ink: Qt.rgba(0, 0, 0, 0.38)

                    onIsImageChanged: requestPaint()
                    onBoardChanged: requestPaint()
                    onClipChanged: requestPaint()
                    Component.onCompleted: requestPaint()

                    function rr(ctx, x, y, w, h, r) {
                        ctx.beginPath();
                        ctx.moveTo(x + r, y);
                        ctx.lineTo(x + w - r, y);
                        ctx.arcTo(x + w, y, x + w, y + r, r);
                        ctx.lineTo(x + w, y + h - r);
                        ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
                        ctx.lineTo(x + r, y + h);
                        ctx.arcTo(x, y + h, x, y + h - r, r);
                        ctx.lineTo(x, y + r);
                        ctx.arcTo(x, y, x + r, y, r);
                        ctx.closePath();
                    }

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        const s = width;

                        // board
                        ctx.fillStyle = board;
                        rr(ctx, s * 0.25, s * 0.20, s * 0.50, s * 0.60, 5);
                        ctx.fill();

                        // clip
                        ctx.fillStyle = clip;
                        rr(ctx, s * 0.37, s * 0.13, s * 0.26, s * 0.14, 3.5);
                        ctx.fill();

                        ctx.fillStyle = ink;
                        if (isImage) {
                            // little picture on the board
                            ctx.beginPath();
                            ctx.moveTo(s * 0.31, s * 0.71);
                            ctx.lineTo(s * 0.44, s * 0.50);
                            ctx.lineTo(s * 0.53, s * 0.62);
                            ctx.lineTo(s * 0.58, s * 0.55);
                            ctx.lineTo(s * 0.69, s * 0.71);
                            ctx.closePath();
                            ctx.fill();
                            ctx.beginPath();
                            ctx.arc(s * 0.62, s * 0.42, s * 0.04, 0, Math.PI * 2);
                            ctx.fill();
                        } else {
                            // text lines
                            ctx.fillRect(s * 0.32, s * 0.42, s * 0.36, s * 0.045);
                            ctx.fillRect(s * 0.32, s * 0.53, s * 0.36, s * 0.045);
                            ctx.fillRect(s * 0.32, s * 0.64, s * 0.22, s * 0.045);
                        }
                    }
                }
            }

            // title + subtitle
            Column {
                anchors.left: tile.right
                anchors.leftMargin: 16
                anchors.right: delBtn.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    text: rowItem.modelData.isImage ? "Image" : rowItem.modelData.preview
                    color: Theme.text
                    renderType: Text.NativeRendering
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(Theme.px(17))
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    text: rowItem.modelData.isImage ? root.imageInfo(rowItem.modelData.preview) : "Text"
                    color: Theme.dim
                    renderType: Text.NativeRendering
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(Theme.px(14))
                }
            }

            // delete button (shows on the selected row)
            Rectangle {
                id: delBtn
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                height: 30
                radius: 15
                color: root.tint(delMa.containsMouse ? 0.20 : 0.09)
                opacity: rowItem.selected ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 160 } }
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "\u00d7"
                    color: Theme.text
                    renderType: Text.NativeRendering
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(Theme.px(18))
                }
                MouseArea {
                    id: delMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ClipboardService.remove(rowItem.modelData.id)
                }
            }
        }
    }

    // empty / error state
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 230
        visible: root.list.length === 0
        horizontalAlignment: Text.AlignHCenter
        text: ClipboardService.error ? "Install cliphist and wl-clipboard"
            : search.text.length > 0 ? "No matches"
            : "Nothing copied yet"
        color: Theme.dim
        renderType: Text.NativeRendering
        font.family: Theme.fontFamily
        font.pixelSize: Math.round(Theme.px(15))
    }

    // footer
    Text {
        x: 30
        y: root.height - 30
        text: root.list.length + (root.list.length === 1 ? " item" : " items")
        color: Theme.dim
        renderType: Text.NativeRendering
        font.family: Theme.fontFamily
        font.pixelSize: Math.round(Theme.px(12))
    }
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 30
        y: root.height - 30
        text: "Enter to copy  \u00b7  Esc to close"
        color: Theme.dim
        renderType: Text.NativeRendering
        font.family: Theme.fontFamily
        font.pixelSize: Math.round(Theme.px(12))
    }
}