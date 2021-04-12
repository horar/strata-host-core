import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: controlNavigation

    anchors.fill: parent
    property real minContentHeight: 688
    property real minContentWidth: 1024-rightBarWidth
    property real rightBarWidth: 80
    property real ratioCalc: Math.min(controlNavigation.height/minContentHeight,(controlNavigation.width-rightBarWidth)/minContentWidth)
    property real vfactor: Math.max(1,height/minContentHeight)
    property real hfactor: Math.max(1,(width-rightBarWidth)/minContentWidth)
    property string popup_message

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
    // property var control_states: platformInterface.control_states

    property var control_states_enable: platformInterface.control_states.enable
    onControl_states_enableChanged: {
        if(control_states_enable === true) {
            enableSW.checked = true
            slewRateLabel.opacity = 0.5
            slewRateLabel.enabled = false
            vccVoltageSWLabel.opacity = 0.5
            vccVoltageSW.enabled= false
            vccVoltageSW.opacity  = 0.9
            shortCircuitSWLabel.opacity = 1.0
            shortCircuitSWLabel.enabled = true


        }
        else {
            enableSW.checked = false
            slewRateLabel.opacity = 1.0
            slewRateLabel.enabled = true
            vccVoltageSWLabel.opacity = 1.0
            vccVoltageSWLabel.enabled = true
            vccVoltageSW.opacity  = 1.0
            vccVoltageSW.enabled= true
            shortCircuitSWLabel.opacity = 0.5
            shortCircuitSWLabel.enabled = false

        }
    }

    property var control_states_slew_rate: platformInterface.control_states.slew_rate
    onControl_states_slew_rateChanged: {
        slewRate.currentIndex = slewRate.model.indexOf(control_states_slew_rate)
    }

    property var control_states_vcc_sel: platformInterface.control_states.vcc_sel
    onControl_states_vcc_selChanged: {
        vccVoltageSW.checked = control_states_vcc_sel === "5"
    }


    // property var telemetryNoti: platformInterface.telemetry
    property bool underVoltageNoti: platformInterface.int_vin_lw_th.value
    property bool overVoltageNoti: platformInterface.int_vin_up_th.value
    property bool powerGoodNoti: platformInterface.int_pg.value
    property bool osAlertNoti: platformInterface.int_os_alert.value

    onUnderVoltageNotiChanged: underVoltage.status = underVoltageNoti ? SGStatusLight.Red : SGStatusLight.Off
    onOverVoltageNotiChanged: overVoltage.status = overVoltageNoti ? SGStatusLight.Red : SGStatusLight.Off
    onPowerGoodNotiChanged: powerGood.status = powerGoodNoti ? SGStatusLight.Green : SGStatusLight.Off
    onOsAlertNotiChanged: osAlert.status = osAlertNoti ? SGStatusLight.Red : SGStatusLight.Off



    Component.onCompleted: {
        platformInterface.get_all_states.update()
        Help.registerTarget(demoLabel, "Click this check box to disable the inrush-current warning popup when enabling the ecoSWITCH.", 0, "ecoSWITCHHelp")
        Help.registerTarget(enableSWLabel, "This switch enables or disables the ecoSWITCH.", 1, "ecoSWITCHHelp")
        Help.registerTarget(shortCircuitSWLabel, "This button triggers a short from the output voltage to ground for 10 ms. This feature can only be used when the ecoSWITCH is enabled and is recommended to be used for input voltages greater than 2V. The ecoSWITCH enable signal must be toggled to turn it back on after short-circuit protection is triggered.", 2, "ecoSWITCHHelp")
        Help.registerTarget(vccVoltageSWLabel, "This switch toggles the ecoSWITCH VCC between 3.3V and USB 5V and can only be changed when the ecoSWITCH is disabled.", 3, "ecoSWITCHHelp")
        Help.registerTarget(slewRateLabel, "This drop-down box selects between four programmable output voltage slew rates when the ecoSWITCH turns on. The slew rate can only be changed when the ecoSWITCH is disabled.", 4, "ecoSWITCHHelp")
        Help.registerTarget(currentBoxLabel, "This info box shows the current through the ecoSWITCH.", 5, "ecoSWITCHHelp")
        Help.registerTarget(vinesBoxLabel, "This info box shows the input voltage of the ecoSWITCH.", 6, "ecoSWITCHHelp")
        Help.registerTarget(vccBoxLabel, "This info box shows the ecoSWITCH VCC voltage.", 7, "ecoSWITCHHelp")
        Help.registerTarget(voutBoxLabel, "This info box shows the output voltage of the ecoSWITCH.", 8, "ecoSWITCHHelp")
        Help.registerTarget(powerGoodLabel, "This LED is green when the ecoSWITCH PG signal is high indicating that the ecoSWITCH's internal MOSFET is enabled. The LED will turn off when the ecoSWITCH is disabled or during an OCP, input UVLO, or thermal shutdown event.", 9, "ecoSWITCHHelp")
        Help.registerTarget(underVoltageLabel, "This LED is red when the input voltage monitor (NCP308) detects an input voltage less than 0.5V.", 10, "ecoSWITCHHelp")
        Help.registerTarget(overVoltageLabel, "This LED is red when the input voltage monitor (NCP308) detects an input voltage greater than approximately 13.5V.", 12, "ecoSWITCHHelp")
        Help.registerTarget(osAlertLabel, "This LED is red when the onboard temperature sensor (NCT375) detects a board temperature near the ecoSWITCH greater than 80 degrees Celsius.", 11, "ecoSWITCHHelp")
        Help.registerTarget(boardTempLabel, "This gauge monitors the board temperature near the ecoSWITCH in degrees Celsius.", 13, "ecoSWITCHHelp")
        Help.registerTarget(rdsVoltageDropLabel, "This gauge monitors the voltage drop across the ecoSWITCH when enabled and Power Good is high.", 14, "ecoSWITCHHelp")
        Help.registerTarget(powerLossLabel, "This gauge monitors the power loss in the ecoSWITCH when enabled and Power Good is high.", 15, "ecoSWITCHHelp")
    }

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
                width: warningContainerFoCheckBox.width - 50
                height: warningContainerFoCheckBox.height - 50

                Rectangle {
                    id: warningLabelForCheckEnable
                    width: warningBoxForCheckEnable.width - 100
                    height: parent.height/5
                    color:"red"
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top:parent.top
                    }

                    Text {
                        id: warningLabelTextForCheckEnable
                        anchors.centerIn: warningLabelForCheckEnable
                        text: "<b>WARNING</b>"
                        font.pixelSize: ratioCalc * 15
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
                    height:  parent.height - warningLabelForCheckEnable.height - selectionContainerForCheckEnable.height
                    Text {
                        id: warningTextForCheckEnable
                        anchors.fill:parent

                        property var i_lim_popup: platformInterface.i_lim_popup.i_lim
                        property string i_lim_text
                        onI_lim_popupChanged: {
                            i_lim_text = i_lim_popup
                        }
                        text: {
                            "Loading the ecoSWITCH with more than " + i_lim_popup + " A during startup may cause device failure and a potential fire hazard. See the Platform Content page for more information. Click OK to acknowledge and disable this popup when the Enable switch is toggled or Cancel to abort."
                        }
                        verticalAlignment:  Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        width: parent.width
                        font.bold: true
                        font.pixelSize: ratioCalc * 15
                    }
                }

                Rectangle {
                    id: selectionContainerForCheckEnable
                    width: parent.width
                    height: parent.height/4.5
                    anchors{
                        top: messageContainerForCheckEnable.bottom
                        topMargin: 10
                    }
                    color: "transparent"

                    Rectangle {
                        id: okButtonForCheckEnable
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
                                enableAccess.checked = true
                                warningPopupCheckEnable.close()
                            }
                        }
                    }

                    Rectangle {
                        id: cancelButtonForCheckEnable
                        width: parent.width/2
                        height:parent.height
                        anchors.left: okButtonForCheckEnable.right
                        color: "transparent"


                        SGButton {
                            anchors.centerIn: parent
                            text: "Cancel"
                            roundedLeft: true
                            roundedRight: true
                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                            onClicked: {
                                enableAccess.checked = false
                                warningPopupCheckEnable.close()

                            }
                        }
                    }
                }
            }
        }

        Popup{
            id: warningPopupSC
            width: content.width/1.7
            height: content.height/3
            anchors.centerIn: parent
            modal: true
            focus: true
            closePolicy:Popup.NoAutoClose
            background: Rectangle{
                id: warningContainerForSC
                width: warningPopupSC.width
                height: warningPopupSC.height
                color: "white"
                border.color: "black"
                border.width: 4
                radius: 10
            }

            Rectangle {
                id: warningBoxForSC
                color: "transparent"
                anchors {
                    top: parent.top
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                width: warningContainer.width - 50
                height: warningContainer.height - 50

                Rectangle {
                    id: warningLabelForSC
                    width: warningBox.width - 100
                    height: parent.height/5
                    color:"red"
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top:parent.top
                    }

                    Text {
                        id: warningLabelTextForSC
                        anchors.centerIn: warningLabelForSC
                        text: "<b>WARNING</b>"
                        font.pixelSize: ratioCalc * 15
                        color: "white"
                    }

                    Text {
                        id: warningIconLeftSC
                        anchors {
                            right: warningLabelTextForSC.left
                            verticalCenter: warningLabelTextForSC.verticalCenter
                            rightMargin: 10
                        }
                        text: "\ue80e"
                        font.family: Fonts.sgicons
                        font.pixelSize: (parent.width + parent.height)/25
                        color: "white"
                    }

                    Text {
                        id: warningIconRightSC
                        anchors {
                            left: warningLabelTextForSC.right
                            verticalCenter: warningLabelTextForSC.verticalCenter
                            leftMargin: 10
                        }
                        text: "\ue80e"
                        font.family: Fonts.sgicons
                        font.pixelSize: (parent.width + parent.height)/25
                        color: "white"
                    }

                }

                Rectangle {
                    id: messageContainerForSC
                    anchors {
                        top: warningLabelForSC.bottom
                        topMargin: 10
                        centerIn:  parent.Center
                    }
                    color: "transparent"
                    width: parent.width
                    height:  parent.height - warningLabelForSC.height - selectionContainerForSC.height
                    Text {
                        id: warningTextForSC
                        anchors.fill:parent
                        text: {
                            "The onboard short-circuit load was turned on, but did not trigger the ecoSWITCH's short-circuit protection feature. It is recommended to only use the short-circuit feature of this EVB for input voltages greater than 2.0V. See the Platform Content page for more information."
                        }
                        verticalAlignment:  Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        width: parent.width
                        font.bold: true
                        font.pixelSize: ratioCalc * 15
                    }
                }

                Rectangle {
                    id: selectionContainerForSC
                    width: parent.width
                    height: parent.height/4.5
                    anchors{
                        top: messageContainerForSC.bottom
                    }
                    color: "transparent"

                    Rectangle {
                        id: okButtonForSC
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
                                warningPopupSC.close()
                            }
                        }
                    }
                }
            }
        }

        Popup{
            id: warningPopupEnableSwitch
            width: content.width/1.7
            height: content.height/3
            anchors.centerIn: parent
            modal: true
            focus: true
            closePolicy:Popup.NoAutoClose
            background: Rectangle{
                id: warningContainer
                width: warningPopupEnableSwitch.width
                height: warningPopupEnableSwitch.height
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
                        top:parent.top

                    }

                    Text {
                        id: warningLabelText
                        anchors.centerIn: warningLabel
                        text: "<b>WARNING</b>"
                        font.pixelSize: ratioCalc * 15
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
                        centerIn:  parent.Center

                    }
                    color: "transparent"
                    width: parent.width
                    height: parent.height - warningLabel.height - selectionContainer.height
                    Text {
                        id: warningText
                        anchors.fill:parent


                        property var i_lim_popup: platformInterface.i_lim_popup.i_lim
                        property string i_lim_text
                        onI_lim_popupChanged: {
                            i_lim_text = i_lim_popup
                        }
                        text: {
                            "Loading the ecoSWITCH with more than "+  i_lim_popup + "A during startup may cause device failure and a potential fire hazard. See the Platform Content page for more information. Click OK to proceed or Cancel to abort."
                        }

                        verticalAlignment:  Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        width: parent.width
                        font.bold: true
                        font.pixelSize: ratioCalc * 15
                    }
                }

                Rectangle {
                    id: selectionContainer
                    width: parent.width
                    height: parent.height/5
                    anchors{
                        top: messageContainer.bottom
                        topMargin: 10
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
                                warningPopupEnableSwitch.close()
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
                                warningPopupEnableSwitch.close()
                            }
                        }
                    }
                }
            }
        }


        GridLayout {
            anchors{
                centerIn: parent
                margins: 30 * ratioCalc
            }
            columns: 3
            rows: 2

            GridLayout {
                columns: 2
                rows: 3
                columnSpacing: 20 * ratioCalc
                rowSpacing: 20 * ratioCalc
                Layout.alignment: Qt.AlignCenter

                SGAlignedLabel {
                    id: demoLabel
                    target: enableAccess
                    fontSizeMultiplier: ratioCalc * 1.4
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
                    fontSizeMultiplier: ratioCalc * 1.2
                    Layout.topMargin: 70
                    Layout.alignment: Qt.AlignCenter
                    alignment: SGAlignedLabel.SideTopCenter
                    SGSwitch {
                        id: enableSW
                        height: 35 * ratioCalc
                        width: 90 * ratioCalc
                        checkedLabel: "On"
                        uncheckedLabel: "Off"
                        fontSizeMultiplier: ratioCalc * 1.2
                        onClicked: {
                            if(!enableAccess.checked) {
                                if(checked) {
                                    warningPopupEnableSwitch.open()
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
                            }
                            else  {
                                platformInterface.set_enable.update(checked ? "on" : "off")
                            }
                        }
                    }
                }

                SGButton{
                    id: shortCircuitSWLabel
                    height: 200 * ratioCalc
                    width: 100 * ratioCalc
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
                        property var sc_status_value: platformInterface.sc_status.value
                        onSc_status_valueChanged: {
                            if(sc_status_value === "failed") {
                                warningPopupSC.open()
                                platformInterface.check_i_lim.update()
                            }
                        }
                        onClicked: {
                            platformInterface.short_circuit_enable.update()
                        }
                    }
                    text: qsTr("Trigger" ) + "<br>"+  qsTr("Short Circuit" )
                    fontSizeMultiplier: ratioCalc * 1.2
                    color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ?   "#eee" : "#e0e0e0"
                }

                SGAlignedLabel {
                    id: vccVoltageSWLabel
                    target: vccVoltageSW
                    text: "<b>" + qsTr("VCC Selection") + "</b>"
                    fontSizeMultiplier: ratioCalc * 1.2
                    Layout.alignment: Qt.AlignCenter
                    alignment: SGAlignedLabel.SideTopCenter
                    SGSwitch {
                        id: vccVoltageSW
                        height: 35 * ratioCalc
                        width: 95 * ratioCalc
                        checkedLabel: "5V"
                        uncheckedLabel: "3.3V"
                        fontSizeMultiplier: ratioCalc * 1.2
                        grooveColor: "#0cf"
                        onClicked: platformInterface.set_vcc.update(checked ? "5" : "3.3")
                    }
                }

                SGAlignedLabel {
                    id: slewRateLabel
                    target: slewRate
                    text: "<b>" + qsTr("Approximate Slew Rate") + "</b>"
                    fontSizeMultiplier: ratioCalc * 1.2
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 20
                    alignment: SGAlignedLabel.SideTopCenter
                    SGComboBox {
                        id: slewRate
                        height: 35 * ratioCalc
                        width: 130 * ratioCalc
                        model: ["4.1 kV/s","7 kV/s", "10 kV/s", "13.7 kV/s"]
                        fontSizeMultiplier: ratioCalc * 1.2
                        onActivated: platformInterface.set_slew_rate.update(currentText)
                    }
                }
            }

            GridLayout {
                columns: 2
                rows: 2
                columnSpacing: 30 * ratioCalc
                rowSpacing: 20 * ratioCalc
                Layout.alignment: Qt.AlignCenter

                SGAlignedLabel {
                    id: currentBoxLabel
                    target: currentBox
                    text: "Input Current \n (IIN)"
                    font.bold: true
                    fontSizeMultiplier: ratioCalc * 1.2

                    SGInfoBox {
                        id: currentBox
                        height: 40 * ratioCalc
                        width: 90 * ratioCalc
                        text: "0"
                        unit: "A"
                        fontSizeMultiplier: ratioCalc * 1.2
                    }
                }
                SGAlignedLabel {
                    id: vinesBoxLabel
                    target: vinesBox
                    text: "Input Voltage \n (VIN_ES)"
                    font.bold: true
                    fontSizeMultiplier: ratioCalc * 1.2

                    SGInfoBox {
                        id: vinesBox
                        height: 40 * ratioCalc
                        width: 90 * ratioCalc
                        text: "0"
                        unit: "V"
                        fontSizeMultiplier: ratioCalc * 1.2
                    }
                }
                SGAlignedLabel {
                    id: vccBoxLabel
                    target: vccBox
                    text: "VCC Voltage \n (VCC)"
                    font.bold: true
                    fontSizeMultiplier: ratioCalc * 1.2
                    SGInfoBox {
                        id: vccBox
                        height: 40 * ratioCalc
                        width: 90 * ratioCalc
                        text: "0"
                        unit: "V"
                        fontSizeMultiplier: ratioCalc * 1.2
                    }
                }
                SGAlignedLabel {
                    id: voutBoxLabel
                    target: voutBox
                    text: "Output Voltage \n (VOUT)"
                    font.bold: true
                    fontSizeMultiplier: ratioCalc * 1.2
                    SGInfoBox {
                        id: voutBox
                        height: 40 * ratioCalc
                        width: 90 * ratioCalc
                        text: "0"
                        unit: "V"
                        fontSizeMultiplier: ratioCalc * 1.2
                    }
                }
            }

            GridLayout {
                rows: 2
                columns: 2
                columnSpacing: 10 * ratioCalc
                rowSpacing: 20 * ratioCalc
                Layout.alignment: Qt.AlignCenter

                SGAlignedLabel {
                    id: powerGoodLabel
                    target: powerGood
                    text: "<b>" + qsTr("Power Good") + "</b>"
                    fontSizeMultiplier: ratioCalc * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: powerGood
                        height: 40 * ratioCalc
                        width: 40 * ratioCalc
                        status: SGStatusLight.Off
                    }
                }
                SGAlignedLabel {
                    id: underVoltageLabel
                    target: underVoltage
                    text: "<b>" + qsTr("Under Voltage") + "</b>"
                    fontSizeMultiplier: ratioCalc * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: underVoltage
                        height: 40 * ratioCalc
                        width: 40 * ratioCalc
                        status: SGStatusLight.Off
                    }
                }
                SGAlignedLabel {
                    id: osAlertLabel
                    target: osAlert
                    text: "<b>" + qsTr("OS/ALERT") + "</b>"
                    fontSizeMultiplier: ratioCalc * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: osAlert
                        height: 40 * ratioCalc
                        width: 40 * ratioCalc
                        status: SGStatusLight.Off
                    }
                }
                SGAlignedLabel {
                    id: overVoltageLabel
                    target: overVoltage
                    text: "<b>" + qsTr("Over Voltage") + "</b>"
                    fontSizeMultiplier: ratioCalc * 1.2
                    alignment: SGAlignedLabel.SideTopCenter
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        id: overVoltage
                        height: 40 * ratioCalc
                        width: 40 * ratioCalc
                        status: SGStatusLight.Off
                    }
                }
            }
            SGAlignedLabel {
                id: boardTempLabel
                target: boardTemp
                text: "<b>" + qsTr("Board Temperature (°C)") + "</b>"
                fontSizeMultiplier: ratioCalc * 1.2
                alignment: SGAlignedLabel.SideBottomCenter
                Layout.alignment: Qt.AlignCenter
                SGCircularGauge {
                    id: boardTemp
                    height: 300 * ratioCalc
                    width: 300 * ratioCalc
                    unitText: "°C"
                    unitTextFontSizeMultiplier: ratioCalc * 1.4
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
                fontSizeMultiplier: ratioCalc * 1.2
                alignment: SGAlignedLabel.SideBottomCenter
                Layout.alignment: Qt.AlignCenter
                SGCircularGauge {
                    id: rdsVoltageDrop
                    height: 300 * ratioCalc
                    width: 300 * ratioCalc
                    unitText: "mV"
                    unitTextFontSizeMultiplier: ratioCalc * 1.2
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
                fontSizeMultiplier: ratioCalc * 1.2
                alignment: SGAlignedLabel.SideBottomCenter
                Layout.alignment: Qt.AlignCenter
                SGCircularGauge {
                    id: powerLoss
                    height: 300 * ratioCalc
                    width: 300 * ratioCalc
                    unitText: "W"
                    unitTextFontSizeMultiplier: ratioCalc * 1.2
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
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }
}
