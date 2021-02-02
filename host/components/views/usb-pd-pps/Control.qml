import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import "sgwidgets"
import "./views/"
import "views/basic-partial-views/" //needed for DebugMenu for some reason
import tech.strata.fonts 1.0

Item {
    id: controlView
    objectName: "control"
    anchors { fill: parent }

    PlatformInterface {
        id: platformInterface
    }

    property var maxBoardPower: 60  //in Watts

    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered: {
            platformInterface.requestfirmwareVersion.send()
        }
    }

    property var fw_verison: platformInterface.get_firmware_info.application.version
    onFw_verisonChanged: {
        if(fw_verison === "1.0.0") {
            warningPopup.open()
        }
    }

    //Only Red Banner
    Popup {
        id: warningPopup
        width: controlView.width/2.9
        height: controlView.height/5
        anchors.centerIn: controlView
        modal: true
        focus: true
        closePolicy:Popup.CloseOnPressOutside

        background: Rectangle {
            id: warningPopupContainer1
            width: warningPopup.width
            height: warningPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }

        Rectangle {
            id: warningBox
            color: "red"
            anchors.centerIn: parent

            anchors.horizontalCenter: parent.horizontalCenter
            width: (parent.width) -2
            height: parent.height/3
            Text {
                id: warningText
                anchors.centerIn: parent
                text: "Schematic Changed. Look at FAQ for more info."
                font.pixelSize: (parent.width + parent.height)/ 32
                color: "white"
                font.bold: true
            }

            Text {
                id: warningIcon3
                anchors {
                    right: warningText.left
                    verticalCenter: warningText.verticalCenter
                    rightMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }

            Text {
                id: warningIcon4
                anchors {
                    left: warningText.right
                    verticalCenter: warningText.verticalCenter
                    leftMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
        }
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
            property real initialAspectRatio
        }

        AdvancedControl {
            id: advancedControl
            visible: false
            property real initialAspectRatio
        }
    }

    Component.onCompleted: {
        advancedControl.initialAspectRatio = basicControl.initialAspectRatio = controlContainer.width / controlContainer.height

        console.log("Requesting platform Refresh")
        platformInterface.refresh.send() //ask the platform for all the current values
    }


    //    DebugMenu {
    //        // See description in control-views/DebugMenu.qml
    //        anchors {
    //            right: controlContainer.right
    //            bottom: controlContainer.bottom
    //        }
    //    }
}
