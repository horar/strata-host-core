import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
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
}
