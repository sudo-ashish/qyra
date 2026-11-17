import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"
import "../services"

PanelWindow {
    id: root

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    WlrLayershell.namespace: "qyra-powermenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Power.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    visible: Power.isOpen

    property int currentIndex: 0

    onVisibleChanged: {
        if (visible) {
            root.currentIndex = 0;
            Qt.callLater(function() { keyCatcher.forceActiveFocus(); });
        }
    }

    // Dismiss on outside click
    MouseArea {
        anchors.fill: parent
        onClicked: Power.close()
    }

    Item {
        id: keyCatcher
        focus: true

        Keys.onLeftPressed: {
            if (Power.actions.length > 0) {
                root.currentIndex = (root.currentIndex - 1 + Power.actions.length) % Power.actions.length;
            }
        }
        Keys.onRightPressed: {
            if (Power.actions.length > 0) {
                root.currentIndex = (root.currentIndex + 1) % Power.actions.length;
            }
        }
        Keys.onReturnPressed: {
            if (root.currentIndex >= 0 && root.currentIndex < Power.actions.length) {
                Power.actions[root.currentIndex].action();
            }
        }
        Keys.onSpacePressed: {
            if (root.currentIndex >= 0 && root.currentIndex < Power.actions.length) {
                Power.actions[root.currentIndex].action();
            }
        }
        Keys.onEscapePressed: Power.close()
    }

    // Crisp Centered Command Card
    Rectangle {
        id: card
        width: 500
        height: 190
        anchors.centerIn: parent
        radius: 8
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // Header
            Item {
                width: parent.width
                height: 24

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Session Control"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.fg
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "ESC to cancel"
                    font.pixelSize: 11
                    color: Theme.muted
                }
            }

            // Action Buttons Row
            Row {
                width: parent.width
                height: 96
                spacing: 10

                Repeater {
                    model: Power.actions

                    Rectangle {
                        id: btn
                        readonly property bool isSelected: root.currentIndex === index
                        readonly property bool isDanger: modelData.id === "shutdown" || modelData.id === "reboot"
                        width: (parent.width - (4 * 10)) / 5
                        height: parent.height
                        radius: 6
                        color: isSelected ? Theme.surface : (btnMouse.containsMouse ? Theme.surface : "transparent")
                        border.color: isSelected ? (isDanger ? Theme.urgent : Theme.accent) : Theme.border
                        border.width: isSelected ? 2 : 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.icon
                                font.pixelSize: 26
                                color: btn.isSelected ? (btn.isDanger ? Theme.urgent : Theme.accent) : Theme.fg
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                font.pixelSize: 12
                                font.bold: btn.isSelected
                                color: btn.isSelected ? Theme.fg : Theme.muted
                            }
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.currentIndex = index
                            onClicked: modelData.action()
                        }
                    }
                }
            }
        }
    }
}
