import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    id: imageContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true

    property int modelIndex: index
    property string file: model.filename

    Image {
        id: imageView

        source: model.filepath
        anchors.fill: parent
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        asynchronous: true
        cache: true
        /**
         * Fillmode is set as follows:
         * If the image is larger than the parent container in either width or height, then resize it to fit, while keeping aspect ratio.
         * Otherwise, keep the original size
         */
        fillMode: sourceSize.width > parent.width || sourceSize.height > parent.height ? Image.PreserveAspectFit : Image.Pad

        onStatusChanged: {
            if (status === Image.Error) {
                imageView.source = "../ImageLoadError.svg"
                console.error("Error loading image in Image container")
            }
        }
    }
}
