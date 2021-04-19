import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

RowLayout {
    id: digitalReadout
    spacing: 10
    Layout.fillWidth: false
    Layout.alignment: Qt.AlignRight

    property alias text: title.text
    property alias unit: unit.text
    property alias value: value.text
    property real fontSizeMultiplier: 1.5

    SGText {
        id: title
        text: "DC Bus Voltage"
        font.bold: true
        fontSizeMultiplier: parent.fontSizeMultiplier
        horizontalAlignment: Text.AlignRight
    }

    RowLayout {

        Rectangle {
            id: container
            implicitHeight: 40
            implicitWidth: 110
            color: "#eee"

            SGText {
                id: value
                text: "0.00"
                renderType: Text.NativeRendering
                anchors {
                    rightMargin: 5
                    right: container.right
                    verticalCenter: container.verticalCenter
                    verticalCenterOffset: container.implicitHeight *.07
                    left: container.left
                    leftMargin: 5
                }
                horizontalAlignment: Text.AlignRight
                font.family: Fonts.digitalseven
                font.pixelSize: container.implicitHeight - 5
            }
        }

        SGText {
            id: unit
            text: "A"
            font.bold: true
            Layout.preferredWidth: 30
            fontSizeMultiplier: digitalReadout.fontSizeMultiplier
        }
    }
}


