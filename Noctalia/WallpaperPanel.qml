import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Settings
import qs.Services

PanelWindow {
    id: wallpaperPanelModal

    visible: true
    color: "transparent"
    anchors.top: true
    anchors.right: true
    anchors.left: true
    anchors.bottom: true
    margins.right: 0
    margins.top: 0

    mask: Region {
        width: recty.width
        height: recty.height
        x: recty.x
        y: recty.y
    }

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property var wallpapers: []

    Connections {
        target: WallpaperManager
        function onWallpaperListChanged() {
            wallpapers = WallpaperManager.wallpaperList;
        }
    }

    onVisibleChanged: {
        if (wallpaperPanelModal.visible) {
            wallpapers = WallpaperManager.wallpaperList;
        } else {
            wallpapers = [];
        }
    }

    Rectangle {
        id: recty
        Keys.onEscapePressed: {
            wallpaperPanelModal.visible = false;
            Qt.quit();
        }
        focus: true
        anchors.centerIn: parent
        implicitWidth: parent.width / 2
        implicitHeight: 780
        color: Theme.backgroundPrimary
        radius: 24
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 0
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                Layout.preferredHeight: 48
                Text {
                    text: "image"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: Theme.fontSizeHeader
                    color: Theme.accentPrimary
                }
                Text {
                    text: "Wallpapers"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeHeader
                    font.bold: true
                    color: Theme.textPrimary
                    Layout.fillWidth: true
                }
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: closeButtonArea.containsMouse ? Theme.accentPrimary : "transparent"
                    border.color: Theme.accentPrimary
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "close"
                        font.family: closeButtonArea.containsMouse ? "Material Symbols Rounded" : "Material Symbols Outlined"
                        font.pixelSize: Theme.fontSizeBody
                        color: closeButtonArea.containsMouse ? Theme.onAccent : Theme.accentPrimary
                    }
                    MouseArea {
                        id: closeButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: wallpaperPanelModal.visible = false
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.outline
                opacity: 0.12
            }
            // Wallpaper grid area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                anchors.topMargin: 16
                anchors.bottomMargin: 16
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.margins: 0
                clip: true
                ScrollView {
                    id: scrollView
                    anchors.fill: parent
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    GridView {
                        id: wallpaperGrid

                        anchors.fill: parent
                        cellWidth: Math.max(120, (scrollView.width / 3) - 12)
                        cellHeight: cellWidth * 0.6
                        model: wallpapers
                        cacheBuffer: 32
                        leftMargin: 8
                        rightMargin: 8
                        topMargin: 8
                        bottomMargin: 8
                        delegate: Item {
                            width: wallpaperGrid.cellWidth - 8
                            height: wallpaperGrid.cellHeight - 8
                            ClippingRectangle {
                                id: wallpaperItem
                                anchors.fill: parent
                                anchors.margins: 4
                                color: Qt.darker(Theme.backgroundPrimary, 1.1)
                                radius: 12
                                border.color: Settings.settings.currentWallpaper === modelData ? Theme.accentPrimary : Theme.outline
                                border.width: Settings.settings.currentWallpaper === modelData ? 3 : 1
                                Image {
                                    id: wallpaperImage
                                    anchors.fill: parent
                                    source: modelData
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    sourceSize.width: Math.min(width, 150)
                                    sourceSize.height: Math.min(height, 90)
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        WallpaperManager.changeWallpaper(modelData);
                                    }
                                    onEntered: wallpaperItem.border.color = Theme.accentPrimary
                                    onExited: wallpaperItem.border.color = Theme.outline
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
