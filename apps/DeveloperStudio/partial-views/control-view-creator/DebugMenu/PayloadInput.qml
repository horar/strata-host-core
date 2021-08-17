import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.signals 1.0

Item {
    width: parent.width
    height: row.height
    
    property alias name: labelText.text
    property string type: ""
    property alias value: textInput.text

    RowLayout {
        id: row
        anchors {
            left: parent.left
            right: parent.right
            margins: 10
        }

        SGText {
            id: labelText
            font.bold: true
            fontSizeMultiplier: 1.2
            Layout.preferredWidth: 100
        }

        Rectangle {
            id: textInputBorder
            Layout.fillWidth: true
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
    }

    IntValidator {
        id: intValid
    }

    DoubleValidator {
        id: doubleValid
        decimals: 2
    }
}
