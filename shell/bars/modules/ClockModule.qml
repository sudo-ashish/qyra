import QtQuick
import Quickshell
import "../../config"
import "../../services"

Rectangle {
    id: root
    property bool compact: false

    implicitHeight: 28
    implicitWidth: clockRow.implicitWidth + 14
    radius: 6
    color: clockHover.containsMouse ? Theme.surface : "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    readonly property string format: (Config.bar && Config.bar.clockFormat) ? Config.bar.clockFormat : "HH:mm"

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "🕒"
            font.pixelSize: 11
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, root.format)
            color: Theme.fg
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            visible: !root.compact
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "ddd, MMM d")
            color: Theme.muted
            font.pixelSize: 11
        }
    }

    MouseArea {
        id: clockHover
        anchors.fill: parent
        hoverEnabled: true
    }

    // Tooltip with full timestamp and calendar date
    Rectangle {
        visible: clockHover.containsMouse
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
            text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy  •  HH:mm:ss")
            color: Theme.fg
            font.pixelSize: 10
        }
    }
}
