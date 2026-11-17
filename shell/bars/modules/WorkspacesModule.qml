import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../config"
import "../../services"

Rectangle {
    id: root
    property bool compact: false

    implicitHeight: 28
    implicitWidth: wsRow.implicitWidth + 8
    radius: 6
    color: "transparent"

    readonly property string style: Config.bar ? Config.bar.workspaceStyle : "pills"
    readonly property var activeWs: Hyprland.focusedWorkspace
    readonly property int activeWsId: activeWs ? activeWs.id : 1

    // Model: 1..5 or dynamic workspaces
    readonly property var workspaceIds: {
        var ids = [1, 2, 3, 4, 5];
        if (Hyprland.workspaces && Hyprland.workspaces.values) {
            var list = Hyprland.workspaces.values;
            for (var i = 0; i < list.length; ++i) {
                var wId = list[i].id;
                if (wId > 0 && ids.indexOf(wId) === -1) {
                    ids.push(wId);
                }
            }
        }
        ids.sort(function(a, b) { return a - b; });
        return ids;
    }

    Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: root.compact ? 3 : 5

        Repeater {
            model: root.workspaceIds

            Rectangle {
                id: wsPill
                readonly property int wsId: modelData
                readonly property bool isFocused: wsId === root.activeWsId

                width: {
                    if (root.style === "dots") return isFocused ? 18 : 8;
                    if (root.style === "numbers") return 20;
                    return isFocused ? 28 : (root.compact ? 18 : 22);
                }
                height: root.style === "dots" ? 8 : 22
                radius: root.style === "dots" ? 4 : 5
                anchors.verticalCenter: parent.verticalCenter

                color: {
                    if (root.style === "numbers") return "transparent";
                    if (isFocused) return Theme.accent;
                    if (wsHover.containsMouse) return Theme.surface;
                    return root.style === "dots" ? Theme.border : "transparent";
                }

                border.color: {
                    if (root.style === "dots") return "transparent";
                    if (isFocused) return Theme.accent;
                    return Theme.border;
                }
                border.width: 1

                Text {
                    visible: root.style !== "dots"
                    anchors.centerIn: parent
                    text: wsId
                    font.pixelSize: 11
                    font.bold: isFocused
                    color: isFocused ? (root.style === "numbers" ? Theme.accent : Theme.bg) : (wsHover.containsMouse ? Theme.fg : Theme.muted)
                }

                MouseArea {
                    id: wsHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hypr.dispatch("workspace " + wsId)
                }

                Behavior on width { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                Hypr.dispatch("workspace e+1");
            } else if (wheel.angleDelta.y < 0) {
                Hypr.dispatch("workspace e-1");
            }
        }
    }
}
