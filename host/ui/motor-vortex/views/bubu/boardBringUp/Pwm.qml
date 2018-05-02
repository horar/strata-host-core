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
    anchors.fill:parent

    function setCommands(pinFunction, portName, tabIndex)
    {
        if(pinFunction === "pwm"){
            BubuControl.setPwmPort(portName);
            BubuControl.printPwmCommand();
            pwmbitView.currentIndex = tabIndex;
        }
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
        SGMiddleSegmentedButton{text:"Port E";portName: "e"; tabIndex: 3; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGRightSegmentedButton{text:"Port F";portName: "f"; tabIndex: 3; pinFunction: "pwm";onClicked: setCommands(pinFunction, portName,tabIndex)}

    }
    SwipeView {
        id: pwmbitView
        anchors { left:parent.left
            right:parent.right
            bottom:parent.bottom
            top:pwmbuttonRow.bottom
        }
        currentIndex: 0

        onCurrentIndexChanged: {
            pwmbuttonRow.children[pwmbitView.currentIndex].checked = true;

        }
        ButtonViewPwm { }
        ButtonViewPwm { }
        ButtonViewPwm { }
        ButtonViewPwm { }
        ButtonViewPwm { }
        ButtonViewPwm { }
    }

    PageIndicator {
        id: indicator
        count: pwmbitView.count
        currentIndex: pwmbitView.currentIndex
        anchors.bottom: pwmbitView.bottom
        anchors.horizontalCenter: pwmOutline.horizontalCenter

    }

}

