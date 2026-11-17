pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import "../config"

QtObject {
    id: root

    readonly property string snapshotsDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/qyra/snapshots"
    readonly property string lastGoodPath: snapshotsDir + "/last-good.json"
    readonly property string statePath: Config.statePath

    property FileView lastGoodWriter: FileView {
        id: lastGoodWriter
        path: root.lastGoodPath
        printErrors: false
    }

    property FileView lastGoodReader: FileView {
        id: lastGoodReader
        path: root.lastGoodPath
        blockLoading: true
        blockAllReads: true
        printErrors: false
    }

    property FileView snapshotWriter: FileView {
        id: snapshotWriter
        atomicWrites: true
        printErrors: false
    }

    property FileView snapshotReader: FileView {
        id: snapshotReader
        blockLoading: true
        blockAllReads: true
        printErrors: false
    }

    property FolderListModel folderModel: FolderListModel {
        id: folderModel
        folder: "file://" + root.snapshotsDir
        nameFilters: ["*.json"]
        showDirs: false
        sortField: FolderListModel.Time
        sortReversed: false
    }

    readonly property alias count: folderModel.count

    function backupLastGood() {
        var data = Config.serialize();
        lastGoodWriter.setText(JSON.stringify(data, null, 2));
    }

    function createSnapshot(label) {
        var cleanLabel = (label && label.length > 0) ? label.replace(/[^a-zA-Z0-9_-]/g, "_") : "manual";
        var timestamp = Qt.formatDateTime(new Date(), "yyyyMMdd-hhmmss");
        var filename = timestamp + "-" + cleanLabel + ".json";
        var targetPath = root.snapshotsDir + "/" + filename;

        snapshotWriter.path = targetPath;
        snapshotWriter.setText(JSON.stringify(Config.serialize(), null, 2));
        return filename;
    }

    function restoreSnapshot(filename) {
        var sourcePath = (filename.indexOf("/") !== -1) ? filename : (root.snapshotsDir + "/" + filename);
        snapshotReader.path = sourcePath;
        var content = snapshotReader.text();
        if (!content || content.trim().length === 0) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "Qyra Snapshot", "Cannot restore: snapshot is empty or missing."]);
            return false;
        }

        try {
            var parsed = JSON.parse(content);
            Config.stateFile.setText(JSON.stringify(parsed, null, 2));
            Config.stateFile.reload();
            Quickshell.execDetached(["notify-send", "Qyra Snapshot", "Restored snapshot: " + filename]);
            return true;
        } catch (e) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "Qyra Snapshot", "Corrupted snapshot file: " + e.message]);
            return false;
        }
    }

    function rollbackLastGood() {
        var content = lastGoodReader.text();
        if (!content || content.trim().length === 0) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "Qyra Recovery", "state.json corrupted and no last-good.json available!"]);
            return false;
        }

        try {
            var parsed = JSON.parse(content);
            Config.stateFile.setText(JSON.stringify(parsed, null, 2));
            Config.stateFile.reload();
            Quickshell.execDetached(["notify-send", "-u", "critical", "Qyra Recovery", "state.json was corrupted. Automatically rolled back to last-good.json."]);
            return true;
        } catch (e) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "Qyra Recovery", "last-good.json is also unreadable: " + e.message]);
            return false;
        }
    }

    function deleteSnapshot(filename) {
        var targetPath = (filename.indexOf("/") !== -1) ? filename : (root.snapshotsDir + "/" + filename);
        Quickshell.execDetached(["rm", "-f", targetPath]);
    }

    function listSnapshots() {
        var list = [];
        for (var i = 0; i < folderModel.count; ++i) {
            var name = folderModel.get(i, "fileName");
            if (name === "last-good.json") continue;
            list.push({
                name: name,
                path: folderModel.get(i, "filePath"),
                modified: folderModel.get(i, "fileModified")
            });
        }
        return list;
    }

    property Connections configConnections: Connections {
        target: Config
        function onLoaded() {
            root.backupLastGood();
        }
        function onLoadFailed(error) {
            root.rollbackLastGood();
        }
    }

    Component.onCompleted: {
        // Create initial last-good snapshot on first boot if it does not yet exist
        backupLastGood();
    }
}
