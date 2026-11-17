pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var players: Mpris.players.values

    readonly property var activePlayer: {
        var list = Mpris.players.values;
        if (!list || list.length === 0) return null;
        for (var i = 0; i < list.length; ++i) {
            if (list[i] && list[i].isPlaying) return list[i];
        }
        return list[0];
    }

    readonly property bool hasPlayer: activePlayer !== null
    readonly property string title: activePlayer ? (activePlayer.trackTitle || "Unknown Track") : ""
    readonly property string artist: activePlayer ? (activePlayer.trackArtist || "Unknown Artist") : ""
    readonly property string album: activePlayer ? (activePlayer.trackAlbum || "") : ""
    readonly property string artUrl: activePlayer ? (activePlayer.trackArtUrl || "") : ""
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false
    readonly property real position: activePlayer ? activePlayer.position : 0.0
    readonly property real length: activePlayer ? activePlayer.length : 0.0

    function playPause() {
        if (activePlayer) {
            activePlayer.togglePlaying();
        }
    }

    function play() {
        if (activePlayer && typeof activePlayer.play === "function") {
            activePlayer.play();
        }
    }

    function pause() {
        if (activePlayer && typeof activePlayer.pause === "function") {
            activePlayer.pause();
        }
    }

    function next() {
        if (activePlayer && activePlayer.canGoNext) {
            activePlayer.next();
        }
    }

    function previous() {
        if (activePlayer && activePlayer.canGoPrevious) {
            activePlayer.previous();
        }
    }

    function seek(offset) {
        if (activePlayer && activePlayer.canSeek) {
            activePlayer.seek(offset);
        }
    }
}
