import QtQuick
import Quickshell
import Quickshell.Wayland

WlrLayershell {
    id: layerRoot

    required property ShellScreen model

    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    anchors.top: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    implicitHeight: 28
    layer: WlrLayer.Background
    namespace: "zenful-wall"
    screen: model
    surfaceFormat.opaque: false

    Wallpaper {
        id: wallpaper

        anchors.fill: parent
        source: ""

        Component.onCompleted: {
            source = Config.data.wallSrc;

            Config.data.wallSrcChanged.connect(() => {
                if (walAnimation.running) {
                    walAnimation.complete();
                }
                animatingWal.source = Config.data.wallSrc;
            });
            animatingWal.statusChanged.connect(() => {
                if (animatingWal.status == Image.Ready) {
                    walAnimation.start();
                }
            });

            walAnimation.finished.connect(() => {
                wallpaper.source = animatingWal.source;
                animatingWal.source = "";
                animatinRect.width = 0;
            });
        }
    }

    Rectangle {
        id: animatinRect

        anchors.right: parent.right
        clip: true
        color: "transparent"
        height: layerRoot.screen.height
        width: 0

        NumberAnimation {
            id: walAnimation

            duration: 100
            easing.bezierCurve: Easing.InQuad
            from: 0
            property: "width"
            target: animatinRect
            to: Math.max(layerRoot.screen.width)
        }

        Wallpaper {
            id: animatingWal

            anchors.right: parent.right
            height: layerRoot.height
            source: ""
            width: layerRoot.width
        }
    }
}
