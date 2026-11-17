pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null

    property bool powered: adapter ? adapter.enabled : false
    property bool discovering: adapter ? adapter.discovering : false

    readonly property var devicesModel: adapter ? adapter.devices : Bluetooth.devices
    readonly property var devices: devicesModel ? devicesModel.values : []

    readonly property int connectedCount: {
        var count = 0;
        var devs = root.devices;
        for (var i = 0; i < devs.length; ++i) {
            if (devs[i].connected) count++;
        }
        return count;
    }

    readonly property bool hasConnectedDevice: connectedCount > 0

    function togglePower() {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    function toggleDiscovery() {
        if (adapter) {
            adapter.discovering = !adapter.discovering;
        }
    }

    function connectDevice(device) {
        if (device && typeof device.connect === "function") {
            device.connect();
            return true;
        }
        return false;
    }

    function disconnectDevice(device) {
        if (device && typeof device.disconnect === "function") {
            device.disconnect();
            return true;
        }
        return false;
    }

    function pairDevice(device) {
        if (device && typeof device.pair === "function") {
            device.pair();
            return true;
        }
        return false;
    }

    function forgetDevice(device) {
        if (device && typeof device.forget === "function") {
            device.forget();
            return true;
        }
        return false;
    }
}
