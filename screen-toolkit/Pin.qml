import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Widgets
import qs.Services.UI

Variants {
    id: root

    property var pluginApi: null

    property var pins: []
    readonly property bool hasPins: pins.length > 0

    function addPin(imgPath, pw, ph) {
        var p = pins.slice()
        p.push({ imgPath: imgPath, w: Math.min(pw, 900), h: Math.min(ph, 700) })
        pins = p
    }

    function removePin(i) {
        var p = pins.slice()
        p.splice(i, 1)
        pins = p
    }

    function pinField(i, field) {
        if (i < 0 || i >= pins.length) return null
        return pins[i][field]
    }

    model: Quickshell.screens

    delegate: PanelWindow {
        required property ShellScreen modelData
        screen: modelData

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        visible: root.hasPins

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "noctalia-pin"

        mask: Region {
            Region { item: pinRepeater.itemAt(0) }
            Region { item: pinRepeater.itemAt(1) }
            Region { item: pinRepeater.itemAt(2) }
            Region { item: pinRepeater.itemAt(3) }
            Region { item: pinRepeater.itemAt(4) }
            Region { item: pinRepeater.itemAt(5) }
            Region { item: pinRepeater.itemAt(6) }
            Region { item: pinRepeater.itemAt(7) }
            Region { item: pinRepeater.itemAt(8) }
            Region { item: pinRepeater.itemAt(9) }
            Region { item: pinRepeater.itemAt(10) }
            Region { item: pinRepeater.itemAt(11) }
            Region { item: pinRepeater.itemAt(12) }
            Region { item: pinRepeater.itemAt(13) }
            Region { item: pinRepeater.itemAt(14) }
            Region { item: pinRepeater.itemAt(15) }
            Region { item: pinRepeater.itemAt(16) }
            Region { item: pinRepeater.itemAt(17) }
            Region { item: pinRepeater.itemAt(18) }
            Region { item: pinRepeater.itemAt(19) }
            Region { item: pinRepeater.itemAt(20) }
            Region { item: pinRepeater.itemAt(21) }
            Region { item: pinRepeater.itemAt(22) }
            Region { item: pinRepeater.itemAt(23) }
            Region { item: pinRepeater.itemAt(24) }
            Region { item: pinRepeater.itemAt(25) }
            Region { item: pinRepeater.itemAt(26) }
            Region { item: pinRepeater.itemAt(27) }
            Region { item: pinRepeater.itemAt(28) }
            Region { item: pinRepeater.itemAt(29) }
        }

        Repeater {
            id: pinRepeater
            model: root.pins.length

            delegate: Item {
                id: pinDelegate

                readonly property int myIdx: index
                readonly property string pinImgPath: root.pinField(myIdx, "imgPath") || ""
                readonly property real pinW: root.pinField(myIdx, "w") || 400
                readonly property real pinH: root.pinField(myIdx, "h") || 300

                x: (parent.width  - pinW)  / 2 + myIdx * 24
                y: (parent.height - pinH)   / 2 + myIdx * 24
                width:  pinW
                height: pinH

                property bool _hovered: false

                Rectangle {
                    id: pinCard
                    anchors.fill: parent
                    radius: Style.radiusL
                    color: Color.mSurface
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: pinDelegate.pinImgPath !== "" ? "file://" + pinDelegate.pinImgPath : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        drag.target: pinDelegate
                        drag.minimumX: -pinDelegate.width + 40
                        drag.maximumX: pinDelegate.parent ? pinDelegate.parent.width - 40 : 9999
                        drag.minimumY: 0
                        drag.maximumY: pinDelegate.parent ? pinDelegate.parent.height - 40 : 9999
                        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        onEntered: pinDelegate._hovered = true
                        onExited: { if (!closeBtn.containsMouse) pinDelegate._hovered = false }
                    }

                    Rectangle {
                        anchors { top: parent.top; right: parent.right; margins: 8 }
                        width: 24; height: 24; radius: 12
                        color: closeBtn.containsMouse ? Qt.rgba(0, 0, 0, 0.8) : Qt.rgba(0, 0, 0, 0.5)
                        visible: pinDelegate._hovered || closeBtn.containsMouse
                        opacity: pinDelegate._hovered ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        NIcon {
                            anchors.centerIn: parent; icon: "x"; scale: 0.75
                            color: "white"
                        }
                        MouseArea {
                            id: closeBtn; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.removePin(pinDelegate.myIdx)
                            onEntered: { pinDelegate._hovered = true; TooltipService.show(closeBtn, root.pluginApi?.tr("pin.close")) }
                            onExited: { pinDelegate._hovered = false; TooltipService.hide() }
                        }
                    }
                }
            }
        }
    }
}
