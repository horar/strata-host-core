import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.signals 1.0

Item {
    width: parent.width
    height: row.height

    property bool initialized: false
    property string type: ""

    property alias name: labelText.text
    property alias value: textInput.text

    RowLayout {
        id: row
        width: parent.width
        spacing: 10

        SGText {
            id: labelText
            font.bold: true
            fontSizeMultiplier: 1.2
            Layout.fillWidth: true
            elide: Text.ElideRight
            Layout.leftMargin: 10
        }

        SGText {
            id: typeText
            fontSizeMultiplier: 1.1
            Layout.minimumWidth: 50
            text: type
        }

        Rectangle {
            id: textInputBorder
            Layout.minimumWidth: 150
            Layout.maximumWidth: root.width
            Layout.preferredHeight: 35
            border.color: Theme.palette.lightGray
            border.width: 1
            radius: 5

            SGTextInput {
                id: textInput
                anchors.fill: textInputBorder
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: 5
                fontSizeMultiplier: 1.2
                clip: true
                focus: true
                selectByMouse: true
                validator: switch(type) {
                    case "int": return intValid
                    case "double": return doubleValid
                }
            }
        }

        Item {
            Layout.preferredWidth: 10
        }
    }

    IntValidator {
        id: intValid
    }

    DoubleValidator {
        id: doubleValid
    }
}
