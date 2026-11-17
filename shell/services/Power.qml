pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    property bool isOpen: false

    function toggle() {
        root.isOpen = !root.isOpen;
    }

    function open() {
        root.isOpen = true;
    }

    function close() {
        root.isOpen = false;
    }

    function lock() {
        root.close();
        Quickshell.execDetached(["hyprlock"]);
    }

    function suspend() {
        root.close();
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        root.close();
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function shutdown() {
        root.close();
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function logout() {
        root.close();
        Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
    }

    readonly property var actions: [
        { id: "lock", label: "Lock", icon: "󰌾", action: function() { root.lock(); } },
        { id: "suspend", label: "Suspend", icon: "󰤄", action: function() { root.suspend(); } },
        { id: "logout", label: "Log Out", icon: "󰍃", action: function() { root.logout(); } },
        { id: "reboot", label: "Reboot", icon: "󰜉", action: function() { root.reboot(); } },
        { id: "shutdown", label: "Power Off", icon: "󰐥", action: function() { root.shutdown(); } }
    ]
}
