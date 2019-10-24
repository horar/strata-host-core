import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidget09

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: controlNavigation

    anchors.fill: parent

    property real minContentHeight: 688
    property real minContentWidth: 1024-rightBarWidth
    property real rightBarWidth: 80
    property real factor: Math.min(controlNavigation.height/minContentHeight,(controlNavigation.width-rightBarWidth)/minContentWidth)
    property real vFactor: Math.max(1,height/minContentHeight)
    property real hFactor: Math.max(1,(width-rightBarWidth)/minContentWidth)

    property var telemetryNotitemperature: platformInterface.telemetry.temperature
    onTelemetryNotitemperatureChanged: {
        boardTemp.value = telemetryNotitemperature
    }

    property var telemetryVCC: platformInterface.telemetry.vcc
    onTelemetryVCCChanged: {
        vccBox.text = telemetryVCC
    }

    property var telemetryVIN: platformInterface.telemetry.vin
    onTelemetryVINChanged: {
        vinesBox.text = telemetryVIN
    }


    property var telemetryVOUT: platformInterface.telemetry.vout
    onTelemetryVOUTChanged: {
        voutBox.text = telemetryVOUT
    }

    property var telemetryIIN: platformInterface.telemetry.iin
    onTelemetryIINChanged: {
        currentBox.text = telemetryIIN
    }

    property var telemetryVDROP: platformInterface.telemetry.vdrop
    onTelemetryVDROPChanged: {
        rdsVoltageDrop.value = parseFloat(telemetryVDROP)
    }

    property var telemetryPLOSS: platformInterface.telemetry.ploss
    onTelemetryPLOSSChanged: {
        powerLoss.value  = parseFloat(telemetryPLOSS)
    }




    // Notifications
    //    property var control_states: platformInterface.control_states

    property var control_states_enable: platformInterface.control_states.enable
    onControl_states_enableChanged: {
        if(control_states_enable === true) {
            enableSW.checked = true
            slewRateLabel.opacity = 0.5
            slewRateLabel.enabled = false
            vccVoltageSWLabel.opacity = 0.5
            vccVoltageSW.enabled= false
            vccVoltageSW.opacity  = 0.9

        }
        else {
            enableSW.checked = false
            slewRateLabel.opacity = 1.0
            slewRateLabel.enabled = true
            vccVoltageSWLabel.opacity = 1.0
            vccVoltageSWLabel.enabled = true
            vccVoltageSW.opacity  = 1.0
            vccVoltageSW.enabled= true

        }
    }

    property var control_states_slew_rate: platformInterface.control_states.slew_rate
    onControl_states_slew_rateChanged: {
        slewRate.currentIndex = slewRate.model.indexOf(control_states_slew_rate)
    }

    //    property var control_states_sc_en: platformInterface.control_states.sc_en
    //    onControl_states_sc_enChanged: {
    //        if(control_states_sc_en === true) {
    //            shortCircuitSW.checked = true
    //        }
    //        else shortCircuitSW.checked = false

    //        //  shortCircuitSW.checked = control_states_sc_en
    //    }

    property var control_states_vcc_sel: platformInterface.control_states.vcc_sel
    onControl_states_vcc_selChanged: {
        vccVoltageSW.checked = control_states_vcc_sel === "5"
    }


    // property var telemetryNoti: platformInterface.telemetry
    property bool underVoltageNoti: platformInterface.int_vin_lw_th.value
    property bool overVoltageNoti: platformInterface.int_vin_up_th.value
    property bool powerGoodNoti: platformInterface.int_pg.value
    property bool osAlertNoti: platformInterface.int_os_alert.value




    Component.onCompleted: {
        platformInterface.get_all_states.update()
        Help.registerTarget(enableSWLabel, "This switch enables or disables the ecoSWITCH.", 0, "ecoSWITCHHelp")
        Help.registerTarget(shortCircuitSWLabel, "This button triggers a short from the output voltage to ground for 10 ms.", 1, "ecoSWITCHHelp")
        Help.registerTarget(vccVoltageSWLabel, "This switch toggles the ecoSWITCH VCC between 3.3V and USB 5V.", 2, "ecoSWITCHHelp")
        Help.registerTarget(slewRateLabel, "This drop-down box selects between four programmable output voltage slew rates when the ecoSWITCH turns on.", 3, "ecoSWITCHHelp")
        Help.registerTarget(currentBoxLabel, "This info box shows the current through the ecoSWITCH.", 4, "ecoSWITCHHelp")
        Help.registerTarget(vinesBoxLabel, "This info box shows the input voltage of the ecoSWITCH.", 5, "ecoSWITCHHelp")
        Help.registerTarget(vccBoxLabel, "This info box shows the ecoSWITCH VCC voltage.", 6, "ecoSWITCHHelp")
        Help.registerTarget(voutBoxLabel, "This info box shows the output voltage of the ecoSWITCH.", 7, "ecoSWITCHHelp")
        Help.registerTarget(powerGoodLabel, "This LED is green when the ecoSWITCH PG signal is high indicating that the ecoSWITCH's internal MOSFET is enabled. The LED will turn off when the ecoSWITCH is disabled or during an OCP, input UVLO, or thermal shutdown event.", 8, "ecoSWITCHHelp")
        Help.registerTarget(underVoltageLabel, "This LED is red when the input voltage monitor (NCP308) detects an input voltage less than 0.5V.", 9, "ecoSWITCHHelp")
        Help.registerTarget(overVoltageLabel, "This LED is red when the input voltage monitor (NCP308) detects an input voltage greater than approximately 13.5V.", 11, "ecoSWITCHHelp")
        Help.registerTarget(osAlertLabel, "This LED is red when the onboard temperature sensor (NCT375) detects a board temperature near the ecoSWITCH greater than 80 degrees Celsius.", 10, "ecoSWITCHHelp")
        Help.registerTarget(boardTempLabel, "This gauge monitors the board temperature near the ecoSWITCH in degrees Celsius.", 12, "ecoSWITCHHelp")
        Help.registerTarget(rdsVoltageDropLabel, "This gauge monitors the voltage drop across the ecoSWITCH when enabled and Power Good is high.", 13, "ecoSWITCHHelp")
        Help.registerTarget(powerLossLabel, "This gauge monitors the power loss in the ecoSWITCH when enabled and Power Good is high.", 14, "ecoSWITCHHelp")
    }

    //    onControl_statesChanged: {
    //        enableSW.checked = control_states.enable
    //        shortCircuitSW.checked = control_states.sc_en
    //        vccVoltageSW.checked = control_states.vcc_sel === "5"
    //        slewRate.currentIndex = slewRate.model.indexOf(control_states.slew_rate)
    //    }




    onUnderVoltageNotiChanged: underVoltage.status = underVoltageNoti ? SGStatusLight.Red : SGStatusLight.Off
    onOverVoltageNotiChanged: overVoltage.status = overVoltageNoti ? SGStatusLight.Red : SGStatusLight.Off
    onPowerGoodNotiChanged: powerGood.status = powerGoodNoti ? SGStatusLight.Green : SGStatusLight.Off
    onOsAlertNotiChanged: osAlert.status = osAlertNoti ? SGStatusLight.Red : SGStatusLight.Off



    PlatformInterface {
        id: platformInterface
    }

    Rectangle {
        id: content
        anchors {
            top: parent.top
            topMargin: 10
            bottom: parent.bottom
            left: parent.left
            leftMargin: 20
            right: rightMenu.left
        }

        Popup{
            id: warningPopupCheckEnable
            width: content.width/1.7
            height: content.height/3
            anchors.centerIn: parent
            modal: true
            focus: true
            closePolicy:Popup.NoAutoClose
            background: Rectangle{
                id: warningContainerFoCheckBox
                width: warningPopupCheckEnable.width
                height: warningPopupCheckEnable.height
                color: "white"
                border.color: "black"
                border.width: 4
                radius: 10
            }


            Rectangle {
                id: warningBoxForCheckEnable
                color: "transparent"
                anchors {
                    top: parent.top
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                width: warningContainer.width - 50
                height: warningContainer.height - 50

                Rectangle {
                    id:warningLabelForCheckEnable
                    width: warningBox.width - 100
                    height: parent.height/5
                    color:"red"
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        //topMargin: 5
                        top:parent.top

                    }

                    Text {
                        id: warningLabelTextForCheckEnable
                        anchors.centerIn: warningLabelForCheckEnable
                        text: "<b>WARNING</b>"
                        font.pixelSize: factor * 15
                        color: "white"
                    }

                    Text {
                        id: warningIconLeft
                        anchors {
                            right: warningLabelTextForCheckEnable.left
                            verticalCenter: warningLabelTextForCheckEnable.verticalCenter
                            rightMargin: 10
                        }
                        text: "\ue80e"
                        font.family: Fonts.sgicons
                        font.pixelSize: (parent.width + parent.height)/25
                        color: "white"
                    }

                    Text {
                        id: warningIconRight
                        anchors {
                            left: warningLabelTextForCheckEnable.right
                            verticalCenter: warningLabelTextForCheckEnable.verticalCenter
                            leftMargin: 10
                        }
                        text: "\ue80e"
                        font.family: Fonts.sgicons
                        font.pixelSize: (parent.width + parent.height)/25
                        color: "white"
                    }

                }

                Rectangle {
                    id: messageContainerForCheckEnable
                    anchors {
                        top: warningLabelForCheckEnable.bottom
                        topMargin: 10
                        centerIn:  parent.Center
                    }
                    color: "transparent"
                    width: parent.width
                    height: parent.height - warningLabelForCheckEnable.height - selectionContainer.height
                    Text {
                        id: warningTextForCheckEnable

                        anchors.fill:parent
                        property var vin_popup: platformInterface.i_lim_popup.vin
                        property string vin_text
                        onVin_popupChanged: {
                            vin_text = vin_popup
                        }

                        property var i_lim_popup: platformInterface.i_lim_popup.i_lim
                        property string i_lim_text
                        onI_lim_popupChanged: {
                            i_lim_text = i_lim_popup
                        }

                        property string slew_rate: "1.00"
                        property var slew_rate_poppup: platformInterface.i_lim_popup.slew_rate
                        onSlew_rate_poppupChanged: {
                            slew_rate = slew_rate_poppup
                        }

                        //<current slew rate setting here>,
                        text: {
                            "Due to potentially damaging in rush current during startup, for the current input voltage of " + vin_text + " V, slew rate setting of " + slew_rate + ", and default load capacitance of 10 uF, the maximum load current pulled at startup is recommended to be less than " + i_lim_text + " A. This value must be further derated for any additional load capacitance. Refer to the Platform Content page for more information. Exceeding this recommended current value could result in catastrophic device failure and a potential fire hazard. Click OK to override enable warning for ecoSWITCH"
                        }
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        width: parent.width


                        font.bold: true
                        font.pixelSize: factor * 15
                    }
                }

                Rectangle {
                    id: selectionContainerForCheckpop
                    width: parent.width
                    height: parent.height/4.5
                    anchors{
                        top: messageContainerForCheckEnable.bottom
                        //topMargin: 10
                    }
                    color: "transparent"

                    Rectangle {
                        id: okButtonForCheckpop
                        width: parent.width/2
                        height:parent.height
                        anchors.centerIn: parent
                        color: "transparent"


                        SGButton {
                            anchors.centerIn: parent
                            text: "OK"
                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                            roundedLeft: true
                            roundedRight: true
                            onClicked: {
                                warningPopupCheckEnable.close()
                            }
                        }
                    }
                }
            }
        }

        Popup{
            id: warningPopup
            width: content.width/1.7
            height: content.height/3
            anchors.centerIn: parent
            modal: true
            focus: true
            closePolicy:Popup.NoAutoClose
            background: Rectangle{
                id: warningContainer
                width: warningPopup.width
                height: warningPopup.height
                color: "white"
                border.color: "black"
                border.width: 4
                radius: 10
            }

            Rectangle {
                id: warningBox
                color: "transparent"
                anchors {
                    top: parent.top
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }

                width: warningContainer.width - 50
                height: warningContainer.height - 50

                Rectangle {
                    id:warningLabel
                    width: warningBox.width - 100
                    height: parent.height/5
                    color:"red"
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        //topMargin: 5
                        top:parent.top

                    }

                    Text {
                        id: warningLabelText
                        anchors.centerIn: warningLabel
                        text: "<b>WARNING</b>"
                        font.pixelSize: factor * 15
                        color: "white"
                    }

                    Text {
                        id: warningIcon1
                        anchors {
                            right: warningLabelText.left
                            verticalCenter: warningLabelText.verticalCenter
                            rightMargin: 10
                        }
                        text: "\ue80e"
                        font.family: Fonts.sgicons
                        font.pixelSize: (parent.width + parent.height)/25
                        color: "white"
                    }

                    Text {
                        id: warningIcon2
                        anchors {
                            left: warningLabelText.right
                            verticalCenter: warningLabelText.verticalCenter
                            leftMargin: 10
                        }
                        text: "\ue80e"
                        font.family: Fonts.sgicons
                        font.pixelSize: (parent.width + parent.height)/25
                        color: "white"
                    }
                }

                Rectangle {
                    id: messageContainer
                    anchors {
                        top: warningLabel.bottom
                        topMargin: 5
                    }
                    color: "transparent"
                    width: parent.width
                    height: parent.height - warningLabel.height - selectionContainer.height
                    Text {
                        id: warningText

                        anchors.fill:parent
                        property var vin_popup: platformInterface.i_lim_popup.vin
                        property string vin_text
                        onVin_popupChanged: {
                            vin_text = vin_popup
                        }

                        property var i_lim_popup: platformInterface.i_lim_popup.i_lim
                        property string i_lim_text
                        onI_lim_popupChanged: {
                            i_lim_text = i_lim_popup
                        }

                        property string slew_rate: "1.00"
                        property var slew_rate_poppup: platformInterface.i_lim_popup.slew_rate
                        onSlew_rate_poppupChanged: {
                            slew_rate = slew_rate_poppup
                        }

                        //<current slew rate setting here>,
                        text: {
                            "Due to potentially damaging in rush current during startup, for the current input voltage of " + vin_text + " V, slew rate setting of " + slew_rate + ", and default load capacitance of 10 uF, the maximum load current pulled at startup is recommended to be less than " + i_lim_text + " A. This value must be further derated for any additional load capacitance. Refer to the Platform Content page for more information. Exceeding this recommended current value could result in catastrophic device failure and a potential fire hazard. Click OK to proceed with enabling the ecoSWITCH or Cancel to abort."
                        }
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        width: parent.width

                        font.bold: true
                        font.pixelSize: factor * 15
                    }
                }

                Rectangle {
                    id: selectionContainer
                    width: parent.width
                    height: parent.height/5
                    anchors{
                        top: messageContainer.bottom
                        topMargin: 5
                    }
                    color: "transparent"

                    Rectangle {
                        id: okButton
                        width: parent.width/2
                        height:parent.height
                        color: "transparent"

                        SGButton {
                            anchors.centerIn: parent
                            text: "OK"
                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                            roundedLeft: true
                            roundedRight: true
                            onClicked: {
                                platformInterface.set_enable.update("on")
                                slewRateLabel.opacity = 0.5
                                slewRateLabel.enabled = false
                                vccVoltageSWLabel.opacity = 0.5
                                vccVoltageSWLabel.enabled = false
                                vccVoltageSW.opacity  = 0.9
                                warningPopup.close()
                            }
                        }
                    }
                    Rectangle {
                        id: cancelButton
                        width: parent.width/2
                        height:parent.height
                        anchors.left: okButton.right
                        color: "transparent"


                        SGButton {
                            anchors.centerIn: parent
                            text: "Cancel"
                            roundedLeft: true
                            roundedRight: true
                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                            onClicked: {
                                platformInterface.set_enable.update("off")
                                slewRateLabel.opacity = 1.0
                                slewRateLabel.enabled = true
                                vccVoltageSWLabel.opacity = 1.0
                                vccVoltageSWLabel.enabled = true
                                vccVoltageSW.opacity  = 1.0
                                vccVoltageSW.enabled = true
                                warningPopup.close()
                            }
                        }
                    }

                }

            }

        }
        GridLayout {
            anchors{
                centerIn: parent
                margins: 30 * factor

            }
            columns: 3
            rows: 2

            GridLayout {
                columns: 2
                rows: 3
                columnSpacing: 20 * factor
                rowSpacing: 20 * factor
                Layout.alignment: Qt.AlignCenter




                SGAlignedLabel {
                    id: demoLabel
                    target: enableAccess
                    fontSizeMultiplier: factor * 1.4
                    text: "Override \n Enable Warning"
                    font.bold: true
                    font.italic: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 90
                    alignment: SGAlignedLabel.SideLeftCenter
                    horizontalAlignment: Text.AlignHCenter

                    Rectangle {
                        color: "transparent"
                        anchors { fill: demoLabel }
                        MouseArea {
                            id: hoverArea
                            anchors { fill: parent }
                            hoverEnabled: true
                        }
                    }

                    //                    SGWidget09.SGToolTipPopup {
                    //                        id: sgToolTipPopup

                    //                        showOn: hoverArea.containsMouse // Connect this to whatever boolean you want the tooltip to be shown when true
                    //                        anchors {
                    //                            bottom: enableAccess.top
                    //                            horizontalCenter: enableAccess.horizontalCenter
                    //                            horizontalCenterOffset: -10
                    //                            bottomMargin: 16
                    //                        }
                    //                        opacity: 1.0
                    //                        // Optional Configuration:
                    //                        radius: 5               // Default: 5 (0 for square)
                    //                        color: "#0ce"           // Default: "#00ccee"
                    //                        arrowOnTop: false         // Default: false (determines if arrow points up or down)
                    //                        horizontalAlignment: "center"     // Default: "center" (determines horizontal offset of arrow, other options are "left" and "right")

                    //                        // Content can contain any single object (which can have nested objects within it)
                    //                        content: Text {
                    //                            text: qsTr("Click this box to disable the warning \npopup when enabling the ecoSWITCH.")
                    //                            color: "white"
                    //                        }
                    //                    }

                    CheckBox {
                        id: enableAccess
                        checked: false
                        onClicked: {
                            if(checked) {
                                warningPopupCheckEnable.open()
                                platformInterface.check_i_lim.update()
                            }
                        }

                    }


                }
                SGAlignedLabel {
                    id: enableSWLabel
                    target: enableSW
                    text: "<b>" + qsTr("Enable") + "</b>"
                    fontSizeMultiplier: factor * 1.2
                    Layout.topMargin: 70
                    Layout.alignment: Qt.AlignCenter
                    alignment: SGAlignedLabel.SideTopCenter
                    SGSwitch {
                        id: enableSW
                        height: 35 * factor
                        width: 90 * factor
                        checkedLabel: "On"
                        uncheckedLabel: "Off"
                        fontSizeMultiplier: factor * 1.2
                        onClicked: {
                            if(!enableAccess.checked) {
                                if(checked) {
                                    warningPopup.open()
                                    platformInterface.check_i_lim.update()
                                }
                                else {
                                    platformInterface.set_enable.update("off")
                                    slewRateLabel.opacity = 1.0
                                    slewRateLabel.enabled = true
                                    vccVoltageSWLabel.opacity = 1.0
                                    vccVoltageSWLabel.enabled = true
                                    vccVoltageSW.opacity  = 1.0
                                    vccVoltageSW.enabled = true
                                }
                                //platformInterface.set_enable.update(checked ? "on" : "off")
                            }
                            else  {
                                platformInterface.set_enable.update(checked ? "on" : "off")
                            }
                        }
                    }
                }

                SGButton{
                    id: shortCircuitSWLabel
                    height: 200 * factor
                    width: 100 * factor
                    roundedLeft: true
                    roundedRight: true
                    roundedTop: true
                    roundedBottom: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 20
                    hoverEnabled: true
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            platformInterface.short_circuit_enable.update()
                        }
                    }
                    text: qsTr("Trigger" ) + "<br>"+  qsTr("Short Circuit" )
                    fontSizeMultiplier: factor * 1.2


                    color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ?   "#eee" : "#e0e0e0"


                }
                SGAlignedLabel {
                    id: vccVoltageSWLabel
                    target: vccVoltageSW
                    text: "<b>" + qsTr("VCC Selection") + "</b>"
                    fontSizeMultiplier: factor * 1.2
                    Layout.alignment: Qt.AlignCenter
                    alignment: SGAlignedLabel.SideTopCenter
                    SGSwitch {
                        id: vccVoltageSW
                        height: 35 * factor
                        width: 95 * factor
                        checkedLabel: "5V"
                        uncheckedLabel: "3.3V"
                        fontSizeMultiplier: factor * 1.2
                        grooveColor: "#0cf"
                        onClicked: platformInterface.set_vcc.update(checked ? "5" : "3.3")
                    }
                }

                SGAlignedLabel {
                    id: slewRateLabel
                    target: slewRate
                    text: "<b>" + qsTr("Approximate Slew Rate") + "</b>"
                    fontSizeMultiplier: factor * 1.2
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 20
                    alignment: SGAlignedLabel.SideTopCenter
                    SGComboBox {
                        id: slewRate
                        height: 35 * factor
                        width: 130 * factor
                        model: ["4.1 kV/s","7 kV/s", "10 kV/s", "13.7 kV/s"]
                        fontSizeMultiplier: factor * 1.2
                        onActivated: platformInterface.set_slew_rate.update(currentText)
                    }
                }
            }

            GridLayout {
                columns: 2
                rows: 2
                columnSpacing: 30 * factor
                rowSpacing: 20 * factor
                Layout.alignment: Qt.AlignCenter

                SGAlignedLabel {
                    id: currentBoxLabel
                    target: currentBox
                    text: "Input Current \n (IIN)"
                    font.bold: true
                    fontSizeMultiplier: factor * 1.2

                    SGInfoBox {
                        id: currentBox
                        height: 40 * factor
                        width: 90 * factor
                        text: "0"
                        unit: "A"
                        fontSizeMultiplier: factor * 1.2
                    }
                }
                SGAlignedLabel {
                    id: vinesBoxLabel
                    target: vinesBox
                    text: "Input Voltage \n (VIN_ES)"
                    font.bold: true
                    fontSizeMultiplier: factor * 1.2

                    SGInfoBox {
                        id: vinesBox
                        height: 40 * factor
                        width: 90 * factor
                        text: "0"
                        unit: "V"
                        fontSizeMultiplier: factor * 1.2
                    }
                }
                SGAlignedLabel {
                    id: vccBoxLabel
                    target: vccBox
                    text: "VCC Voltage \n (VCC)"
                    font.bold: true
                    fontSizeMultiplier: factor * 1.2
                    SGInfoBox {
                        id: vccBox
                        height: 40 * factor
                        width: 90 * factor
                        text: "0"
                        unit: "V"
                        fontSizeMultiplier: factor * 1.2
                    }
                }
                SGAlignedLabel {
                    id: voutBoxLabel
                    target: voutBox
                    text: "Output Voltage \n (VOUT)"
                    font.bold: true
                    fontSizeMultiplier: factor * 1.2
                    SGInfoBox {
                        id: voutBox
                        height: 40 * factor
                        width: 90 * factor
                        text: "0"
                        unit: "V"
                        fontSizeMultiplier: factor * 1.2
                    }
                }
            }

            GridLayout {
                rows: 2
                columns: 2
                columnSpacing: 10 * factor
                rowSpacing: 20 * factor
                Layout.alignment: Qt.AlignCenter

                SGAlignedLabel {
                    id: powerGoodLabel
                    target: powerGood
                    text: "<b>" + qsTr("Power Good") + "</b>"
                    fontSizeMultiplier: factor * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: powerGood
                        height: 40 * factor
                        width: 40 * factor
                        status: SGStatusLight.Off
                    }
                }
                SGAlignedLabel {
                    id: underVoltageLabel
                    target: underVoltage
                    text: "<b>" + qsTr("Under Voltage") + "</b>"
                    fontSizeMultiplier: factor * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: underVoltage
                        height: 40 * factor
                        width: 40 * factor
                        status: SGStatusLight.Off
                    }
                }
                SGAlignedLabel {
                    id: osAlertLabel
                    target: osAlert
                    text: "<b>" + qsTr("OS/ALERT") + "</b>"
                    fontSizeMultiplier: factor * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: osAlert
                        height: 40 * factor
                        width: 40 * factor
                        status: SGStatusLight.Off
                    }
                }
                SGAlignedLabel {
                    id: overVoltageLabel
                    target: overVoltage
                    text: "<b>" + qsTr("Over Voltage") + "</b>"
                    fontSizeMultiplier: factor * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: overVoltage
                        height: 40 * factor
                        width: 40 * factor
                        status: SGStatusLight.Off
                    }
                }
            }
            SGAlignedLabel {
                id: boardTempLabel
                target: boardTemp
                text: "<b>" + qsTr("Board Temperature (°C)") + "</b>"
                fontSizeMultiplier: factor * 1.2
                alignment: SGAlignedLabel.SideBottomCenter
                Layout.alignment: Qt.AlignCenter
                SGCircularGauge {
                    id: boardTemp
                    height: 300 * factor
                    width: 300 * factor
                    unitText: "°C"
                    unitTextFontSizeMultiplier: factor * 1.4
                    value: 0
                    tickmarkStepSize: 10
                    minimumValue: 0
                    maximumValue: 150
                }
            }
            SGAlignedLabel {
                id: rdsVoltageDropLabel
                target: rdsVoltageDrop
                text: "<b>" + qsTr("RDS Voltage Drop") + "</b>"
                fontSizeMultiplier: factor * 1.2
                alignment: SGAlignedLabel.SideBottomCenter
                Layout.alignment: Qt.AlignCenter
                SGCircularGauge {
                    id: rdsVoltageDrop
                    height: 300 * factor
                    width: 300 * factor
                    unitText: "mV"
                    unitTextFontSizeMultiplier: factor * 1.2
                    value: 0
                    tickmarkStepSize: 25
                    minimumValue: 0
                    maximumValue: 250
                    valueDecimalPlaces: 1
                }
            }
            SGAlignedLabel {
                id: powerLossLabel
                target: powerLoss
                text: "<b>" + qsTr("Power Loss") + "</b>"
                fontSizeMultiplier: factor * 1.2
                alignment: SGAlignedLabel.SideBottomCenter
                Layout.alignment: Qt.AlignCenter
                SGCircularGauge {
                    id: powerLoss
                    height: 300 * factor
                    width: 300 * factor
                    unitText: "W"
                    unitTextFontSizeMultiplier: factor * 1.2
                    value: 0
                    tickmarkStepSize: 0.5
                    minimumValue: 0
                    maximumValue: 6
                    valueDecimalPlaces: 2
                }
            }
        }
    }

    Rectangle {
        id: rightMenu
        width: rightBarWidth
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        MouseArea { // to remove focus in input box when click outside
            anchors.fill: parent

            preventStealing: true
            onClicked: focus = true
        }

        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            color: "lightgrey"
        }

        SGIcon {
            id: helpIcon
            height: 40
            width: 40
            anchors {
                right: parent.right
                top: parent.top
                margins: (rightBarWidth-helpIcon.width)/2
            }

            source: "images/question-circle-solid.svg"
            iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"

            MouseArea {
                id: helpMouse
                anchors.fill: helpIcon

                hoverEnabled: true

                onClicked: {
                    focus = true
                    Help.startHelpTour("ecoSWITCHHelp")
                }
            }
        }
    }
}
