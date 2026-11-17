import QtQuick
import "../config"

Loader {
    id: root

    property url barView
    property url islandView
    property Component barComponent: null
    property Component islandComponent: null

    readonly property string currentStyle: Config.activeDesignStyle

    source: {
        if (barComponent || islandComponent) return "";
        return currentStyle === "bar" ? barView : islandView;
    }

    sourceComponent: {
        if (currentStyle === "bar") return barComponent;
        return islandComponent;
    }
}
