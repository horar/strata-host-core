import QtQuick 2.12

import tech.strata.sgwidgets 1.0

Rectangle {
    color: "#ddd"
    anchors {
        fill: parent
    }

    property alias error_message: error.text

    Column {
        anchors.centerIn: parent
        spacing: 15

        SGText {
            id: errorIntro
            fontSizeMultiplier: 2
            color: "#666"
            text: "Failed to load platform user interface:"
            font.bold: true
        }

        SGText {
            id: error
            fontSizeMultiplier: 1.5
            color: "#666"
        }
    }
}
