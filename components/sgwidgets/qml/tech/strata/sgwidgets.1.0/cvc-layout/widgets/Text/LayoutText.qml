import QtQuick 2.12

import "../../"

LayoutContainer {

    // pass through all properties
    property alias text: textObject.text
    property alias color: textObject.color
    property alias font: textObject.font
    property alias elide: textObject.elide
    property alias fontSizeMode: textObject.fontSizeMode
    property alias horizontalAlignment: textObject.horizontalAlignment
    property alias verticalAlignment: textObject.verticalAlignment
    property alias maximumLineCount: textObject.maximumLineCount

    Text {
        id: textObject
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
    }
}

