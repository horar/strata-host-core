import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0

Rectangle {
    id: root

    width: parent.width
    color: Theme.palette.gray
    border {
        color: "black"
        width: 1
    }

    ColumnLayout {
        id: mainColumnLayout
    }
}
