import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import "qrc:/views/bubu/Control.js" as BubuControl


Row {
    id: settingRow
    property string settingMessageOne: ""
    property string settingMessageTwo: ""
    property bool initialState: false
    property int switchAngle: 90
    property int bitNumber: 0
    /*
    Holds the state of the switch.
    */
    property bool stateOfTheSwitch: initialState
    spacing: 10
    signal activated()

    /*
    Check switch state and _setDirection_ accordingly.
    */
    function checkSwitchState()
    {
        if(switchComponent.checked === true) {
            stateOfTheSwitch = true;
            BubuControl.setDirection("output");
        }
        else {
            stateOfTheSwitch = false;
            BubuControl.setDirection("input");
        }
    }

    Switch {
        id: switchComponent
        checkable: true
        checked: initialState

        transform: Rotation {angle : switchAngle}
        onClicked: {
            BubuControl.setBit(bitNumber);
            settingRow.activated();
            checkSwitchState();
            BubuControl.printCommand(); // For testing
        }

    }

    Text {
        width: settingRow.width - settingRow.spacing - switchComponent.width
        height: switchComponent.height
        anchors { left: switchComponent.right
            top: parent.top
            topMargin: 10
        }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: switchComponent.checked ? settingMessageOne : settingMessageTwo
    }
}



