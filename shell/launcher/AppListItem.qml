import QtQuick
import Quickshell
import "../config"
import "../services"

Rectangle {
    id: root

    property var modelData
    property int index
    property bool isCurrent: false
    signal selected()

    width: parent ? parent.width : 500
    height: 52
    radius: 10
    color: isCurrent ? Theme.withAlpha(Theme.accent, 0.16)
                    : (rowMouse.containsMouse ? Theme.withAlpha(Theme.surface, 0.45) : "transparent")

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 14

        Item {
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: iconImg
                anchors.fill: parent
                source: (root.modelData && root.modelData.icon)
                    ? (root.modelData.icon.indexOf("/") === 0 ? ("file://" + root.modelData.icon) : Quickshell.iconPath(root.modelData.icon))
                    : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            Rectangle {
                anchors.fill: parent
                radius: 8
                visible: !root.modelData || !root.modelData.icon || iconImg.status === Image.Error
                color: root.isCurrent ? Theme.accent : Theme.withAlpha(Theme.accent, 0.18)

                Text {
                    anchors.centerIn: parent
                    text: (root.modelData && root.modelData.name && root.modelData.name.length > 0)
                        ? root.modelData.name.charAt(0).toUpperCase()
                        : "󰵆"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.isCurrent ? Theme.bg : Theme.accent
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 58
            spacing: 2

            Text {
                text: (root.modelData && root.modelData.name) || ""
                color: Theme.fg
                font.pixelSize: 14
                font.bold: root.isCurrent
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: (root.modelData && (root.modelData.comment || root.modelData.genericName)) || ""
                color: Theme.muted
                font.pixelSize: 12
                elide: Text.ElideRight
                width: parent.width
                visible: text.length > 0
            }
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: root.selected()
        onClicked: Apps.launch(root.modelData)
    }
}
