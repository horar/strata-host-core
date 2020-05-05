import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.fonts 1.0

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width/1200
    property real initialAspectRatio: Screen.width/Screen.height
    property string vinGoodThreshText: ""
    property string pgoodLabelText: "\n(PG_308)"
    property string prevVinLDOSel: ""
    property string newVinLDOSel: ""
    anchors.centerIn: parent
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Component.onCompleted: {
        advPGoodTimer.start()
        Help.registerTarget(currentLimitThresholdLabel, "This info box will show the approximate output current threshold at which the LDO's output current limit protection was triggered. This info box does not show the current limit threshold during a short-circuit event caused by enabling the onboard short-circuit load or if a load is attached directly at the LDO output via the solder pad.", 0, "AdjLDOAdvanceHelp")
        Help.registerTarget(resetCurrLimitButton, "This button resets the previous detected current limit threshold value and re-enables the logic for detecting a current limit event. The current limit threshold may immediately update after resetting if the output current remains above the current limit threshold.", 1, "AdjLDOAdvanceHelp")
        Help.registerTarget(shortCircuitButton, "This button enables the onboard short-circuit load used to emulate a short to ground on the LDO output for approximately 2 ms. The short-circuit load cannot be enabled when powering the LDO via the 5V from the Strata USB connector and/or when the input buck regulator is enabled. The current pulled by the short-circuit load will vary with LDO output voltage. See the Platform Content page for more information about the short-circuit load and LDO behavior during a short-circuit event.", 2, "AdjLDOAdvanceHelp")
        Help.registerTarget(currentLimitReachLabel, "This indicator will turn red when the LDO's current limit protection is triggered. The indicator state will need to be cleared manually when triggered using the \"Reset Current Limit Trigger\" button. See the Platform Content for more information on the current limit behavior of the LDO and how this is detected.", 3, "AdjLDOAdvanceHelp")
        Help.registerTarget(pgldoLabel, "This indicator will be green when the LDO power good signal is high. Since the TSOP-5 package has no PG output, if the TSOP-5 LDO package is being used, the indicator will be green when the PG_308 signal from the NCP308 used to monitor the LDO output voltage is high. During an LDO current limit or TSD event, this indicator will flash red.", 4, "AdjLDOAdvanceHelp")
        Help.registerTarget(ocpTriggeredLabel, "This indicator will turn red momentarily if the LDO's power good signal or the PG_308 signal goes low while the short-circuit load is enabled.", 5, "AdjLDOAdvanceHelp")
        Help.registerTarget(tsdTriggeredLabel, "This indicator will turn red when the LDO's thermal shutdown (TSD) protection is triggered. The indicator state will need to be cleared manually when triggered using the \"Reset TSD Trigger\" button. See the Platform Content for more information on the TSD behavior of the LDO and how this is detected.", 6, "AdjLDOAdvanceHelp")
        Help.registerTarget(resetTSDButton, "This button resets the previous detected TSD threshold value and re-enables the logic for detecting a TSD event. During a sustained TSD event, the TSD threshold will update immediately after it is reset and will continue to do so as long as the TSD conditions are valid.", 7, "AdjLDOAdvanceHelp")
        Help.registerTarget(estTSDThresLabel, "This info box will show the estimated LDO junction temperature threshold at which the LDO's TSD protection was triggered.", 8, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoPowerDissipationLabel, "This gauge shows the power loss in the LDO when it is enabled. This gauge will not be accurate when an external load is attached directly to the LDO output via the solder pad.", 9, "AdjLDOAdvanceHelp")
        Help.registerTarget(boardTempLabel, "This gauge shows the board temperature near the ground pad of the selected LDO package.", 10, "AdjLDOAdvanceHelp")
        Help.registerTarget(appxLDoTempLabel, "This gauge shows the approximate LDO junction temperature. See the Platform Content page for more information on how it is calculated.", 11, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoInputVolLabel, "This slider allows you to set the desired input voltage of the LDO when being supplied by the input buck regulator. The value can be set while the input buck regulator is not being used and the voltage will automatically be adjusted as needed when the input buck regulator is activated.", 12, "AdjLDOAdvanceHelp")
        Help.registerTarget(boardInputLabel, "This combo box allows you to choose the main input voltage option (upstream power supply) for the board. The 'External' option uses the input voltage from the input banana plugs. The 'USB 5V' option uses the 5V supply from the Strata USB connector. The 'Off' option disconnects both inputs from VIN and pulls VIN low.", 13, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoEnableSwitchLabel, "This switch enables the LDO.", 14, "AdjLDOAdvanceHelp")
        Help.registerTarget(setLDOOutputVoltageContainer, "This slider allows you to set the desired output voltage of the LDO. The value can be set while the LDO is disabled, and the voltage will automatically be adjusted as needed whenever the LDO is enabled again.", 15, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoInputLabel, "This combo box allows you to choose the input voltage option for the LDO. The 'Bypass' option connects the LDO input directly to VIN_SB through a load switch. The 'Buck Regulator' option allows adjustment of the input voltage to the LDO through an adjustable output voltage buck regulator. The 'Off' option disables both the input buck regulator and bypass load switch, disconnecting the LDO from the input power supply, and pulls VIN_LDO low. The 'Direct' option allows you to power the LDO directly through the VIN_LDO solder pad on the board, bypassing the input stage entirely. WARNING! - when using this option, ensure you do not use the other LDO input voltage options while an external power supply is supplying power to the LDO through the VIN_LDO solder pad. See the Platform Content page for more information about the options for supplying the LDO input voltage.", 16, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoDisableLabel, "This switch disables the LDO output voltage adjustment circuit included on this board. See the Platform Content page for more information on using this feature.", 17, "AdjLDOAdvanceHelp")
        Help.registerTarget(setOutputCurrentLabel, "This slider allows you to set the current pulled by the onboard load. The value can be set while the load is disabled and the load current will automatically be adjusted as needed when the load is enabled. The value may need to be reset to the desired level after recovery from an LDO UVLO event.", 18, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoPackageLabel, "This combo box allows you to choose the LDO package currently populated on the board if different from the stock LDO package option. See the Platform Content page for more information about using alternate LDO packages with this board.", 19, "AdjLDOAdvanceHelp")
        Help.registerTarget(loadEnableSwitchLabel, "This switch enables the onboard load.", 20, "AdjLDOAdvanceHelp")
        Help.registerTarget(extLoadCheckboxLabel, "Check this box if an external load is connected to the output banana plugs. During normal onboard load operation, a loop is run when the current level is set within the LDO's nominal output current range to minimize the load current error, and this loop should not be run if an external load is attached.", 21, "AdjLDOAdvanceHelp")
        Help.registerTarget(vinGoodLabel, "This indicator will be green when:\na.) VIN is greater than 2.5V when the input buck regulator is enabled\nb.) VIN is greater than 1.5V when it is disabled.", 22, "AdjLDOAdvanceHelp")
        Help.registerTarget(vinReadyLabel, "This indicator will be green when the LDO input voltage is greater than the LDO input UVLO threshold of 1.6V.", 23, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoInputVoltageLabel, "This info box shows the input voltage of the LDO.", 24, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoOutputVoltageLabel, "This info box shows the output voltage of the LDO.", 25, "AdjLDOAdvanceHelp")
        Help.registerTarget(ldoOutputCurrentLabel, "This info box shows the output current of the LDO when pulled by either the onboard electronic load or through an external load connected to the output banana plugs. Current pulled by the onboard short-circuit load or an external load attached directly to the LDO output via the solder pad is not measured will not be shown in this box.", 26, "AdjLDOAdvanceHelp")
        Help.registerTarget(diffVoltageLabel, "This info box shows the voltage drop across the LDO.", 27, "AdjLDOAdvanceHelp")
        Help.registerTarget(dropReachedLabel, "This indicator will turn red when the LDO is in dropout. The dropout threshold is defined as the point when the LDO output voltage drops 3% below the value set with the \"Set LDO Output Voltage\" slider or info box. The indicator state is invalid when the LDO output voltage adjustment feature is disabled using the \"Disable LDO Output Voltage Adjustment\" switch.", 28, "AdjLDOAdvanceHelp")
    }



    property var variant_name: platformInterface.variant_name.value
    onVariant_nameChanged: {
        if(variant_name === "NCP164A_TSOP5" || variant_name === "NCP164A_DFN6" || variant_name === "NCP164A_DFN8") {
            setLDOOutputVoltage.fromText.text = "1.1V"
            setLDOOutputVoltage.toText.text =  "5V"
            setLDOOutputVoltage.from = 1.1
            setLDOOutputVoltage.to = 5
        } else if (variant_name === "NCV8164A_TSOP5" || variant_name === "NCV8164A_DFN6" || variant_name === "NCV8164A_DFN8") {
            setLDOOutputVoltage.fromText.text ="1.2V"
            setLDOOutputVoltage.toText.text =  "5V"
            setLDOOutputVoltage.from = 1.2
            setLDOOutputVoltage.to = 5
        }
    }

    property var telemetry_notification: platformInterface.telemetry
    onTelemetry_notificationChanged: {
        boardTemp.value = telemetry_notification.board_temp
        ldoPowerDissipation.value = telemetry_notification.ploss
        appxLDoTemp.value = telemetry_notification.ldo_temp
        ldoInputVoltage.text = telemetry_notification.vin_ldo
        ldoOutputVoltage.text = telemetry_notification.vout_ldo
        ldoOutputCurrent.text = telemetry_notification.iout
        diffVoltage.text = telemetry_notification.vdiff
    }

    property var ldo_clim_thresh_notification: platformInterface.ldo_clim_thresh.value
    onLdo_clim_thresh_notificationChanged: {
        currentLimitThreshold.text  = ldo_clim_thresh_notification
    }

    property var  tsd_thresh_notification: platformInterface.tsd_thresh.value
    onTsd_thresh_notificationChanged: {
        estTSDThres.text =  tsd_thresh_notification
    }

    property var control_states: platformInterface.control_states
    onControl_statesChanged: {

        if(control_states.vin_sel === "USB 5V")  {
            if (setOutputCurrent.value > 300) {
                setOutputCurrent.value = 300
            }
            setOutputCurrent.to = 300
            setOutputCurrent.toText.text = "300mA"
            boardInputComboBox.currentIndex = 0
        }
        else if(control_states.vin_sel === "External") {
            setOutputCurrent.to = 650
            setOutputCurrent.toText.text = "650mA"
            boardInputComboBox.currentIndex = 1
        }
        else if (control_states.vin_sel === "Off") {
            setOutputCurrent.to = 650
            setOutputCurrent.toText.text = "650mA"
            boardInputComboBox.currentIndex = 2
        }

        if(control_states.vin_ldo_sel === "Bypass") {
            vinGoodThreshText = "\n (Above 1.5V)"
            ldoInputComboBox.currentIndex = 0
        }
        else if (control_states.vin_ldo_sel === "Buck Regulator") {
            vinGoodThreshText = "\n (Above 2.5V)"
            ldoInputComboBox.currentIndex = 1
        }
        else if (control_states.vin_ldo_sel === "Off") {
            vinGoodThreshText = "\n (Above 1.5V)"
            ldoInputComboBox.currentIndex = 2
        }
        else if (control_states.vin_ldo_sel === "Direct") {
            vinGoodThreshText = "\n (Above 1.5V)"
            ldoInputComboBox.currentIndex = 3
        }

        if(control_states.load_en === "on")
            loadEnableSwitch.checked = true
        else loadEnableSwitch.checked = false

        if(control_states.ldo_en === "on")
            ldoEnableSwitch.checked = true
        else ldoEnableSwitch.checked = false

        ldoInputVolSlider.value = control_states.vin_ldo_set
        setLDOOutputVoltage.value = control_states.vout_ldo_set
        setOutputCurrent.value = control_states.load_set

        if(control_states.ldo_sel === "TSOP5")  {
            pgoodLabelText = "\n(PG_308)"
            ldoPackageComboBox.currentIndex = 0
        }
        else if(control_states.ldo_sel === "DFN6") {
            pgoodLabelText = "\n(PG_LDO)"
            ldoPackageComboBox.currentIndex = 1
        }
        else if (control_states.ldo_sel === "DFN8") {

            pgoodLabelText = "\n(PG_LDO)"
            ldoPackageComboBox.currentIndex = 2
        }

        if (control_states.vout_set_disabled === true) {
            setLDOOutputVoltageLabel.opacity = 0.5
            setLDOOutputVoltageLabel.enabled = false
            dropReachedLabel.opacity = 0.5
            dropReachedLabel.enabled = false
            ldoDisable.checked = true
        } else {
            setLDOOutputVoltageLabel.opacity = 1
            setLDOOutputVoltageLabel.enabled = true
            dropReachedLabel.opacity = 1
            dropReachedLabel.enabled = true
            ldoDisable.checked = false
        }

    }

    property var int_status: platformInterface.int_status
    onInt_statusChanged: {
        if(int_status.ocp === true) ocpTriggered.status = SGStatusLight.Red
        else ocpTriggered.status = SGStatusLight.Off

        if(int_status.ldo_clim === true) {
            currentLimitReach.status = SGStatusLight.Red
        }
        else currentLimitReach.status = SGStatusLight.Off

        if(int_status.tsd === true) {
            tsdTriggered.status = SGStatusLight.Red
        }
        else  tsdTriggered.status = SGStatusLight.Off

        if(int_status.dropout === true && dropReachedLabel.enabled)  dropReached.status = SGStatusLight.Red
        else dropReached.status = SGStatusLight.Off
    }

    property var ext_load_checked: platformInterface.ext_load_status.value
    onExt_load_checkedChanged: {
        if (ext_load_checked === true) extLoadCheckbox.checked = true
        else extLoadCheckbox.checked = false
    }

    property string popup_message: ""
    property var sc_allowed: platformInterface.sc_allowed.value
    onSc_allowedChanged: {
        if (sc_allowed === false) {
            if (root.visible && !warningPopup.opened) {
                popup_message = "The short-circuit load cannot be enabled when using USB 5V or the input buck regulator to supply the LDO input voltage."
                warningPopup.open()
            }
        }
    }

    property var config_running: platformInterface.config_running.value
    onConfig_runningChanged: {
        if(config_running === true) {
            if (root.visible && !warningPopup.opened) {
                popup_message = "A function to configure the hardware on the board is already running. Please wait and try applying the settings again."
                warningPopup.open()
            }
        }
    }

    Popup{
        id: warningPopup
        width: root.width/2
        height: root.height/4
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
            Rectangle {
                id:topBorder
                width: parent.width
                height: parent.height/7
                anchors{
                    top: parent.top
                    topMargin: 2
                    right: parent.right
                    rightMargin: 2
                    left: parent.left
                    leftMargin: 2
                }
                radius: 5
                color: "#c0c0c0"
                border.color: "#c0c0c0"
                border.width: 2
            }
        }

        Rectangle {
            id: warningPopupBox
            color: "transparent"
            anchors {
                top: parent.top
                topMargin: 5
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
                height:  parent.height - selectionContainerForPopup.height
                Text {
                    id: warningTextForPopup
                    anchors.fill:parent
                    text: popup_message
                    verticalAlignment:  Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                }
            }

            Rectangle {
                id: selectionContainerForPopup
                width: parent.width/2
                height: parent.height/4.5
                anchors{
                    top: messageContainerForPopup.bottom
                    topMargin: 10
                    right: parent.right
                }
                color: "transparent"
                SGButton {
                    width: parent.width/3
                    height:parent.height
                    anchors.centerIn: parent
                    text: "OK"
                    color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                    roundedLeft: true
                    roundedRight: true

                    onClicked: {
                        warningPopup.close()
                    }
                }
            }
        }
    }

    Popup{
        id: warningPopupLDOInput
        width: root.width/2
        height: root.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupLDOInputContainer
            width: warningPopupLDOInput.width
            height: warningPopupLDOInput.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
            Rectangle {
                id:topBorderLDOInput
                width: parent.width
                height: parent.height/7
                anchors{
                    top: parent.top
                    topMargin: 2
                    right: parent.right
                    rightMargin: 2
                    left: parent.left
                    leftMargin: 2
                }
                radius: 5
                color: "#c0c0c0"
                border.color: "#c0c0c0"
                border.width: 2
            }
        }

        Rectangle {
            id: warningPopupLDOInputBox
            color: "transparent"
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupLDOInputContainer.width - 50
            height: warningPopupLDOInputContainer.height - 50

            Rectangle {
                id: messageContainerForWarningPopupLDOInput
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - selectionContainerForWarningPopupLDOInput.height
                Text {
                    id: warningTextForWarningPopupLDOInput
                    anchors.fill:parent
                    text: "Damage to the board and/or external supply may result from applying power from the input power stage" +
                          " of the board to the LDO while simultaneously directly applying external power to the LDO through the solder pads." +
                          " Click OK to acknowledge and proceed with changing the LDO input voltage option or Cancel to abort."
                    verticalAlignment:  Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                }
            }

            Rectangle {
                id: selectionContainerForWarningPopupLDOInput
                width: parent.width
                height: parent.height/4.5
                anchors{
                    top: messageContainerForWarningPopupLDOInput.bottom
                    topMargin: 10
                    right: parent.right
                }
                color: "transparent"
                Rectangle {
                    id: okButtonForLDOInput
                    width: parent.width/2
                    height:parent.height
                    color: "transparent"

                    SGButton {
                        anchors.centerIn: parent
                        text: "OK"
                        color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                        roundedLeft: true
                        roundedRight: true
                        onClicked: {
                            platformInterface.select_vin_ldo.update(newVinLDOSel)
                            prevVinLDOSel = newVinLDOSel
                            warningPopupLDOInput.close()
                        }
                    }
                }

                Rectangle {
                    id: cancelButtonForLDOInput
                    width: parent.width/2
                    height:parent.height
                    anchors.left: okButtonForLDOInput.right
                    color: "transparent"

                    SGButton {
                        anchors.centerIn: parent
                        text: "Cancel"
                        roundedLeft: true
                        roundedRight: true
                        color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                        onClicked: {
                            ldoInputComboBox.currentIndex = 3
                            warningPopupLDOInput.close()

                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: noteMessage
        width: parent.width/2
        height: 40
        anchors{
            top: root.top
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: noteBox
            color: "red"
            anchors.fill: parent

            Text {
                id: noteText
                anchors.centerIn: noteBox
                text: "Note: External Input Required For OCP Testing"
                font.bold: true
                font.pixelSize:  ratioCalc * 16
                color: "white"
            }

            Text {
                id: warningIconleft
                anchors {
                    right: noteText.left
                    verticalCenter: noteText.verticalCenter
                    rightMargin: 5
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize:  ratioCalc * 16
                color: "white"
            }

            Text {
                id: warningIconright
                anchors {
                    left: noteText.right
                    verticalCenter: noteText.verticalCenter
                    leftMargin: 5
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize:  ratioCalc * 16
                color: "white"
            }
        }
    }

    Rectangle {
        width: parent.width
        height: parent.height - noteMessage.height - 50
        anchors {
            top: noteMessage.bottom
            topMargin: 5
            left: parent.left
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
        }

        ColumnLayout {
            anchors.fill:parent

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * (5/12)

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            id: outputShortCircuiContainer
                            anchors.fill: parent

                            Text {
                                id: outputShortCircuitText
                                font.bold: true
                                text: "Output Current Limiting/Short-Circuit Protection"
                                font.pixelSize: ratioCalc * 20
                                Layout.topMargin: 10
                                color: "#696969"
                                Layout.leftMargin: 20

                            }

                            Rectangle {
                                id: line1
                                Layout.preferredHeight: 2
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: outputShortCircuiContainer.width + 10
                                border.color: "lightgray"
                                radius: 2
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10


                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: currentLimitThresholdLabel
                                            target: currentLimitThreshold
                                            text:  "Approximate Current\nLimit Threshold"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopLeft
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGInfoBox {
                                                id: currentLimitThreshold
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                width: 100 * ratioCalc
                                                unit: "<b>mA</b>"
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGButton {
                                            id: resetCurrLimitButton
                                            height: preferredContentHeight * 1.5
                                            width: preferredContentWidth * 1.25
                                            text: "Reset Current \n Limit Trigger"
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                            hoverEnabled: true
                                            MouseArea {
                                                hoverEnabled: true
                                                anchors.fill: parent
                                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                onClicked: {
                                                    platformInterface.reset_clim.update()
                                                    currentLimitThreshold.text = ""

                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGButton {
                                            id: shortCircuitButton
                                            height: preferredContentHeight * 1.5
                                            width: preferredContentWidth * 1.25
                                            text: "Trigger Short \n Circuit"
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                            hoverEnabled: true
                                            MouseArea {
                                                hoverEnabled: true
                                                anchors.fill: parent
                                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                onClicked: {
                                                    platformInterface.enable_sc.update()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: currentLimitReachLabel
                                            target: currentLimitReach
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            text: "Current Limit \n Reached"
                                            font.bold: true

                                            SGStatusLight {
                                                height: 40
                                                width: 40
                                                id: currentLimitReach
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id:pgldoLabel
                                            target: pgldo
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            text: "Power Good" + pgoodLabelText
                                            font.bold: true

                                            SGStatusLight {
                                                id: pgldo
                                                height: 40
                                                width: 40

                                                Timer {
                                                    id: advPGoodTimer
                                                    interval: 250; running: true; repeat: true
                                                    onTriggered: {
                                                        if(platformInterface.int_status.int_pg_ldo === true) {
                                                            pgldo.status  = SGStatusLight.Green
                                                            pgldoLabel.text = "Power Good" + pgoodLabelText
                                                        } else if ((platformInterface.int_status.int_pg_ldo === false) &&
                                                                   (platformInterface.control_states.ldo_en === "on") &&
                                                                   (platformInterface.int_status.vin_ldo_good === true))
                                                        {
                                                            if ((platformInterface.int_status.ldo_clim === true) || (platformInterface.int_status.tsd === true)) {
                                                                pgldoLabel.text = "Current Limit\nor TSD Event"
                                                            } else {
                                                                pgldoLabel.text = "Power Good" + pgoodLabelText
                                                            }

                                                            if (pgldo.status === SGStatusLight.Off) {
                                                                pgldo.status = SGStatusLight.Red
                                                            } else {
                                                                pgldo.status = SGStatusLight.Off
                                                            }
                                                        } else  {
                                                            pgldo.status  = SGStatusLight.Off
                                                            pgldoLabel.text = "Power Good" + pgoodLabelText
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: ocpTriggeredLabel
                                            target: ocpTriggered
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            text: "Short-Circuit\nOCP Triggered"
                                            font.bold: true

                                            SGStatusLight {
                                                height: 40
                                                width: 40
                                                id: ocpTriggered
                                            }
                                        }
                                    }

                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            id: thermalShutdownContainer
                            anchors.fill: parent
                            anchors.bottomMargin: 10

                            Text {
                                id: thermalShutdownText
                                font.bold: true
                                text: "Thermal Shutdown"
                                font.pixelSize: ratioCalc * 20
                                Layout.topMargin: 10
                                color: "#696969"
                                Layout.leftMargin: 20

                            }

                            Rectangle {
                                id: line2
                                Layout.preferredHeight: 2
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: thermalShutdownContainer.width + 10
                                border.color: "lightgray"
                                radius: 2
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: (parent.height - thermalShutdownText.height - line2.height)/4

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: 10
                                    spacing: 10

                                    Rectangle {
                                        id: tsdTriggeredContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: tsdTriggeredLabel
                                            target: tsdTriggered
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            text: "TSD Triggered"
                                            font.bold: true

                                            SGStatusLight {
                                                height: tsdTriggeredContainer.height - tsdTriggeredLabel.contentHeight
                                                id: tsdTriggered
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGButton {
                                            id: resetTSDButton
                                            height: preferredContentHeight * 1.5
                                            width: preferredContentWidth * 1.25
                                            text: "Reset TSD \n Trigger"
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                            hoverEnabled: true
                                            MouseArea {
                                                hoverEnabled: true
                                                anchors.fill: parent
                                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                onClicked: {
                                                    platformInterface.reset_tsd.update()
                                                    estTSDThres.text = ""
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: estTSDThresLabel
                                            target: estTSDThres
                                            text:  "Estimated TSD \nThreshold"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopLeft
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGInfoBox {
                                                id: estTSDThres
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                width: 100 * ratioCalc
                                                unit: "<b>˚C</b>"
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: (parent.height - thermalShutdownText.height - line2.height) * (3/4)

                                RowLayout {
                                    anchors.fill: parent

                                    Rectangle {
                                        id: ldoPowerDissipationContiner
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id:  ldoPowerDissipationLabel
                                            target: ldoPowerDissipation
                                            text: "LDO Power \n Loss"
                                            margin: -5
                                            anchors.centerIn: parent
                                            anchors.verticalCenterOffset: -(contentHeight*0.25)
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier:   ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter

                                            SGCircularGauge {
                                                id: ldoPowerDissipation
                                                minimumValue: 0
                                                maximumValue: 2.75
                                                tickmarkStepSize:0.25
                                                gaugeFillColor1:"green"
                                                gaugeFillColor2:"red"
                                                width: ldoPowerDissipationContiner.width
                                                height: ldoPowerDissipationContiner.height - ldoPowerDissipationLabel.contentHeight
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
                                                unitText: "W"
                                                valueDecimalPlaces: 3
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: boardTempContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id:  boardTempLabel
                                            target: boardTemp
                                            text: "Board \n Temperature"
                                            margin: -5
                                            anchors.centerIn: parent
                                            anchors.verticalCenterOffset: -(contentHeight*0.25)
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier:   ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter

                                            SGCircularGauge {
                                                id: boardTemp
                                                minimumValue: 0
                                                maximumValue: 125
                                                tickmarkStepSize: 25
                                                gaugeFillColor1:"green"
                                                gaugeFillColor2:"red"
                                                width: boardTempContainer.width
                                                height: boardTempContainer.height - boardTempLabel.contentHeight
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
                                                unitText: "˚C"
                                                valueDecimalPlaces: 1
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: appxLDoTempContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id:  appxLDoTempLabel
                                            target: appxLDoTemp
                                            text: "Approximate LDO \n Temperature"
                                            margin: -5
                                            anchors.centerIn: parent
                                            anchors.verticalCenterOffset: -(contentHeight*0.25)
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier:   ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter

                                            SGCircularGauge {
                                                id: appxLDoTemp
                                                minimumValue: 0
                                                maximumValue: 175
                                                tickmarkStepSize:25
                                                gaugeFillColor2:"red"
                                                width: appxLDoTempContainer.width
                                                height: appxLDoTempContainer.height - appxLDoTempLabel.contentHeight
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
                                                unitText: "˚C"
                                                valueDecimalPlaces: 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * (7/12)

                RowLayout {
                    anchors.fill: parent
                    anchors.bottomMargin: 10
                    spacing: 20

                    Rectangle {
                        Layout.preferredWidth: parent.width/1.5
                        Layout.fillHeight: true

                        ColumnLayout {
                            id: setBoardConfigContainer
                            anchors.fill: parent

                            Text {
                                id: bordConfigText
                                font.bold: true
                                text: "Set Board Configuration"
                                font.pixelSize: ratioCalc * 20
                                Layout.topMargin: 10
                                color: "#696969"
                                Layout.leftMargin: 20
                            }

                            Rectangle {
                                id: line3
                                Layout.preferredHeight: 2
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: setBoardConfigContainer.width + 10
                                border.color: "lightgray"
                                radius: 2
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                RowLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        id: setLDOSliderContainer
                                        Layout.preferredWidth: parent.width/2
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: ldoInputVolLabel
                                            target: ldoInputVolSlider
                                            text:"Set LDO Input Voltage"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGSlider {
                                                id:ldoInputVolSlider
                                                width: setLDOSliderContainer.width/1.1
                                                textColor: "black"
                                                stepSize: 0.01
                                                from: 1.6
                                                to: 5.5
                                                live: false
                                                fromText.text: "1.6V"
                                                fromText.fontSizeMultiplier: 0.9
                                                toText.text: "5.5V"
                                                toText.fontSizeMultiplier: 0.9
                                                inputBoxWidth: setLDOSliderContainer.width/6
                                                onUserSet: {
                                                    platformInterface.set_vin_ldo.update(value.toFixed(2))
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: boardInputLabel
                                            target: boardInputComboBox
                                            text: "Upstream Supply Voltage Selection"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.verticalCenter: parent.verticalCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGComboBox {
                                                id: boardInputComboBox
                                                fontSizeMultiplier: ratioCalc * 0.9
                                                model: ["USB 5V", "External", "Off"]
                                                onActivated: {
                                                    if ((ldoInputComboBox.currentIndex === 3) && (currentText !== "Off")) {
                                                        if (root.visible && !warningPopup.opened) {
                                                            popup_message = "The upstream supply voltage option cannot be changed while the LDO input voltage option is set to 'Direct'"
                                                            warningPopup.open()
                                                        }
                                                    }
                                                    platformInterface.select_vin.update(currentText)
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"

                                        SGAlignedLabel {
                                            id: ldoEnableSwitchLabel
                                            target: ldoEnableSwitch
                                            text: "Enable LDO"
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGSwitch {
                                                id: ldoEnableSwitch
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel:   "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                onToggled: {
                                                    if(checked)
                                                        platformInterface.set_ldo_enable.update("on")
                                                    else  platformInterface.set_ldo_enable.update("off")
                                                }
                                            }
                                        }
                                    }
                                }
                            }


                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                RowLayout {
                                    anchors.fill: parent

                                    Rectangle {
                                        id: setLDOOutputVoltageContainer
                                        Layout.preferredWidth: parent.width/2
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: setLDOOutputVoltageLabel
                                            target: setLDOOutputVoltage
                                            text: "Set LDO Output Voltage"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGSlider {
                                                id:setLDOOutputVoltage
                                                width: setLDOOutputVoltageContainer.width/1.1
                                                textColor: "black"
                                                stepSize: 0.01
                                                from: 1.1
                                                to: 4.7
                                                live: false
                                                fromText.text: "1.1V"
                                                toText.text: "4.7V"
                                                fromText.fontSizeMultiplier: 0.9
                                                toText.fontSizeMultiplier: 0.9
                                                inputBoxWidth: setLDOOutputVoltageContainer.width/6
                                                onUserSet: {
                                                    platformInterface.set_vout_ldo.update(value.toFixed(2))
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: ldoInputLabel
                                            target: ldoInputComboBox
                                            text: "LDO Input Voltage Selection"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.verticalCenter: parent.verticalCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGComboBox {
                                                id: ldoInputComboBox
                                                fontSizeMultiplier: ratioCalc
                                                model: ["Bypass", "Buck Regulator", "Off", "Direct"]
                                                onActivated: {
                                                    if (prevVinLDOSel === "Direct") {
                                                        newVinLDOSel = currentText
                                                        if (!warningPopupLDOInput.opened & !((newVinLDOSel === prevVinLDOSel) || (newVinLDOSel === "Off"))) {
                                                            warningPopupLDOInput.open()
                                                        } else {
                                                            if (newVinLDOSel === "Off") {
                                                                platformInterface.select_vin_ldo.update(newVinLDOSel)
                                                            }
                                                            prevVinLDOSel = newVinLDOSel
                                                        }
                                                        console.log("prevVinLDOSel = " + prevVinLDOSel)
                                                        console.log("newVinLDOSel = " + newVinLDOSel)
                                                    } else {
                                                        prevVinLDOSel = currentText
                                                        platformInterface.select_vin_ldo.update(currentText)
                                                        console.log("prevVinLDOSel = " + prevVinLDOSel)
                                                        console.log("newVinLDOSel = " + newVinLDOSel)
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"

                                        SGAlignedLabel {
                                            id: ldoDisableLabel
                                            target: ldoDisable
                                            text: "Disable LDO Output\nVoltage Adjustment"
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGSwitch {
                                                id: ldoDisable
                                                labelsInside: true
                                                checkedLabel: "Yes"
                                                uncheckedLabel:   "No"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                onToggled: {
                                                    if(checked)
                                                        platformInterface.disable_vout_set.update(true)
                                                    else  platformInterface.disable_vout_set.update(false)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                RowLayout {
                                    anchors.fill:parent

                                    Rectangle {
                                        id: setOutputContainer
                                        Layout.preferredWidth: parent.width/2
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: setOutputCurrentLabel
                                            target: setOutputCurrent
                                            text: "Set Onboard Load Current"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGSlider {
                                                id: setOutputCurrent
                                                width: setOutputContainer.width/1.1
                                                textColor: "black"
                                                stepSize: 0.1
                                                from:0
                                                to: 650
                                                live: false
                                                fromText.text: "0mA"
                                                toText.text: "650mA"
                                                fromText.fontSizeMultiplier: 0.9
                                                toText.fontSizeMultiplier: 0.9
                                                inputBoxWidth: setOutputContainer.width/6
                                                onUserSet: platformInterface.set_load.update(value.toFixed(1))
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"

                                        SGAlignedLabel {
                                            id: ldoPackageLabel
                                            target: ldoPackageComboBox
                                            text: "Populated LDO Package"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.verticalCenter: parent.verticalCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGComboBox {
                                                id: ldoPackageComboBox
                                                fontSizeMultiplier: ratioCalc * 0.9
                                                model: ["TSOP5", "WDFN6", "DFNW8"]
                                                onActivated: {
                                                    if(currentIndex === 0)
                                                        platformInterface.select_ldo.update("TSOP5")
                                                    else if(currentIndex === 1)
                                                        platformInterface.select_ldo.update("DFN6")
                                                    else if(currentIndex === 2)
                                                        platformInterface.select_ldo.update("DFN8")
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                RowLayout {
                                    anchors.fill:parent
                                    Rectangle {
                                        Layout.preferredWidth: parent.width/2
                                        Layout.fillHeight: true
                                        RowLayout {
                                            anchors.fill: parent
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                SGAlignedLabel {
                                                    id: loadEnableSwitchLabel
                                                    target: loadEnableSwitch
                                                    text: "Enable Onboard \nLoad"
                                                    alignment: SGAlignedLabel.SideTopLeft
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.top: parent.top
                                                    fontSizeMultiplier: ratioCalc
                                                    font.bold : true

                                                    SGSwitch {
                                                        id: loadEnableSwitch
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel:   "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        onToggled: {
                                                            if(checked)
                                                                platformInterface.set_load_enable.update("on")
                                                            else  platformInterface.set_load_enable.update("off")
                                                        }
                                                    }
                                                }
                                            }


                                            Rectangle {
                                                id:extLoadCheckboxContainer
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                Item {
                                                    id: checkBoxContainer
                                                    anchors.fill: extLoadCheckboxContainer
                                                    MouseArea {
                                                        id: hoverArea2
                                                        anchors { fill: parent }
                                                        hoverEnabled: true
                                                    }
                                                }

                                                Widget09.SGToolTipPopup {
                                                    id: sgToolTipPopup
                                                    showOn: hoverArea2.containsMouse
                                                    arrowOnTop: false
                                                    anchors {
                                                        bottom: extLoadCheckboxContainer.top
                                                        horizontalCenter: extLoadCheckboxContainer.horizontalCenter
                                                    }

                                                    color: "#0bd"   // Default: "#00ccee"
                                                    content: Text {
                                                        text: qsTr("Check this box\nif an external load\nis connected to the\noutput banana plugs.")
                                                        color: "white"
                                                    }
                                                }

                                                SGAlignedLabel {
                                                    id: extLoadCheckboxLabel
                                                    target: extLoadCheckbox
                                                    text: "External Load \nConnected?"
                                                    font.bold : true
                                                    font.italic: true
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    fontSizeMultiplier: ratioCalc
                                                    anchors {
                                                        horizontalCenter: parent.horizontalCenter
                                                        verticalCenter: parent.verticalCenter
                                                        top: parent.top
                                                    }
                                                    margin: -5

                                                    CheckBox {
                                                        id: extLoadCheckbox
                                                        checked: false
                                                        z: 100
                                                        onClicked: {
                                                            if(checked) {
                                                                platformInterface.ext_load_conn.update(true)
                                                            } else {
                                                                platformInterface.ext_load_conn.update(false)
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
                                        color: "transparent"

                                        SGAlignedLabel {
                                            id:vinGoodLabel
                                            target: vinGood
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            text: "VIN Ready" + vinGoodThreshText
                                            font.bold: true

                                            SGStatusLight {
                                                id: vinGood
                                                property var vin_good: platformInterface.int_status.vin_good
                                                height: 40
                                                width: 40
                                                onVin_goodChanged: {
                                                    if(vin_good === true && vinGoodLabel.enabled)
                                                        vinGood.status  = SGStatusLight.Green
                                                    else vinGood.status  = SGStatusLight.Off
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        SGAlignedLabel {
                                            id:vinReadyLabel
                                            target: vinReadyLight
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.horizontalCenterOffset: 20
                                            fontSizeMultiplier: ratioCalc
                                            text: "VIN_LDO Ready\n(Above 1.6V)"
                                            font.bold: true

                                            SGStatusLight {
                                                id: vinReadyLight
                                                height: 40
                                                width: 40
                                                property var vin_ldo_good: platformInterface.int_status.vin_ldo_good
                                                onVin_ldo_goodChanged: {
                                                    if(vin_ldo_good === true)
                                                        vinReadyLight.status  = SGStatusLight.Green
                                                    else vinReadyLight.status  = SGStatusLight.Off
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ColumnLayout {
                                    id: dropoutContainer
                                    anchors.fill: parent

                                    Text {
                                        id: dropoutText
                                        font.bold: true
                                        text: "Dropout"
                                        font.pixelSize: ratioCalc * 20
                                        Layout.topMargin: 10
                                        color: "#696969"
                                        Layout.leftMargin: 20

                                    }

                                    Rectangle {
                                        id: line4
                                        Layout.preferredHeight: 2
                                        Layout.alignment: Qt.AlignCenter
                                        Layout.preferredWidth: dropoutContainer.width + 10
                                        border.color: "lightgray"
                                        radius: 2
                                    }

                                    Rectangle{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        ColumnLayout {
                                            anchors.fill: parent
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                RowLayout {
                                                    anchors.fill: parent
                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        SGAlignedLabel {
                                                            id: ldoInputVoltageLabel
                                                            target: ldoInputVoltage
                                                            text: "LDO Input Voltage \n(VIN_LDO)"
                                                            alignment: SGAlignedLabel.SideTopLeft
                                                            anchors {
                                                                left: parent.left
                                                                leftMargin: 20
                                                                verticalCenter: parent.verticalCenter
                                                            }
                                                            fontSizeMultiplier: ratioCalc
                                                            font.bold : true

                                                            SGInfoBox {
                                                                id: ldoInputVoltage
                                                                unit: "V"
                                                                width: 100* ratioCalc
                                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                boxColor: "lightgrey"
                                                                boxFont.family: Fonts.digitalseven
                                                                unitFont.bold: true
                                                            }
                                                        }
                                                    }

                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true

                                                        SGAlignedLabel {
                                                            id: ldoOutputVoltageLabel
                                                            target: ldoOutputVoltage
                                                            text: "LDO Output Voltage \n(VOUT_LDO)"
                                                            alignment: SGAlignedLabel.SideTopLeft
                                                            anchors {
                                                                left: parent.left
                                                                leftMargin: 20
                                                                verticalCenter: parent.verticalCenter
                                                            }
                                                            fontSizeMultiplier: ratioCalc
                                                            font.bold : true

                                                            SGInfoBox {
                                                                id: ldoOutputVoltage
                                                                unit: "V"
                                                                width: 100* ratioCalc
                                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                boxColor: "lightgrey"
                                                                boxFont.family: Fonts.digitalseven
                                                                unitFont.bold: true
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                RowLayout {
                                                    anchors.fill: parent
                                                    Rectangle {
                                                        id: ldoOutputCurrentContainer
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true

                                                        SGAlignedLabel {
                                                            id: ldoOutputCurrentLabel
                                                            target: ldoOutputCurrent
                                                            text: "LDO Output Current \n(IOUT)"
                                                            alignment: SGAlignedLabel.SideTopLeft
                                                            anchors {
                                                                left: parent.left
                                                                leftMargin: 20
                                                                verticalCenter: parent.verticalCenter
                                                            }
                                                            fontSizeMultiplier: ratioCalc
                                                            font.bold : true

                                                            SGInfoBox {
                                                                id: ldoOutputCurrent
                                                                unit: "mA"
                                                                width: 100* ratioCalc
                                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                boxColor: "lightgrey"
                                                                boxFont.family: Fonts.digitalseven
                                                                unitFont.bold: true

                                                            }
                                                        }
                                                    }

                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true

                                                        SGAlignedLabel {
                                                            id: diffVoltageLabel
                                                            target: diffVoltage
                                                            text: "LDO Voltage\nDrop"
                                                            alignment: SGAlignedLabel.SideTopLeft
                                                            anchors {
                                                                left: parent.left
                                                                leftMargin: 20
                                                                verticalCenter: parent.verticalCenter
                                                            }
                                                            fontSizeMultiplier: ratioCalc
                                                            font.bold : true

                                                            SGInfoBox {
                                                                id: diffVoltage
                                                                unit: "V"
                                                                width: 100* ratioCalc
                                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                boxColor: "lightgrey"
                                                                boxFont.family: Fonts.digitalseven
                                                                unitFont.bold: true
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                SGAlignedLabel {
                                                    id: dropReachedLabel
                                                    target: dropReached
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    anchors.centerIn: parent
                                                    fontSizeMultiplier: ratioCalc
                                                    text: "Dropout Reached"
                                                    font.bold: true

                                                    SGStatusLight {
                                                        height: 40
                                                        width: 40
                                                        id: dropReached
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
        }
    }
}
