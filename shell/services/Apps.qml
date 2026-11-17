pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    property bool isOpen: false
    property string searchQuery: ""

    // Raw desktop entries from Quickshell C++ engine
    readonly property var rawApps: DesktopEntries.applications.values || []

    // Sorted list of valid displayable applications
    readonly property var appsList: {
        var list = [];
        var raw = root.rawApps;
        for (var i = 0; i < raw.length; ++i) {
            var item = raw[i];
            if (!item || item.noDisplay || !item.name || item.name.trim() === "") continue;
            list.push(item);
        }
        list.sort(function(a, b) {
            return a.name.localeCompare(b.name, undefined, { sensitivity: "base" });
        });
        return list;
    }

    // Filtered applications based on searchQuery
    readonly property var filteredApps: {
        var q = root.searchQuery.trim().toLowerCase();
        var all = root.appsList;
        if (q.length === 0) return all;

        var exactMatches = [];
        var prefixMatches = [];
        var otherMatches = [];

        for (var i = 0; i < all.length; ++i) {
            var app = all[i];
            var name = app.name ? app.name.toLowerCase() : "";
            var generic = app.genericName ? app.genericName.toLowerCase() : "";
            var comment = app.comment ? app.comment.toLowerCase() : "";
            var id = app.id ? app.id.toLowerCase() : "";

            if (name === q) {
                exactMatches.push(app);
                continue;
            }
            if (name.startsWith(q)) {
                prefixMatches.push(app);
                continue;
            }

            var matched = false;
            if (name.indexOf(q) !== -1 || generic.indexOf(q) !== -1 || comment.indexOf(q) !== -1 || id.indexOf(q) !== -1) {
                matched = true;
            } else if (app.keywords && Array.isArray(app.keywords)) {
                for (var k = 0; k < app.keywords.length; ++k) {
                    if (app.keywords[k] && app.keywords[k].toLowerCase().indexOf(q) !== -1) {
                        matched = true;
                        break;
                    }
                }
            }

            if (matched) {
                otherMatches.push(app);
            }
        }

        return exactMatches.concat(prefixMatches).concat(otherMatches);
    }

    function toggle() {
        if (root.isOpen) {
            root.close();
        } else {
            root.open();
        }
    }

    function open() {
        root.searchQuery = "";
        root.isOpen = true;
    }

    function close() {
        root.isOpen = false;
        root.searchQuery = "";
    }

    function launch(entry) {
        if (!entry) return;
        if (typeof entry.execute === "function") {
            entry.execute();
        } else if (typeof entry === "string" && entry.trim().length > 0) {
            Quickshell.execDetached([entry]);
        }
        root.close();
    }
}
