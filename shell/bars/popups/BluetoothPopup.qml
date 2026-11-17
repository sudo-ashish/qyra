import QtQuick
import Quickshell
import "../../config"
import "../../services"

PopupWindow {
    id: root
    visible: false
    implicitWidth: 280
    implicitHeight: 320
    color: "transparent"

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    function toggle() {
        visible = !visible;
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.bg
        border.color: Theme.border
        border.width: 1
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Header
            Item {
                width: parent.width
                height: 28

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth Devices"
                    color: Theme.fg
                    font.bold: true
                    font.pixelSize: 13
                }

                // Scan & Power Toggle
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: 52
                        height: 24
                        radius: 5
                        color: Bluetooth.discovering ? Theme.accent : Theme.surface
                        border.color: Theme.border
                        Text {
                            anchors.centerIn: parent
                            text: Bluetooth.discovering ? "Scanning" : "Pair"
                            color: Bluetooth.discovering ? Theme.bg : Theme.fg
                            font.pixelSize: 10
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Bluetooth.toggleDiscovery() }
                    }

                    Rectangle {
                        width: 38
                        height: 20
                        radius: 10
                        color: Bluetooth.powered ? Theme.accent : Theme.surface
                        border.color: Theme.border

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: Bluetooth.powered ? parent.width - width - 2 : 2
                            width: 16
                            height: 16
                            radius: 8
                            color: Bluetooth.powered ? Theme.bg : Theme.fg
                            Behavior on x { NumberAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Bluetooth.togglePower()
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // Device list
            ListView {
                width: parent.width
                height: parent.height - 52
                clip: true
                spacing: 4
                model: Bluetooth.devices

                delegate: Rectangle {
                    id: devRow
                    width: parent.width
                    height: 38
                    radius: 6
                    color: devHover.containsMouse ? Theme.surface : "transparent"

                    readonly property bool isConn: modelData && modelData.connected

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "🎧"
                                font.pixelSize: 12
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: devRow.width - 100
                                spacing: 1

                                Text {
                                    text: modelData ? (modelData.name || modelData.address || "Unknown Device") : ""
                                    color: isConn ? Theme.accent : Theme.fg
                                    font.pixelSize: 11
                                    font.bold: isConn
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: isConn ? "Connected" : (modelData && modelData.paired ? "Paired" : "Available")
                                    color: Theme.muted
                                    font.pixelSize: 9
                                }
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 58
                            height: 24
                            radius: 4
                            color: isConn ? Theme.surface : Theme.accent
                            border.color: Theme.border

                            Text {
                                anchors.centerIn: parent
                                text: isConn ? "Disconnect" : "Connect"
                                color: isConn ? Theme.urgent : Theme.bg
                                font.pixelSize: 9
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (isConn) Bluetooth.disconnectDevice(modelData);
                                    else Bluetooth.connectDevice(modelData);
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: devHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { /* row clicked */ }
                    }
                }
            }
        }
    }
}
