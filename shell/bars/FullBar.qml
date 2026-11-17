import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"
import "../services"
import "modules"

PanelWindow {
    id: root

    anchors {
        top: !Config.bar || Config.bar.position === "top"
        bottom: Config.bar && Config.bar.position === "bottom"
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    implicitHeight: (Config.bar && Config.bar.height) ? Config.bar.height : 34
    exclusiveZone: implicitHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        Item {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            // Left Zone: Workspaces + Active Title
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                WorkspacesModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }

                Rectangle {
                    width: 1
                    height: 16
                    color: Theme.border
                    anchors.verticalCenter: parent.verticalCenter
                }

                ActiveTitleModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }
            }

            // Center Zone: Media + Clock
            Row {
                anchors.centerIn: parent
                spacing: 10

                MediaModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }

                ClockModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }
            }

            // Right Zone: Status cluster + Settings
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                TrayModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }

                Rectangle {
                    visible: Config.bar && Config.bar.showTray
                    width: 1
                    height: 16
                    color: Theme.border
                    anchors.verticalCenter: parent.verticalCenter
                }

                NetworkModule {
                    barWindow: root
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }

                BluetoothModule {
                    barWindow: root
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }

                AudioModule {
                    barWindow: root
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }

                BatteryModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: false
                }

                Rectangle {
                    width: 1
                    height: 16
                    color: Theme.border
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Settings button
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 26
                    height: 26
                    radius: 5
                    color: setHover.containsMouse ? Theme.surface : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "⚙"
                        color: setHover.containsMouse ? Theme.accent : Theme.fg
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: setHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["qyractl", "settings", "toggle"]);
                        }
                    }
                }
            }
        }
    }
}
