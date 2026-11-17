pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

QtObject {
    id: root

    readonly property string installedDir: (Quickshell.env("XDG_DATA_HOME") || (Quickshell.env("HOME") + "/.local/share")) + "/qyra"
    readonly property string systemDir: "/usr/share/qyra"
    readonly property string repoDir: (Quickshell.env("PWD") || ".")
    property string activeDir: repoDir
    readonly property bool isSystem: activeDir.startsWith("/usr/")

    property string currentVersion: "0.1.0"
    property string remoteVersion: "0.1.0"
    property bool hasUpdate: false
    // status: "idle" | "checking" | "available" | "up-to-date" | "updating" | "error"
    property string status: "idle"
    property string statusMessage: "Up to date"
    property string changelog: ""
    property string errorMessage: ""

    property FileView installedVersionFile: FileView {
        path: root.installedDir + "/VERSION"
        blockLoading: true
        blockAllReads: true
        printErrors: false
        onLoaded: root.loadVersion()
    }

    property FileView systemVersionFile: FileView {
        path: root.systemDir + "/VERSION"
        blockLoading: true
        blockAllReads: true
        printErrors: false
        onLoaded: root.loadVersion()
    }

    property FileView repoVersionFile: FileView {
        path: root.repoDir + "/VERSION"
        blockLoading: true
        blockAllReads: true
        printErrors: false
        onLoaded: root.loadVersion()
    }

    function loadVersion() {
        var txt = installedVersionFile.text();
        if (txt && txt.trim().length > 0) {
            root.currentVersion = txt.trim();
            root.activeDir = root.installedDir;
            return;
        }
        var stxt = systemVersionFile.text();
        if (stxt && stxt.trim().length > 0) {
            root.currentVersion = stxt.trim();
            root.activeDir = root.systemDir;
            return;
        }
        var rtxt = repoVersionFile.text();
        if (rtxt && rtxt.trim().length > 0) {
            root.currentVersion = rtxt.trim();
            root.activeDir = root.repoDir;
        }
    }

    property Process checkProcess: Process {
        id: checkProcess
        workingDirectory: root.activeDir
        command: [
            "sh", "-c",
            "if [ \"" + (root.isSystem ? "1" : "0") + "\" = \"1\" ]; then " +
            "  if command -v yay >/dev/null && yay -Qua 2>/dev/null | grep -q qyra; then " +
            "    echo 'SYSTEM_AUR_UPDATE'; " +
            "  else echo 'UP_TO_DATE'; fi; " +
            "elif git remote -v 2>/dev/null | grep -q origin; then " +
            "  git fetch origin 2>&1 >/dev/null && " +
            "  BEHIND=$(git rev-list HEAD..@{u} --count 2>/dev/null || echo 0); " +
            "  if [ \"$BEHIND\" -gt 0 ]; then " +
            "    echo \"COMMITS_BEHIND:$BEHIND\"; " +
            "    git log HEAD..@{u} --oneline -n 10 2>/dev/null; " +
            "  else echo \"UP_TO_DATE\"; fi; " +
            "else echo \"LOCAL_DEV\"; fi"
        ]

        property string rawOutput: ""

        stdout: SplitParser {
            onRead: function(data) {
                checkProcess.rawOutput += data + "\n";
            }
        }

        onExited: function(code, exitStatus) {
            var output = checkProcess.rawOutput.trim();
            checkProcess.rawOutput = "";

            if (code !== 0) {
                root.status = "error";
                root.statusMessage = "Failed to check for updates";
                root.errorMessage = output;
                return;
            }

            if (output.indexOf("COMMITS_BEHIND:") !== -1) {
                var lines = output.split("\n");
                var count = lines[0].replace("COMMITS_BEHIND:", "");
                root.hasUpdate = true;
                root.status = "available";
                root.statusMessage = count + " update(s) available";
                root.remoteVersion = "v" + root.currentVersion + " (" + count + " new commits)";
                root.changelog = lines.slice(1).join("\n");
            } else if (output.indexOf("SYSTEM_AUR_UPDATE") !== -1) {
                root.hasUpdate = true;
                root.status = "available";
                root.statusMessage = "System package update available";
                root.remoteVersion = "AUR Package Upgrade";
                root.changelog = "A newer version of the Qyra package is available in the repository.";
            } else if (output.indexOf("LOCAL_DEV") !== -1) {
                root.hasUpdate = false;
                root.status = "up-to-date";
                root.statusMessage = "Local development build (no remote tracked)";
                root.remoteVersion = root.currentVersion;
                root.changelog = "Running active working tree in development mode.";
            } else {
                root.hasUpdate = false;
                root.status = "up-to-date";
                root.statusMessage = "Qyra is up to date";
                root.remoteVersion = root.currentVersion;
                root.changelog = "You have the latest version installed.";
            }
        }
    }

    property Process updateProcess: Process {
        id: updateProcess
        workingDirectory: root.activeDir
        command: ["git", "pull", "--ff-only"]

        property string rawOutput: ""

        stdout: SplitParser {
            onRead: function(data) { updateProcess.rawOutput += data + "\n"; }
        }
        stderr: SplitParser {
            onRead: function(data) { updateProcess.rawOutput += data + "\n"; }
        }

        onExited: function(code, exitStatus) {
            var output = updateProcess.rawOutput.trim();
            updateProcess.rawOutput = "";

            if (code === 0) {
                root.status = "up-to-date";
                root.statusMessage = "Update completed successfully!";
                root.hasUpdate = false;
                Quickshell.execDetached(["notify-send", "Qyra Update", "Update installed successfully. Reloading shell..."]);
                Quickshell.reload(false);
            } else {
                root.status = "error";
                root.statusMessage = "Update failed (fast-forward error)";
                root.errorMessage = output;
                Quickshell.execDetached(["notify-send", "-u", "critical", "Qyra Update", "Update failed: " + output]);
            }
        }
    }

    function checkUpdate() {
        if (root.status === "checking" || root.status === "updating") return;
        root.status = "checking";
        root.statusMessage = "Checking for updates...";
        root.errorMessage = "";
        checkProcess.rawOutput = "";
        checkProcess.running = true;
    }

    function installUpdate() {
        if (root.status === "updating") return;
        root.status = "updating";
        root.statusMessage = "Creating snapshot & installing update...";
        root.errorMessage = "";

        Snapshot.createSnapshot("pre-update-v" + root.currentVersion);

        if (root.isSystem) {
            Quickshell.execDetached(["sh", "-c",
                "notify-send 'Qyra Update' 'Launching terminal for system package upgrade...'; " +
                "kitty --title 'Qyra Package Upgrade' sh -c 'if command -v yay >/dev/null; then yay -S qyra; elif command -v paru >/dev/null; then paru -S qyra; else sudo pacman -S qyra; fi; echo; read -p \"Press Enter to reload Qyra...\" dummy; qyractl config toggle bar.visible && qyractl config toggle bar.visible' 2>/dev/null || true"
            ]);
            root.status = "up-to-date";
            root.statusMessage = "Package upgrade launched in terminal";
            root.hasUpdate = false;
            return;
        }

        updateProcess.rawOutput = "";
        updateProcess.running = true;
    }

    Component.onCompleted: {
        loadVersion();
        if (Config.updates && Config.updates.autoCheck) {
            checkUpdate();
        }
    }
}
