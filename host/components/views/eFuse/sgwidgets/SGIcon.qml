import QtQuick 2.12
import QtGraphicalEffects 1.12

/*
 * Primary purpose of this component is to change color of simple icons.
 * It is not recomended to use it as general replacement of Image component
 * due to much worse performance.
 */

Item {
    width: image.width
    height: image.height

    property alias iconColor: overlay.color
    property int iconWidth: image.width
    property int iconHeight: image.height

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
        visible: !useOverlay
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        id: overlay
        anchors.fill: image
        source: useOverlay ? image : undefined
        visible: useOverlay
    }
}
