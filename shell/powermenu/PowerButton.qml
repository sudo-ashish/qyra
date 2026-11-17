import QtQuick
import "../config"
import "../services"

Item {
    id: root

    property var modelData
    property int index
    property bool isActive: false
    signal activated()
    signal selected()

    readonly property bool isDanger: modelData.id === "shutdown" || modelData.id === "reboot"

    width: 58
    height: 58

    scale: isActive ? 1.08 : (btnMouse.containsMouse ? 1.03 : 1.0)
    Behavior on scale {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutBack
            easing.overshoot: 1.15
        }
    }

    Rectangle {
        id: btnBg
        anchors.fill: parent
        radius: root.isActive ? 14 : 29

        Behavior on radius {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
                easing.overshoot: 1.15
            }
        }

        color: {
            if (root.isActive) {
                return root.isDanger ? Theme.urgent : Theme.accent;
            }
            if (btnMouse.containsMouse) {
                return Theme.surface;
            }
            return Theme.withAlpha(Theme.surface, 0.45);
        }
        Behavior on color { ColorAnimation { duration: 160 } }

        Text {
            anchors.centerIn: parent
            text: root.modelData.icon || ""
            font.pixelSize: 26
            color: root.isActive ? Theme.bg : (root.isDanger ? Theme.urgent : Theme.fg)
            Behavior on color { ColorAnimation { duration: 160 } }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selected()
            onClicked: root.activated()
        }
    }
}
