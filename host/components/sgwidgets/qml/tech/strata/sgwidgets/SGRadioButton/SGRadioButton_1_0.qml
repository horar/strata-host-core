import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0

SGAlignedLabel {
    id: root
    target: radioButton
    color: buttonContainer ? buttonContainer.textColor : "black"
    objectName: "RadioButton"
    alignment: buttonContainer ? buttonContainer.alignment : SGAlignedLabel.SideRightCenter
    fontSizeMultiplier: buttonContainer ? buttonContainer.fontSizeMultiplier : 1
    opacity: enabled ? 1.0 : 0.3

    property Item buttonContainer: null
    property real radioSize: buttonContainer ? buttonContainer.radioSize : 20 * fontSizeMultiplier
    property color radioColor: buttonContainer ? buttonContainer.radioColor : "black"
    property int index

    property alias checked: radioButton.checked
    property alias button: radioButton
    property alias pressed: radioButton.pressed

    signal clicked()
    signal toggled()
    signal released()

    onCheckedChanged: {
        if (checked && buttonContainer) {
            buttonContainer.currentIndex = index
        }
    }

    RadioButton {
        id: radioButton

        implicitWidth: indicator.width
        implicitHeight: indicator.height

        onClicked: root.clicked()
        onToggled: root.toggled()
        onReleased: root.released()

        indicator: Rectangle {
            id: outerRadio
            implicitWidth: root.radioSize
            implicitHeight: implicitWidth
            radius: width/2
            color: "transparent"
            border.width: 1
            border.color: root.radioColor

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
                color: root.radioColor
                visible: radioButton.checked
            }
        }
    }
}

