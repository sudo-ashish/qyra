pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

QtObject {
    id: root

    readonly property string themesDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/themes"
    readonly property string currentColorsPath: themesDir + "/current/generated/colors.json"
    readonly property string currentWallpaperPath: themesDir + "/current/background"

    // Reactive Color Tokens (Gruvbox Dark Fallbacks)
    property color bg: "#282828"
    property color fg: "#ebdbb2"
    property color surface: "#3c3836"
    property color accent: "#7daea3"
    property color urgent: "#ea6962"
    property color border: "#504945"
    property color muted: "#7c6f64"
    property color red: "#ea6962"
    property color green: "#a9b665"
    property color yellow: "#d8a657"
    property color blue: "#7daea3"
    property color magenta: "#d3869b"
    property color cyan: "#89b482"

    function withAlpha(colorVal, alphaVal) {
        if (!colorVal || colorVal.r === undefined) {
            var c = Qt.color(colorVal || "#000000");
            return Qt.rgba(c.r, c.g, c.b, alphaVal !== undefined ? alphaVal : 1.0);
        }
        return Qt.rgba(colorVal.r, colorVal.g, colorVal.b, alphaVal !== undefined ? alphaVal : 1.0);
    }

    property FileView colorsFile: FileView {
        id: colorsFile
        path: root.currentColorsPath
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: {
            reload();
            root.loadColors();
            root.reloadKitty();
        }
        onLoaded: root.loadColors()
    }

    function reloadKitty() {
        var kittyDir = (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/kitty";
        var currentLink = root.themesDir + "/current";
        Quickshell.execDetached(["sh", "-c",
            "mkdir -p '" + kittyDir + "' && " +
            "if [ -f '" + currentLink + "/color.conf' ]; then ln -sfn '" + currentLink + "/color.conf' '" + kittyDir + "/color.conf'; " +
            "elif [ -f '" + currentLink + "/generated/color.conf' ]; then ln -sfn '" + currentLink + "/generated/color.conf' '" + kittyDir + "/color.conf'; fi && " +
            "if pgrep -u \"$(id -u)\" -x kitty >/dev/null 2>&1; then pkill -SIGUSR1 -u \"$(id -u)\" -x kitty 2>/dev/null || true; fi"
        ]);
    }

    function loadColors() {
        var raw = colorsFile.text();
        if (!raw || raw.trim().length === 0) return;
        try {
            var c = JSON.parse(raw);
            if (c.bg) root.bg = c.bg;
            if (c.fg) root.fg = c.fg;
            if (c.surface) root.surface = c.surface;
            if (c.accent) root.accent = c.accent;
            if (c.urgent) root.urgent = c.urgent;
            if (c.border) root.border = c.border;
            if (c.muted) root.muted = c.muted;
            if (c.red) root.red = c.red;
            if (c.green) root.green = c.green;
            if (c.yellow) root.yellow = c.yellow;
            if (c.blue) root.blue = c.blue;
            if (c.magenta) root.magenta = c.magenta;
            if (c.cyan) root.cyan = c.cyan;
        } catch (e) {
            console.log("Theme: Error parsing colors.json:", e);
        }
    }

    function applyTheme(themeName) {
        if (!themeName || themeName.length === 0) return false;

        var targetThemeDir = root.themesDir + "/" + themeName;
        var currentLink = root.themesDir + "/current";
        var genColors = targetThemeDir + "/generated/colors.json";
        var wallpaper = targetThemeDir + "/background";
        var kittyDir = (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/kitty";

        // 1. Run theme generator if generated assets do not exist
        var themeGenBin = Quickshell.env("HOME") + "/.local/share/qyra/bin/qyra-theme-gen";
        // Also check repo bin during development
        var repoBin = (Quickshell.env("PWD") || ".") + "/bin/qyra-theme-gen";

        Quickshell.execDetached(["sh", "-c",
            "mkdir -p '" + root.themesDir + "' && " +
            "if [ ! -d '" + targetThemeDir + "' ] && [ -d 'defaults/themes/" + themeName + "' ]; then cp -r 'defaults/themes/" + themeName + "' '" + root.themesDir + "/'; fi && " +
            "if [ ! -f '" + genColors + "' ]; then (" + repoBin + " '" + targetThemeDir + "' || " + themeGenBin + " '" + targetThemeDir + "'); fi && " +
            "ln -sfn '" + targetThemeDir + "' '" + currentLink + "' && " +
            "if [ -f '" + wallpaper + "' ]; then awww img '" + wallpaper + "' 2>/dev/null || true; fi && " +
            "mkdir -p '" + kittyDir + "' && " +
            "if [ -f '" + targetThemeDir + "/color.conf' ]; then ln -sfn '" + currentLink + "/color.conf' '" + kittyDir + "/color.conf'; " +
            "elif [ -f '" + targetThemeDir + "/generated/color.conf' ]; then ln -sfn '" + currentLink + "/generated/color.conf' '" + kittyDir + "/color.conf'; fi && " +
            "if pgrep -u \"$(id -u)\" -x kitty >/dev/null 2>&1; then pkill -SIGUSR1 -u \"$(id -u)\" -x kitty 2>/dev/null || true; fi"
        ]);

        Config.theme.active = themeName;
        colorsFile.reload();
        root.loadColors();
        return true;
    }

    function createTheme(name, baseTheme, wallpaperPath, palette) {
        if (!name || name.length === 0) return "";
        var cleanName = name.trim().toLowerCase().replace(/[^a-z0-9_-]/g, "-");
        var targetDir = root.themesDir + "/" + cleanName;

        var tomlLines = ['# Theme: ' + cleanName, 'name = "' + cleanName + '"'];
        var pal = palette || {};
        var keys = ["background", "dark_background", "lighter_background", "foreground", "dark_foreground",
                    "accent", "selection", "muted", "border", "urgent", "red", "green", "yellow", "blue", "magenta", "cyan"];
        for (var i = 0; i < keys.length; ++i) {
            var k = keys[i];
            if (pal[k]) tomlLines.push(k + ' = "' + pal[k] + '"');
        }
        var tomlContent = tomlLines.join("\n") + "\n";

        var themeGenBin = Quickshell.env("HOME") + "/.local/share/qyra/bin/qyra-theme-gen";
        var repoBin = (Quickshell.env("PWD") || ".") + "/bin/qyra-theme-gen";
        var wpCmd = (wallpaperPath && wallpaperPath.length > 0) ? ("cp '" + wallpaperPath + "' '" + targetDir + "/background' && ") : "";

        Quickshell.execDetached(["sh", "-c",
            "mkdir -p '" + targetDir + "' && " +
            "cat << 'EOF' > '" + targetDir + "/colors.toml'\n" + tomlContent + "EOF\n" +
            wpCmd +
            "(" + repoBin + " '" + targetDir + "' || " + themeGenBin + " '" + targetDir + "')"
        ]);

        return cleanName;
    }

    Component.onCompleted: {
        loadColors();
    }
}
