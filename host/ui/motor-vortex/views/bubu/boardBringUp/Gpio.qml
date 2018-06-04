import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import "qrc:/views/bubu/Control.js" as BubuControl


Rectangle {
    id:gpioContainer

    property var currentTab : gpioView
    property var newTab:  gpioView
//  visible: opacity > 0 // for testing
    anchors.fill:parent
    property variant portAMapDisable: [0, 1, 2, 3, 4 ,5 ,6,7,8,9,10,11,12,13,14,15]
    property variant portBMapDisable: [0, 1, 2, 3, 4 ,5 ,6,7,8,9,10,11,12,13,14,15]
    property variant portCMapDisable: [0, 1, 2, 3, 4 ,5 ,6,7,8,9,10,11,12,13,14,15]
    property variant portDMapDisable: [2]
    property variant portHMapDisable: [0, 1]

    function setCommands(pinFunction, portName, tabIndex)
    {
            BubuControl.setGpioPort(portName);
            bitView.currentIndex = tabIndex;
    }

    Component.onCompleted: {
        BubuControl.setGpioPort("A"); //Setting default port as "A"
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

   /*
     Holds the animation for the ports
   */
    ButtonGroup {
        id: animateButton
        buttons: buttonRow.children
        onClicked: {
            crosfadeTabs.start()
        }
    }


    Row {
        id:buttonRow
        anchors { top: gpioContainer.top;topMargin: 40; horizontalCenter: gpioContainer.horizontalCenter }
        width: 600
        height: 40

        /* passing port name to set "port" member in setPort function */
        SGLeftSegmentedButton{text:"Port A"; portName:"a"; tabIndex: 0; pinFunction: "gpio"; onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port B"; portName: "b"; tabIndex: 1; pinFunction: "gpio"; onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port C"; portName: "c"; tabIndex: 2; pinFunction: "gpio"; onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGMiddleSegmentedButton{text:"Port D"; portName: "d"; tabIndex: 3; pinFunction: "gpio"; onClicked: setCommands(pinFunction, portName,tabIndex)}
      //  SGMiddleSegmentedButton{text:"Port E"; portName: "e"; tabIndex: 4; pinFunction: "gpio"; onClicked: setCommands(pinFunction, portName,tabIndex)}
        SGRightSegmentedButton{text:"Port H"; portName: "f"; tabIndex: 4; pinFunction: "gpio"; onClicked: setCommands(pinFunction, portName,tabIndex)}

    }

    SwipeView {
        id: bitView
        anchors { left:gpioContainer.left
            right:gpioContainer.right
            bottom:gpioContainer.bottom
            top:buttonRow.bottom
        }
        currentIndex: 0
        onCurrentIndexChanged: {
            buttonRow.children[bitView.currentIndex].checked = true;
        }
        ButtonView { holdDisableBits: portAMapDisable } // A
        ButtonView { holdDisableBits: portBMapDisable} // B
        ButtonView { holdDisableBits: portCMapDisable} // C
        ButtonView { holdDisableBits: portDMapDisable }   // D
        ButtonView { holdDisableBits: portHMapDisable} // H
    }

    PageIndicator {
        id: indicator
        count: bitView.count
        currentIndex: bitView.currentIndex
        anchors.bottom: bitView.bottom
        anchors.horizontalCenter: gpioContainer.horizontalCenter

    }
}



