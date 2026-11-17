import QtQuick
import "../config"
import "../services"

Item {
    id: root
    anchors.fill: parent

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        Item {
            width: parent.width; height: 32
            Column {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 2
                Text { text: "System & Software Updates"; color: Theme.fg; font.pixelSize: 15; font.bold: true }
                Text { text: "Manage Qyra desktop environment core updates"; color: Theme.muted; font.pixelSize: 11 }
            }
        }

        // Version & Status Banner
        Rectangle {
            width: parent.width; height: 76; radius: 8; color: Theme.surface; border.color: Theme.border

            Item {
                anchors.fill: parent; anchors.margins: 14

                Row {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 16

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        Text { text: "Installed Version"; color: Theme.muted; font.pixelSize: 11 }
                        Text { text: "v" + Updater.currentVersion; color: Theme.fg; font.pixelSize: 16; font.bold: true }
                    }

                    Rectangle { width: 1; height: 36; color: Theme.border; anchors.verticalCenter: parent.verticalCenter }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        Text { text: "Status"; color: Theme.muted; font.pixelSize: 11 }
                        Row {
                            spacing: 6
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 8; height: 8; radius: 4
                                color: {
                                    if (Updater.status === "available") return Theme.yellow;
                                    if (Updater.status === "error") return Theme.urgent;
                                    if (Updater.status === "checking" || Updater.status === "updating") return Theme.accent;
                                    return Theme.green;
                                }
                            }
                            Text {
                                text: Updater.statusMessage
                                color: Theme.fg
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }
                }

                // Actions
                Row {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: 10

                    Rectangle {
                        width: 120; height: 32; radius: 6; color: Theme.bg; border.color: Theme.border
                        Text { anchors.centerIn: parent; text: "Check Updates"; color: Theme.fg; font.pixelSize: 11 }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: Updater.checkUpdate()
                        }
                    }

                    Rectangle {
                        width: 120; height: 32; radius: 6
                        color: Updater.hasUpdate ? Theme.accent : Theme.surface
                        opacity: Updater.hasUpdate ? 1.0 : 0.5
                        border.color: Theme.border

                        Text {
                            anchors.centerIn: parent
                            text: "Install Update"
                            color: Updater.hasUpdate ? Theme.bg : Theme.muted
                            font.bold: Updater.hasUpdate
                            font.pixelSize: 11
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Updater.hasUpdate ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (Updater.hasUpdate) Updater.installUpdate();
                            }
                        }
                    }
                }
            }
        }

        // Changelog Box
        Column {
            width: parent.width; height: 170; spacing: 6
            Text { text: "Release Notes / Changelog"; color: Theme.muted; font.pixelSize: 12; font.bold: true }

            Rectangle {
                width: parent.width; height: parent.height - 24; radius: 8; color: Theme.bg; border.color: Theme.border
                Flickable {
                    anchors.fill: parent; anchors.margins: 10; contentWidth: width; contentHeight: logText.implicitHeight; clip: true
                    Text {
                        id: logText
                        width: parent.width
                        text: Updater.changelog ? Updater.changelog : "No pending release notes."
                        color: Theme.fg; font.pixelSize: 11; font.family: "monospace"; wrapMode: Text.Wrap
                    }
                }
            }
        }

        // Safety Architecture Card
        Rectangle {
            width: parent.width; height: 72; radius: 8; color: Theme.surface; border.color: Theme.border

            Row {
                anchors.fill: parent; anchors.margins: 12; spacing: 12
                Text { text: "🛡"; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 3; width: parent.width - 44
                    Text { text: "3-Tier Non-Destructive Update Guarantee"; color: Theme.fg; font.pixelSize: 12; font.bold: true }
                    Text {
                        text: "Updates strictly pull Tier 1 immutable source into ~/.local/share/qyra/. Your state (~/.local/state/qyra/state.json) and custom files (~/.config/) are 100% isolated and never overwritten."
                        color: Theme.muted; font.pixelSize: 10; wrapMode: Text.Wrap; width: parent.width
                    }
                }
            }
        }
    }
}
