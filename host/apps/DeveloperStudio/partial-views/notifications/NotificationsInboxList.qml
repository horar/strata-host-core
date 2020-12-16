import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

ColumnLayout {
    spacing: 0

    property string level
    property ListModel dataModel

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 25
        color: Theme.palette.darkGray
        Text {
            anchors.fill: parent
            text: level
            textFormat: level.toUpperCase()
        }
    }

    ListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        model: dataModel
        delegate: Text {
            text: model.title
        }
    }
}
