import QtQuick
import Quickshell
import "../../config"
import "../../services"

PopupWindow {
    id: root
    visible: false
    implicitWidth: 300
    implicitHeight: 220
    color: "transparent"

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    function toggle() {
        visible = !visible;
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
            anchors.margins: 14
            spacing: 12

            Text {
                text: "Audio Mixer"
                color: Theme.fg
                font.bold: true
                font.pixelSize: 13
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // Master Output Volume
            Column {
                width: parent.width
                spacing: 6

                Item {
                    width: parent.width
                    height: 16
                    Text { anchors.left: parent.left; text: "Speaker / Output"; color: Theme.muted; font.pixelSize: 11 }
                    Text {
                        anchors.right: parent.right
                        text: Audio.muted ? "Muted" : (Math.round(Audio.volume * 100) + "%")
                        color: Audio.muted ? Theme.urgent : Theme.fg
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Row {
                    width: parent.width
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 5
                        color: Audio.muted ? Theme.urgent : Theme.surface
                        border.color: Theme.border
                        Text {
                            anchors.centerIn: parent
                            text: Audio.muted ? "🔇" : "🔊"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Audio.toggleMute()
                        }
                    }

                    // Slider Track
                    Rectangle {
                        id: outTrack
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 36
                        height: 6
                        radius: 3
                        color: Theme.surface

                        Rectangle {
                            height: parent.height
                            radius: 3
                            color: Audio.muted ? Theme.muted : Theme.accent
                            width: Math.max(0, Math.min(outTrack.width, Audio.volume * outTrack.width))
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            function setVol(mouseX) {
                                var ratio = Math.max(0.0, Math.min(1.5, mouseX / outTrack.width));
                                Audio.setVolume(ratio);
                            }
                            onPressed: function(mouse) { setVol(mouse.x); }
                            onPositionChanged: function(mouse) { if (pressed) setVol(mouse.x); }
                        }
                    }
                }
            }

            // Microphone Input Volume
            Column {
                width: parent.width
                spacing: 6

                Item {
                    width: parent.width
                    height: 16
                    Text { anchors.left: parent.left; text: "Microphone / Input"; color: Theme.muted; font.pixelSize: 11 }
                    Text {
                        anchors.right: parent.right
                        text: Audio.micMuted ? "Muted" : (Math.round(Audio.micVolume * 100) + "%")
                        color: Audio.micMuted ? Theme.urgent : Theme.fg
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Row {
                    width: parent.width
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 5
                        color: Audio.micMuted ? Theme.urgent : Theme.surface
                        border.color: Theme.border
                        Text {
                            anchors.centerIn: parent
                            text: Audio.micMuted ? "🚫" : "🎤"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Audio.toggleMicMute()
                        }
                    }

                    // Slider Track
                    Rectangle {
                        id: inTrack
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 36
                        height: 6
                        radius: 3
                        color: Theme.surface

                        Rectangle {
                            height: parent.height
                            radius: 3
                            color: Audio.micMuted ? Theme.muted : Theme.accent
                            width: Math.max(0, Math.min(inTrack.width, Audio.micVolume * inTrack.width))
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            function setVol(mouseX) {
                                var ratio = Math.max(0.0, Math.min(1.5, mouseX / inTrack.width));
                                Audio.setMicVolume(ratio);
                            }
                            onPressed: function(mouse) { setVol(mouse.x); }
                            onPositionChanged: function(mouse) { if (pressed) setVol(mouse.x); }
                        }
                    }
                }
            }
        }
    }
}
