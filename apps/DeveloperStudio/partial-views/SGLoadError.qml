import QtQuick 2.12
import QtQuick.Layouts 1.3

import tech.strata.sgwidgets 1.0

Rectangle {
    id: loadError
    anchors {
        fill: parent
    }
    color: "#ddd"

    property alias error_intro: errorIntro.text
    property alias error_message: error.text

    ColumnLayout {   
        anchors {
            fill: loadError
            margins: 20
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: false
            Layout.fillWidth: false
            Layout.maximumHeight: parent.height
            Layout.maximumWidth: parent.width
            spacing: 15

            SGText {
                id: errorIntro
                color: "#666"
                font.bold: true
                fontSizeMultiplier: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Failed to load platform user interface: "
            }

            SGText {
                id: error
                color: "#666"
                elide: Text.ElideRight
                fontSizeMultiplier: 1.5
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.Wrap
            }
        }
    }
}
