import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "qrc:/views/bubu/Control.js" as BubuControl


Rectangle{

    width: 1000; height: 60
    color: lightGreyColor
    property int bitNum: 0 //Gets overloaded by delegate
    anchors.horizontalCenter: parent.horizontalCenter
    property bool portsDisabled: true

    function prepareCommand()
    {
        BubuControl.setPwmBit(bitNum);
        BubuControl.setPwmFrequency(parseInt(frequency.text));
        BubuControl.setDutyCycle(Math.round(dutycycleSlider.value));
        BubuControl.printPwmCommand();
        coreInterface.sendCommand(BubuControl.getPwmCommand());
    }

    RowLayout {
        id:rowContainer
        width: 800
        height: 50
        spacing: 6
        enabled: portsDisabled

        Label {
            id: bitNumber
            width: 95
            height: 25
            Text {
                width: 94
                height: 24
                text: bitNum
                horizontalAlignment: Text.AlignHCenter
            }
        }

        TextField {
            id: frequency
            text: "10"
            anchors { left: bitNumber.right
                leftMargin: 180 }
            onEditingFinished: {
                prepareCommand();
            }
        }

        Rectangle {
            id: dutyCycleContainer
            width: 250
            height: 50
            anchors { left: frequency.right
                leftMargin: 170}
            color: "transparent"

            Slider {
                id: dutycycleSlider
                from: 0
                to: 100
                value: 0
                onPressedChanged: {
                    if(!pressed) {
                        prepareCommand();

                    }
                }
            }
            TextField {
                id: dutyCycleValue
                width: 50
                text: Math.round(dutycycleSlider.value);
                validator:  IntValidator { bottom : 0;top: 100 }
                anchors { right: parent.right;
                    leftMargin: 40 }

                onEditingFinished: {
                    dutycycleSlider.value = Math.round(dutyCycleValue.text)
                    prepareCommand();

                }
            }
        }
    }
}
