import QtQuick
import "../services"

Rectangle {
    id: root
    width: 190
    color: Theme.surface
    border.color: Theme.border
    border.width: 1

    property var categories: []
    property string activeCategory: "Bar"
    signal categorySelected(string category)

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Repeater {
            model: root.categories

            Rectangle {
                id: tabBtn
                width: parent.width
                height: 38
                radius: 6
                readonly property bool isSelected: root.activeCategory === modelData.id
                color: isSelected ? Theme.accent : (btnHover.containsMouse ? Theme.bg : "transparent")

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 10

                    Text {
                        text: modelData.icon
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.label
                        color: tabBtn.isSelected ? Theme.bg : Theme.fg
                        font.pixelSize: 12
                        font.bold: tabBtn.isSelected
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: btnHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.categorySelected(modelData.id)
                }
            }
        }
    }
}
