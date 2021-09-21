/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtGraphicalEffects 1.12

/*
 * Primary purpose of this component is to change color of simple icons.
 * It is not recomended to use it as general replacement of Image component
 * due to much worse performance.
 */

Item {
    property alias iconColor: overlay.color

    property alias asynchronous: image.asynchronous
    property alias autoTransform: image.autoTransform
    property alias cache: image.cache
    property alias fillMode: image.fillMode
    property alias horizontalAlignment: image.horizontalAlignment
    property alias mipmap: image.mipmap
    property alias mirror: image.mirror
    property alias paintedHeight: image.paintedHeight
    property alias paintedWidth: image.paintedWidth
    property alias progress: image.progress
    property alias smooth: image.smooth
    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias status: image.status
    property alias verticalAlignment: image.verticalAlignment

    //internal properties
    property bool useOverlay: iconColor != Qt.rgba(0,0,0,0)

    Image {
        id: image
        width: parent.width
        height: parent.height

        visible: !useOverlay
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
    }

    ColorOverlay {
        id: overlay
        anchors.fill: image
        source: useOverlay ? image : undefined
        visible: useOverlay
    }
}
