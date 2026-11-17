import QtQuick
import Quickshell
import "../config"
import "../services"

FloatingWindow {
    id: root
    title: "Qyra Settings"
    implicitWidth: 880
    implicitHeight: 560
    color: Theme.bg

    PersistentProperties {
        id: persist
        reloadableId: "qyraSettingsWindow"
        property bool isVisible: false
        property string activeCategory: "Bar"
        property string searchQuery: ""
    }

    visible: persist.isVisible

    function toggle() {
        persist.isVisible = !persist.isVisible;
    }

    function openCategory(cat) {
        persist.activeCategory = cat;
        persist.searchQuery = "";
        persist.isVisible = true;
    }

    readonly property var categories: [
        { id: "Bar", label: "Bar & Dock", icon: "📊" },
        { id: "Theme", label: "Appearance", icon: "🎨" },
        { id: "Hyprland", label: "Window Manager", icon: "🪟" },
        { id: "Input", label: "Keyboard & Mouse", icon: "⌨" },
        { id: "Snapshots", label: "Snapshots", icon: "💾" },
        { id: "Updates", label: "Updates", icon: "🔄" }
    ]

    function searchEntries(query) {
        var q = query.trim().toLowerCase();
        if (q.length === 0) return [];
        var res = [];
        for (var i = 0; i < Schema.entries.length; ++i) {
            var e = Schema.entries[i];
            if (e.label.toLowerCase().indexOf(q) !== -1 ||
                e.key.toLowerCase().indexOf(q) !== -1 ||
                (e.description && e.description.toLowerCase().indexOf(q) !== -1)) {
                res.push(e);
            }
        }
        return res;
    }

    Column {
        anchors.fill: parent

        // Titlebar & Search Bar
        Rectangle {
            width: parent.width
            height: 48
            color: Theme.surface
            border.color: Theme.border
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 16

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Text { text: "⚙"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Qyra Settings"; color: Theme.fg; font.pixelSize: 14; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                }

                // Search field
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 320
                    height: 30
                    radius: 6
                    color: Theme.bg
                    border.color: searchInput.activeFocus ? Theme.accent : Theme.border
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text { text: "🔍"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }

                        TextInput {
                            id: searchInput
                            width: parent.width - 40
                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            text: persist.searchQuery
                            color: Theme.fg
                            font.pixelSize: 12
                            onTextChanged: persist.searchQuery = text

                            Text {
                                anchors.fill: parent
                                text: "Search all settings..."
                                color: Theme.muted
                                font.pixelSize: 11
                                visible: !searchInput.text && !searchInput.activeFocus
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Text {
                            text: "✕"
                            color: Theme.muted
                            font.pixelSize: 11
                            visible: persist.searchQuery.length > 0
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { persist.searchQuery = ""; searchInput.text = ""; }
                            }
                        }
                    }
                }

                Item { width: parent.width - 550; height: 1 }

                // Close button
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 26
                    height: 26
                    radius: 13
                    color: closeHover.containsMouse ? Theme.urgent : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeHover.containsMouse ? Theme.bg : Theme.fg
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: closeHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: persist.isVisible = false
                    }
                }
            }
        }

        // Main Layout (Sidebar + Content)
        Row {
            width: parent.width
            height: parent.height - 48

            SettingsSidebar {
                height: parent.height
                categories: root.categories
                activeCategory: persist.searchQuery === "" ? persist.activeCategory : ""
                onCategorySelected: function(catId) {
                    persist.searchQuery = "";
                    searchInput.text = "";
                    persist.activeCategory = catId;
                }
            }

            // Right Content Area
            Item {
                width: parent.width - 190
                height: parent.height
                clip: true

                // Search Results
                ListView {
                    visible: persist.searchQuery.trim().length > 0
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 2
                    model: root.searchEntries(persist.searchQuery)
                    delegate: DynamicControl {
                        width: parent ? parent.width : 500
                        entry: modelData
                    }
                }

                // Dedicated Pages & Schema Category Views
                Item {
                    visible: persist.searchQuery.trim().length === 0
                    anchors.fill: parent

                    ThemePage {
                        anchors.fill: parent
                        visible: persist.activeCategory === "Theme"
                    }

                    SnapshotPage {
                        anchors.fill: parent
                        visible: persist.activeCategory === "Snapshots"
                    }

                    UpdatePage {
                        anchors.fill: parent
                        visible: persist.activeCategory === "Updates"
                    }

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 2
                        visible: persist.activeCategory === "Bar" || persist.activeCategory === "Hyprland" || persist.activeCategory === "Input"
                        model: Schema.getByCategory(persist.activeCategory)
                        delegate: DynamicControl {
                            width: parent ? parent.width : 500
                            entry: modelData
                        }
                    }
                }
            }
        }
    }
}
