import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias color: rect.color
    property alias border: rect.border
    property alias radius: rect.radius
    property alias gradient: rect.gradient

    contentItem: Rectangle {
        id: rect
    }
}

