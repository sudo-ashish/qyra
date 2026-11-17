import QtQuick
import "../config"

Item {
    id: root

    readonly property bool isBarVisible: Config.bar ? Config.bar.visible : true
    readonly property string mode: Config.bar ? Config.bar.mode : "island"

    Loader {
        id: barLoader
        active: root.isBarVisible
        source: {
            if (!root.isBarVisible) return "";
            if (root.mode === "bar") return "FullBar.qml";
            return "IslandBar.qml";
        }
    }
}
