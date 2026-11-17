import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"
import "../services"

PanelWindow {
    id: root

    anchors {
        bottom: true
    }
    margins {
        bottom: 70
    }

    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth: 220
    implicitHeight: 64
    color: "transparent"
    visible: hideTimer.running

    property string iconText: "🔊"
    property string labelText: "Volume"
    property string valueText: "50%"
    property real progressValue: 0.5
    property bool hasProgress: true

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
    }

    function trigger() {
        hideTimer.restart();
    }

    function showAudio(vol, isMuted) {
        if (isMuted) {
            iconText = "󰝟";
            valueText = "Muted";
            progressValue = 0;
        } else {
            var p = Math.round(vol * 100);
            iconText = p > 50 ? "󰕾" : (p > 0 ? "󰖀" : "󰕿");
            valueText = p + "%";
            progressValue = Math.min(1.0, vol);
        }
        labelText = "Output Volume";
        hasProgress = !isMuted;
        trigger();
    }

    function showMic(vol, isMuted) {
        if (isMuted) {
            iconText = "🚫";
            valueText = "Muted";
            progressValue = 0;
        } else {
            var p = Math.round(vol * 100);
            iconText = "🎤";
            valueText = p + "%";
            progressValue = Math.min(1.0, vol);
        }
        labelText = "Microphone";
        hasProgress = !isMuted;
        trigger();
    }

    function showBrightness(percent) {
        iconText = "☀️";
        labelText = "Brightness";
        valueText = percent + "%";
        progressValue = percent / 100.0;
        hasProgress = true;
        trigger();
    }

    function showConfig(key, val) {
        var entry = Schema.get(key);
        iconText = "⚙";
        labelText = entry ? entry.label : key;
        valueText = String(val);
        hasProgress = false;
        trigger();
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            Item {
                width: parent.width
                height: 20

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.iconText
                        font.pixelSize: 15
                        color: Theme.accent
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.labelText
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.fg
                        elide: Text.ElideRight
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.valueText
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.muted
                }
            }

            // Progress bar
            Rectangle {
                visible: root.hasProgress
                width: parent.width
                height: 6
                radius: 3
                color: Theme.surface

                Rectangle {
                    height: parent.height
                    radius: 3
                    color: Theme.accent
                    width: Math.max(0, Math.min(parent.width, root.progressValue * parent.width))
                }
            }
        }
    }
}
