import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }
    property real ratioCalc: controlNavigation.width / 1200

    PlatformInterface {
        id: platformInterface
    }

    function toHex(d) {
        return  ("0"+(Number(d).toString(16))).slice(-2).toUpperCase()
    }



    Component.onCompleted: {
        platformInterface.set_startup.update(96,false)
       // platformInterface.control_props.update()
        platformInterface.set_mode.update("Car Demo")

    }

    property var startup: platformInterface.startup
    onStartupChanged: {
        if(startup.value === false)
            startupWarningPopup.open()
    }

    Popup {
        id: startupWarningPopup
        width: parent.width/2
        height: parent.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: startupWarningPopupContainer
            width: startupWarningPopup.width
            height: startupWarningPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }

        Rectangle {
            id: startupWarningPopupBox
            color: "transparent"
            anchors {
                top: parent.top
                //topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: startupWarningPopupContainer.width - 50
            height: startupWarningPopupContainer.height - 50

            Rectangle {
                id: messageContainerForPopup
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - selectionContainerForPopup.height
                Text {
                    id: startupWarningTextForPopup
                    anchors.fill:parent
                    text: "I2C communication with the LED driver has failed. This is likely because the LED driver has previously been OTP’ed/configured to have a different I2C address or I2C CRC is enabled. Please enter valid I2C address and I2C CRC state to re-check for I2C communication.”"
                    verticalAlignment:  Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                    font.bold: true
                }
            }

            Rectangle {
                id: selectionContainerForPopup
                width: parent.width
                height: parent.height/3
                anchors{
                    top: messageContainerForPopup.bottom
                    topMargin: 10
                    bottom: startupWarningPopupBox.Bottom
                    bottomMargin: 10
                }

                color: "transparent"

                RowLayout {
                    anchors.fill: parent

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        SGAlignedLabel {
                            id: new7bitLabel
                            target: new7bit
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            text: "7-bit I2C Address"

                            SGText{
                                id: nw7bitText
                                text: "0x"
                                anchors.right: new7bit.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: new7bit.verticalCenter
                                font.bold: true
                            }

                            SGSubmitInfoBox {
                                id: new7bit
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                height:  35 * ratioCalc
                                width: 50 * ratioCalc
                                text: toHex(96)
                                onAccepted: {
                                    var hexTodecimal = parseInt(text, 16)
                                    console.log(text)
                                    console.log(hexTodecimal)
                                    if(hexTodecimal > platformInterface.soc_addr_new.scales[0]) {
                                        console.log(text.toString(16))
                                        new7bit.text = toHex(platformInterface.soc_addr_new.scales[0])
                                        platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                    }

                                    else if(hexTodecimal < platformInterface.soc_addr_new.scales[1]){
                                        new7bit.text = toHex(platformInterface.soc_addr_new.scales[1])
                                        platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                    }
                                    else if(hexTodecimal <= platformInterface.soc_addr_new.scales[0] && hexTodecimal >= platformInterface.soc_addr_new.scales[1]){
                                        new7bit.text = text
                                        platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                    }
                                }

                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        SGAlignedLabel {
                            id: enableCRCLabel
                            target: enableCRC
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            text: "I2C CRC"
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true

                            SGSwitch {
                                id: enableCRC
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc * 1.2
                                checked: false

                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        SGButton {
                            id: continueButton
                            width: parent.width/2
                            height:parent.height - 10
                            anchors.right: parent.right
                            anchors.centerIn: parent
                            text: "Continue"
                            color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                            roundedLeft: true
                            roundedRight: true
                            onClicked: {
                                var hexTodecimal = parseInt(new7bit.text, 16)
                                console.log(new7bit.text)
                                console.log(hexTodecimal)
                                if(hexTodecimal > platformInterface.soc_addr_new.scales[0]) {
                                    console.log(new7bit.text.toString(16))
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[0])
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }

                                else if(hexTodecimal < platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[1])
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }
                                else if(hexTodecimal <= platformInterface.soc_addr_new.scales[0] && hexTodecimal >= platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = new7bit.text
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }
                                platformInterface.set_startup.update(hexTodecimal,enableCRC.checked)

                            }
                        }
                    }
                }
            }
        }
    }

    TabBar {
        id: navTabs
        anchors {
            top: controlNavigation.top
            left: controlNavigation.left
            right: controlNavigation.right
        }

        TabButton {
            id: carDemoButton
            text: qsTr("Car Demo Mode")
            onClicked: {
                platformInterface.set_mode.update("Car Demo")
                carDemoMode.visible = true
                ledControl.visible = false
                powerControl.visible = false
                sAMOPTControl.visible = false
                miscControl.visible = false
            }
        }

        TabButton {
            id: ledControlButton
            text: qsTr("LED Control")
            onClicked: {
                platformInterface.set_mode.update("LED Driver")
                carDemoMode.visible = false
                ledControl.visible = true
                powerControl.visible = false
                sAMOPTControl.visible = false
                miscControl.visible = false
            }
        }

        TabButton {
            id: powerControlButton
            text: qsTr("Power")
            onClicked: {
                platformInterface.set_mode.update("Power")
                carDemoMode.visible = false
                ledControl.visible = false
                powerControl.visible = true
                sAMOPTControl.visible = false
                miscControl.visible = false
            }
        }

        TabButton {
            id: samOptControlButton
            text: qsTr("SAM, OTP, and CRC")
            onClicked: {
                platformInterface.set_mode.update("LED Driver")
                carDemoMode.visible = false
                ledControl.visible = false
                powerControl.visible = false
                sAMOPTControl.visible = true
                miscControl.visible = false
            }
        }

        TabButton {
            id: miscControlButton
            text: qsTr("Miscellaneous")
            onClicked: {
                platformInterface.set_mode.update("LED Driver")
                carDemoMode.visible = false
                ledControl.visible = false
                powerControl.visible = false
                sAMOPTControl.visible = false
                miscControl.visible = true
            }
        }
    }

    Item {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        CarDemoControl{
            id: carDemoMode
            visible: true
        }

        LEDControl {
            id: ledControl
            visible: false
        }

        PowerControl {
            id: powerControl
            visible: false
        }

        SAMOPTControl {
            id: sAMOPTControl
            visible: false
        }

        MiscControl {
            id: miscControl
            visible: false
        }

    }
}
