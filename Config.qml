pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias data: jsonData
    property alias fgGenProc: generateFg
    property string wallFg: ""

    FileView {
        path: Paths.config + "config.json"
        watchChanges: true

        onAdapterUpdated: writeAdapter()
        onFileChanged: reload()

        JsonAdapter {
            id: jsonData

            property bool mousePsystem: false
            property bool reservedShell: false
            property bool setWallpaper: true
            property bool wallFgLayer: false
            property string wallSrc: Quickshell.env("HOME") + "/Wallpapers/"
        }
    }

    IpcHandler {
        function setWallpaper(path: string) {
            path = Qt.resolvedUrl(path);
            jsonData.wallSrc = path;
        }

        target: "config"
    }

    Process {
        id: generateFg

        property string script: Paths.urlToPath(Qt.resolvedUrl("../scripts/extractFg.sh"))

        command: ["bash", script, Paths.urlToPath(jsonData.wallSrc), Paths.urlToPath(Paths.cache)]

        stdout: SplitParser {
            onRead: data => {
                if (/\[.*\]/.test(data)) {
                    console.log(data);
                } else if (/FOREGROUND/.test(data)) {
                    root.wallFg = data.split(" ")[1];
                } else {
                    console.log("[EXT] " + data);
                }
            }
        }
    }

    Connections {
        function onWallFgLayerChanged() {
            onWallSrcChanged();
        }

        function onWallSrcChanged() {
            if (jsonData.wallSrc != "" && jsonData.wallFgLayer) {
                if (!generateFg.running) {
                    generateFg.running = true;
                }
            }
        }

        target: jsonData
    }
}
