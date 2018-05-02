import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import "qrc:/views/bubu/Control.js" as BubuControl


Rectangle {
    id: settingRow
    property string settingMessageOne: ""
    property string settingMessageTwo: ""
    property bool initialState: false
    property int switchAngle: 90
    property int bitNumber: 0
    property string settingSwitchType:  ""
    color: "transparent"
    /*
    Holds the state of the switch.
    */
    property bool stateOfTheSwitch: initialState

    /*
    Check switch state and _setDirection_ accordingly.
    */
    function checkSwitchState()
    {
        if(settingSwitchType == "input_output") {
            if(switchComponent.checked === true) {
                stateOfTheSwitch = true;
                BubuControl.setDirection("input");
                coreInterface.sendCommand(BubuControl.getDirectionCommand());
            }
            else {
                stateOfTheSwitch = false;
                BubuControl.setDirection("output");
                coreInterface.sendCommand(BubuControl.getDirectionCommand());
            }
        }
        else  {
            if(switchComponent.checked === true) {
                BubuControl.setOutputValue("low");
                coreInterface.sendCommand(BubuControl.getOutputCommand());
            }
            else {
                BubuControl.setOutputValue("high");
                coreInterface.sendCommand(BubuControl.getOutputCommand());
            }
        }
    }

    Switch {
        id: switchComponent
        checkable: true
        checked: initialState
        anchors.verticalCenter: settingRow.verticalCenter
        onClicked: {
            BubuControl.setGpioBit(bitNumber);
            checkSwitchState();
            BubuControl.printGpioCommand();// For testing
        }

    }

    Text {
        anchors.left: switchComponent.right
        width: settingRow.width - settingRow.spacing - switchComponent.width
        height: switchComponent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: switchComponent.checked ? settingMessageOne : settingMessageTwo
    }
}



