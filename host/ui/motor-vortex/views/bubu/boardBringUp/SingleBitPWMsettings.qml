import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4


Rectangle{

    width: 1000; height: 60
    color: lightGreyColor
    property int bitNum: 0
    anchors.horizontalCenter: parent.horizontalCenter

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

        }

        Rectangle {
            id: dutyCyclleContainer
            width: 250
            height: 50
            anchors { left: frequency.right
            leftMargin: 170}
            color: "transparent"

            Slider {
                id: dutycycleSlider
                from: 0
                to: 100
                value: dutyCycleValue.text

            }
            TextField {
                id: dutyCycleValue
                width: 50
                text: Math.round(dutycycleSlider.value)
                anchors { right: parent.right;
                leftMargin: 20 }
            }
        }
    }
}
