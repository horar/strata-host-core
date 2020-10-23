import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1400/900
    anchors.centerIn: parent
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

    property var helpTourCount: 0

    Connections{
        target: helpMouse
        onClicked: {
            if(visible) {
                if(helpTourCount === 0) {
                    console.info("sam test")
                    Help.registerTarget(enableCRC, "Toggles the cyclic redundancy check (CRC) to prevent data corruption on I2C communication lines. A CRC byte is calculated inserted into I2C read and write communications and verified by master and slave devices. The CRC configuration is as follows:\n\n1) The CRC polynomial is 0x2F (x⁸+x⁵+x³+x²+x+1)\n2) The initial XOR is 0xFF\n3) The final XOR is 0x00\n4) Reflect and data and remainder are disabled\n\nThis design will by default search for a device with I2C CRC disabled and 7-bit I2C slave address of 0x60 - if no LED driver is found the user must enter a valid I2C configuration to enable the user interface.", 0, "samoptHelp")
                    Help.registerTarget(current7bit, "The current 7-bit I2C slave address used to communicate with the LED driver.", 1, "samoptHelp")
                    Help.registerTarget(filterHelpContainer2, "Sets a new 7-bit I2C slave address. Click Apply I2C Address to change. The value entered will be coerced to a valid I2C slave address between 0x60 and 0x7F. The Current 7-bit I2C Address will be updated with the new address if successfully applied. The firmware will by default search for a device with I2C CRC disabled and 7-bit I2C slave address of 0x60. The user will be required to enter a valid I2C configuration to enable the user interface if the default search failed.", 2, "samoptHelp")
                    Help.registerTarget( i2cStandalone, "Changes the LED driver mode between SAM and I2C. I2C mode adheres to the LED register settings configured on the LED Control tab. SAM mode adheres to the settings on this tab in the SAM_CONF_1/2 controls.", 3, "samoptHelp")
                    Help.registerTarget(samConfig, "Toggles between SAM configurations SAM_CONF_1 and SAM_CONF_2 when Mode (I2CFLAG) control is set to SAM mode.", 4, "samoptHelp")
                    Help.registerTarget(vDDVoltageDisconnect, "Removes the VDD supply to the LED driver. This will put the LED driver into SAM mode automatically. A popup will appear that requires the user to reconnect VDD. The previously set LED driver Mode (I2CFLAG) will be enabled.", 5, "samoptHelp")
                    Help.registerTarget(filterHelpContainer1, "Sets the on or off state of each individual LED channel when Mode (I2CFLAG) control is set to SAM mode. Use the SAM Configuration control to toggle between the two SAM configurations. The hard-coded registers will be read during board boot and these controls will be updated accordingly.", 6, "samoptHelp")
                    Help.registerTarget(zapButton, "Click to OTP the LED driver using the SAM configuration on this tab. A popup warning will appear with Cancel or Continue commands to confirm desire to OTP. An additional warning will appear if the LED driver had been previously OTP'ed with a configuration other than default register values.", 7, "samoptHelp")
                    Help.registerTarget(diag, "Generic diagnostic error when any LED channel is in an error mode.", 8, "samoptHelp")
                    Help.registerTarget(samOpenLoadDiagnostic, "Sets the diagnostic state of the LED driver in SAM mode. This control will be disabled unless diagRange is on.\n\nNo Diagnostic = No open load detection is performed\n\nAuto Retry = During open load fault, 1) DIAG pin is pulled low, 2) low current is imposed on faulty channel only, 3) other channels turned off. If fault is recovered DIAG is released and normal operation continues.\n\nDiagnostic Only = During open load fault, the DIAG pin is pulled low with no change to current regulation. DIAG is released when the fault is recovered.", 9, "samoptHelp")
                    Help.startHelpTour("samoptHelp")
                    helpTourCount++;
                }
                else  {
                    Help.startHelpTour("samoptHelp")
                }
            }
        }
    }
    Item {
        id: filterHelpContainer1
        property point topLeft
        property point bottomRight
        width:  (out12.width) * 15
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = out12.mapToItem(root, 0,  0)
            bottomRight = samOut1.mapToItem(root, samOut1.width, samOut1.height)
        }
    }

    Item {
        id: filterHelpContainer2
        property point topLeft
        property point bottomRight
        width:  new7bitLabel.width + applyContainer.width + 35
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = new7bitLabel.mapToItem(root, 0,  0)
            bottomRight = applyContainer.mapToItem(root, applyContainer.width, applyContainer.height)
        }
    }


    onWidthChanged: {
        filterHelpContainer1.update()
        filterHelpContainer2.update()
    }
    onHeightChanged: {
        filterHelpContainer1.update()
        filterHelpContainer2.update()
    }

    Connections {
        target: Help.utility
        onTour_runningChanged:{
            filterHelpContainer1.update()
            filterHelpContainer2.update()
        }
    }

    MouseArea {
        id: containMouseArea
        anchors.fill:root
        onClicked: {
            forceActiveFocus()
        }
    }

    function toHex(d) {
        return  ("0"+(Number(d).toString(16))).slice(-2).toUpperCase()
    }

    function setStatesForControls (theId, index){
        if(index !== null && index !== undefined)  {
            if(index === 0) {
                theId.enabled = true
                theId.opacity = 1.0
            }
            else if(index === 1) {
                theId.enabled = false
                theId.opacity = 1.0
            }
            else {
                theId.enabled = false
                theId.opacity = 0.5
            }
        }
    }

    property var soc_sam_conf_1: platformInterface.soc_sam_conf_1
    onSoc_sam_conf_1Changed: {
        samconfi1Text.text = soc_sam_conf_1.caption
        out1.checked = soc_sam_conf_1.values[0]
        out2.checked = soc_sam_conf_1.values[1]
        out3.checked = soc_sam_conf_1.values[2]
        out4.checked = soc_sam_conf_1.values[3]
        out5.checked = soc_sam_conf_1.values[4]
        out6.checked = soc_sam_conf_1.values[5]
        out7.checked = soc_sam_conf_1.values[6]
        out8.checked = soc_sam_conf_1.values[7]
        out9.checked = soc_sam_conf_1.values[8]
        out10.checked = soc_sam_conf_1.values[9]
        out11.checked = soc_sam_conf_1.values[10]
        out12.checked = soc_sam_conf_1.values[11]

        platformInterface.soc_sam_conf_1_out1 = soc_sam_conf_1.values[0]
        platformInterface.soc_sam_conf_1_out2 = soc_sam_conf_1.values[1]
        platformInterface.soc_sam_conf_1_out3 = soc_sam_conf_1.values[2]
        platformInterface.soc_sam_conf_1_out4 = soc_sam_conf_1.values[3]
        platformInterface.soc_sam_conf_1_out5 = soc_sam_conf_1.values[4]
        platformInterface.soc_sam_conf_1_out6 = soc_sam_conf_1.values[5]
        platformInterface.soc_sam_conf_1_out7 = soc_sam_conf_1.values[6]
        platformInterface.soc_sam_conf_1_out8 = soc_sam_conf_1.values[7]
        platformInterface.soc_sam_conf_1_out9 = soc_sam_conf_1.values[8]
        platformInterface.soc_sam_conf_1_out10 = soc_sam_conf_1.values[9]
        platformInterface.soc_sam_conf_1_out11 = soc_sam_conf_1.values[10]
        platformInterface.soc_sam_conf_1_out12 = soc_sam_conf_1.values[11]

        setStatesForControls(out1,soc_sam_conf_1.states[0])
        setStatesForControls(out2,soc_sam_conf_1.states[1])
        setStatesForControls(out3,soc_sam_conf_1.states[2])
        setStatesForControls(out4,soc_sam_conf_1.states[3])
        setStatesForControls(out5,soc_sam_conf_1.states[4])
        setStatesForControls(out6,soc_sam_conf_1.states[5])
        setStatesForControls(out7,soc_sam_conf_1.states[6])
        setStatesForControls(out8,soc_sam_conf_1.states[7])
        setStatesForControls(out9,soc_sam_conf_1.states[8])
        setStatesForControls(out10,soc_sam_conf_1.states[9])
        setStatesForControls(out11,soc_sam_conf_1.states[10])
        setStatesForControls(out12,soc_sam_conf_1.states[11])
    }

    property var soc_sam_conf_1_values: platformInterface.soc_sam_conf_1_values.values
    onSoc_sam_conf_1_valuesChanged: {
        out1.checked = soc_sam_conf_1_values[0]
        out2.checked = soc_sam_conf_1_values[1]
        out3.checked = soc_sam_conf_1_values[2]
        out4.checked = soc_sam_conf_1_values[3]
        out5.checked = soc_sam_conf_1_values[4]
        out6.checked = soc_sam_conf_1_values[5]
        out7.checked = soc_sam_conf_1_values[6]
        out8.checked = soc_sam_conf_1_values[7]
        out9.checked = soc_sam_conf_1_values[8]
        out10.checked = soc_sam_conf_1_values[9]
        out11.checked = soc_sam_conf_1_values[10]
        out12.checked = soc_sam_conf_1_values[11]

        platformInterface.soc_sam_conf_1_out1 = soc_sam_conf_1_values[0]
        platformInterface.soc_sam_conf_1_out2 = soc_sam_conf_1_values[1]
        platformInterface.soc_sam_conf_1_out3 = soc_sam_conf_1_values[2]
        platformInterface.soc_sam_conf_1_out4 = soc_sam_conf_1_values[3]
        platformInterface.soc_sam_conf_1_out5 = soc_sam_conf_1_values[4]
        platformInterface.soc_sam_conf_1_out6 = soc_sam_conf_1_values[5]
        platformInterface.soc_sam_conf_1_out7 = soc_sam_conf_1_values[6]
        platformInterface.soc_sam_conf_1_out8 = soc_sam_conf_1_values[7]
        platformInterface.soc_sam_conf_1_out9 = soc_sam_conf_1_values[8]
        platformInterface.soc_sam_conf_1_out10 = soc_sam_conf_1_values[9]
        platformInterface.soc_sam_conf_1_out11 = soc_sam_conf_1_values[10]
        platformInterface.soc_sam_conf_1_out12 = soc_sam_conf_1_values[11]
    }

    property var soc_sam_conf_1_state: platformInterface.soc_sam_conf_1_states.states
    onSoc_sam_conf_1_stateChanged: {
        setStatesForControls(out1,soc_sam_conf_1_state[0])
        setStatesForControls(out2,soc_sam_conf_1_state[1])
        setStatesForControls(out3,soc_sam_conf_1_state[2])
        setStatesForControls(out4,soc_sam_conf_1_state[3])
        setStatesForControls(out5,soc_sam_conf_1_state[4])
        setStatesForControls(out6,soc_sam_conf_1_state[5])
        setStatesForControls(out7,soc_sam_conf_1_state[6])
        setStatesForControls(out8,soc_sam_conf_1_state[7])
        setStatesForControls(out9,soc_sam_conf_1_state[8])
        setStatesForControls(out10,soc_sam_conf_1_state[9])
        setStatesForControls(out11,soc_sam_conf_1_state[10])
        setStatesForControls(out12,soc_sam_conf_1_state[11])
    }

    property var soc_sam_conf_2: platformInterface.soc_sam_conf_2
    onSoc_sam_conf_2Changed: {
        samConfig2Text.text = soc_sam_conf_2.caption
        samOut1.checked = soc_sam_conf_2.values[0]
        samOut2.checked = soc_sam_conf_2.values[1]
        samOut3.checked = soc_sam_conf_2.values[2]
        samOut4.checked = soc_sam_conf_2.values[3]
        samOut5.checked = soc_sam_conf_2.values[4]
        samOut6.checked = soc_sam_conf_2.values[5]
        samOut7.checked = soc_sam_conf_2.values[6]
        samOut8.checked = soc_sam_conf_2.values[7]
        samOut9.checked = soc_sam_conf_2.values[8]
        samOut10.checked = soc_sam_conf_2.values[9]
        samOut11.checked = soc_sam_conf_2.values[10]
        samOut12.checked = soc_sam_conf_2.values[11]


        platformInterface.soc_sam_conf_2_out1 = soc_sam_conf_2.values[0]
        platformInterface.soc_sam_conf_2_out2 = soc_sam_conf_2.values[1]
        platformInterface.soc_sam_conf_2_out3 = soc_sam_conf_2.values[2]
        platformInterface.soc_sam_conf_2_out4 = soc_sam_conf_2.values[3]
        platformInterface.soc_sam_conf_2_out5 = soc_sam_conf_2.values[4]
        platformInterface.soc_sam_conf_2_out6 = soc_sam_conf_2.values[5]
        platformInterface.soc_sam_conf_2_out7 = soc_sam_conf_2.values[6]
        platformInterface.soc_sam_conf_2_out8 = soc_sam_conf_2.values[7]
        platformInterface.soc_sam_conf_2_out9 = soc_sam_conf_2.values[8]
        platformInterface.soc_sam_conf_2_out10 = soc_sam_conf_2.values[9]
        platformInterface.soc_sam_conf_2_out11 = soc_sam_conf_2.values[10]
        platformInterface.soc_sam_conf_2_out12 = soc_sam_conf_2.values[11]

        setStatesForControls(samOut1,soc_sam_conf_2.states[0])
        setStatesForControls(samOut2,soc_sam_conf_2.states[1])
        setStatesForControls(samOut3,soc_sam_conf_2.states[2])
        setStatesForControls(samOut4,soc_sam_conf_2.states[3])
        setStatesForControls(samOut5,soc_sam_conf_2.states[4])
        setStatesForControls(samOut6,soc_sam_conf_2.states[5])
        setStatesForControls(samOut7,soc_sam_conf_2.states[6])
        setStatesForControls(samOut8,soc_sam_conf_2.states[7])
        setStatesForControls(samOut9,soc_sam_conf_2.states[8])
        setStatesForControls(samOut10,soc_sam_conf_2.states[9])
        setStatesForControls(samOut11,soc_sam_conf_2.states[10])
        setStatesForControls(samOut12,soc_sam_conf_2.states[11])
    }

    property var soc_sam_conf_2_values: platformInterface.soc_sam_conf_2_values.values
    onSoc_sam_conf_2_valuesChanged: {
        samOut1.checked = soc_sam_conf_2_values[0]
        samOut2.checked = soc_sam_conf_2_values[1]
        samOut3.checked = soc_sam_conf_2_values[2]
        samOut4.checked = soc_sam_conf_2_values[3]
        samOut5.checked = soc_sam_conf_2_values[4]
        samOut6.checked = soc_sam_conf_2_values[5]
        samOut7.checked = soc_sam_conf_2_values[6]
        samOut8.checked = soc_sam_conf_2_values[7]
        samOut9.checked = soc_sam_conf_2_values[8]
        samOut10.checked = soc_sam_conf_2_values[9]
        samOut11.checked = soc_sam_conf_2_values[10]
        samOut12.checked = soc_sam_conf_2_values[11]

        platformInterface.soc_sam_conf_2_out1 = soc_sam_conf_2_values[0]
        platformInterface.soc_sam_conf_2_out2 = soc_sam_conf_2_values[1]
        platformInterface.soc_sam_conf_2_out3 = soc_sam_conf_2_values[2]
        platformInterface.soc_sam_conf_2_out4 = soc_sam_conf_2_values[3]
        platformInterface.soc_sam_conf_2_out5 = soc_sam_conf_2_values[4]
        platformInterface.soc_sam_conf_2_out6 = soc_sam_conf_2_values[5]
        platformInterface.soc_sam_conf_2_out7 = soc_sam_conf_2_values[6]
        platformInterface.soc_sam_conf_2_out8 = soc_sam_conf_2_values[7]
        platformInterface.soc_sam_conf_2_out9 = soc_sam_conf_2_values[8]
        platformInterface.soc_sam_conf_2_out10 = soc_sam_conf_2_values[9]
        platformInterface.soc_sam_conf_2_out11 = soc_sam_conf_2_values[10]
        platformInterface.soc_sam_conf_2_out12 = soc_sam_conf_2_values[11]


    }

    property var soc_sam_conf_2_state: platformInterface.soc_sam_conf_2_states.states
    onSoc_sam_conf_2_stateChanged: {
        setStatesForControls(samOut1,soc_sam_conf_2_state[0])
        setStatesForControls(samOut2,soc_sam_conf_2_state[1])
        setStatesForControls(samOut3,soc_sam_conf_2_state[2])
        setStatesForControls(samOut4,soc_sam_conf_2_state[3])
        setStatesForControls(samOut5,soc_sam_conf_2_state[4])
        setStatesForControls(samOut6,soc_sam_conf_2_state[5])
        setStatesForControls(samOut7,soc_sam_conf_2_state[6])
        setStatesForControls(samOut8,soc_sam_conf_2_state[7])
        setStatesForControls(samOut9,soc_sam_conf_2_state[8])
        setStatesForControls(samOut10,soc_sam_conf_2_state[9])
        setStatesForControls(samOut11,soc_sam_conf_2_state[10])
        setStatesForControls(samOut12,soc_sam_conf_2_state[11])
    }

    property var soc_otp_popup: platformInterface.soc_otp_popup
    onSoc_otp_popupChanged: {
        if(soc_otp_popup.value === true)
            warningPopupOTP.open()
    }

    property var soc_vdd_popup: platformInterface.soc_vdd_popup
    onSoc_vdd_popupChanged: {
        if(soc_vdd_popup.value === true)
            warningPopupVDDVol.open()
        else  warningPopupVDDVol.close()
    }

    Popup {
        id: warningPopupVDDVol
        width: parent.width/2
        height: parent.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainerVDD
            width: warningPopupVDDVol.width
            height: warningPopupVDDVol.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }
        Rectangle {
            id: warningPopupBoxVDDVol
            color: "transparent"
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainerVDD.width - 50
            height: warningPopupContainerVDD.height - 50

            Rectangle {
                id: messageContainerForPopupVDDVol
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - (parent.height/2) - 7
                Text {
                    id: warningTextForPopupVDDVol
                    anchors.fill:parent
                    text: "VDD was temporarily disconnected from LED driver. Loss of VDD will put the LED driver into SAM mode. Click "+ "\"" + "Reconnect VDD" + "\"" + " to reconnect VDD and resume previous LED driver Mode setting (SAM or I2C)."
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
                id: selectionContainerForPopupVDD
                width: parent.width
                height: parent.height/2
                anchors{
                    top: messageContainerForPopupVDDVol.bottom
                    topMargin: 15
                    bottom: warningPopupBoxVDDVol.bottom
                    bottomMargin: 10
                }
                color: "transparent"
                RowLayout {
                    anchors.fill: parent
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        SGButton {
                            id: reconnectButton
                            width: parent.width/1.5
                            height:parent.height

                            anchors.centerIn: parent
                            text: "Reconnect VDD"
                            color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                            roundedLeft: true
                            roundedRight: true
                            onClicked: {
                                if(i2cStandalone.checked)
                                    platformInterface.set_soc_mode.update("I2C")
                                else  platformInterface.set_soc_mode.update("SAM")
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: warningPopupOTP
        width: parent.width/2
        height: parent.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainerOTP
            width: warningPopupOTP.width
            height: warningPopupOTP.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }

        Rectangle {
            id: warningPopupBoxOTP
            color: "transparent"
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainerOTP.width - 50
            height: warningPopupContainerOTP.height - 50

            Rectangle {
                id: messageContainerForPopupOTP
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - (parent.height/2) - 10
                Text {
                    id: warningTextForPopupOTP
                    anchors.fill:parent
                    text: "Cannot OTP the part as it has been previously OTPâ€™ed."
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
                id: selectionContainerForPopupOTP
                width: parent.width
                height: parent.height/2
                anchors{
                    top: messageContainerForPopupOTP.bottom
                    topMargin: 15
                    bottom: warningPopupBoxOTP.bottom
                    bottomMargin: 10
                }
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        SGButton {
                            id: continueButton
                            width: parent.width/2
                            height:parent.height

                            anchors.centerIn: parent
                            text: "Continue"
                            color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                            roundedLeft: true
                            roundedRight: true
                            onClicked: {
                                warningPopupOTP.close()
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: warningPopup
        width: parent.width/2
        height: parent.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainer
            width: warningPopup.width
            height: warningPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }

        Rectangle {
            id: warningPopupBox
            color: "transparent"
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainer.width - 50
            height: warningPopupContainer.height - 50

            Rectangle {
                id: messageContainerForPopup
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - (parent.height/2) - 7
                Text {
                    id: warningTextForPopup
                    anchors.fill:parent
                    text: "The part will be permanently OTPâ€™ed. The non-volatile registers settings in ID_LOCK_OTP cannot be changed again! The volatile register settings in ID_SET_OTP can still be modified to illustrate SAM configuration."
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
                height: parent.height/2
                anchors{
                    top: messageContainerForPopup.bottom
                    topMargin: 20
                    bottom: warningPopupBox.bottom
                    bottomMargin: 10
                }
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        SGButton {
                            id: cancelButton
                            width: parent.width/2
                            height:parent.height
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                            roundedLeft: true
                            roundedRight: true
                            onClicked: {
                                warningPopup.close()
                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        SGButton {
                            id: continueButtonOPT
                            width: parent.width/2
                            height:parent.height
                            anchors.centerIn: parent
                            text: "Continue"
                            color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                            roundedLeft: true
                            roundedRight: true
                            onClicked: {
                                warningPopup.close()
                                platformInterface.set_soc_write.update(
                                            true,
                                            [platformInterface.soc_sam_conf_1_out1,
                                             platformInterface.soc_sam_conf_1_out2,
                                             platformInterface.soc_sam_conf_1_out3,
                                             platformInterface.soc_sam_conf_1_out4,
                                             platformInterface.soc_sam_conf_1_out5,
                                             platformInterface.soc_sam_conf_1_out6,
                                             platformInterface.soc_sam_conf_1_out7,
                                             platformInterface.soc_sam_conf_1_out8,
                                             platformInterface.soc_sam_conf_1_out9,
                                             platformInterface.soc_sam_conf_1_out10,
                                             platformInterface.soc_sam_conf_1_out11,
                                             platformInterface.soc_sam_conf_1_out12

                                            ],
                                            [platformInterface.soc_sam_conf_2_out1,
                                             platformInterface.soc_sam_conf_2_out2,
                                             platformInterface.soc_sam_conf_2_out3,
                                             platformInterface.soc_sam_conf_2_out4,
                                             platformInterface.soc_sam_conf_2_out5,
                                             platformInterface.soc_sam_conf_2_out6,
                                             platformInterface.soc_sam_conf_2_out7,
                                             platformInterface.soc_sam_conf_2_out8,
                                             platformInterface.soc_sam_conf_2_out9,
                                             platformInterface.soc_sam_conf_2_out10,
                                             platformInterface.soc_sam_conf_2_out11,
                                             platformInterface.soc_sam_conf_2_out12
                                            ],
                                            samOpenLoadDiagnostic.currentText,
                                            platformInterface.soc_crcValue,
                                            platformInterface.addr_curr_apply)

                            }
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        width: parent.width/1.1
        height: parent.height/1.2
        anchors.centerIn: parent
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"
            Text {
                id: i2cConfigHeading
                text: "I2C Configuration"
                font.bold: true
                font.pixelSize: ratioCalc * 20
                color: "#696969"
                anchors {
                    top: parent.top
                    topMargin: 5
                }
            }

            Rectangle {
                id: line
                height: 1.5
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: i2cConfigHeading.bottom
                    topMargin: 7
                }
            }

            RowLayout {
                width: parent.width
                height: parent.height - i2cConfigHeading.contentHeight - line.height
                anchors {
                    top: line.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: enableCRCLabel
                        target: enableCRC
                        //text: "Enable\nCRC"
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }
                        Component.onCompleted: { fontSizeMultiplier = Qt.binding(function(){ return ratioCalc * 1.2}) }
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
                            Component.onCompleted: { fontSizeMultiplier = Qt.binding(function(){ return (ratioCalc * 1.2).toFixed(2)})  }
                            onToggled: {
                                platformInterface.soc_crcValue = checked
                                platformInterface.set_soc_write.update(
                                            false,
                                            [platformInterface.soc_sam_conf_1_out1,
                                             platformInterface.soc_sam_conf_1_out2,
                                             platformInterface.soc_sam_conf_1_out3,
                                             platformInterface.soc_sam_conf_1_out4,
                                             platformInterface.soc_sam_conf_1_out5,
                                             platformInterface.soc_sam_conf_1_out6,
                                             platformInterface.soc_sam_conf_1_out7,
                                             platformInterface.soc_sam_conf_1_out8,
                                             platformInterface.soc_sam_conf_1_out9,
                                             platformInterface.soc_sam_conf_1_out10,
                                             platformInterface.soc_sam_conf_1_out11,
                                             platformInterface.soc_sam_conf_1_out12

                                            ],
                                            [platformInterface.soc_sam_conf_2_out1,
                                             platformInterface.soc_sam_conf_2_out2,
                                             platformInterface.soc_sam_conf_2_out3,
                                             platformInterface.soc_sam_conf_2_out4,
                                             platformInterface.soc_sam_conf_2_out5,
                                             platformInterface.soc_sam_conf_2_out6,
                                             platformInterface.soc_sam_conf_2_out7,
                                             platformInterface.soc_sam_conf_2_out8,
                                             platformInterface.soc_sam_conf_2_out9,
                                             platformInterface.soc_sam_conf_2_out10,
                                             platformInterface.soc_sam_conf_2_out11,
                                             platformInterface.soc_sam_conf_2_out12
                                            ],
                                            samOpenLoadDiagnostic.currentText,
                                            platformInterface.soc_crcValue,
                                            platformInterface.addr_curr)

                            }
                        }

                        property var soc_crc: platformInterface.soc_crc
                        onSoc_crcChanged: {
                            enableCRCLabel.text = soc_crc.caption
                            setStatesForControls(enableCRC,soc_crc.states[0])
                            enableCRC.checked = soc_crc.value
                            platformInterface.soc_crcValue = soc_crc.value
                        }

                        property var soc_crc_caption: platformInterface.soc_crc_caption.caption
                        onSoc_crc_captionChanged: {
                            enableCRCLabel.text = soc_crc_caption
                        }

                        property var soc_crc_state: platformInterface.soc_crc_states.states
                        onSoc_crc_stateChanged: {
                            setStatesForControls(enableCRC,soc_crc_state[0])
                        }

                        property var soc_crc_value: platformInterface.soc_crc_value.value
                        onSoc_crc_valueChanged: {
                            enableCRC.checked = soc_crc_value
                            platformInterface.soc_crcValue = soc_crc_value
                        }

                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: current7bitLabel
                        target: current7bit
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        font.bold : true

                        SGInfoBox {
                            id: current7bit
                            height:  35 * ratioCalc
                            width: 50 * ratioCalc
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                        }
                        SGText{
                            id: current7bitText
                            text: "0x"
                            anchors.right: current7bit.left
                            anchors.rightMargin: 10
                            anchors.verticalCenter: current7bit.verticalCenter
                            font.bold: true
                        }


                        property var soc_addr_curr: platformInterface.soc_addr_curr
                        onSoc_addr_currChanged: {
                            text = soc_addr_curr.caption
                            setStatesForControls(current7bit,soc_addr_curr.states[0])
                            current7bit.text = toHex(soc_addr_curr.value)
                            platformInterface.addr_curr = soc_addr_curr.value
                        }
                        property var soc_addr_curr_caption: platformInterface.soc_addr_curr_caption.caption
                        onSoc_addr_curr_captionChanged: {
                            text = soc_addr_curr_caption
                        }
                        property var soc_addr_curr_state: platformInterface.soc_addr_curr_states.states
                        onSoc_addr_curr_stateChanged: {
                            setStatesForControls(current7bit,soc_addr_curr_state[0])
                        }
                        property var soc_addr_curr_value: platformInterface.soc_addr_curr_value.value
                        onSoc_addr_curr_valueChanged: {
                            current7bit.text = toHex(soc_addr_curr_value)
                            platformInterface.addr_curr = soc_addr_curr_value

                        }
                    }
                }

                Rectangle {

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: new7bitLabel
                        target: new7bit
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        font.bold : true
                        SGSubmitInfoBox {
                            id: new7bit
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                            height:  35 * ratioCalc
                            width: 50 * ratioCalc
                            infoBoxObject.boxFont.capitalization: Font.AllUppercase
                            validator: RegExpValidator { regExp: /[0-9A-Fa-f]+/ }
                            onEditingFinished: {
                                var hexTodecimal = parseInt(text, 16)
                                if(hexTodecimal > platformInterface.soc_addr_new.scales[0]) {
                                    console.log(text.toString(16).toUpperCase())
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[0]).toUpperCase()
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }

                                else if(hexTodecimal < platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[1]).toUpperCase()
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }
                                else if(hexTodecimal <= platformInterface.soc_addr_new.scales[0] && hexTodecimal >= platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = text
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }

                            }

                        }

                        SGText{
                            id: nw7bitText
                            text: "0x"
                            anchors.right: new7bit.left
                            anchors.rightMargin: 10
                            anchors.verticalCenter: new7bit.verticalCenter
                            font.bold: true
                        }


                        property var soc_addr_new: platformInterface.soc_addr_new
                        onSoc_addr_newChanged: {
                            new7bitLabel.text = soc_addr_new.caption
                            setStatesForControls(new7bit,soc_addr_new.states[0])
                            new7bit.text =  toHex(soc_addr_new.value)
                            platformInterface.addr_curr_apply = parseInt(new7bit.text , 16)
                        }

                        property var soc_addr_new_caption: platformInterface.soc_addr_new_caption.caption
                        onSoc_addr_new_captionChanged: {
                            new7bitLabel.text = soc_addr_new_caption
                        }

                        property var soc_addr_new_state: platformInterface.soc_addr_new_states.states
                        onSoc_addr_new_stateChanged: {
                            setStatesForControls(new7bit,soc_addr_new_state[0])
                        }

                        property var soc_addr_new_value: platformInterface.soc_addr_new_value.value
                        onSoc_addr_new_valueChanged: {
                            new7bit.text =  toHex(soc_addr_new_value)
                            platformInterface.addr_curr_apply = parseInt(new7bit.text , 16)
                        }

                    }

                }
                Rectangle {
                    id: applyContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGButton {
                        id:  i2cAddressButton
                        text: qsTr("Apply I2C Address")
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                        hoverEnabled: true
                        height: parent.height/2
                        width: parent.width/2
                        MouseArea {
                            hoverEnabled: true
                            anchors.fill: parent
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                var hexTodecimal = parseInt(new7bit.text, 16)
                                if(hexTodecimal > platformInterface.soc_addr_new.scales[0]) {
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[0]).toUpperCase()
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }

                                else if(hexTodecimal < platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[1]).toUpperCase()
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }
                                else if(hexTodecimal <= platformInterface.soc_addr_new.scales[0] && hexTodecimal >= platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = new7bit.text.toUpperCase()
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }

                                platformInterface.set_soc_write.update(
                                            false,
                                            [platformInterface.soc_sam_conf_1_out1,
                                             platformInterface.soc_sam_conf_1_out2,
                                             platformInterface.soc_sam_conf_1_out3,
                                             platformInterface.soc_sam_conf_1_out4,
                                             platformInterface.soc_sam_conf_1_out5,
                                             platformInterface.soc_sam_conf_1_out6,
                                             platformInterface.soc_sam_conf_1_out7,
                                             platformInterface.soc_sam_conf_1_out8,
                                             platformInterface.soc_sam_conf_1_out9,
                                             platformInterface.soc_sam_conf_1_out10,
                                             platformInterface.soc_sam_conf_1_out11,
                                             platformInterface.soc_sam_conf_1_out12
                                            ],
                                            [platformInterface.soc_sam_conf_2_out1,
                                             platformInterface.soc_sam_conf_2_out2,
                                             platformInterface.soc_sam_conf_2_out3,
                                             platformInterface.soc_sam_conf_2_out4,
                                             platformInterface.soc_sam_conf_2_out5,
                                             platformInterface.soc_sam_conf_2_out6,
                                             platformInterface.soc_sam_conf_2_out7,
                                             platformInterface.soc_sam_conf_2_out8,
                                             platformInterface.soc_sam_conf_2_out9,
                                             platformInterface.soc_sam_conf_2_out10,
                                             platformInterface.soc_sam_conf_2_out11,
                                             platformInterface.soc_sam_conf_2_out12
                                            ],
                                            samOpenLoadDiagnostic.currentText,
                                            platformInterface.soc_crcValue,
                                            platformInterface.addr_curr_apply)

                            }
                        }
                    }
                }
            }
        }


        Rectangle {
            Layout.preferredHeight: parent.height/2
            Layout.fillWidth: true
            color: "transparent"
            ColumnLayout{
                anchors.fill: parent
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/9
                    color: "transparent"
                    Text {
                        id: standAloneModeHeading
                        text: "Stand Alone Mode (SAM) Configuration"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line2
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: standAloneModeHeading.bottom
                            topMargin: 7
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout{
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: i2cStandaloneLabel
                                target: i2cStandalone
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: i2cStandalone
                                    labelsInside: true
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_soc_mode.update("I2C")
                                        else platformInterface.set_soc_mode.update("SAM")
                                    }
                                }

                                property var soc_mode: platformInterface.soc_mode
                                onSoc_modeChanged: {
                                    i2cStandaloneLabel.text = soc_mode.caption
                                    setStatesForControls(i2cStandalone,soc_mode.states[0])
                                    i2cStandalone.checkedLabel = soc_mode.values[0]
                                    i2cStandalone.uncheckedLabel = soc_mode.values[1]
                                    if(soc_mode.value === "I2C")
                                        i2cStandalone.checked = true
                                    else  i2cStandalone.checked = false
                                }

                                property var soc_mode_caption: platformInterface.soc_mode_caption.caption
                                onSoc_mode_captionChanged: {
                                    i2cStandaloneLabel.text = soc_mode_caption
                                }

                                property var soc_mode_state: platformInterface.soc_mode_states.states
                                onSoc_mode_stateChanged: {
                                    setStatesForControls(i2cStandalone,soc_mode_state[0])
                                }

                                property var soc_mode_values: platformInterface.soc_mode_values.values
                                onSoc_mode_valuesChanged: {
                                    i2cStandalone.checkedLabel = soc_mode_values[0]
                                    i2cStandalone.uncheckedLabel = soc_mode_values[1]
                                }

                                property var soc_mode_value: platformInterface.soc_mode_value.value
                                onSoc_mode_valueChanged:{
                                    if(soc_mode_value === "I2C")
                                        i2cStandalone.checked = true
                                    else  i2cStandalone.checked = false
                                }
                            }
                        }

                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: samConfigLabel
                                target: samConfig
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }

                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: samConfig
                                    labelsInside: true
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_soc_conf.update("SAM1")
                                        else
                                            platformInterface.set_soc_conf.update("SAM2")

                                    }

                                    property var soc_conf: platformInterface.soc_conf
                                    onSoc_confChanged: {
                                        samConfigLabel.text = soc_conf.caption
                                        setStatesForControls(samConfig,soc_conf.states[0])
                                        samConfig.checkedLabel = soc_conf.values[0]
                                        samConfig.uncheckedLabel = soc_conf.values[1]
                                        if(soc_conf.value === "SAM1")
                                            samConfig.checked = true
                                        else  samConfig.checked = false

                                    }

                                    property var soc_conf_caption: platformInterface.soc_conf_caption.caption
                                    onSoc_conf_captionChanged: {
                                        samConfigLabel.text = soc_conf_caption
                                    }

                                    property var soc_conf_state: platformInterface.soc_conf_states.states
                                    onSoc_conf_stateChanged: {
                                        setStatesForControls(samConfig,soc_conf_state[0])
                                    }

                                    property var soc_conf_values: platformInterface.soc_conf_values.values
                                    onSoc_conf_valuesChanged: {
                                        samConfig.checkedLabel = soc_conf_values[0]
                                        samConfig.uncheckedLabel = soc_conf_values[1]
                                    }

                                    property var soc_conf_value: platformInterface.soc_conf_value.value
                                    onSoc_conf_valueChanged:{
                                        if(soc_conf_value === "SAM1"){
                                            samConfig.checked = true
                                        }
                                        else  samConfig.checked = false
                                    }

                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGButton {
                                id:  vDDVoltageDisconnect
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                height: parent.height/1.8
                                width: parent.width/2
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: platformInterface.set_soc_vdd_disconnect.update()

                                }
                            }

                            property var soc_vdd_disconnect: platformInterface.soc_vdd_disconnect
                            onSoc_vdd_disconnectChanged: {
                                vDDVoltageDisconnect.text = soc_vdd_disconnect.caption
                                setStatesForControls(vDDVoltageDisconnect,soc_vdd_disconnect.states[0])
                            }

                            property var soc_vdd_disconnect_caption: platformInterface.soc_vdd_disconnect_caption.caption
                            onSoc_vdd_disconnect_captionChanged: {
                                vDDVoltageDisconnect.text = soc_vdd_disconnect_caption
                            }

                            property var soc_vdd_disconnect_state: platformInterface.soc_vdd_disconnect_states.states
                            onSoc_vdd_disconnect_stateChanged: {
                                setStatesForControls(vDDVoltageDisconnect,soc_vdd_disconnect_state[0])
                            }

                        }

                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout{
                        id: sam1Row
                        anchors.fill: parent
                        Rectangle {
                            Layout.preferredWidth: parent.width/4
                            Layout.fillHeight: true
                            SGText {
                                id:samconfi1Text
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                                property var soc_sam_conf_1_caption: platformInterface.soc_sam_conf_1_caption.caption
                                onSoc_sam_conf_1_captionChanged: {
                                    text = soc_sam_conf_1_caption
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out12Label
                                target: out12
                                text: "OUT 12"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out12
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out12 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out11Label
                                target: out11
                                text: "OUT 11"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out11
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out11 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out10Label
                                target: out10
                                text: "OUT 10"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out10
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out10 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out9Label
                                target: out9
                                text: "OUT 9"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out9
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out9 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12
                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out8Label
                                target: out8
                                text: "OUT 8"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out8
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out8 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out7Label
                                target: out7
                                text: "OUT 7"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out7
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out7 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out6Label
                                target: out6
                                text: "OUT 6"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out6
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out6 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12
                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out5Label
                                target: out5
                                text: "OUT 5"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out5
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out5 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out4Label
                                target: out4
                                text: "OUT 4"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out4
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out4 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out3Label
                                target: out3
                                text: "OUT 3"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out3
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false

                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out3 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: out2Label
                                target: out2
                                text: "OUT 2"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out2
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false

                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out2 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: out1Label
                                target: out1
                                text: "OUT 1"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out1
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out1 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    RowLayout{
                        id: sam2Row
                        anchors.fill: parent
                        Rectangle {
                            Layout.preferredWidth: parent.width/4
                            Layout.fillHeight: true
                            SGText {
                                id: samConfig2Text
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                anchors.verticalCenter: parent.verticalCenter
                                font.bold: true

                                property var soc_sam_conf_2_caption: platformInterface.soc_sam_conf_2_caption.caption
                                onSoc_sam_conf_2_captionChanged: {
                                    text = soc_sam_conf_2_caption
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut12
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out12 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut11
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out11 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut10
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out10 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut9
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out9 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }



                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut8
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out8 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut7
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out7 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }



                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut6
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out6 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }



                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut5
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out5 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }




                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut4
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out4 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut3
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out3 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }



                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut2
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out2 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGSwitch {
                                id: samOut1
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out1 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }
                    }
                }
            }
        }


        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Text {
                        id: oneTimeProgramHeading
                        text: "One Time Program (OTP)"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        id: line3
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: oneTimeProgramHeading.bottom
                            topMargin: 7
                        }
                    }


                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        anchors {
                            top: line3.bottom
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        SGButton {
                            id:  zapButton

                            anchors.verticalCenter: parent.verticalCenter
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                            hoverEnabled: true
                            height: parent.height/2
                            width: parent.width/2
                            MouseArea {
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: warningPopup.open()

                            }

                            property var soc_otp: platformInterface.soc_otp
                            onSoc_otpChanged:{
                                text = soc_otp.caption
                                setStatesForControls(zapButton,soc_otp.states[0])
                            }

                            property var soc_otp_caption: platformInterface.soc_otp_caption.caption
                            onSoc_otp_captionChanged: {
                                text = soc_otp_caption
                            }

                            property var soc_otp_state: platformInterface.soc_otp_states.states
                            onSoc_otp_stateChanged: {
                                setStatesForControls(zapButton,soc_otp_state[0])
                            }
                        }
                    }


                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/1.5


                    Text {
                        id: diagnosticHeading
                        text: "Diagnostic"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line4
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: diagnosticHeading.bottom
                            topMargin: 7
                        }
                    }

                    RowLayout{
                        width: parent.width
                        height: parent.height - diagnosticHeading.contentHeight - line4.height
                        anchors {
                            top: line4.bottom
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: diagLabel
                                target: diag
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                // text: "DIAG"
                                font.bold: true

                                SGStatusLight {
                                    id: diag
                                    width : 40

                                }


                                property var soc_diag: platformInterface.soc_diag
                                onSoc_diagChanged: {
                                    diagLabel.text = soc_diag.caption
                                    setStatesForControls(diag,soc_diag.states[0])
                                    if(soc_diag.value === true)
                                        diag.status = SGStatusLight.Red
                                    else  diag.status = SGStatusLight.Off

                                }

                                property var soc_diag_caption: platformInterface.soc_diag_caption.caption
                                onSoc_diag_captionChanged: {
                                    diagLabel.text = soc_diag_caption
                                }

                                property var soc_diag_state: platformInterface.soc_diag_states.states
                                onSoc_diag_stateChanged: {
                                    setStatesForControls(diag,soc_diag_state[0])
                                }

                                property var soc_diag_value: platformInterface.soc_diag_value.value
                                onSoc_diag_valueChanged: {
                                    if(soc_diag_value === true)
                                        diag.status = SGStatusLight.Red
                                    else  diag.status = SGStatusLight.Off
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"

                            SGAlignedLabel {
                                id: samOpenLoadLabel
                                target: samOpenLoadDiagnostic
                                //text: "SAM Open Load\nDiagnostic"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true

                                SGComboBox {
                                    id: samOpenLoadDiagnostic
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    onActivated: {
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12
                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                                property var soc_sam_open_load_diagnostic: platformInterface.soc_sam_open_load_diagnostic
                                onSoc_sam_open_load_diagnosticChanged: {
                                    samOpenLoadLabel.text = soc_sam_open_load_diagnostic.caption
                                    setStatesForControls(samOpenLoadDiagnostic,soc_sam_open_load_diagnostic.states[0])
                                    samOpenLoadDiagnostic.model = soc_sam_open_load_diagnostic.values
                                    for(var a = 0; a < samOpenLoadDiagnostic.model.length; ++a) {
                                        if(soc_sam_open_load_diagnostic.value === samOpenLoadDiagnostic.model[a].toString()){
                                            samOpenLoadDiagnostic.currentIndex = a
                                        }
                                    }

                                }

                                property var soc_sam_open_load_diagnostic_caption: platformInterface.soc_sam_open_load_diagnostic_caption.caption
                                onSoc_sam_open_load_diagnostic_captionChanged: {
                                    samOpenLoadLabel.text = soc_sam_open_load_diagnostic_caption
                                }

                                property var soc_sam_open_load_diagnostic_state: platformInterface.soc_sam_open_load_diagnostic_states.states
                                onSoc_sam_open_load_diagnostic_stateChanged: {
                                    setStatesForControls(samOpenLoadDiagnostic,soc_sam_open_load_diagnostic_state[0])
                                }

                                property var soc_sam_open_load_diagnostic_values: platformInterface.soc_sam_open_load_diagnostic_values.values
                                onSoc_sam_open_load_diagnostic_valuesChanged: {
                                    samOpenLoadDiagnostic.model = soc_sam_open_load_diagnostic_values
                                }

                                property var soc_sam_open_load_diagnostic_value: platformInterface.soc_sam_open_load_diagnostic_values.value
                                onSoc_sam_open_load_diagnostic_valueChanged: {
                                    for(var a = 0; a < samOpenLoadDiagnostic.model.length; ++a) {
                                        if(soc_sam_open_load_diagnostic_values === samOpenLoadDiagnostic.model[a].toString()){
                                            samOpenLoadDiagnostic.currentIndex = a
                                            samOpenLoadDiagnostic.currentText = soc_sam_open_load_diagnostic_values
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
