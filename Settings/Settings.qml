pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {

    property string shellName: "Noctalia"
    property string settingsDir: Quickshell.env("NOCTALIA_SETTINGS_DIR") || (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/" + shellName + "/"
    property string settingsFile: "../Settings.json"
    property string themeFile: "./Theme.json"
    property var settings: settingAdapter

    FileView {
        id: settingFileView
        path: settingsFile
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        Component.onCompleted: function () {
            reload();
        }
        onLoaded: function () {
            Qt.callLater(function () {
                WallpaperManager.setCurrentWallpaper(settings.currentWallpaper, true);
            });
        }
        onLoadFailed: function (error) {
            settingAdapter = {};
            writeAdapter();
        }
        JsonAdapter {
            id: settingAdapter
            property string weatherCity: "Dinslaken"
            property string profileImage: Quickshell.env("HOME") + "/.face"
            property bool useFahrenheit: false
            property string wallpaperFolder: Quickshell.env("HOME") + "/Wallpapers"
            property string currentWallpaper: ""
            property string videoPath: "~/Videos/"
            property bool showActiveWindowIcon: false
            property bool showSystemInfoInBar: false
            property bool showCorners: true
            property bool showTaskbar: true
            property bool showMediaInBar: false
            property bool randomWallpaper: false
            property bool useWallpaperTheme: false
            property int wallpaperInterval: 300
            property string wallpaperResize: "crop"
            property int transitionFps: 90
            property string transitionType: "random"
            property real transitionDuration: 1.1
            property string visualizerType: "radial"
            property bool reverseDayMonth: false
            property bool use12HourClock: false
            property bool dimPanels: true
            property real fontSizeMultiplier: 1.0  // Font size multiplier (1.0 = normal, 1.2 = 20% larger, 0.8 = 20% smaller)
            property int taskbarIconSize: 24  // Taskbar icon button size in pixels (default: 32, smaller: 24, larger: 40)
            property var pinnedExecs: [] // Added for AppLauncher pinned apps
        }
    }

    Connections {
        target: settingAdapter
        function onRandomWallpaperChanged() {
            WallpaperManager.toggleRandomWallpaper();
        }
        function onWallpaperIntervalChanged() {
            WallpaperManager.restartRandomWallpaperTimer();
        }
        function onWallpaperFolderChanged() {
            WallpaperManager.loadWallpapers();
        }
    }
}
