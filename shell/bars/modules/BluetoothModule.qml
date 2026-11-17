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
    implicitWidth: btRow.implicitWidth + 12
    radius: 6
    color: (btMouse.containsMouse || btPopup.visible) ? Theme.surface : "transparent"

    Row {
        id: btRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰂯"
            font.pixelSize: 13
            color: {
                if (!Bluetooth.powered) return Theme.muted;
                if (Bluetooth.hasConnectedDevice) return Theme.accent;
                return Theme.fg;
            }
        }

        Text {
            visible: !root.compact && Bluetooth.hasConnectedDevice
            anchors.verticalCenter: parent.verticalCenter
            text: Bluetooth.connectedCount > 1 ? ("" + Bluetooth.connectedCount) : "On"
            font.pixelSize: 11
            color: Theme.accent
            font.bold: true
        }
    }

    MouseArea {
        id: btMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btPopup.toggle()
    }

    BluetoothPopup {
        id: btPopup
        anchor.window: root.barWindow
        anchor.item: root
    }
}
