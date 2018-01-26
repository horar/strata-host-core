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
    color:"grey"

    readonly property bool inLandscape: boardBringUP.width > boardBringUP.height
    property var currentTab
    property var newTab

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
        id:boardCommunicationsGroup
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

    Drawer {
        id: drawer

        y: 44   //header height
        width: boardBringUP.width / 8
        height: boardBringUP.height //- overlayHeader.height

        modal: false
        interactive: false
        position: inLandscape ? 1 : 0
        visible: inLandscape

        ColumnLayout{
            id:communicaionsColumnView
            anchors.fill:parent
            spacing:0
            Button{
                id:serialBoardBringUpButton
                objectName: "serialBoardBringUpButton"
                Layout.preferredWidth: communicaionsColumnView.width
                Layout.preferredHeight: communicaionsColumnView.height/3
                text: "serial"
                ButtonGroup.group:boardCommunicationsGroup
                checkable:true
                checked: true
                icon.source: "./images/icons/serialIcon.svg"
                background: Rectangle{
                    color: serialBoardBringUpButton.checked ? "grey" :"lightgrey"
                }

            }
            Button{
                id:gpioBoardBringUpButton
                objectName: "gpioBoardBringUpButton"
                Layout.preferredWidth: communicaionsColumnView.width
                Layout.preferredHeight: communicaionsColumnView.height/3
                text: "GPIO"
                ButtonGroup.group:boardCommunicationsGroup
                checkable:true
                icon.source: "./images/icons/gpioIcon.svg"
                background: Rectangle{
                    color: gpioBoardBringUpButton.checked ? "grey" :"lightgrey"
                }
            }
            Button{
                id:pwmBoardBringUpButton
                objectName: "pwmBoardBringUpButton"
                Layout.preferredWidth: communicaionsColumnView.width
                Layout.preferredHeight: communicaionsColumnView.height/3
                text: "PWM"
                ButtonGroup.group:boardCommunicationsGroup
                checkable:true
                icon.source: "./images/icons/pwmIcon.svg"
                background: Rectangle{
                    color: pwmBoardBringUpButton.checked ? "grey" :"lightgrey"
                }
            }

        }

    }

    Flickable {
        id: contentArea
        anchors.fill: parent
        anchors.leftMargin: inLandscape ? drawer.width : undefined
        topMargin: 0
        bottomMargin: 0
        contentHeight: boardBringUP.height

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

        ScrollIndicator.vertical: ScrollIndicator { }
    }



}


