pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

QtObject {
    id: root

    property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property var devicesModel: Networking.devices
    readonly property var devices: Networking.devices.values

    readonly property var wifiDevice: {
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; ++i) {
            if (devs[i].type === DeviceType.Wifi) return devs[i];
        }
        return null;
    }

    readonly property var wiredDevice: {
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; ++i) {
            if (devs[i].type === DeviceType.Wired) return devs[i];
        }
        return null;
    }

    readonly property var networks: (wifiDevice && wifiDevice.networks) ? wifiDevice.networks.values : []

    readonly property var connectedNetwork: {
        if (!wifiDevice || !wifiDevice.networks) return null;
        var nets = wifiDevice.networks.values;
        for (var i = 0; i < nets.length; ++i) {
            if (nets[i].connected) return nets[i];
        }
        return null;
    }

    readonly property bool connected: (connectedNetwork !== null) || (wiredDevice !== null && wiredDevice.connected)
    readonly property bool isWired: wiredDevice !== null && wiredDevice.connected
    readonly property string ssid: connectedNetwork ? connectedNetwork.name : (isWired ? "Ethernet" : "")

    readonly property int signalStrength: {
        if (isWired) return 100;
        if (!connectedNetwork) return 0;
        var s = connectedNetwork.signalStrength;
        return Math.round(s <= 1.0 ? s * 100 : s);
    }

    readonly property string connectivity: {
        switch (Networking.connectivity) {
        case NetworkConnectivity.Full: return "full";
        case NetworkConnectivity.Limited: return "limited";
        case NetworkConnectivity.Portal: return "portal";
        case NetworkConnectivity.None: return "none";
        default: return "unknown";
        }
    }

    property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function scan() {
        if (wifiDevice) {
            wifiDevice.scannerEnabled = true;
        }
    }

    function connect(network, password) {
        if (!network) return false;
        if (password && password.length > 0) {
            network.connectWithPsk(password);
        } else {
            network.connect();
        }
        return true;
    }

    function disconnect() {
        if (connectedNetwork) {
            connectedNetwork.disconnect();
        } else if (wifiDevice) {
            wifiDevice.disconnect();
        }
    }
}
