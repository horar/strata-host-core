import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import "qrc:/views/usb-pd-multiport/views"

Item {
    id: controlView
    objectName: "control"
    anchors { fill: parent }

    PlatformInterface {
        id: platformInterface
    }

    TabBar {
        id: navTabs
        anchors {
            top: controlView.top
            left: controlView.left
            right: controlView.right
        }

        TabButton {
            id: basicButton
            text: qsTr("Basic")
            onClicked: {
                basicControl.visible = true
                advancedControl.visible = false
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: {
                basicControl.visible = false
                advancedControl.visible = true
            }
        }
    }

    Item {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlView.bottom
            right: controlView.right
            left: controlView.left
        }

        BasicControl {
            id: basicControl
            visible: true
        }

        AdvancedControl {
            id: advancedControl
            visible: false
        }        
    }

    Rectangle{
        id:sleepScrim
        anchors.fill:parent
        color:"white"
        opacity: .75
        visible:true
        z:1

        property var sleepState: platformInterface.sleep_state.state

        onSleepStateChanged: {
            console.log("sleep state changed to",sleepState)
            if (sleepState === "asleep"){
                sleepScrim.visible = true
            }
            else{
                sleepScrim.visible = false
            }
        }

        Text{
            id:sleepMessage
            anchors.centerIn:parent
            text:"plug in device to wake board"
            color:"darkgrey"
            font.family:"helvetica"
            font.pixelSize: 72
            font.bold:true
        }
    }

    Component.onCompleted: {
        console.log("Requesting platform Refresh")
        platformInterface.refresh.send() //ask the platform for all the current values

        console.log("asking for firmware version")
        platformInterface.getFirmwareInfo.send()
    }
}
