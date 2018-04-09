import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "qrc:/views/bubu/Control.js" as BubuControl


Row {
    property int bitNum: 0
    width: 1000; height: 60

    /*
      Depending on the state of the _inputOutput_ switch, set the visibility of
      _highLow_ switch. On input state (switch is false), don't show the _highLow_
      switch otherwise show the _highLow_
    */
    function checkingState()
    {
        if(inputOutput.stateOfTheSwitch === false){
            highLow.visible = false;
        }
        else {
            highLow.visible = true;
        }
    }

    Rectangle{

        width: 1000; height: 70
        color: lightGreyColor
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id: bitNumber
            text: bitNum
            width: 58
            height: 25
            anchors { left: parent.left
                leftMargin: 50
                top: parent.top
                topMargin: 10
            }
        }

        GPIOSetting {
            id: inputOutput
            anchors { left : bitNumber.right
                leftMargin: 50
            }
            bitNumber: bitNum
            switchAngle: 90
            settingMessageOne: "Input"
            settingMessageTwo: "Output"
            initialState: true
            onActivated: checkingState();

        }

        GPIOSetting {
            id: highLow
            anchors { left : inputOutput.right
                leftMargin: 300
            }
            bitNumber: bitNum
            switchAngle: 90
            settingMessageOne: "Low"
            settingMessageTwo: "High"
            initialState: true
            visible: false

        }

        TextField {
            id: currentState
            width: 58
            height: 25
            anchors { left : highLow.right
                leftMargin: 300
                top: parent.top
                topMargin: 10
            }
            placeholderText: qsTr("1")

        }

        Button {
            id: readButton
            text: "Read"
            font.family:"helvetica"
            font.pointSize: smallFontSize
            font.bold: true
            anchors { left : currentState.right
                leftMargin: 40
                top: parent.top
                topMargin: 10
            }
        }
    }
}


