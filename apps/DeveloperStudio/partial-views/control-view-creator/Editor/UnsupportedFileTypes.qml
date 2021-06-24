import QtQuick 2.12
import tech.strata.sgwidgets 1.0

Rectangle {
    anchors.fill: containerLoader
    color: "#666"

    SGText {
        id: errorIntro

        anchors {
            centerIn: parent
        }

        color: "white"
        font.bold: true
        fontSizeMultiplier: 2
        text: "Unsupported file format"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
