import QtQuick
import Quickshell
import Quickshell.Io
import "config"
import "services"
import "settings"
import "bars"
import "osd"
import "components"
import "launcher"
import "powermenu"

ShellRoot {
    id: root

    // Reference singletons to ensure eager instantiation
    property var configRef: Config
    property var schemaRef: Schema
    property var snapshotRef: Snapshot
    property var themeRef: Theme
    property var hyprRef: Hypr
    property var batteryRef: Battery
    property var networkRef: Network
    property var bluetoothRef: Bluetooth
    property var audioRef: Audio
    property var mediaRef: Media
    property var notificationsRef: Notifications
    property var updaterRef: Updater
    property var appsRef: Apps
    property var powerRef: Power

    property bool settingsVisible: false
    property string activeSettingsCategory: "Bar"

    signal settingsToggleRequested()
    signal settingsCategoryRequested(string category)

    // IPC Target: config
    IpcHandler {
        target: "config"

        function toggle(key: string): string {
            var res = Config.toggleBool(key);
            osdWin.showConfig(key, String(res));
            return String(res);
        }

        function cycle(key: string): string {
            var res = Config.cycleEnum(key);
            osdWin.showConfig(key, String(res));
            return String(res);
        }

        function set(key: string, val: string): string {
            var ok = Config.set(key, val);
            if (ok) osdWin.showConfig(key, String(val));
            return ok ? "ok" : "failed";
        }

        function get(key: string): string {
            var val = Config.get(key);
            return val !== undefined ? String(val) : "undefined";
        }
    }

    SettingsWindow {
        id: settingsWin
    }

    BarController {
        id: barCtrl
    }

    ModeViewLoader {
        id: launcherLoader
        barView: "launcher/BarLauncher.qml"
        islandView: "launcher/IslandLauncher.qml"
    }

    ModeViewLoader {
        id: powerMenuLoader
        barView: "powermenu/BarPowerMenu.qml"
        islandView: "powermenu/IslandPowerMenu.qml"
    }

    OsdWindow {
        id: osdWin
    }

    // IPC Target: launcher
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            Apps.toggle();
        }
    }

    // IPC Target: powermenu
    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            Power.toggle();
        }
    }

    // IPC Target: settings
    IpcHandler {
        target: "settings"

        function toggle(): void {
            settingsWin.toggle();
        }

        function openCategory(category: string): void {
            settingsWin.openCategory(category);
        }
    }

    // IPC Target: theme
    IpcHandler {
        target: "theme"

        function apply(name: string): string {
            var ok = Theme.applyTheme(name);
            return ok ? "ok" : "failed";
        }

        function open(): void {
            settingsWin.openCategory("Theme");
        }
    }

    // IPC Target: osd
    IpcHandler {
        target: "osd"

        function outputVolume(action: string): void {
            if (action === "raise") Audio.adjustVolume(0.05);
            else if (action === "lower") Audio.adjustVolume(-0.05);
            else if (action === "raise-fine") Audio.adjustVolume(0.01);
            else if (action === "lower-fine") Audio.adjustVolume(-0.01);
            else if (action === "mute-toggle") Audio.toggleMute();
            osdWin.showAudio(Audio.volume, Audio.muted);
        }

        function inputVolume(action: string): void {
            if (action === "mute-toggle") Audio.toggleMicMute();
            osdWin.showMic(Audio.micVolume, Audio.micMuted);
        }
    }

    // IPC Target: brightness
    IpcHandler {
        target: "brightness"

        function action(act: string): void {
            if (act === "raise") Quickshell.execDetached(["brightnessctl", "set", "5%+"]);
            else if (act === "lower") Quickshell.execDetached(["brightnessctl", "set", "5%-"]);
            else if (act === "raise-fine") Quickshell.execDetached(["brightnessctl", "set", "1%+"]);
            else if (act === "lower-fine") Quickshell.execDetached(["brightnessctl", "set", "1%-"]);
        }
    }

    // IPC Target: snapshot
    IpcHandler {
        target: "snapshot"

        function create(label: string): string {
            return Snapshot.createSnapshot(label);
        }

        function restore(filename: string): string {
            var ok = Snapshot.restoreSnapshot(filename);
            return ok ? "ok" : "failed";
        }
    }

    Component.onCompleted: {
        console.log("Qyra desktop shell initialized successfully.");
        console.log("State path:", Config.statePath);
        console.log("Active bar mode:", Config.bar.mode);
        console.log("Active theme:", Config.theme.active);
        console.log("Audio sink volume:", Math.round(Audio.volume * 100) + "%");
        console.log("Battery present:", Battery.hasBattery ? (Battery.percentage + "%") : "No battery");
        console.log("IPC handlers ready: config, settings, theme, osd, brightness, snapshot, launcher, powermenu");
    }
}
