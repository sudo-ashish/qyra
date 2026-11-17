import QtQuick
import "../config"
import "../services"

Rectangle {
    id: root
    property var entry: null

    implicitWidth: 500
    implicitHeight: 52
    color: "transparent"

    readonly property string sectionKey: entry ? entry.key.split(".")[0] : ""
    readonly property string propKey: entry ? entry.key.split(".")[1] : ""
    readonly property var currentValue: {
        if (!entry) return undefined;
        var sec = Config[sectionKey];
        return sec ? sec[propKey] : undefined;
    }
    readonly property bool isModified: entry !== null && currentValue !== undefined && currentValue !== entry.defaultValue

    Row {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 16

        // Left info column (Label, Modified dot, Reset button, Description)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - controlContainer.width - 24
            spacing: 3

            Row {
                spacing: 8
                anchors.left: parent.left

                Text {
                    text: entry ? entry.label : ""
                    color: Theme.fg
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                // Modified indicator dot
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: 6
                    radius: 3
                    color: Theme.accent
                    visible: root.isModified
                }

                // Reset to default button
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    radius: 9
                    color: resetHover.containsMouse ? Theme.surface : "transparent"
                    visible: root.isModified

                    Text {
                        anchors.centerIn: parent
                        text: "↺"
                        color: resetHover.containsMouse ? Theme.accent : Theme.muted
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: resetHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.resetToDefault(entry.key)
                    }
                }
            }

            Text {
                text: entry ? entry.description : ""
                color: Theme.muted
                font.pixelSize: 11
                elide: Text.ElideRight
                width: parent.width
            }
        }

        // Right interactive control container
        Item {
            id: controlContainer
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: {
                if (!entry) return 100;
                if (entry.type === "bool") return 48;
                if (entry.type === "enum") return enumRow.implicitWidth;
                if (entry.type === "int" || entry.type === "real") return 220;
                return 140;
            }

            // 1. Bool toggle switch
            Rectangle {
                visible: entry && entry.type === "bool"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: 44
                height: 22
                radius: 11
                color: root.currentValue ? Theme.accent : Theme.surface
                border.color: Theme.border
                border.width: 1

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.currentValue ? parent.width - width - 2 : 2
                    width: 18
                    height: 18
                    radius: 9
                    color: root.currentValue ? Theme.bg : Theme.fg
                    Behavior on x { NumberAnimation { duration: 120 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.set(entry.key, !root.currentValue)
                }
            }

            // 2. Enum segmented pill selector
            Row {
                id: enumRow
                visible: entry && entry.type === "enum"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 4

                Repeater {
                    model: entry && entry.options ? entry.options : []
                    Rectangle {
                        property bool isSelected: root.currentValue === modelData
                        width: optText.implicitWidth + 16
                        height: 26
                        radius: 6
                        color: isSelected ? Theme.accent : (optHover.containsMouse ? Theme.surface : "transparent")
                        border.color: isSelected ? Theme.accent : Theme.border
                        border.width: 1

                        Text {
                            id: optText
                            anchors.centerIn: parent
                            text: modelData
                            color: isSelected ? Theme.bg : Theme.fg
                            font.pixelSize: 11
                            font.bold: isSelected
                        }

                        MouseArea {
                            id: optHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Config.set(entry.key, modelData)
                        }
                    }
                }
            }

            // 3. Int & Real slider
            SettingSlider {
                visible: entry && (entry.type === "int" || entry.type === "real")
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                entry: root.entry
                propKey: root.propKey
                currentValue: root.currentValue
            }
        }
    }

    // Divider line at bottom
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.border
        opacity: 0.35
    }
}
