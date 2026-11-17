import QtQuick
import Qt.labs.folderlistmodel
import "../config"
import "../services"

Item {
    id: root
    anchors.fill: parent

    FolderListModel {
        id: themesModel
        folder: "file://" + Theme.themesDir
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        Item {
            width: parent.width
            height: 36

            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: "Theme Presets"
                    color: Theme.fg
                    font.pixelSize: 16
                    font.bold: true
                }
                Text {
                    text: "Select a preset or create your own custom theme"
                    color: Theme.muted
                    font.pixelSize: 11
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 110
                height: 32
                radius: 6
                color: Theme.accent

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "+"; color: Theme.bg; font.bold: true; font.pixelSize: 14 }
                    Text { text: "New Theme"; color: Theme.bg; font.bold: true; font.pixelSize: 12 }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: creatorModal.openModal()
                }
            }
        }

        // Themes Grid
        GridView {
            id: grid
            width: parent.width
            height: parent.height - 52
            cellWidth: 200
            cellHeight: 160
            clip: true
            model: themesModel

            delegate: Item {
                id: cardItem
                width: grid.cellWidth
                height: grid.cellHeight
                visible: fileName !== "current"

                readonly property bool isActive: Config.theme && Config.theme.active === fileName

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: 8
                    color: Theme.surface
                    border.color: cardItem.isActive ? Theme.accent : (cardHover.containsMouse ? Theme.fg : Theme.border)
                    border.width: cardItem.isActive ? 2 : 1
                    clip: true

                    // Wallpaper thumbnail
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 96
                        color: Theme.bg
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file://" + filePath + "/background"
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        // Active badge
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 6
                            width: 50
                            height: 18
                            radius: 4
                            color: Theme.accent
                            visible: cardItem.isActive

                            Text {
                                anchors.centerIn: parent
                                text: "ACTIVE"
                                color: Theme.bg
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    // Theme label bar
                    Item {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 52

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: fileName
                            color: cardItem.isActive ? Theme.accent : Theme.fg
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.width - 20
                        }
                    }

                    MouseArea {
                        id: cardHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Theme.applyTheme(fileName)
                    }
                }
            }
        }
    }

    ThemeCreatorModal {
        id: creatorModal
    }
}
