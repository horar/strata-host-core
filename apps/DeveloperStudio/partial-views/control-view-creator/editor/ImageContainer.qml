/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    id: imageContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true

    Image {
        source: model.filepath.toString().includes("file:/") ? model.filepath : "file:/" + model.filepath

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
                source = "../ImageLoadError.svg"
                console.error("Error loading image in Image container")
            }
        }
    }
}
