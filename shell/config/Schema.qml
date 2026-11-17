pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var categories: ["Bar", "UI", "Theme", "Hyprland", "Input", "Updates"]

    readonly property var entries: [
        // Bar
        { key: "bar.visible", category: "Bar", label: "Bar Visibility", description: "Toggle desktop status bar", type: "bool", defaultValue: true },
        { key: "bar.mode", category: "Bar", label: "Bar Mode", description: "Panel layout style", type: "enum", defaultValue: "island", options: ["bar", "island"] },
        { key: "bar.position", category: "Bar", label: "Bar Position", description: "Screen docking position", type: "enum", defaultValue: "top", options: ["top", "bottom"] },
        { key: "bar.height", category: "Bar", label: "Bar Height", description: "Height in pixels", type: "int", defaultValue: 34, min: 24, max: 64, step: 2 },
        { key: "bar.batteryMode", category: "Bar", label: "Battery Style", description: "Battery display style", type: "enum", defaultValue: "hybrid", options: ["icon", "percentage", "hybrid"] },
        { key: "bar.workspaceStyle", category: "Bar", label: "Workspace Style", description: "Workspaces widget style", type: "enum", defaultValue: "pills", options: ["pills", "numbers", "dots"] },
        { key: "bar.showTray", category: "Bar", label: "System Tray", description: "Show system status icons", type: "bool", defaultValue: true },
        { key: "bar.clockFormat", category: "Bar", label: "Clock Format", description: "Timestamp display pattern", type: "enum", defaultValue: "HH:mm", options: ["HH:mm", "hh:mm AP", "HH:mm:ss"] },

        // UI
        { key: "ui.designStyle", category: "UI", label: "Design Style", description: "Visual design language for interactive overlays", type: "enum", defaultValue: "follow-bar", options: ["follow-bar", "bar", "island"] },

        // Theme
        { key: "theme.active", category: "Theme", label: "Active Theme", description: "Current desktop color scheme preset", type: "string", defaultValue: "gruvbox-dark" },
        { key: "theme.followThemeBarMode", category: "Theme", label: "Theme Follows Bar Mode", description: "Sync bar mode to theme preset", type: "bool", defaultValue: false },

        // Hyprland
        { key: "hypr.gapsIn", category: "Hyprland", label: "Inner Gaps", description: "Gaps between windows (px)", type: "int", defaultValue: 2, min: 0, max: 30, step: 1 },
        { key: "hypr.gapsOut", category: "Hyprland", label: "Outer Gaps", description: "Gaps at screen edges (px)", type: "int", defaultValue: 4, min: 0, max: 60, step: 1 },
        { key: "hypr.borderSize", category: "Hyprland", label: "Border Size", description: "Window border thickness (px)", type: "int", defaultValue: 0, min: 0, max: 8, step: 1 },
        { key: "hypr.rounding", category: "Hyprland", label: "Corner Radius", description: "Window corner rounding (px)", type: "int", defaultValue: 10, min: 0, max: 30, step: 1 },
        { key: "hypr.roundingPower", category: "Hyprland", label: "Rounding Power", description: "Corner curvature exponent", type: "real", defaultValue: 10.0, min: 1.0, max: 20.0, step: 0.5 },
        { key: "hypr.activeOpacity", category: "Hyprland", label: "Active Opacity", description: "Opacity of focused window", type: "real", defaultValue: 0.95, min: 0.5, max: 1.0, step: 0.05 },
        { key: "hypr.inactiveOpacity", category: "Hyprland", label: "Inactive Opacity", description: "Opacity of unfocused windows", type: "real", defaultValue: 0.88, min: 0.5, max: 1.0, step: 0.05 },
        { key: "hypr.blurEnabled", category: "Hyprland", label: "Window Blur", description: "Dual kawase background blur", type: "bool", defaultValue: true },
        { key: "hypr.blurSize", category: "Hyprland", label: "Blur Size", description: "Sampling radius for blur", type: "int", defaultValue: 6, min: 1, max: 20, step: 1 },
        { key: "hypr.blurPasses", category: "Hyprland", label: "Blur Passes", description: "Number of filtering passes", type: "int", defaultValue: 4, min: 1, max: 6, step: 1 },
        { key: "hypr.animationsEnabled", category: "Hyprland", label: "Animations", description: "Enable window and layer animations", type: "bool", defaultValue: true },
        { key: "hypr.layout", category: "Hyprland", label: "Tiling Layout", description: "Active tiling algorithm", type: "enum", defaultValue: "dwindle", options: ["dwindle", "master"] },

        // Input
        { key: "input.sensitivity", category: "Input", label: "Cursor Sensitivity", description: "Mouse pointer speed multiplier", type: "real", defaultValue: 0.5, min: -1.0, max: 1.0, step: 0.1 },
        { key: "input.naturalScroll", category: "Input", label: "Natural Scrolling", description: "Invert touchpad scroll direction", type: "bool", defaultValue: true },
        { key: "input.disableWhileTyping", category: "Input", label: "Disable While Typing", description: "Ignore touchpad when typing", type: "bool", defaultValue: true },
        { key: "input.capsToEscape", category: "Input", label: "Caps Lock as Escape", description: "Remap Caps Lock to Escape key", type: "bool", defaultValue: true },

        // Updates
        { key: "updates.autoCheck", category: "Updates", label: "Auto Check Updates", description: "Periodically check for new releases", type: "bool", defaultValue: true },
        { key: "updates.checkIntervalHours", category: "Updates", label: "Check Interval", description: "Hours between automated checks", type: "int", defaultValue: 12, min: 1, max: 72, step: 1 }
    ]

    function get(key) {
        for (var i = 0; i < entries.length; ++i) {
            if (entries[i].key === key) return entries[i];
        }
        return null;
    }

    function getByCategory(category) {
        var result = [];
        for (var i = 0; i < entries.length; ++i) {
            if (entries[i].category === category) result.push(entries[i]);
        }
        return result;
    }
}
