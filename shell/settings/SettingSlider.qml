import QtQuick
import "../config"
import "../services"

Item {
    id: root
    property var entry: null
    property string propKey: ""
    property var currentValue: 0

    width: 220
    height: 30

    readonly property real minVal: entry && entry.min !== undefined ? entry.min : 0
    readonly property real maxVal: entry && entry.max !== undefined ? entry.max : 100
    readonly property real stepVal: entry && entry.step !== undefined ? entry.step : 1
    property real activeVal: currentValue !== undefined ? currentValue : minVal

    onCurrentValueChanged: {
        if (!sliderArea.pressed) {
            activeVal = currentValue !== undefined ? currentValue : minVal;
        }
    }

    // Slider track
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: parent.width - 50
        height: 6
        radius: 3
        color: Theme.surface
        border.color: Theme.border
        border.width: 1

        Rectangle {
            height: parent.height
            radius: 3
            color: Theme.accent
            width: {
                var range = root.maxVal - root.minVal;
                if (range <= 0) return 0;
                var ratio = (root.activeVal - root.minVal) / range;
                return Math.max(0, Math.min(track.width, ratio * track.width));
            }
        }

        Rectangle {
            id: thumb
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(track.width - width, (track.width - width) * ((root.activeVal - root.minVal) / Math.max(0.001, root.maxVal - root.minVal))))
            width: 14
            height: 14
            radius: 7
            color: Theme.fg
            border.color: Theme.accent
            border.width: 1
        }

        MouseArea {
            id: sliderArea
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor

            function updateFromMouse(mouseX) {
                var ratio = Math.max(0, Math.min(1.0, mouseX / track.width));
                var rawVal = root.minVal + ratio * (root.maxVal - root.minVal);
                var steps = Math.round((rawVal - root.minVal) / root.stepVal);
                var stepped = root.minVal + steps * root.stepVal;
                if (entry && entry.type === "int") stepped = Math.round(stepped);
                root.activeVal = stepped;

                if (entry && entry.key.startsWith("hypr.")) {
                    Hypr.queueChange(root.propKey, stepped);
                }
            }

            onPositionChanged: function(mouse) {
                if (pressed) updateFromMouse(mouse.x);
            }
            onPressed: function(mouse) {
                updateFromMouse(mouse.x);
            }
            onReleased: {
                if (entry) Config.set(entry.key, root.activeVal);
            }
        }
    }

    // Readout pill
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: 44
        height: 22
        radius: 4
        color: Theme.surface
        border.color: Theme.border
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: (entry && entry.type === "real") ? Number(root.activeVal).toFixed(1) : Math.round(root.activeVal)
            color: Theme.fg
            font.pixelSize: 11
        }
    }
}
