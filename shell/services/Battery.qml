pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

QtObject {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool hasBattery: device !== null && device.isPresent

    readonly property int percentage: {
        if (!hasBattery) return 100;
        var p = device.percentage;
        return Math.round(p <= 1.0 && p > 0.0 ? p * 100 : p);
    }

    readonly property bool isCharging: {
        if (!hasBattery) return false;
        return device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge;
    }

    readonly property string stateText: {
        if (!hasBattery) return "AC Connected";
        switch (device.state) {
        case UPowerDeviceState.Charging: return "Charging";
        case UPowerDeviceState.Discharging: return "Discharging";
        case UPowerDeviceState.FullyCharged: return "Fully Charged";
        case UPowerDeviceState.Empty: return "Empty";
        case UPowerDeviceState.PendingCharge: return "Pending Charge";
        case UPowerDeviceState.PendingDischarge: return "Pending Discharge";
        default: return "Not Charging";
        }
    }

    readonly property int timeToEmpty: hasBattery ? device.timeToEmpty : 0
    readonly property int timeToFull: hasBattery ? device.timeToFull : 0

    readonly property string iconName: {
        if (!hasBattery) return "battery-missing-symbolic";
        var bucket = Math.round(percentage / 10) * 10;
        bucket = Math.max(0, Math.min(100, bucket));
        if (isCharging) {
            return "battery-level-" + bucket + "-charging-symbolic";
        } else {
            return "battery-level-" + bucket + "-symbolic";
        }
    }

    // Power Profiles integration
    readonly property string activePowerProfile: {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver: return "power-saver";
        case PowerProfile.Performance: return "performance";
        case PowerProfile.Balanced:
        default: return "balanced";
        }
    }

    function setPowerProfile(profileName) {
        if (profileName === "power-saver") {
            PowerProfiles.profile = PowerProfile.PowerSaver;
        } else if (profileName === "performance" && PowerProfiles.hasPerformanceProfile) {
            PowerProfiles.profile = PowerProfile.Performance;
        } else {
            PowerProfiles.profile = PowerProfile.Balanced;
        }
    }
}
