import QtQuick
import Quickshell.Hyprland
import "../../config"
import "../../services"

Rectangle {
    id: root
    property bool compact: false

    implicitHeight: 28
    implicitWidth: Math.min(titleText.implicitWidth + 14, 220)
    radius: 6
    color: "transparent"
    visible: titleText.text.length > 0

    Text {
        id: titleText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 6
        width: parent.width - 12
        text: Hyprland.activeToplevel ? (Hyprland.activeToplevel.title || "") : ""
        color: Theme.muted
        font.pixelSize: 11
        elide: Text.ElideRight
    }
}
