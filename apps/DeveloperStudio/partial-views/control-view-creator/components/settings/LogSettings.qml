import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "../"

ColumnLayout {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    SGText {
        text: "Console Log Settings"
        fontSizeMultiplier: 1.3
    }

    Rectangle {
        Layout.preferredHeight: 1
        Layout.fillWidth: true
        color: "#666"
    }
}
