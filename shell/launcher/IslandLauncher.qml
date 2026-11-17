import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"
import "../services"

PanelWindow {
    id: root

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    WlrLayershell.namespace: "qyra-island-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Apps.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    visible: Apps.isOpen

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            grid.currentIndex = 0;
            Qt.callLater(function() { searchInput.forceActiveFocus(); });
        }
    }

    // Dismiss on outside click
    MouseArea {
        anchors.fill: parent
        onClicked: Apps.close()
    }

    // Dynamic Island Floating Pill
    Rectangle {
        id: islandPill
        anchors.top: parent.top
        anchors.topMargin: (Config.bar && Config.bar.position === "bottom") ? 24 : ((Config.bar && Config.bar.height ? Config.bar.height : 34) + 16)
        anchors.horizontalCenter: parent.horizontalCenter

        width: Apps.isOpen ? 640 : 380
        height: Apps.isOpen ? 460 : 48
        radius: 26
        color: Theme.bg
        border.color: Theme.border
        border.width: 1
        clip: true

        Behavior on width { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Top Search Bar
            Rectangle {
                width: parent.width
                height: 44
                radius: 22
                color: Theme.surface
                border.color: searchInput.activeFocus ? Theme.accent : Theme.border
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        font.pixelSize: 15
                        color: Theme.accent
                    }

                    TextInput {
                        id: searchInput
                        width: parent.width - 56
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.fg
                        font.pixelSize: 14
                        clip: true

                        onTextChanged: {
                            Apps.searchQuery = text;
                            grid.currentIndex = 0;
                        }

                        Keys.onDownPressed: if (grid.count > 0) grid.moveCurrentIndexDown()
                        Keys.onUpPressed: if (grid.count > 0) grid.moveCurrentIndexUp()
                        Keys.onRightPressed: if (grid.count > 0) grid.moveCurrentIndexRight()
                        Keys.onLeftPressed: if (grid.count > 0) grid.moveCurrentIndexLeft()
                        Keys.onReturnPressed: {
                            if (grid.currentIndex >= 0 && grid.currentIndex < Apps.filteredApps.length) {
                                Apps.launch(Apps.filteredApps[grid.currentIndex]);
                            } else if (text.trim().length > 0) {
                                Apps.launch(text.trim());
                            }
                        }
                        Keys.onEscapePressed: Apps.close()

                        Text {
                            anchors.fill: parent
                            text: "Search apps or run command..."
                            color: Theme.muted
                            font.pixelSize: 14
                            visible: !searchInput.text
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅖"
                        font.pixelSize: 14
                        color: Theme.muted
                        visible: searchInput.text.length > 0
                        MouseArea {
                            anchors.fill: parent
                            onClicked: searchInput.text = ""
                        }
                    }
                }
            }

            // Grid of Rounded App Cards
            GridView {
                id: grid
                width: parent.width
                height: parent.height - 56
                cellWidth: parent.width / 3
                cellHeight: 64
                clip: true
                model: Apps.filteredApps
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        id: cardRect
                        readonly property bool isSelected: grid.currentIndex === index
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 14
                        color: cardRect.isSelected ? Theme.surface : (cardMouse.containsMouse ? Theme.surface : "transparent")
                        border.color: cardRect.isSelected ? Theme.accent : (cardMouse.containsMouse ? Theme.border : "transparent")
                        border.width: cardRect.isSelected ? 2 : 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Item {
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    id: cardIcon
                                    anchors.fill: parent
                                    source: modelData.icon ? (modelData.icon.indexOf("/") === 0 ? ("file://" + modelData.icon) : Quickshell.iconPath(modelData.icon)) : ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: !modelData.icon || cardIcon.status === Image.Error
                                    text: "󰵆"
                                    font.pixelSize: 20
                                    color: Theme.accent
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 48
                                spacing: 2

                                Text {
                                    text: modelData.name || ""
                                    color: cardRect.isSelected ? Theme.accent : Theme.fg
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: modelData.comment || modelData.genericName || ""
                                    color: Theme.muted
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    width: parent.width
                                    visible: text.length > 0
                                }
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: grid.currentIndex = index
                            onClicked: Apps.launch(modelData)
                        }
                    }
                }

                Item {
                    anchors.centerIn: parent
                    visible: grid.count === 0
                    width: 200
                    height: 80

                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰍉"; font.pixelSize: 28; color: Theme.muted }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "No applications found"; font.pixelSize: 13; color: Theme.muted }
                    }
                }
            }
        }
    }
}
