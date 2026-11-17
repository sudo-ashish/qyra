import QtQuick
import Quickshell
import "../config"
import "../services"

Rectangle {
    id: root
    visible: false
    anchors.fill: parent
    color: "#cc000000"

    signal closed()

    property string themeName: ""
    property string wallpaperPath: ""
    property string bgHex: "#1e1e2e"
    property string surfaceHex: "#313244"
    property string fgHex: "#cdd6f4"
    property string accentHex: "#cba6f7"
    property string urgentHex: "#f38ba8"

    function openModal() {
        themeName = "custom-" + Qt.formatDateTime(new Date(), "hhmm");
        wallpaperPath = Theme.currentWallpaperPath;
        bgHex = "" + Theme.bg;
        surfaceHex = "" + Theme.surface;
        fgHex = "" + Theme.fg;
        accentHex = "" + Theme.accent;
        urgentHex = "" + Theme.urgent;
        visible = true;
    }

    function createAndApply() {
        var cleanName = themeName.trim().toLowerCase().replace(/[^a-z0-9_-]/g, "-");
        if (cleanName.length === 0) return;

        var targetDir = Theme.themesDir + "/" + cleanName;
        var tomlContent = "[colors]\n" +
            "bg = \"" + bgHex + "\"\n" +
            "surface = \"" + surfaceHex + "\"\n" +
            "fg = \"" + fgHex + "\"\n" +
            "accent = \"" + accentHex + "\"\n" +
            "urgent = \"" + urgentHex + "\"\n" +
            "border = \"" + surfaceHex + "\"\n" +
            "muted = \"" + surfaceHex + "\"\n";

        var wallCmd = "";
        if (wallpaperPath && wallpaperPath.trim().length > 0) {
            wallCmd = "cp '" + wallpaperPath.trim() + "' '" + targetDir + "/background' 2>/dev/null || true; ";
        } else {
            wallCmd = "cp '" + Theme.currentWallpaperPath + "' '" + targetDir + "/background' 2>/dev/null || true; ";
        }

        Quickshell.execDetached(["sh", "-c",
            "mkdir -p '" + targetDir + "' && " +
            "cat << 'EOF' > '" + targetDir + "/colors.toml'\n" + tomlContent + "EOF\n" +
            wallCmd
        ]);

        // Debounce apply to give write time to finish
        applyTimer.targetName = cleanName;
        applyTimer.start();
        root.visible = false;
        root.closed();
    }

    Timer {
        id: applyTimer
        property string targetName: ""
        interval: 150
        repeat: false
        onTriggered: {
            Theme.applyTheme(targetName);
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { /* block clicks through */ }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 440
        height: 380
        radius: 12
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Item {
                width: parent.width
                height: 20
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Create Custom Theme"
                    color: Theme.fg
                    font.pixelSize: 15
                    font.bold: true
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "✕"
                    color: Theme.muted
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.visible = false; root.closed(); }
                    }
                }
            }

            // Name field
            Column {
                width: parent.width
                spacing: 4
                Text { text: "Theme Name"; color: Theme.muted; font.pixelSize: 11 }
                Rectangle {
                    width: parent.width; height: 30; radius: 6; color: Theme.surface; border.color: Theme.border
                    TextInput {
                        anchors.fill: parent; anchors.margins: 6; text: root.themeName; color: Theme.fg; font.pixelSize: 12
                        onTextChanged: root.themeName = text
                    }
                }
            }

            // Wallpaper field
            Column {
                width: parent.width
                spacing: 4
                Text { text: "Wallpaper Path"; color: Theme.muted; font.pixelSize: 11 }
                Rectangle {
                    width: parent.width; height: 30; radius: 6; color: Theme.surface; border.color: Theme.border
                    TextInput {
                        anchors.fill: parent; anchors.margins: 6; text: root.wallpaperPath; color: Theme.fg; font.pixelSize: 12
                        onTextChanged: root.wallpaperPath = text
                    }
                }
            }

            // Colors grid
            Text { text: "Color Palette"; color: Theme.muted; font.pixelSize: 11 }
            Row {
                spacing: 8
                Repeater {
                    model: [
                        { label: "BG", prop: "bgHex", val: root.bgHex },
                        { label: "Surface", prop: "surfaceHex", val: root.surfaceHex },
                        { label: "FG", prop: "fgHex", val: root.fgHex },
                        { label: "Accent", prop: "accentHex", val: root.accentHex },
                        { label: "Urgent", prop: "urgentHex", val: root.urgentHex }
                    ]
                    Column {
                        spacing: 4
                        Text { text: modelData.label; color: Theme.muted; font.pixelSize: 10 }
                        Rectangle {
                            width: 68; height: 26; radius: 4; color: modelData.val; border.color: Theme.border
                            TextInput {
                                anchors.centerIn: parent
                                text: modelData.val
                                color: (modelData.label === "BG" || modelData.label === "Surface") ? "#ffffff" : "#000000"
                                font.pixelSize: 10
                                onTextChanged: {
                                    if (modelData.prop === "bgHex") root.bgHex = text;
                                    else if (modelData.prop === "surfaceHex") root.surfaceHex = text;
                                    else if (modelData.prop === "fgHex") root.fgHex = text;
                                    else if (modelData.prop === "accentHex") root.accentHex = text;
                                    else if (modelData.prop === "urgentHex") root.urgentHex = text;
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 6; width: 1 }

            // Action buttons
            Row {
                anchors.right: parent.right
                spacing: 12

                Rectangle {
                    width: 80; height: 32; radius: 6; color: Theme.surface; border.color: Theme.border
                    Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.fg; font.pixelSize: 12 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.visible = false; root.closed(); }
                    }
                }

                Rectangle {
                    width: 120; height: 32; radius: 6; color: Theme.accent
                    Text { anchors.centerIn: parent; text: "Create & Apply"; color: Theme.bg; font.bold: true; font.pixelSize: 12 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.createAndApply()
                    }
                }
            }
        }
    }
}
