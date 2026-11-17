import QtQuick
import "../config"
import "../services"

Item {
    id: root
    anchors.fill: parent
    property string newLabel: ""

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // Header
        Item {
            width: parent.width; height: 32
            Column {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 2
                Text { text: "State Snapshots & Recovery"; color: Theme.fg; font.pixelSize: 15; font.bold: true }
                Text { text: "Save milestones or rollback configuration"; color: Theme.muted; font.pixelSize: 11 }
            }
            Rectangle {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                width: 130; height: 30; radius: 6; color: Theme.surface; border.color: Theme.border
                Text { anchors.centerIn: parent; text: "↺ Backup Last Good"; color: Theme.fg; font.pixelSize: 11 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Snapshot.backupLastGood() }
            }
        }

        // Create snapshot bar
        Rectangle {
            width: parent.width; height: 44; radius: 8; color: Theme.surface; border.color: Theme.border
            Row {
                anchors.fill: parent; anchors.margins: 6; spacing: 8
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 138; height: 30; radius: 6; color: Theme.bg; border.color: Theme.border
                    TextInput {
                        id: labelInput
                        anchors.fill: parent; anchors.margins: 6; text: root.newLabel; color: Theme.fg; font.pixelSize: 12
                        verticalAlignment: TextInput.AlignVCenter
                        onTextChanged: root.newLabel = text
                        Text {
                            anchors.fill: parent; text: "Snapshot label..."; color: Theme.muted; font.pixelSize: 11
                            visible: !labelInput.text && !labelInput.activeFocus; verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 120; height: 30; radius: 6; color: Theme.accent
                    Text { anchors.centerIn: parent; text: "Create Snapshot"; color: Theme.bg; font.bold: true; font.pixelSize: 11 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Snapshot.createSnapshot(root.newLabel);
                            root.newLabel = "";
                            labelInput.text = "";
                        }
                    }
                }
            }
        }

        // Snapshots list
        ListView {
            id: list
            width: parent.width; height: parent.height - 104; clip: true; spacing: 6
            model: Snapshot.folderModel
            delegate: Rectangle {
                width: list.width; height: 48; radius: 6; color: Theme.surface
                border.color: isLastGood ? Theme.accent : Theme.border
                readonly property bool isLastGood: fileName === "last-good.json"

                Row {
                    anchors.fill: parent; anchors.margins: 10; spacing: 10
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 150; spacing: 2
                        Row {
                            spacing: 8
                            Text { text: fileName; color: Theme.fg; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight }
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 68; height: 16; radius: 4; color: isLastGood ? Theme.accent : Theme.border
                                visible: isLastGood
                                Text { anchors.centerIn: parent; text: "AUTO-BACKUP"; color: isLastGood ? Theme.bg : Theme.muted; font.pixelSize: 8; font.bold: true }
                            }
                        }
                        Text { text: fileModified ? Qt.formatDateTime(fileModified, "yyyy-MM-dd hh:mm") : ""; color: Theme.muted; font.pixelSize: 10 }
                    }

                    // Action buttons
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 6
                        Rectangle {
                            width: 64; height: 26; radius: 5; color: restoreHover.containsMouse ? Theme.accent : Theme.bg
                            border.color: Theme.accent
                            Text { anchors.centerIn: parent; text: "Restore"; color: restoreHover.containsMouse ? Theme.bg : Theme.accent; font.pixelSize: 11; font.bold: true }
                            MouseArea { id: restoreHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Snapshot.restoreSnapshot(fileName) }
                        }
                        Rectangle {
                            width: 28; height: 26; radius: 5; color: delHover.containsMouse ? Theme.urgent : Theme.bg
                            border.color: Theme.border; visible: !isLastGood
                            Text { anchors.centerIn: parent; text: "✕"; color: delHover.containsMouse ? Theme.bg : Theme.urgent; font.pixelSize: 11 }
                            MouseArea { id: delHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Snapshot.deleteSnapshot(fileName) }
                        }
                    }
                }
            }
        }
    }
}
