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
    implicitWidth: audioRow.implicitWidth + 12
    radius: 6
    color: (audioMouse.containsMouse || audioPopup.visible) ? Theme.surface : "transparent"

    Row {
        id: audioRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (Audio.muted) return "󰝟";
                var vol = Audio.volume;
                if (vol <= 0.01) return "󰕿";
                if (vol <= 0.5) return "󰖀";
                return "󰕾";
            }
            font.pixelSize: 13
            color: Audio.muted ? Theme.urgent : Theme.accent
        }

        Text {
            visible: !root.compact || Audio.muted
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.muted ? "Mute" : (Math.round(Audio.volume * 100) + "%")
            font.pixelSize: 11
            color: Audio.muted ? Theme.urgent : Theme.fg
            font.bold: true
        }
    }

    MouseArea {
        id: audioMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                audioPopup.toggle();
            } else {
                Audio.toggleMute();
            }
        }

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                Audio.adjustVolume(0.05);
            } else if (wheel.angleDelta.y < 0) {
                Audio.adjustVolume(-0.05);
            }
        }
    }

    AudioPopup {
        id: audioPopup
        anchor.window: root.barWindow
        anchor.item: root
    }
}
