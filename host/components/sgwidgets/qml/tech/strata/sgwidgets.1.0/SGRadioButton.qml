import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


RadioButton {
    id: radioButton
    implicitWidth: indicator.width
    implicitHeight: indicator.height
    objectName: "RadioButton"

    property Item buttonContainer: null
    property real radioSize: buttonContainer ? buttonContainer.radioSize : 20 * root.fontSizeMultiplier
    property color radioColor: buttonContainer ? buttonContainer.radioColor : "black"
    property int index

    onCheckedChanged: {
        if (checked && buttonContainer) {
            buttonContainer.currentIndex = index
        }
    }

    indicator: SGAlignedLabel {
        id: root
        target: outerRadio
        text: radioButton.text
        color: buttonContainer ? buttonContainer.textColor : "black"
        alignment: buttonContainer ? buttonContainer.alignment : SGAlignedLabel.SideRightCenter
        fontSizeMultiplier: buttonContainer ? buttonContainer.fontSizeMultiplier : 1
        opacity: enabled ? 1.0 : 0.3
        clickableLabel : false  // Default: false (True: disables the label to be clicked.)

        Rectangle {
            id: outerRadio
            implicitWidth: radioButton.radioSize
            implicitHeight: implicitWidth
            radius: width/2
            color: "transparent"
            border.width: 1
            border.color: radioButton.radioColor

            Rectangle {
                id: innerRadio
                implicitWidth: outerRadio.width * 0.6
                implicitHeight: implicitWidth
                anchors {
                    horizontalCenter: outerRadio.horizontalCenter
                    verticalCenter: outerRadio.verticalCenter
                }
                radius: width / 2
                opacity: enabled ? 1.0 : 0.3
                color: radioButton.radioColor
                visible: radioButton.checked
            }
        }
    }
}


