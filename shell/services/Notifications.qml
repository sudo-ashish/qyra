pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    property bool dndEnabled: false

    property NotificationServer server: NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: function(notif) {
            notif.tracked = true;
            root.unreadCount++;
            root.notificationReceived(notif);
        }
    }

    signal notificationReceived(var notif)

    readonly property var listModel: server.trackedNotifications
    readonly property var notifications: server.trackedNotifications.values
    property int unreadCount: 0

    function toggleDnd() {
        dndEnabled = !dndEnabled;
        return dndEnabled;
    }

    function dismiss(id) {
        var list = server.trackedNotifications.values;
        for (var i = 0; i < list.length; ++i) {
            var n = list[i];
            if (n && n.id === id) {
                n.dismiss();
                if (unreadCount > 0) unreadCount--;
                return true;
            }
        }
        return false;
    }

    function clearAll() {
        var list = server.trackedNotifications.values;
        for (var i = list.length - 1; i >= 0; --i) {
            if (list[i]) list[i].dismiss();
        }
        unreadCount = 0;
    }

    function markAllRead() {
        unreadCount = 0;
    }
}
