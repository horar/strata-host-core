import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "qrc:/views/bubu/Control.js" as BubuControl

Rectangle {
    id: container
    property var currentTab: pwmView
    property var newTab: pwmView
    /*
      List of disabled pin for pwm for each port
    */
    property variant portAMapDisable: []
    property variant portBMapDisable: []
    property variant portCMapDisable: []
    property variant portDMapDisable: []
    property variant portEMapDisable: []
    property variant portHMapDisable: []

    /*
      set Pwm port based on pin function
    */
    function setPwmPort(pinFunction, portName, tabIndex) {
        BubuControl.setPwmPort(portName);
        pwmbitView.currentIndex = tabIndex;
    }

    /*
        Setting default port as "a"
    */
    Component.onCompleted: {
        BubuControl.setPwmPort("a");
    }


    ParallelAnimation {
        id: crosfadeTabs
        OpacityAnimator{
            target: currentTab
            from: 1
            to: 0
            duration: 500
            running: false
        }
        OpacityAnimator{
            target: newTab
            from: 0
            to: 1
            duration: 500
            running: false
        }
    }

    ButtonGroup {
        buttons: pwmbuttonRow.children
        onClicked: {
            crosfadeTabs.start()
        }
    }


    Row {
        id:pwmbuttonRow
        anchors { top: container.top; topMargin: 40; horizontalCenter: container.horizontalCenter }
        width: 600
        height: 40
        /*
            passing port name to set "port" member in setPort function
        */

        SGLeftSegmentedButton{text:"Port A"; portName:"a"; tabIndex: 0; pinFunction: "pwm";onClicked: setPwmPort(pinFunction, portName,tabIndex) }
        SGMiddleSegmentedButton{text:"Port B"; portName: "b"; tabIndex: 1; pinFunction: "pwm";onClicked: setPwmPort(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port C";portName: "c"; tabIndex: 2; pinFunction: "pwm";onClicked: setPwmPort(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port D";portName: "d"; tabIndex: 3; pinFunction: "pwm";onClicked: setPwmPort(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port E";portName: "e"; tabIndex: 4; pinFunction: "pwm";onClicked: setPwmPort(pinFunction, portName,tabIndex) }
        SGRightSegmentedButton{text:"Port H";portName: "h"; tabIndex: 5; pinFunction: "pwm";onClicked: setPwmPort(pinFunction, portName,tabIndex)}

    }

    SwipeView {
        id: pwmbitView
        anchors { left:container.left
            right:container.right
            bottom:container.bottom
            top:pwmbuttonRow.bottom
        }
        currentIndex: 0

        onCurrentIndexChanged: {
            pwmbuttonRow.children[pwmbitView.currentIndex].checked = true;

        }
        /*
            view for the ports
        */
        ButtonViewPwm { holdDisableBits: portAMapDisable }
        ButtonViewPwm { holdDisableBits: portBMapDisable }
        ButtonViewPwm { holdDisableBits: portCMapDisable }
        ButtonViewPwm { holdDisableBits: portDMapDisable }
        ButtonViewPwm { holdDisableBits: portEMapDisable }
        ButtonViewPwm { holdDisableBits: portHMapDisable }

    }

    PageIndicator {
        id: indicator
        count: pwmbitView.count
        currentIndex: pwmbitView.currentIndex
        anchors.bottom: pwmbitView.bottom
        anchors.horizontalCenter: container.horizontalCenter

    }

}


