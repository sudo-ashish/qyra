import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"
import "../services"

PanelWindow {
    id: root

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    WlrLayershell.namespace: "qyra-island-powermenu"
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

    // Dynamic Island Floating Pill
    Rectangle {
        id: islandPill
        anchors.top: parent.top
        anchors.topMargin: (Config.bar && Config.bar.position === "bottom") ? 24 : ((Config.bar && Config.bar.height ? Config.bar.height : 34) + 16)
        anchors.horizontalCenter: parent.horizontalCenter

        width: Power.isOpen ? 440 : 260
        height: Power.isOpen ? 94 : 44
        radius: 26
        color: Theme.bg
        border.color: Theme.border
        border.width: 1
        clip: true

        Behavior on width { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.centerIn: parent
            spacing: 6

            // Buttons Row
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Repeater {
                    model: Power.actions

                    Rectangle {
                        id: pillBtn
                        readonly property bool isSelected: root.currentIndex === index
                        readonly property bool isDanger: modelData.id === "shutdown" || modelData.id === "reboot"
                        width: 52
                        height: 52
                        radius: 26
                        color: isSelected ? Theme.surface : (btnMouse.containsMouse ? Theme.surface : "transparent")
                        border.color: isSelected ? (isDanger ? Theme.urgent : Theme.accent) : Theme.border
                        border.width: isSelected ? 2 : 1
                        scale: isSelected ? 1.08 : 1.0

                        Behavior on scale { NumberAnimation { duration: 140 } }
                        Behavior on border.color { ColorAnimation { duration: 140 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 22
                            color: pillBtn.isSelected ? (pillBtn.isDanger ? Theme.urgent : Theme.accent) : Theme.fg
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

            // Active Action Label
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (root.currentIndex >= 0 && root.currentIndex < Power.actions.length) ? Power.actions[root.currentIndex].label : ""
                font.pixelSize: 11
                font.bold: true
                color: Theme.accent
            }
        }
    }
}
