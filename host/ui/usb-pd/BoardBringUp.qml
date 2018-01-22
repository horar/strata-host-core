import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import "framework"



Rectangle {
    id: boardBringUP

    anchors{ fill:parent }
    color:"grey"

    readonly property bool inLandscape: boardBringUP.width > boardBringUP.height
    property var currentTab
    property var newTab

    function createTab(inTabName, inParent){
        var component  = Qt.createComponent(inTabName);
        var object = component.createObject(inParent);
        return object
    }

    Component.onCompleted: {
        currentTab = createTab("serial.qml", contentRectangle);
        currentTab.opacity = 1;

        newTab = createTab("gpio.qml",contentRectangle);
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
        id:boardCommunicationsGroup
        onClicked: {
            if (button.id == "serialBringUpButton"){
                newTab = serial
                }
            else if (button.id == "gpioBoardBringUpButton"){
                newTab = gpio
                }
            else if (button.id == "pwmBoardBringUpButton"){
                newTab = pwm
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

        modal: inLandscape
        interactive: inLandscape
        position: inLandscape ? 1 : 0
        visible: inLandscape

        ColumnLayout{
            id:communicaionsColumnView
            anchors.fill:parent
            spacing:0
            Button{
                id:serialBoardBringUpButton
                Layout.preferredWidth: communicaionsColumnView.width
                Layout.preferredHeight: communicaionsColumnView.height/3
                text: "serial"
                ButtonGroup.group:boardCommunicationsGroup
                checkable:true
                checked: true
                background: Rectangle{
                    color: serialBoardBringUpButton.checked ? "grey" :"lightgrey"
                }

            }
            Button{
                id:gpioBoardBringUpButton
                Layout.preferredWidth: communicaionsColumnView.width
                Layout.preferredHeight: communicaionsColumnView.height/3
                text: "GPIO"
                ButtonGroup.group:boardCommunicationsGroup
                checkable:true
                background: Rectangle{
                    color: gpioBoardBringUpButton.checked ? "grey" :"lightgrey"
                }
            }
            Button{
                id:pwmBoardBringUpButton
                Layout.preferredWidth: communicaionsColumnView.width
                Layout.preferredHeight: communicaionsColumnView.height/3
                text: "PWM"
                ButtonGroup.group:boardCommunicationsGroup
                checkable:true
                background: Rectangle{
                    color: pwmBoardBringUpButton.checked ? "grey" :"lightgrey"
                }
            }

        }

    }

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.leftMargin: inLandscape ? drawer.width : undefined

        topMargin: 20
        bottomMargin: 20
        contentHeight: column.height

//        serial{}
//        gpio{}
//        pwm{}

        ScrollIndicator.vertical: ScrollIndicator { }
    }

}


