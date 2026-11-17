import QtQuick
import "../../config"
import "../../services"

Rectangle {
    id: root
    property bool compact: false

    implicitHeight: 28
    implicitWidth: contentRow.implicitWidth + 12
    radius: 6
    color: hoverArea.containsMouse ? Theme.surface : "transparent"

    readonly property string mode: Config.bar ? Config.bar.batteryMode : "hybrid"
    readonly property color statusColor: {
        if (Battery.isCharging) return Theme.green;
        if (Battery.percentage <= 15) return Theme.urgent;
        if (Battery.percentage <= 30) return Theme.yellow;
        return Theme.fg;
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        // Icon (visible in "icon" and "hybrid" modes)
        Text {
            visible: root.mode === "icon" || root.mode === "hybrid"
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!Battery.hasBattery) return "⚡";
                if (Battery.isCharging) return "🔌";
                if (Battery.percentage <= 15) return "🪫";
                return "🔋";
            }
            font.pixelSize: 12
            color: root.statusColor
        }

        // Percentage (visible in "percentage" and "hybrid" modes)
        Text {
            visible: root.mode === "percentage" || root.mode === "hybrid"
            anchors.verticalCenter: parent.verticalCenter
            text: Battery.hasBattery ? (Battery.percentage + "%") : "AC"
            font.pixelSize: 11
            font.bold: true
            color: root.statusColor
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }

    // Tooltip
    Rectangle {
        visible: hoverArea.containsMouse && Battery.hasBattery
        anchors.top: parent.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        width: tipText.implicitWidth + 16
        height: 24
        radius: 4
        color: Theme.bg
        border.color: Theme.border
        border.width: 1
        z: 99

        Text {
            id: tipText
            anchors.centerIn: parent
            text: Battery.percentage + "% — " + Battery.stateText + (Battery.timeToEmpty > 0 ? " (" + Math.round(Battery.timeToEmpty / 60) + "m left)" : "")
            color: Theme.fg
            font.pixelSize: 10
        }
    }
}
