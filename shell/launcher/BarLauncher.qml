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
    visible: Apps.isOpen || closeAnim.running

    property real animProgress: 0.0

    readonly property real targetHeight: {
        var count = Apps.filteredApps ? Apps.filteredApps.length : 0;
        var isSearching = searchField.text.trim().length > 0;
        if (count <= 0) return isSearching ? 130 : 540;
        var itemH = (count * 52) + (Math.max(0, count - 1) * 2);
        return Math.min(540, 92 + itemH);
    }

    NumberAnimation {
        id: openAnim
        target: root
        property: "animProgress"
        to: 1.0
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0.7, 0.1, 1.0, 1.0, 1.0]
    }

    NumberAnimation {
        id: closeAnim
        target: root
        property: "animProgress"
        to: 0.0
        duration: 200
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.3, 0.0, 0.8, 0.15, 1.0, 1.0]
        onFinished: root.animProgress = 0.0
    }

    Connections {
        target: Apps
        function onIsOpenChanged() {
            if (Apps.isOpen) {
                closeAnim.stop();
                root.animProgress = 0.0;
                searchField.text = "";
                listView.currentIndex = 0;
                openAnim.restart();
                Qt.callLater(function() { searchField.forceActiveFocus(); });
            } else {
                openAnim.stop();
                closeAnim.restart();
            }
        }
    }

    // Material 3 Scrim Backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.withAlpha(Theme.bg, 0.45)
        opacity: root.animProgress

        MouseArea {
            anchors.fill: parent
            onClicked: Apps.close()
        }
    }

    // Bottom-anchored Floating Card
    Rectangle {
        id: card
        width: Math.min(parent.width - 32, 580)
        height: Math.min(parent.height - 60, root.targetHeight)
        radius: 20
        clip: true

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: (Config.bar && Config.bar.position === "bottom") ? ((Config.bar.height || 34) + 16) : 28
        }

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
            }
        }

        color: Theme.withAlpha(Theme.bg, 0.90)
        border.color: Theme.withAlpha(Theme.border, 0.35)
        border.width: 1

        transform: Translate { y: (1.0 - root.animProgress) * (card.height + 64) }
        scale: 0.92 + 0.08 * Math.max(0, Math.min(1.0, root.animProgress))
        opacity: Math.min(1.0, root.animProgress * 1.5)

        MouseArea {
            anchors.fill: parent
            onClicked: searchField.forceActiveFocus()
        }

        // Applications List (Placed above search box)
        Item {
            anchors {
                top: parent.top; topMargin: 14; left: parent.left; leftMargin: 10
                right: parent.right; rightMargin: 10; bottom: searchBox.top; bottomMargin: 8
            }

            ListView {
                id: listView
                anchors.fill: parent
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: Apps.filteredApps

                delegate: AppListItem {
                    modelData: modelData
                    index: index
                    isCurrent: listView.currentIndex === index
                    onSelected: if (listView.currentIndex !== index) listView.currentIndex = index
                }
            }

            // Empty Search State
            Item {
                anchors.fill: parent
                visible: listView.count === 0 && searchField.text.trim().length > 0

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "󰍉"; font.pixelSize: 16; color: Theme.muted; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "No matching applications"; font.pixelSize: 13; color: Theme.muted; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }

        // Bottom Search Container (Borderless elevated pill)
        Rectangle {
            id: searchBox
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 14 }
            height: 56
            radius: 14
            color: Theme.withAlpha(Theme.surface, 0.75)
            border.width: 0

            Item {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 14

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: "Search apps or type to filter..."
                    font.pixelSize: 16
                    color: Theme.muted
                    visible: searchField.text.length === 0
                    elide: Text.ElideRight
                }

                TextInput {
                    id: searchField
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.fg
                    font.pixelSize: 16
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.bg
                    clip: true

                    onTextChanged: {
                        Apps.searchQuery = text;
                        listView.currentIndex = 0;
                    }

                    Keys.onDownPressed: if (listView.count > 0) listView.currentIndex = (listView.currentIndex + 1) % listView.count
                    Keys.onUpPressed: if (listView.count > 0) listView.currentIndex = (listView.currentIndex - 1 + listView.count) % listView.count
                    Keys.onTabPressed: if (listView.count > 0) listView.currentIndex = (listView.currentIndex + 1) % listView.count
                    Keys.onBacktabPressed: if (listView.count > 0) listView.currentIndex = (listView.currentIndex - 1 + listView.count) % listView.count
                    Keys.onReturnPressed: {
                        if (listView.currentIndex >= 0 && listView.currentIndex < Apps.filteredApps.length) {
                            Apps.launch(Apps.filteredApps[listView.currentIndex]);
                        } else if (text.trim().length > 0) {
                            Apps.launch(text.trim());
                        }
                    }
                    Keys.onEscapePressed: Apps.close()
                }
            }
        }
    }
}
