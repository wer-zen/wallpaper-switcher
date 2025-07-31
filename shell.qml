import Quickshell
import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel

PanelWindow {
    color: "transparent"
    mask: Region {
        x: root.x
        y: root.y
        width: root.width
        height: root.height
    }
    anchors {
        left: true
        bottom: true
        right: true
        top: true
    }
    Rectangle {
        id: root
        width: 800
        height: 600
        color: "#1e1e1e"
        anchors.centerIn: parent

        property string wallpaperDirectory: Quickshell.env("HOME") + "/Wallpapers/"
        property string selectedWallpaper: ""
        property int thumbnailSize: 200

        signal wallpaperSelected(string path)

        FolderListModel {
            id: wallpaperModel
            folder: "file://" + root.wallpaperDirectory
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp", "*.tiff"]
            showDirs: false
            sortField: FolderListModel.Name
        }

        // Header
        Rectangle {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 60
            color: "#2d2d2d"

            Row {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wallpapers (" + wallpaperModel.count + ")"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }

                // Size slider
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Size:"
                        color: "#999"
                        font.pixelSize: 12
                    }

                    Slider {
                        id: sizeSlider
                        width: 100
                        height: 20
                        from: 120
                        to: 300
                        value: root.thumbnailSize
                        onValueChanged: root.thumbnailSize = value

                        background: Rectangle {
                            width: sizeSlider.width
                            height: 4
                            color: "#444"
                            radius: 2
                        }

                        handle: Rectangle {
                            x: sizeSlider.leftPadding + sizeSlider.visualPosition * (sizeSlider.availableWidth - width)
                            y: sizeSlider.topPadding + sizeSlider.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: "#4a9eff"
                        }
                    }
                }
            }
        }

        ScrollView {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10

            GridView {
                id: wallpaperGrid
                model: wallpaperModel
                cellWidth: root.thumbnailSize + 20
                cellHeight: root.thumbnailSize + 60

                delegate: Item {
                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    Rectangle {
                        id: wallpaperCard
                        anchors.fill: parent
                        anchors.margins: 10
                        color: "#2d2d2d"
                        radius: 12
                        border.color: root.selectedWallpaper === model.fileURL ? "#4a9eff" : "transparent"
                        border.width: 3

                        // Drop shadow effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 2
                            anchors.leftMargin: 2
                            color: "#00000040"
                            radius: parent.radius
                            z: -1
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            // Thumbnail
                            Rectangle {
                                width: parent.width
                                height: root.thumbnailSize - 40
                                color: "#1a1a1a"
                                radius: 8
                                clip: true

                                Image {
                                    id: thumbnail
                                    anchors.fill: parent
                                    source: model.fileURL
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true

                                    // Loading/Error states
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 60
                                        height: 60
                                        color: thumbnail.status === Image.Error ? "#5d3d3d" : "#3d3d3d"
                                        radius: 30
                                        visible: thumbnail.status !== Image.Ready

                                        Text {
                                            anchors.centerIn: parent
                                            text: thumbnail.status === Image.Error ? "✗" : "⟳"
                                            color: thumbnail.status === Image.Error ? "#ff6b6b" : "#4a9eff"
                                            font.pixelSize: 24

                                            RotationAnimation on rotation {
                                                running: thumbnail.status === Image.Loading
                                                loops: Animation.Infinite
                                                from: 0
                                                to: 360
                                                duration: 1500
                                            }
                                        }
                                    }

                                    // Overlay gradient for text readability
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: 30
                                        gradient: Gradient {
                                            GradientStop {
                                                position: 0
                                                color: "transparent"
                                            }
                                            GradientStop {
                                                position: 1
                                                color: "#80000000"
                                            }
                                        }
                                    }
                                }
                            }

                            // File name
                            Text {
                                width: parent.width
                                text: model.fileName
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                            }

                            // File size
                            Text {
                                width: parent.width
                                text: (model.fileSize / 1024 / 1024).toFixed(1) + " MB"
                                color: "#999999"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                wallpaperCard.color = "#3d3d3d";
                                wallpaperCard.scale = 1.05;
                            }
                            onExited: {
                                wallpaperCard.color = "#2d2d2d";
                                wallpaperCard.scale = 1.0;
                            }
                            onClicked: {
                                root.selectedWallpaper = model.fileURL;
                                root.wallpaperSelected(model.fileURL);
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
