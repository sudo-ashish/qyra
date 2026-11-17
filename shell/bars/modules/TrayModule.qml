import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../../config"
import "../../services"

Rectangle {
    id: root
    property bool compact: false

    visible: Config.bar ? Config.bar.showTray : true
    implicitHeight: 28
    implicitWidth: visible ? (trayRow.implicitWidth + 8) : 0
    radius: 6
    color: "transparent"

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            Rectangle {
                width: 22
                height: 22
                radius: 4
                color: itemHover.containsMouse ? Theme.surface : "transparent"

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 16
                    source: modelData && modelData.icon ? (modelData.icon.indexOf("/") !== -1 ? modelData.icon : Quickshell.iconPath(modelData.icon)) : ""
                }

                MouseArea {
                    id: itemHover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton) {
                            if (modelData && typeof modelData.secondaryActivate === "function") {
                                modelData.secondaryActivate();
                            }
                        } else {
                            if (modelData && typeof modelData.activate === "function") {
                                modelData.activate();
                            }
                        }
                    }
                }

                // Tooltip
                Rectangle {
                    visible: itemHover.containsMouse && modelData && (modelData.tooltipTitle || modelData.title)
                    anchors.top: parent.bottom
                    anchors.topMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: tipText.implicitWidth + 12
                    height: 20
                    radius: 4
                    color: Theme.bg
                    border.color: Theme.border
                    border.width: 1
                    z: 99

                    Text {
                        id: tipText
                        anchors.centerIn: parent
                        text: modelData ? (modelData.tooltipTitle || modelData.title || "") : ""
                        color: Theme.fg
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
