import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import "framework"
import "boardBringUp"



Rectangle {
    id: boardBringUP
    anchors{ fill:parent }
    //color:lightGreyColor

    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 8;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int mediumLargeFontSize: (Qt.platform.os === "osx") ? 20  : 14;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 16;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;

    property color lightGreyColor: "#EBEAE9"
    property color mediumGreyColor: "#E4E3E2"
    property color darkGreyColor: "#DBDAD9"

    property var currentTab : serialView
    property var newTab : gpioView

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
        buttons: buttonRow.children
        onClicked: {
            //console.log("button clicked is ",button.objectName)
            if (button.objectName == "serialBoardBringUpButton"){

                newTab = serialView
                }
            else if (button.objectName == "gpioBoardBringUpButton"){
                newTab = gpioView
                }
            else if (button.objectName == "pwmBoardBringUpButton"){
                newTab = pwmView
            }
            crosfadeTabs.start()
            currentTab = newTab
        }
    }

    Row {
        id:buttonRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 15

        SGLeftSegmentedButton{
            text:"serial" ;
            objectName: "serialBoardBringUpButton"
            tabName:Serial{}
        }

        SGMiddleSegmentedButton{
            text:"gpio";
            objectName: "gpioBoardBringUpButton"
            tabName:Gpio{}
        }
        SGRightSegmentedButton{
            text:"pwm";
            objectName: "pwmBoardBringUpButton"
            tabName:Pwm{}
        }
    }

    Rectangle{
        id:contentRectangle
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        anchors.top:buttonRow.bottom

        Serial{
            id:serialView
            anchors.fill:parent
            opacity:1.0
            }

        Gpio{
            id:gpioView
            anchors.fill:parent
            opacity:0
            }

        Pwm{
            id:pwmView
            anchors.fill:parent
            opacity:0
        }
    }



}


