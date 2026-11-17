import QtQuick
import Quickshell
import "../../config"
import "../../services"
import "../popups"

Rectangle {
    id: root
    property bool compact: false
    property var barWindow: null

    implicitHeight: 28
    implicitWidth: netRow.implicitWidth + 12
    radius: 6
    color: (netMouse.containsMouse || netPopup.visible) ? Theme.surface : "transparent"

    Row {
        id: netRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (Network.isWired) return "🌐";
                if (!Network.wifiEnabled) return "✈";
                if (!Network.connected) return "󰤮";
                if (Network.signalStrength >= 75) return "󰤨";
                if (Network.signalStrength >= 50) return "󰤥";
                if (Network.signalStrength >= 25) return "󰤢";
                return "󰤟";
            }
            font.pixelSize: 12
            color: Network.connected ? Theme.accent : Theme.muted
        }

        Text {
            visible: !root.compact && Network.connected
            anchors.verticalCenter: parent.verticalCenter
            text: Network.ssid
            font.pixelSize: 11
            color: Theme.fg
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    MouseArea {
        id: netMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: function(mouse) {
            if (mouse.button === Qt.MiddleButton) {
                Network.toggleWifi();
            } else {
                netPopup.toggle();
            }
        }
    }

    NetworkPopup {
        id: netPopup
        anchor.window: root.barWindow
        anchor.item: root
    }
}
