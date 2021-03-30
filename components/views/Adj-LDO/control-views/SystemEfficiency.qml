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
    property real ratioCalc: (Screen.width > 1200) ? root.width/1200 : root.width/(1200*(1200/Screen.width))
    property real initialAspectRatio: Screen.width/Screen.height
    property string prevVinLDOSel: ""
    property string newVinLDOSel: ""
    property string pgoodLabelText: "\n(PG_308)"
    anchors.centerIn: parent
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Component.onCompleted: {
        sysEfficiencyPGoodTimer.start()
        Help.registerTarget(systemInputVoltageLabel, "This info box shows the voltage at the input of the buck regulator and bypass load switch (VIN_SB).", 0, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(systemInputCurrentLabel, "This info box shows the input current to the board (current flowing from VIN to VIN_SB).", 1, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(powerOutputgaugeContainer, "This gauge shows the input power to the system consisting of the input buck regulator and LDO. This input power measurement excludes the losses in the input load switches and input current sense resistor.", 2, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(totalSystemEfficiencyContainer, "This gauge shows the total efficiency of the system.", 3, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(buckLDOOutputInputLabel, "This info box shows the output voltage of the buck regulator (LDO input voltage).", 4, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(buckLDOOutputInputCurrentLabel, "This info box shows the output current of the buck regulator (LDO input current).", 5, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoInputPowergaugeContainer, "This gauge shows the input power to the LDO. This gauge will not be accurate when an external load is attached directly to the LDO output via the solder pad.", 6, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(syncBuckEfficiencyContainer, "This gauge shows the efficiency of the input buck regulator", 7, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoSystemOutputVoltageLabel, "This info box shows the output voltage of the LDO (system output voltage).", 8, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoSystemOutputCurrentLabel, "This info box shows the output current of the LDO (system output current) when pulled by either the onboard electronic load or through an external load connected to the output banana plugs. Current pulled by the onboard short-circuit load or an external load attached directly to the LDO output via the solder pad is not measured and will not be shown in this box.", 9, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoOutputPowerContainer, "This gauge shows the output power of the LDO (system output power). This gauge will not be accurate when an external load is attached directly to the LDO output via the solder pad.", 10, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoEfficiencyGaugeContainer, "This gauge shows the efficiency of the LDO.", 11, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(setLDOInputVoltageLabel, "This slider allows you to set the desired input voltage of the LDO when being supplied by the input buck regulator. The value can be set while the input buck regulator is not being used and the voltage will automatically be adjusted as needed whenever the input buck regulator is activated again.", 12, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(setLDOOutputVoltageLabel, "This slider allows you to set the desired output voltage of the LDO. The value can be set while the LDO is disabled. The voltage will automatically be adjusted as needed whenever the LDO is enabled again.", 13, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(setOutputCurrentLabel, "This slider allows you to set the current pulled by the onboard load. The value can be set while the load is disabled and the load current will automatically be adjusted as needed when the load is enabled. The value may need to be reset to the desired level after recovery from an LDO UVLO event.", 14, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(boardInputLabel,"This combo box allows you to choose the main input voltage option (upstream power supply) for the board. The 'External' option uses the input voltage from the input banana plugs. The 'USB 5V' option uses the 5V supply from the Strata USB connector. The 'Off' option disconnects both inputs from VIN and pulls VIN low.", 15, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoPackageLabel, "This combo box allows you to choose the LDO package currently populated on the board if different from the stock LDO package option. See the Platform Content page for more information about using alternate LDO packages with this board.", 16, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoDisableLabel, "This switch disables the LDO output voltage adjustment circuit included on this board. See the Platform Content page for more information on using this feature.", 17, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoInputLabel, "This combo box allows you to choose the input voltage option for the LDO. The 'Bypass' option connects the LDO input directly to VIN_SB through a load switch. The 'Buck Regulator' option allows adjustment of the input voltage to the LDO through an adjustable output voltage buck regulator. The 'Off' option disables both the input buck regulator and bypass load switch, disconnecting the LDO from the input power supply, and pulls VIN_LDO low. The 'Direct' option allows you to power the LDO directly through the VIN_LDO solder pad on the board, bypassing the input stage entirely. WARNING! - when using this option, ensure you do not use the other LDO input voltage options while an external power supply is supplying power to the LDO through the VIN_LDO solder pad. See the Platform Content page for more information about the options for supplying the LDO input voltage.", 18, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(loadEnableSwitchLabel, "This switch enables the onboard load.", 19, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(extLoadCheckboxLabel, "Check this box if an external load is connected to the output banana plugs. During normal onboard load operation, a loop is run when the current level is set within the LDO's nominal output current range to minimize the load current error, and this loop should not be run if an external load is attached.", 20, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(ldoEnableSwitchLabel, "This switch enables the LDO.", 21, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(vinGoodLabel, "This indicator will be green when:\na.) VIN is greater than 2.5V when the input buck regulator is enabled\nb.) VIN is greater than 1.5V when it is disabled.", 22, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(vinReadyLabel, "This indicator will be green when the LDO input voltage is greater than the LDO input UVLO threshold of 1.6V.", 23, "AdjLDOSystemEfficiencyHelp")
        Help.registerTarget(pgldoLabel, "This indicator will be green when the LDO power good signal is high. Since the TSOP-5 package has no PG output, if the TSOP-5 LDO package is being used, the indicator will be green when the PG_308 signal from the NCP308 used to monitor the LDO output voltage is high. During an LDO current limit or TSD event, this indicator will flash red.", 24, "AdjLDOSystemEfficiencyHelp")
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

    property string vinGoodThreshText: ""

    property var ext_load_checked: platformInterface.ext_load_status.value
    onExt_load_checkedChanged: {
        if (ext_load_checked === true) extLoadCheckbox.checked = true
        else extLoadCheckbox.checked = false
    }

    property var telemetry_notification: platformInterface.telemetry
    onTelemetry_notificationChanged: {
        inputPowerGauge.value = telemetry_notification.pin_ldo //LDO input power
        syncBuckEfficiencyGauge.value = telemetry_notification.eff_sb //Sync buck regulator input power
        ldoEfficiencyGauge.value = telemetry_notification.eff_ldo //LDO efficiency
        totalSystemEfficiencyGauge.value = telemetry_notification.eff_tot
        systemInputPowerGauge.value = telemetry_notification.pin_sb
        ldoOutputPowerGauge.value  = telemetry_notification.pout_ldo
        buckLDOInputVoltage.text = telemetry_notification.vin_ldo
        systemInputVoltage.text = telemetry_notification.vin_sb
        systemInputCurrent.text = telemetry_notification.iin
        buckLDOOutputCurrent.text = telemetry_notification.iin_ldo
        ldoSystemInputVoltage.text = telemetry_notification.vout_ldo
        ldoSystemInputCurrent.text = telemetry_notification.iout
    }

    property var control_states: platformInterface.control_states
    onControl_statesChanged: {
        if(control_states.vin_sel === "USB 5V")  {
            if (setOutputCurrentSlider.value > 300) {
                setOutputCurrentSlider.value = 300
            }
            setOutputCurrentSlider.to = 300
            setOutputCurrentSlider.toText.text = "300mA"
            boardInputComboBox.currentIndex = 0
        }
        else if(control_states.vin_sel === "External") {
            setOutputCurrentSlider.to = 650
            setOutputCurrentSlider.toText.text = "650mA"
            boardInputComboBox.currentIndex = 1
        }
        else if (control_states.vin_sel === "Off") {
            setOutputCurrentSlider.to = 650
            setOutputCurrentSlider.toText.text = "650mA"
            boardInputComboBox.currentIndex = 2
        }

        if(control_states.vin_ldo_sel === "Bypass") {
            vinGoodThreshText = "\n (Above 1.5V)"
            systemInputPowerLabel.opacity = 0.5
            systemInputPowerLabel.enabled = false
            totalSystemEfficiencyLabel.opacity = 0.5
            totalSystemEfficiencyLabel.enabled = false
            inputPowerLabel.opacity = 1
            inputPowerLabel.enabled = true
            syncBuckEfficiencyLabel.opacity = 0.5
            syncBuckEfficiencyLabel.enabled = false
            ldoInputComboBox.currentIndex = 0
        }
        else if (control_states.vin_ldo_sel === "Buck Regulator") {
            vinGoodThreshText = "\n (Above 2.5V)"
            systemInputPowerLabel.opacity = 1
            systemInputPowerLabel.enabled = true
            totalSystemEfficiencyLabel.opacity = 1
            totalSystemEfficiencyLabel.enabled = true
            inputPowerLabel.opacity = 1
            inputPowerLabel.enabled = true
            syncBuckEfficiencyLabel.opacity = 1
            syncBuckEfficiencyLabel.enabled = true
            ldoInputComboBox.currentIndex = 1
        }
        else if (control_states.vin_ldo_sel === "Off") {
            vinGoodThreshText = "\n (Above 1.5V)"
            systemInputPowerLabel.opacity = 1
            systemInputPowerLabel.enabled = true
            totalSystemEfficiencyLabel.opacity = 1
            totalSystemEfficiencyLabel.enabled = true
            inputPowerLabel.opacity = 1
            inputPowerLabel.enabled = true
            syncBuckEfficiencyLabel.opacity = 1
            syncBuckEfficiencyLabel.enabled = true
            ldoInputComboBox.currentIndex = 2
        }
        else if (control_states.vin_ldo_sel === "Direct") {
            vinGoodThreshText = "\n (Above 1.5V)"
            systemInputPowerLabel.opacity = 0.5
            systemInputPowerLabel.enabled = false
            totalSystemEfficiencyLabel.opacity = 0.5
            totalSystemEfficiencyLabel.enabled = false
            inputPowerLabel.opacity = 1
            inputPowerLabel.enabled = true
            syncBuckEfficiencyLabel.opacity = 0.5
            syncBuckEfficiencyLabel.enabled = false
            ldoInputComboBox.currentIndex = 3
        }

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

        ldoInputVolSlider.value = control_states.vin_ldo_set
        setLDOOutputVoltage.value = control_states.vout_ldo_set
        setOutputCurrentSlider.value = control_states.load_set

        if(control_states.ldo_en === "on")
            ldoEnableSwitch.checked = true
        else ldoEnableSwitch.checked = false

        if(control_states.load_en === "on")
            loadEnableSwitch.checked = true
        else loadEnableSwitch.checked = false

        if (control_states.vout_set_disabled === true) {
            setLDOOutputVoltageLabel.opacity = 0.5
            setLDOOutputVoltageLabel.enabled = false
            ldoDisable.checked = true
        } else {
            setLDOOutputVoltageLabel.opacity = 1
            setLDOOutputVoltageLabel.enabled = true
            ldoDisable.checked = false
        }
    }

    property string popup_message: ""
    property var config_running: platformInterface.config_running.value
    onConfig_runningChanged: {
        if(config_running === true) {
            popup_message = "A function to configure the previously selected board settings is already running. Please wait and try applying the settings again."
            if (root.visible && !warningPopup.opened) {
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

    RowLayout {
        id: systemEfficiencyView
        anchors.fill: parent
        anchors.margins: 10
        Rectangle {
            id: column1Container
            Layout.fillHeight: true
            Layout.preferredWidth: (parent.width - middleLine.width) * (7/12) - 10
            Layout.leftMargin: 10
            ColumnLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent
                        Text {
                            id: inputConfigurationText
                            font.bold: true
                            text: "System Input"
                            font.pixelSize: ratioCalc * 20
                            color: "#696969"
                            Layout.leftMargin: 20
                        }

                        Rectangle {
                            id: line
                            Layout.preferredHeight: 1.5
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: parent.width + 7
                            border.color: "lightgray"
                            radius: 2
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                ColumnLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        id: systemInputVoltageContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: systemInputVoltageLabel
                                            target: systemInputVoltage
                                            text: "Voltage"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            SGInfoBox {
                                                id: systemInputVoltage
                                                unit: "V"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                width: 120
                                                height: 40
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                unitFont.bold: true
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id:systemInputCurrentContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: systemInputCurrentLabel
                                            target: systemInputCurrent
                                            text: "Current"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            SGInfoBox {
                                                id: systemInputCurrent
                                                unit: "mA"
                                                width: 120
                                                height: 40
                                                fontSizeMultiplier:  ratioCalc * 1.2
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                unitFont.bold: true
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: systemPowerContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        id: powerOutputgaugeContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: systemInputPowerLabel
                                            target: systemInputPowerGauge
                                            text: "System \n Input Power"
                                            margin: -5
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc * 0.95
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: systemInputPowerGauge
                                                minimumValue: 0
                                                maximumValue:  3.5
                                                tickmarkStepSize: 0.5
                                                gaugeFillColor1:"green"
                                                height: powerOutputgaugeContainer.height - systemInputPowerLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "W"
                                                valueDecimalPlaces: 3
                                                unitTextFontSizeMultiplier: ratioCalc * 2
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: totalSystemEfficiencyContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "white"
                                        SGAlignedLabel {
                                            id: totalSystemEfficiencyLabel
                                            target:totalSystemEfficiencyGauge
                                            text: "Total System\nEfficiency"
                                            margin: -5
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc * 0.95
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id:totalSystemEfficiencyGauge
                                                minimumValue: 0
                                                maximumValue:  100
                                                tickmarkStepSize: 10
                                                gaugeFillColor1:"green"
                                                height: totalSystemEfficiencyContainer.height - totalSystemEfficiencyLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "%"
                                                valueDecimalPlaces: 1
                                                unitTextFontSizeMultiplier: ratioCalc * 2


                                            }
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
                    ColumnLayout {
                        anchors.fill: parent
                        Text {
                            id: buckLDOOutputInputText
                            font.bold: true
                            text: "Buck Output/LDO Input"
                            font.pixelSize: ratioCalc * 20
                            color: "#696969"
                            Layout.leftMargin: 20
                        }
                        Rectangle {
                            id: line2
                            Layout.preferredHeight: 1.5
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: parent.width + 7
                            border.color: "lightgray"
                            radius: 2
                        }
                        RowLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                ColumnLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        id: buckLDOOutputInputContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: buckLDOOutputInputLabel
                                            target: buckLDOInputVoltage
                                            text: "Voltage"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            SGInfoBox {
                                                id: buckLDOInputVoltage
                                                unit: "V"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                width: 120
                                                height: 40
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                unitFont.bold: true
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id:buckLDOOutputInputCurrentContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: buckLDOOutputInputCurrentLabel
                                            target: buckLDOOutputCurrent
                                            text: "Current"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            SGInfoBox {
                                                id: buckLDOOutputCurrent
                                                unit: "mA"
                                                width: 120
                                                height: 40
                                                fontSizeMultiplier:  ratioCalc * 1.2
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
                                color: "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        id: ldoInputPowergaugeContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: inputPowerLabel
                                            target:inputPowerGauge
                                            text: "LDO\nInput Power"
                                            margin: -5
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc * 0.95
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: inputPowerGauge
                                                minimumValue: 0
                                                maximumValue:  3.5
                                                tickmarkStepSize: 0.5
                                                gaugeFillColor1:"green"
                                                height: ldoInputPowergaugeContainer.height - inputPowerLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "W"
                                                valueDecimalPlaces: 3
                                                unitTextFontSizeMultiplier: ratioCalc * 2
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id:syncBuckEfficiencyContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: syncBuckEfficiencyLabel
                                            target:syncBuckEfficiencyGauge
                                            text: "Buck Regulator\nEfficiency"
                                            margin: -5
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc * 0.95
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: syncBuckEfficiencyGauge
                                                minimumValue: 0
                                                maximumValue:  100
                                                tickmarkStepSize: 10
                                                gaugeFillColor1:"green"
                                                height: syncBuckEfficiencyContainer.height - syncBuckEfficiencyLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "%"
                                                valueDecimalPlaces: 1
                                                unitTextFontSizeMultiplier: ratioCalc * 2
                                            }
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
                    ColumnLayout {
                        anchors.fill:parent
                        Text {
                            id: ldoSystemOutputText
                            font.bold: true
                            text: "LDO/System Output"
                            font.pixelSize: ratioCalc * 20
                            color: "#696969"
                            Layout.leftMargin: 20
                        }

                        Rectangle {
                            id: line3
                            Layout.preferredHeight: 1.5
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: parent.width + 7
                            border.color: "lightgray"
                            radius: 2
                        }

                        RowLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                ColumnLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        id: ldoSystemOutputVoltageContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: ldoSystemOutputVoltageLabel
                                            target: ldoSystemInputVoltage
                                            text: "Voltage"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            SGInfoBox {
                                                id: ldoSystemInputVoltage
                                                unit: "V"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                width: 120
                                                height: 40
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                unitFont.bold: true
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id:ldoSystemOutputCurrentContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: ldoSystemOutputCurrentLabel
                                            target: ldoSystemInputCurrent
                                            text: "Current"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGInfoBox {
                                                id: ldoSystemInputCurrent
                                                unit: "mA"
                                                width: 120
                                                height: 40
                                                fontSizeMultiplier:  ratioCalc * 1.2
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
                                color: "transparent"
                                RowLayout {
                                    anchors.fill:parent
                                    Rectangle {
                                        id:ldoOutputPowerContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: ldoOutputPowerLabel
                                            target:ldoOutputPowerGauge
                                            text: "LDO \n Output Power"
                                            margin: -5
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc * 0.95
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: ldoOutputPowerGauge
                                                minimumValue: 0
                                                maximumValue:  3.5
                                                tickmarkStepSize: 0.5
                                                gaugeFillColor1:"green"
                                                height: ldoOutputPowerContainer.height - ldoOutputPowerLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "W"
                                                valueDecimalPlaces: 3
                                                unitTextFontSizeMultiplier: ratioCalc * 2
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: ldoEfficiencyGaugeContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: ldoEfficiencyLabel
                                            target:ldoEfficiencyGauge
                                            text: "LDO \n Efficiency"
                                            margin: -5
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc * 0.95
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: ldoEfficiencyGauge
                                                minimumValue: 0
                                                maximumValue:  100
                                                tickmarkStepSize: 10
                                                gaugeFillColor1:"green"
                                                height: ldoEfficiencyGaugeContainer.height - ldoEfficiencyLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "%"
                                                valueDecimalPlaces: 1
                                                unitTextFontSizeMultiplier: ratioCalc * 2
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

        Rectangle {
            id: middleLine
            Layout.preferredHeight: parent.height
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: 1.5
            //Layout.leftMargin: 5
            border.color: "lightgray"
            radius: 2
        }

        Rectangle {
            id: column2Container
            Layout.fillHeight: true
            Layout.preferredWidth: (parent.width - middleLine.width) * (5/12) - 10 - systemEfficiencyView.anchors.margins/2
            Layout.rightMargin: 10
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    id: noteMessage
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: parent.height * (1/12)

                    Rectangle {
                        id: noteBox
                        color: "white"
                        anchors.fill: parent

                        Text {
                            id: noteText
                            anchors.centerIn: noteBox
                            text: "This page allows you to evaluate the overall efficiency of an\n" +
                                  "input buck regulator power stage post-regulated by an LDO\n" +
                                  "using the NCV6324 buck regulator included on this evaluation board."
                            font.bold: true
                            font.pixelSize:  ratioCalc * 12
                            color: "black"
                            horizontalAlignment: Text.AlignJustify
                            anchors {
                                fill: parent
                                topMargin: 5
                                bottomMargin: 5
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: parent.height * (1/6)
                    Layout.fillWidth: true
                    Image {
                        id: blockDiagram
                        source: "images/SystemEfficiencyBD.png"
                        fillMode: Image.PreserveAspectFit
                        anchors.fill: parent
                        anchors.margins: 5
                    }
                }

                Rectangle {
                    Layout.preferredHeight: parent.height * 0.75
                    Layout.fillWidth: true
                    color: "transparent"

                    ColumnLayout {
                        id: setBoardConfigContainer
                        anchors.fill: parent
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        //spacing: 10

                        Text {
                            id: setBoardConfigurationText
                            font.bold: true
                            text: "Set Board Configuration"
                            font.pixelSize: ratioCalc * 20
                            color: "#696969"
                            Layout.leftMargin: 20
                        }

                        Rectangle {
                            id: line4
                            Layout.preferredHeight: 1.5
                            Layout.preferredWidth: column2Container.width
                            border.color: "lightgray"
                            radius: 2
                        }

                        Rectangle {
                            id:setLDOInputVoltageContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            color: "transparent"

                            SGAlignedLabel {
                                id: setLDOInputVoltageLabel
                                target: ldoInputVolSlider
                                text: "Set LDO Input Voltage"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.centerIn: parent

                                SGSlider{
                                    id: ldoInputVolSlider
                                    width: setLDOInputVoltageContainer.width - 10
                                    from: 0.6
                                    to:  5
                                    fromText.text: "1.5V"
                                    toText.text: "5V"
                                    fromText.fontSizeMultiplier: 0.9
                                    toText.fontSizeMultiplier: 0.9
                                    stepSize: 0.01
                                    live: false
                                    // fontSizeMultiplier: ratioCalc * 1.1
                                    inputBoxWidth: setLDOInputVoltageContainer.width/6
                                    onUserSet: {
                                        platformInterface.set_vin_ldo.update(value.toFixed(2))
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id:setLDOOutputVoltageContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            color: "transparent"

                            SGAlignedLabel {
                                id: setLDOOutputVoltageLabel
                                target: setLDOOutputVoltage
                                text: "Set LDO Output Voltage"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.centerIn: parent

                                SGSlider{
                                    id: setLDOOutputVoltage
                                    width: setLDOOutputVoltageContainer.width - 10

                                    from: 1.1
                                    to:  5
                                    fromText.text: "1.1V"
                                    toText.text: "5V"
                                    fromText.fontSizeMultiplier: 0.9
                                    toText.fontSizeMultiplier: 0.9
                                    stepSize: 0.01
                                    live: false
                                    inputBoxWidth: setLDOOutputVoltageContainer.width/6
                                    onUserSet: {
                                        platformInterface.set_vout_ldo.update(value.toFixed(2))
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: setOutputCurrentContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            color: "transparent"

                            SGAlignedLabel {
                                id: setOutputCurrentLabel
                                target: setOutputCurrentSlider
                                text: "Set Onboard Load Current"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.centerIn: parent

                                SGSlider{
                                    id: setOutputCurrentSlider
                                    width: setOutputCurrentContainer.width - 10
                                    from: 0
                                    to:  650
                                    live: false
                                    fromText.text: "0mA"
                                    toText.text: "650mA"
                                    fromText.fontSizeMultiplier: 0.9
                                    toText.fontSizeMultiplier: 0.9
                                    stepSize: 0.1
                                    inputBoxWidth: setOutputCurrentContainer.width/6
                                    onUserSet: platformInterface.set_load.update(value.toFixed(1))

                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: parent.height/2
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            color: "white"

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
                                                id: boardInputLabel
                                                target: boardInputComboBox
                                                text: "Upstream Supply\nVoltage Selection"
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
                                                id: ldoPackageLabel
                                                target: ldoPackageComboBox
                                                text: "Populated LDO\nPackage"
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
                                        anchors.fill: parent

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: ldoInputLabel
                                                target: ldoInputComboBox
                                                text: "LDO Input\nVoltage Selection"
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
                                            Layout.preferredWidth: parent.width/1.5
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
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        anchors.horizontalCenterOffset: -10
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
                                                    color: "transparent"

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
                                                            //horizontalCenterOffset: - 40
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
                                                        margin: -5
                                                        font.bold : true
                                                        font.italic: true
                                                        alignment: SGAlignedLabel.SideTopCenter
                                                        fontSizeMultiplier: ratioCalc
                                                        anchors.centerIn: parent

                                                        CheckBox {
                                                            id: extLoadCheckbox
                                                            checked: false
                                                            z:1

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
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    RowLayout{
                                        anchors.fill:parent

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
                                                    height: 40
                                                    width: 40
                                                    property var vin_good: platformInterface.int_status.vin_good
                                                    onVin_goodChanged: {
                                                        if(vin_good === true && vinGoodLabel.enabled)
                                                            vinGood.status  = SGStatusLight.Green
                                                        else vinGood.status  = SGStatusLight.Off
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            color: "transparent"
                                            SGAlignedLabel {
                                                id:vinReadyLabel
                                                target: vinReadyLight
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc
                                                text: "VIN_LDO Ready \n (Above 1.6V)"
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
                                                        id: sysEfficiencyPGoodTimer
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
                                                                    if(advanced.visible !== true) {
                                                                        protectionDropoutViewBadge.opacity = 1.0
                                                                    }
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
