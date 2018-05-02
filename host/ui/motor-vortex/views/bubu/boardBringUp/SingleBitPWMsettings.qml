import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "qrc:/views/bubu/Control.js" as BubuControl


Rectangle{

    width: 1000; height: 60
    color: lightGreyColor
    property int bitNum: 0
    anchors.horizontalCenter: parent.horizontalCenter

    //    function checkValueState (value) {

    //        if(value === "") {
    //            return;
    //        }
    //        else {
    //            dutycycleSlider.value = value;
    //        }
    //    }

    RowLayout {
        width: 800
        height: 50
        spacing: 6

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
            placeholderText: qsTr("10 Hz")
            anchors { left: bitNumber.right
                leftMargin: 180 }
            onEditingFinished: {
                BubuControl.setPwmBit(bitNum);
                BubuControl.setPwmFrequency(text);
                BubuControl.printPwmCommand();
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
                        BubuControl.setPwmBit(bitNum);
                        BubuControl.setDutyCycle(value);
                        BubuControl.printPwmCommand();
                    }
                }
                onValueChanged: dutyCycleValue.text = Math.round(dutycycleSlider.value)

            }
            TextField {
                id: dutyCycleValue
                width: 60
                text: Math.round(dutycycleSlider.value);
                validator:  IntValidator { bottom : 0
                    top: 100
                }
                anchors { right: parent.right;
                    leftMargin: 40 }

                onEditingFinished: {
                    BubuControl.setPwmBit(bitNum);
                    BubuControl.setDutyCycle(this.text);
                    BubuControl.printPwmCommand();
                }
            }
        }
    }
}
