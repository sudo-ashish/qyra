pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string statePath: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/qyra/state.json"
    readonly property string customPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/qyra/custom.json"

    signal loaded()
    signal loadFailed(var error)

    property alias bar: stateAdapter.bar
    property alias ui: stateAdapter.ui
    property alias theme: stateAdapter.theme
    property alias hypr: stateAdapter.hypr
    property alias input: stateAdapter.input
    property alias updates: stateAdapter.updates

    readonly property string activeDesignStyle: {
        var style = (ui && ui.designStyle) ? ui.designStyle : "follow-bar";
        if (style === "follow-bar") {
            return (bar && bar.mode) ? bar.mode : "island";
        }
        return (style === "bar") ? "bar" : "island";
    }

    property FileView stateFile: FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        atomicWrites: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: {
            root.mergeCustomJson();
            root.loaded();
        }
        onLoadFailed: function(error) {
            root.loadFailed(error);
        }

        adapter: JsonAdapter {
            id: stateAdapter
            property int version: 1

            property JsonObject bar: JsonObject {
                property bool visible: true
                property string mode: "island"
                property string position: "top"
                property int height: 34
                property string batteryMode: "hybrid"
                property string workspaceStyle: "pills"
                property bool showTray: true
                property string clockFormat: "HH:mm"
            }

            property JsonObject ui: JsonObject {
                property string designStyle: "follow-bar"
            }

            property JsonObject theme: JsonObject {
                property string active: "gruvbox-dark"
                property bool followThemeBarMode: false
            }

            property JsonObject hypr: JsonObject {
                property int gapsIn: 2
                property int gapsOut: 4
                property int borderSize: 0
                property int rounding: 10
                property real roundingPower: 10.0
                property real activeOpacity: 0.95
                property real inactiveOpacity: 0.88
                property bool blurEnabled: true
                property int blurSize: 6
                property int blurPasses: 4
                property bool animationsEnabled: true
                property string layout: "dwindle"
            }

            property JsonObject input: JsonObject {
                property real sensitivity: 0.5
                property bool naturalScroll: true
                property bool disableWhileTyping: true
                property bool capsToEscape: true
            }

            property JsonObject updates: JsonObject {
                property bool autoCheck: true
                property int checkIntervalHours: 12
            }
        }
    }

    property FileView customFile: FileView {
        id: customFile
        path: root.customPath
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: {
            reload();
            root.mergeCustomJson();
        }
        onLoaded: root.mergeCustomJson()
    }

    function mergeCustomJson() {
        var raw = customFile.text();
        if (!raw || raw.trim().length === 0) return;
        var parsed;
        try {
            parsed = JSON.parse(raw);
        } catch (e) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "Qyra Config Error", "Syntax error in ~/.config/qyra/custom.json: " + e.message]);
            return;
        }

        var categories = ["bar", "ui", "theme", "hypr", "input", "updates"];
        for (var i = 0; i < categories.length; ++i) {
            var cat = categories[i];
            if (parsed[cat] && typeof parsed[cat] === "object") {
                var target = stateAdapter[cat];
                if (!target) continue;
                for (var prop in parsed[cat]) {
                    if (target[prop] !== undefined && target[prop] !== parsed[cat][prop]) {
                        target[prop] = parsed[cat][prop];
                    }
                }
            }
        }
    }

    function get(key) {
        var parts = key.split(".");
        if (parts.length !== 2) return undefined;
        var section = stateAdapter[parts[0]];
        return section ? section[parts[1]] : undefined;
    }

    function set(key, value) {
        var parts = key.split(".");
        if (parts.length !== 2) return false;
        var section = stateAdapter[parts[0]];
        if (!section || section[parts[1]] === undefined) return false;

        var entry = Schema.get(key);
        var typedValue = value;
        if (entry) {
            if (entry.type === "bool") typedValue = (value === true || value === "true" || value === 1 || value === "1");
            else if (entry.type === "int") typedValue = parseInt(value, 10);
            else if (entry.type === "real") typedValue = parseFloat(value);
            else typedValue = String(value);
        }
        section[parts[1]] = typedValue;
        return true;
    }

    function toggleBool(key) {
        var entry = Schema.get(key);
        if (!entry || entry.type !== "bool") return false;
        var parts = key.split(".");
        var section = stateAdapter[parts[0]];
        if (!section || section[parts[1]] === undefined) return false;
        var nextVal = !section[parts[1]];
        section[parts[1]] = nextVal;
        return nextVal;
    }

    function cycleEnum(key) {
        var entry = Schema.get(key);
        if (!entry || entry.type !== "enum" || !entry.options || entry.options.length === 0) return "";
        var parts = key.split(".");
        var section = stateAdapter[parts[0]];
        if (!section || section[parts[1]] === undefined) return "";
        var nextVal = entry.options[(entry.options.indexOf(section[parts[1]]) + 1) % entry.options.length];
        section[parts[1]] = nextVal;
        return nextVal;
    }

    function resetToDefault(key) {
        var entry = Schema.get(key);
        if (!entry) return false;
        return set(key, entry.defaultValue);
    }

    function serialize() {
        return {
            version: stateAdapter.version,
            bar: {
                visible: stateAdapter.bar.visible,
                mode: stateAdapter.bar.mode,
                position: stateAdapter.bar.position,
                height: stateAdapter.bar.height,
                batteryMode: stateAdapter.bar.batteryMode,
                workspaceStyle: stateAdapter.bar.workspaceStyle,
                showTray: stateAdapter.bar.showTray,
                clockFormat: stateAdapter.bar.clockFormat
            },
            ui: {
                designStyle: stateAdapter.ui.designStyle
            },
            theme: {
                active: stateAdapter.theme.active,
                followThemeBarMode: stateAdapter.theme.followThemeBarMode
            },
            hypr: {
                gapsIn: stateAdapter.hypr.gapsIn,
                gapsOut: stateAdapter.hypr.gapsOut,
                borderSize: stateAdapter.hypr.borderSize,
                rounding: stateAdapter.hypr.rounding,
                roundingPower: stateAdapter.hypr.roundingPower,
                activeOpacity: stateAdapter.hypr.activeOpacity,
                inactiveOpacity: stateAdapter.hypr.inactiveOpacity,
                blurEnabled: stateAdapter.hypr.blurEnabled,
                blurSize: stateAdapter.hypr.blurSize,
                blurPasses: stateAdapter.hypr.blurPasses,
                animationsEnabled: stateAdapter.hypr.animationsEnabled,
                layout: stateAdapter.hypr.layout
            },
            input: {
                sensitivity: stateAdapter.input.sensitivity,
                naturalScroll: stateAdapter.input.naturalScroll,
                disableWhileTyping: stateAdapter.input.disableWhileTyping,
                capsToEscape: stateAdapter.input.capsToEscape
            },
            updates: {
                autoCheck: stateAdapter.updates.autoCheck,
                checkIntervalHours: stateAdapter.updates.checkIntervalHours
            }
        };
    }

    Component.onCompleted: {
        // If state file is not present on disk, initialize it with defaults
        if (!stateFile.loaded) {
            stateFile.writeAdapter();
        }
        mergeCustomJson();
    }
}
