import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias color: rect.color

    Rectangle {
        id: rect
    }
}

