import QtQuick
import Quickshell
import "../../config"
import "../../services"

PopupWindow {
    id: root
    visible: false
    implicitWidth: 280
    implicitHeight: 340
    color: "transparent"

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    function toggle() {
        visible = !visible;
        if (visible) Network.scan();
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
                    text: "Wi-Fi Networks"
                    color: Theme.fg
                    font.bold: true
                    font.pixelSize: 13
                }

                // Scan & Toggle
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: 48
                        height: 24
                        radius: 5
                        color: Theme.surface
                        border.color: Theme.border
                        Text { anchors.centerIn: parent; text: "Scan"; color: Theme.fg; font.pixelSize: 10 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Network.scan() }
                    }

                    Rectangle {
                        width: 38
                        height: 20
                        radius: 10
                        color: Network.wifiEnabled ? Theme.accent : Theme.surface
                        border.color: Theme.border

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: Network.wifiEnabled ? parent.width - width - 2 : 2
                            width: 16
                            height: 16
                            radius: 8
                            color: Network.wifiEnabled ? Theme.bg : Theme.fg
                            Behavior on x { NumberAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Network.toggleWifi()
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // Active Connection Info
            Rectangle {
                width: parent.width
                height: 38
                radius: 6
                color: Theme.surface
                visible: Network.connected

                Item {
                    anchors.fill: parent
                    anchors.margins: 8

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text { text: "✓"; color: Theme.green; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.parent.width - 100
                            Text { text: Network.ssid; color: Theme.fg; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight; width: parent.width }
                            Text { text: Network.signalStrength + "% signal (" + Network.connectivity + ")"; color: Theme.muted; font.pixelSize: 9 }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                        height: 22
                        radius: 4
                        color: Theme.urgent
                        Text { anchors.centerIn: parent; text: "Disconnect"; color: Theme.bg; font.pixelSize: 9; font.bold: true }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Network.disconnect() }
                    }
                }
            }

            // Available Networks List
            ListView {
                width: parent.width
                height: Network.connected ? parent.height - 110 : parent.height - 60
                clip: true
                spacing: 4
                model: Network.networks

                delegate: Rectangle {
                    id: netRow
                    width: parent.width
                    height: 34
                    radius: 6
                    color: netHover.containsMouse ? Theme.surface : "transparent"

                    readonly property bool isCur: modelData && modelData.connected

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
                                text: "📶"
                                font.pixelSize: 11
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: netRow.width - 80
                                text: modelData ? modelData.name : "Unknown"
                                color: isCur ? Theme.accent : Theme.fg
                                font.pixelSize: 11
                                font.bold: isCur
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            text: modelData ? (Math.round(modelData.signalStrength <= 1.0 ? modelData.signalStrength * 100 : modelData.signalStrength) + "%") : ""
                            color: Theme.muted
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: netHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData) Network.connect(modelData);
                        }
                    }
                }
            }
        }
    }
}
