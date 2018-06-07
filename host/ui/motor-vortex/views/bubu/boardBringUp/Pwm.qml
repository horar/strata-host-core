import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "qrc:/views/bubu/Control.js" as BubuControl

Rectangle {
    id: pwmOutline
    property var currentTab: pwmView
    property var newTab: pwmView
//    visible: opacity > 0 //testing
    property variant portAMapDisable: [4, 12, 13, 14]
    property variant portBMapDisable: [2, 12, 10, 11]
    property variant portCMapDisable: [0,1,2,3,4,5,10,11,12,13,14,15]
    property variant portDMapDisable: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    property variant portHMapDisable: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

  //  property type name: value
    anchors.fill:parent

    function setCommands(pinFunction, portName, tabIndex)
    {

            BubuControl.setPwmPort(portName);
            pwmbitView.currentIndex = tabIndex;
    }

    Component.onCompleted: {
        BubuControl.setPwmPort("a"); //Setting default port as "a"
    }


    ParallelAnimation{
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
        anchors { top: pwmOutline.top;topMargin: 40; horizontalCenter: pwmOutline.horizontalCenter }
        width: 600
        height: 40

        SGLeftSegmentedButton{text:"Port A"; portName:"a"; tabIndex: 0; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex) }
        SGMiddleSegmentedButton{text:"Port B"; portName: "b"; tabIndex: 1; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port C";portName: "c"; tabIndex: 2; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port D";portName: "d"; tabIndex: 3; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex)}
    //    SGMiddleSegmentedButton{text:"Port E";portName: "e"; tabIndex: 4; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGRightSegmentedButton{text:"Port H";portName: "h"; tabIndex: 5; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex)}

    }
    SwipeView {
        id: pwmbitView
        anchors { left:pwmOutline.left
            right:pwmOutline.right
            bottom:pwmOutline.bottom
            top:pwmbuttonRow.bottom
        }
        currentIndex: 0

        onCurrentIndexChanged: {
            pwmbuttonRow.children[pwmbitView.currentIndex].checked = true;

        }
        ButtonViewPwm { holdDisableBits: portAMapDisable }
        ButtonViewPwm { holdDisableBits: portBMapDisable }
        ButtonViewPwm { holdDisableBits: portCMapDisable }
        ButtonViewPwm{ holdDisableBits: portDMapDisable }
        ButtonViewPwm { holdDisableBits: portHMapDisable }

    }

    PageIndicator {
        id: indicator
        count: pwmbitView.count
        currentIndex: pwmbitView.currentIndex
        anchors.bottom: pwmbitView.bottom
        anchors.horizontalCenter: pwmOutline.horizontalCenter

    }

}

