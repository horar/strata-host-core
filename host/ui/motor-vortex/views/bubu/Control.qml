
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import "boardBringUp"
import "qrc:/js/navigation_control.js" as NavigationControl


Rectangle {
    id: boardBringUP
    property string user_id
    property string platform_name
    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 8;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int mediumLargeFontSize: (Qt.platform.os === "osx") ? 20  : 14;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 16;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;
    anchors{ fill:parent }
    //color:lightGreyColor

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
                serialView.visible = true

            }
            else if (button.objectName == "gpioBoardBringUpButton"){
                newTab = gpioView
                //TO DO [Tanya] change this to set visible to the opacity
                gpioView.visible = true
                serialView.visible = false
                pwmView.visible = false


            }
            else if (button.objectName == "pwmBoardBringUpButton"){
                newTab = pwmView
                pwmView.visible = true
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
            tabName:Serial{/*visible: false*/}
        }

        SGMiddleSegmentedButton{
            text:"gpio";
            objectName: "gpioBoardBringUpButton"
            tabName:Gpio{/*visible: false*/}
        }
        SGRightSegmentedButton{
            text:"pwm";
            objectName: "pwmBoardBringUpButton"
            tabName:Pwm{/*visible: false*/}
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

    Rectangle{
        height: 40;width:40
        anchors { bottom: boardBringUP.bottom; right: boardBringUP.right }
        color: "white";
        Image {
            id: flipButton
            source:"qrc:/views/motor-vortex/images/icons/infoIcon.svg"
            anchors { fill: parent }
            height: 40;width:40
        }
    }
    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { bottom: parent.bottom; right: parent.right }
        visible: true
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}
