import QtQuick 2.12

import "../../"

LayoutContainer {

    // pass through all properties
    property alias text: textObject.text
    property alias color: textObject.color
    property alias font: textObject.font
    property alias elide: textObject.elide
    property alias fontSizeMode: textObject.fontSizeMode
    property alias wrapMode: textObject.wrapMode
    property alias horizontalAlignment: textObject.horizontalAlignment
    property alias verticalAlignment: textObject.verticalAlignment
    property alias maximumLineCount: textObject.maximumLineCount
    property alias minimumPixelSize: textObject.minimumPixelSize

    contentItem: Text {
        id: textObject
        elide: Text.ElideRight
        wrapMode: Text.Wrap
    }
}

