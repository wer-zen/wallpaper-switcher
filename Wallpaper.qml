import QtQuick

Image {
    antialiasing: true
    asynchronous: true
    fillMode: Image.PreserveAspectCrop
    layer.enabled: true
    retainWhileLoading: true
    smooth: true
    source: Config.data.wallSrc

    onStatusChanged: {
        if (this.status == Image.Error) {
            console.log("[ERROR] Wallpaper source invalid");
            console.log("[INFO] Please disable set wallpaper if not required");
        }
    }
}
