import QtQuick
import "../../config"
import "../../services"

Rectangle {
    id: root
    property bool compact: false

    visible: Media.hasPlayer
    implicitHeight: 28
    implicitWidth: visible ? (mediaRow.implicitWidth + 14) : 0
    radius: 6
    color: Theme.surface
    border.color: Theme.border
    border.width: 1

    Row {
        id: mediaRow
        anchors.centerIn: parent
        spacing: 8

        // Previous button
        Text {
            visible: !root.compact
            anchors.verticalCenter: parent.verticalCenter
            text: "⏮"
            font.pixelSize: 11
            color: prevHover.containsMouse ? Theme.accent : Theme.muted
            MouseArea { id: prevHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Media.previous() }
        }

        // Play/Pause button
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Media.isPlaying ? "⏸" : "▶"
            font.pixelSize: 11
            color: ppHover.containsMouse ? Theme.accent : Theme.fg
            MouseArea { id: ppHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Media.playPause() }
        }

        // Next button
        Text {
            visible: !root.compact
            anchors.verticalCenter: parent.verticalCenter
            text: "⏭"
            font.pixelSize: 11
            color: nextHover.containsMouse ? Theme.accent : Theme.muted
            MouseArea { id: nextHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Media.next() }
        }

        // Track title & artist
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: Media.title
                color: Theme.fg
                font.pixelSize: 11
                font.bold: true
                elide: Text.ElideRight
                width: Math.min(implicitWidth, root.compact ? 90 : 160)
            }

            Text {
                visible: !root.compact && Media.artist.length > 0
                text: "• " + Media.artist
                color: Theme.muted
                font.pixelSize: 11
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 120)
            }
        }
    }
}
