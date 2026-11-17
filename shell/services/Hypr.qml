pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../config"

QtObject {
    id: root

    // Reactive Hyprland State (Native C++)
    readonly property var workspaces: Hyprland.workspaces
    readonly property var monitors: Hyprland.monitors
    readonly property var toplevels: Hyprland.toplevels
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var activeToplevel: Hyprland.activeToplevel

    property var pendingChanges: ({})

    property Timer debounceTimer: Timer {
        interval: 20
        repeat: false
        onTriggered: root.flushPendingChanges()
    }

    function queueChange(key, value) {
        pendingChanges[key] = value;
        debounceTimer.restart();
    }

    function objToLua(obj) {
        var entries = [];
        for (var k in obj) {
            entries.push(k + " = " + obj[k]);
        }
        return "{" + entries.join(", ") + "}";
    }

    function buildLuaConfig(changes) {
        var general = {};
        var decoration = {};
        var blur = {};
        var animations = {};
        var input = {};
        var touchpad = {};

        if (changes.gapsIn !== undefined) general["gaps_in"] = changes.gapsIn;
        if (changes.gapsOut !== undefined) general["gaps_out"] = changes.gapsOut;
        if (changes.borderSize !== undefined) general["border_size"] = changes.borderSize;
        if (changes.layout !== undefined) general["layout"] = '"' + changes.layout + '"';

        if (changes.rounding !== undefined) decoration["rounding"] = changes.rounding;
        if (changes.roundingPower !== undefined) decoration["rounding_power"] = changes.roundingPower;
        if (changes.activeOpacity !== undefined) decoration["active_opacity"] = changes.activeOpacity;
        if (changes.inactiveOpacity !== undefined) decoration["inactive_opacity"] = changes.inactiveOpacity;

        if (changes.blurEnabled !== undefined) blur["enabled"] = changes.blurEnabled ? "true" : "false";
        if (changes.blurSize !== undefined) blur["size"] = changes.blurSize;
        if (changes.blurPasses !== undefined) blur["passes"] = changes.blurPasses;

        if (changes.animationsEnabled !== undefined) animations["enabled"] = changes.animationsEnabled ? "true" : "false";

        if (changes.sensitivity !== undefined) input["sensitivity"] = changes.sensitivity;
        if (changes.capsToEscape !== undefined) input["kb_options"] = changes.capsToEscape ? '"caps:escape"' : '""';

        if (changes.naturalScroll !== undefined) touchpad["natural_scroll"] = changes.naturalScroll ? "true" : "false";
        if (changes.disableWhileTyping !== undefined) touchpad["disable_while_typing"] = changes.disableWhileTyping ? "true" : "false";

        var parts = [];
        if (Object.keys(general).length > 0) parts.push("general = " + objToLua(general));
        if (Object.keys(blur).length > 0) decoration["blur"] = objToLua(blur);
        if (Object.keys(decoration).length > 0) parts.push("decoration = " + objToLua(decoration));
        if (Object.keys(animations).length > 0) parts.push("animations = " + objToLua(animations));
        if (Object.keys(touchpad).length > 0) input["touchpad"] = objToLua(touchpad);
        if (Object.keys(input).length > 0) parts.push("input = " + objToLua(input));

        if (parts.length === 0) return "";
        return "{" + parts.join(", ") + "}";
    }

    function flushPendingChanges() {
        var luaTable = buildLuaConfig(pendingChanges);
        pendingChanges = {};
        if (luaTable.length > 0) {
            console.log("Hypr: Applying live config to Hyprland:", luaTable);
            Quickshell.execDetached(["hyprctl", "eval", "hl.config(" + luaTable + ")"]);
        }
    }

    function updateBorderColors(activeHex, inactiveHex) {
        var active = activeHex ? String(activeHex).replace("#", "0xff") : ("0xff" + String(Theme.accent).replace("#", ""));
        var inactive = inactiveHex ? String(inactiveHex).replace("#", "0xff") : ("0xff" + String(Theme.border).replace("#", ""));
        var cmd = 'hl.config({ general = { ["col.active_border"] = "' + active + '", ["col.inactive_border"] = "' + inactive + '" } })';
        Quickshell.execDetached(["hyprctl", "eval", cmd]);
    }

    function dispatch(request) {
        Hyprland.dispatch(request);
    }

    property Connections hyprConnections: Connections {
        target: Config.hypr
        function onGapsInChanged() { root.queueChange("gapsIn", Config.hypr.gapsIn); }
        function onGapsOutChanged() { root.queueChange("gapsOut", Config.hypr.gapsOut); }
        function onBorderSizeChanged() { root.queueChange("borderSize", Config.hypr.borderSize); }
        function onRoundingChanged() { root.queueChange("rounding", Config.hypr.rounding); }
        function onRoundingPowerChanged() { root.queueChange("roundingPower", Config.hypr.roundingPower); }
        function onActiveOpacityChanged() { root.queueChange("activeOpacity", Config.hypr.activeOpacity); }
        function onInactiveOpacityChanged() { root.queueChange("inactiveOpacity", Config.hypr.inactiveOpacity); }
        function onBlurEnabledChanged() { root.queueChange("blurEnabled", Config.hypr.blurEnabled); }
        function onBlurSizeChanged() { root.queueChange("blurSize", Config.hypr.blurSize); }
        function onBlurPassesChanged() { root.queueChange("blurPasses", Config.hypr.blurPasses); }
        function onAnimationsEnabledChanged() { root.queueChange("animationsEnabled", Config.hypr.animationsEnabled); }
        function onLayoutChanged() { root.queueChange("layout", Config.hypr.layout); }
    }

    property Connections inputConnections: Connections {
        target: Config.input
        function onSensitivityChanged() { root.queueChange("sensitivity", Config.input.sensitivity); }
        function onNaturalScrollChanged() { root.queueChange("naturalScroll", Config.input.naturalScroll); }
        function onDisableWhileTypingChanged() { root.queueChange("disableWhileTyping", Config.input.disableWhileTyping); }
        function onCapsToEscapeChanged() { root.queueChange("capsToEscape", Config.input.capsToEscape); }
    }

    property Connections themeConnections: Connections {
        target: Theme
        function onAccentChanged() { root.updateBorderColors(); }
        function onBorderChanged() { root.updateBorderColors(); }
    }
}
