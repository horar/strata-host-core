import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import "qrc:/views/bubu/Control.js" as BubuControl


Rectangle {
    id: container
    property string settingMessageOne: ""
    property string settingMessageTwo: ""
    property bool initialState: false
    property int switchAngle: 90
    property int bitNumber: 0
    property string switchType:  " "
    color: "transparent"
    property bool stateOfTheSwitch: initialState //  Holds the state of the switch

    /*
         set the port data direction based on the switch type
    */
    function setSwitchState()
    {
        if(switchType == "input_output") {
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
        else if(switchType ==  "low_high") {
            if(switchComponent.checked === true) {
                BubuControl.setOutputValue("low");
                coreInterface.sendCommand(BubuControl.getOutputCommand());
            }
            else {
                BubuControl.setOutputValue("high");
                coreInterface.sendCommand(BubuControl.getOutputCommand());
            }
        }
        else {
            console.log("switch type is undefinded");
        }
    }

    Switch {
        id: switchComponent
        checkable: true
        checked: initialState
        anchors.verticalCenter: container.verticalCenter
        onClicked: {
            BubuControl.setGpioBit(bitNumber);
            setSwitchState();

        }
    }

    Text {
        anchors.left: switchComponent.right
        width: container.width - container.spacing - switchComponent.width
        height: switchComponent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: switchComponent.checked ? settingMessageOne : settingMessageTwo
    }
}



