import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"
import "../services"

PanelWindow {
    id: root

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    WlrLayershell.namespace: "qyra-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Apps.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    visible: Apps.isOpen

    onVisibleChanged: {
        if (visible) {
            searchField.text = "";
            listView.currentIndex = 0;
            Qt.callLater(function() { searchField.forceActiveFocus(); });
        }
    }

    // Dismiss on outside click
    MouseArea {
        anchors.fill: parent
        onClicked: Apps.close()
    }

    // Centered Command Palette Card
    Rectangle {
        id: card
        width: 580
        height: 440
        anchors.centerIn: parent
        radius: 8
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        // Consume click events inside card
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.fill: parent
            spacing: 0

            // Search Header
            Item {
                width: parent.width
                height: 52

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        font.pixelSize: 16
                        color: Theme.accent
                    }

                    TextInput {
                        id: searchField
                        width: parent.width - 60
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.fg
                        font.pixelSize: 15
                        clip: true
                        activeFocusOnTab: true

                        onTextChanged: {
                            Apps.searchQuery = text;
                            listView.currentIndex = 0;
                        }

                        Keys.onDownPressed: if (listView.count > 0) listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + 1)
                        Keys.onUpPressed: if (listView.count > 0) listView.currentIndex = Math.max(0, listView.currentIndex - 1)
                        Keys.onReturnPressed: {
                            if (listView.currentIndex >= 0 && listView.currentIndex < Apps.filteredApps.length) {
                                Apps.launch(Apps.filteredApps[listView.currentIndex]);
                            } else if (text.trim().length > 0) {
                                Apps.launch(text.trim());
                            }
                        }
                        Keys.onEscapePressed: Apps.close()

                        Text {
                            anchors.fill: parent
                            text: "Type to search applications..."
                            color: Theme.muted
                            font.pixelSize: 15
                            visible: !searchField.text
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "ESC"
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.muted
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Application List
            ListView {
                id: listView
                width: parent.width
                height: parent.height - 53
                clip: true
                model: Apps.filteredApps
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: rowItem
                    readonly property bool isCurrent: listView.currentIndex === index
                    width: listView.width
                    height: 44
                    color: isCurrent ? Theme.surface : (rowMouse.containsMouse ? Theme.surface : "transparent")
                    radius: 4

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        // App Icon
                        Item {
                            width: 26
                            height: 26
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: iconImg
                                anchors.fill: parent
                                source: modelData.icon ? (modelData.icon.indexOf("/") === 0 ? ("file://" + modelData.icon) : Quickshell.iconPath(modelData.icon)) : ""
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !modelData.icon || iconImg.status === Image.Error
                                text: "󰵆"
                                font.pixelSize: 18
                                color: Theme.accent
                            }
                        }

                        // App Details
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 50
                            spacing: 1

                            Text {
                                text: modelData.name || ""
                                color: rowItem.isCurrent ? Theme.accent : Theme.fg
                                font.pixelSize: 13
                                font.bold: rowItem.isCurrent
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: modelData.comment || modelData.genericName || ""
                                color: Theme.muted
                                font.pixelSize: 11
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
                        onEntered: listView.currentIndex = index
                        onClicked: Apps.launch(modelData)
                    }
                }

                // Empty state
                Item {
                    anchors.centerIn: parent
                    visible: listView.count === 0
                    width: 200
                    height: 80

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰍉"
                            font.pixelSize: 28
                            color: Theme.muted
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No applications found"
                            font.pixelSize: 13
                            color: Theme.muted
                        }
                    }
                }
            }
        }
    }
}
