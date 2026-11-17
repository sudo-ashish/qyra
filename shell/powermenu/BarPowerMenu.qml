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
    visible: Power.isOpen || closeAnim.running

    property int currentIndex: 0
    property real animProgress: 0.0

    readonly property var currentAction: (Power.actions && root.currentIndex >= 0 && root.currentIndex < Power.actions.length)
        ? Power.actions[root.currentIndex] : null
    readonly property bool isCurrentDanger: currentAction ? (currentAction.id === "shutdown" || currentAction.id === "reboot") : false

    NumberAnimation {
        id: openAnim
        target: root
        property: "animProgress"
        to: 1.0
        duration: 320
        easing.type: Easing.OutBack
        easing.overshoot: 1.15
    }

    NumberAnimation {
        id: closeAnim
        target: root
        property: "animProgress"
        to: 0.0
        duration: 200
        easing.type: Easing.InCubic
        onFinished: root.animProgress = 0.0
    }

    Connections {
        target: Power
        function onIsOpenChanged() {
            if (Power.isOpen) {
                closeAnim.stop();
                root.animProgress = 0.0;
                root.currentIndex = 0;
                openAnim.restart();
                Qt.callLater(function() { keyCatcher.forceActiveFocus(); });
            } else {
                openAnim.stop();
                closeAnim.restart();
            }
        }
    }

    // Material 3 Scrim Backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.withAlpha(Theme.bg, 0.45)
        opacity: root.animProgress

        MouseArea {
            anchors.fill: parent
            onClicked: Power.close()
        }
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
            if (root.currentAction) root.currentAction.action();
        }
        Keys.onSpacePressed: {
            if (root.currentAction) root.currentAction.action();
        }
        Keys.onEscapePressed: Power.close()

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_H) {
                if (Power.actions.length > 0) root.currentIndex = (root.currentIndex - 1 + Power.actions.length) % Power.actions.length;
                event.accepted = true;
            } else if (event.key === Qt.Key_L) {
                if (Power.actions.length > 0) root.currentIndex = (root.currentIndex + 1) % Power.actions.length;
                event.accepted = true;
            } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
                var idx = event.key - Qt.Key_1;
                if (idx < Power.actions.length) {
                    root.currentIndex = idx;
                    Power.actions[idx].action();
                }
                event.accepted = true;
            }
        }
    }

    // Bottom-anchored Floating Pop-Up Card
    Rectangle {
        id: card
        width: 380
        height: 136
        radius: 20
        clip: true

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: (Config.bar && Config.bar.position === "bottom") ? ((Config.bar.height || 34) + 16) : 32
        }

        color: Theme.withAlpha(Theme.bg, 0.90)
        border.color: Theme.withAlpha(Theme.border, 0.35)
        border.width: 1

        transform: Translate { y: (1.0 - root.animProgress) * (card.height + 64) }
        scale: 0.94 + 0.06 * Math.max(0, Math.min(1.0, root.animProgress))
        opacity: Math.min(1.0, root.animProgress * 1.5)

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // Header Row with Status
            Item {
                width: parent.width
                height: 22

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Session Control"
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.fg
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.currentAction ? root.currentAction.label : ""
                    font.pixelSize: 12
                    font.bold: true
                    color: root.isCurrentDanger ? Theme.urgent : Theme.accent
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            // Subtle Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.withAlpha(Theme.border, 0.40)
            }

            // Action Buttons Row
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Repeater {
                    model: Power.actions

                    PowerButton {
                        modelData: modelData
                        index: index
                        isActive: root.currentIndex === index
                        onSelected: root.currentIndex = index
                        onActivated: modelData.action()
                    }
                }
            }
        }
    }
}
