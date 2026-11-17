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
    }

    margins {
        top: (!Config.bar || Config.bar.position === "top") ? 6 : 0
        bottom: (Config.bar && Config.bar.position === "bottom") ? 6 : 0
    }

    WlrLayershell.layer: WlrLayer.Top
    implicitHeight: (Config.bar && Config.bar.height) ? (Config.bar.height + 4) : 38
    implicitWidth: pillContainer.width
    exclusiveZone: implicitHeight + 8
    color: "transparent"

    Rectangle {
        id: pillContainer
        anchors.centerIn: parent
        height: parent.height
        width: pillRow.implicitWidth + 24
        radius: height / 2
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8

            WorkspacesModule {
                anchors.verticalCenter: parent.verticalCenter
                compact: true
            }

            Rectangle {
                width: 1
                height: 14
                color: Theme.border
                anchors.verticalCenter: parent.verticalCenter
            }

            MediaModule {
                anchors.verticalCenter: parent.verticalCenter
                compact: true
            }

            ClockModule {
                anchors.verticalCenter: parent.verticalCenter
                compact: true
            }

            Rectangle {
                width: 1
                height: 14
                color: Theme.border
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                TrayModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: true
                }

                NetworkModule {
                    barWindow: root
                    anchors.verticalCenter: parent.verticalCenter
                    compact: true
                }

                BluetoothModule {
                    barWindow: root
                    anchors.verticalCenter: parent.verticalCenter
                    compact: true
                }

                AudioModule {
                    barWindow: root
                    anchors.verticalCenter: parent.verticalCenter
                    compact: true
                }

                BatteryModule {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: true
                }

                // Settings button
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    height: 22
                    radius: 11
                    color: setHover.containsMouse ? Theme.surface : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "⚙"
                        color: setHover.containsMouse ? Theme.accent : Theme.muted
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: setHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["qyractl", "settings", "toggle"])
                    }
                }
            }
        }
    }
}
