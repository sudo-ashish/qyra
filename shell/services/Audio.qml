pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

QtObject {
    id: root

    property PwObjectTracker tracker: PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property real volume: (sink && sink.audio) ? sink.audio.volume : 0.0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    readonly property real micVolume: (source && source.audio) ? source.audio.volume : 0.0
    readonly property bool micMuted: (source && source.audio) ? source.audio.muted : false

    readonly property var streams: {
        var result = [];
        var nodes = Pipewire.nodes.values;
        for (var i = 0; i < nodes.length; ++i) {
            var n = nodes[i];
            if (n && n.audio && (n.type & PwNodeType.Stream)) {
                result.push(n);
            }
        }
        return result;
    }

    function setVolume(val) {
        if (!sink || !sink.audio) return;
        var clamped = Math.max(0.0, Math.min(1.5, val));
        sink.audio.volume = clamped;
        if (sink.audio.muted && clamped > 0.0) {
            sink.audio.muted = false;
        }
    }

    function adjustVolume(delta) {
        if (!sink || !sink.audio) return;
        var nextVol = volume + delta;
        setVolume(nextVol);
    }

    function toggleMute() {
        if (!sink || !sink.audio) return;
        sink.audio.muted = !sink.audio.muted;
    }

    function setMicVolume(val) {
        if (!source || !source.audio) return;
        var clamped = Math.max(0.0, Math.min(1.5, val));
        source.audio.volume = clamped;
        if (source.audio.muted && clamped > 0.0) {
            source.audio.muted = false;
        }
    }

    function adjustMicVolume(delta) {
        if (!source || !source.audio) return;
        setMicVolume(micVolume + delta);
    }

    function toggleMicMute() {
        if (!source || !source.audio) return;
        source.audio.muted = !source.audio.muted;
    }
}
