import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

ColumnLayout {
    id: root

    property double outputCurrentLoadValue: 0
    property double dcdcBuckVoltageValue: 0

    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Component.onCompleted: {
        platformInterface.get_all_states.send()
//        Help.registerTarget(enableSwitchLabel, "This switch enables the LED driver.", 0, "1A-LEDHelp")
//        Help.registerTarget(dutySliderLabel, "This slider allows you to set the duty cycle of the DIM#/EN PWM signal. The duty cycle can be adjusted for an approximately linear increase/decrease in average LED current from the nominal value of approximately 715 mA at 100% duty cycle.", 1, "1A-LEDHelp")
//        Help.registerTarget(freqSliderLabel, "This slider allows you to set the frequency of the DIM#/EN PWM signal.", 2, "1A-LEDHelp")
//        Help.registerTarget(extLedCheckboxLabel, "Click this checkbox to indicate that external LEDs are connected to the board.", 3, "1A-LEDHelp")
//        Help.registerTarget(ledConfigLabel, "This combo box allows you to choose the operating configuration of the LEDs. See the Platform Content page for more info on using the different LED configurations. Caution: Do not connect external LEDs when onboard LEDs are enabled.", 4, "1A-LEDHelp")
//        Help.registerTarget(vinConnLabel, "This info box shows the input voltage to the board.", 5, "1A-LEDHelp")
//        Help.registerTarget(vinLabel, "This info box shows the input voltage to the onboard LEDs at the anode of the 1st onboard LED. This value may not be accurate for high DIM#/EN frequencies and low DIM#/EN duty cycle settings. See the Platform Content page for more information.", 6, "1A-LEDHelp")
//        Help.registerTarget(inputCurrentLabel, "This info box shows the input current to the board.", 7, "1A-LEDHelp")
//        Help.registerTarget(vledLabel, "This info box shows the approximate voltage across the LEDs. This value may not be accurate for high DIM#/EN frequencies and low DIM#/EN duty cycle settings. See the Platform Content page for more information.", 8, "1A-LEDHelp")
//        Help.registerTarget(voutLEDLabel, "This info box shows the output voltage of the LEDs. This value may not be accurate for high DIM#/EN frequencies and low DIM#/EN duty cycle settings. See the Platform Content page for more information.", 9, "1A-LEDHelp")
//        Help.registerTarget(csCurrentLabel, "This info box shows the approximate average value of the current through the CS resistor. This value may vary greatly at low DIM#/EN frequencies. See the Plaform Content page for more information on the relationship between this current and the average LED current.", 10, "1A-LEDHelp")
//        Help.registerTarget(osAlertThresholdLabel, "This input box can be used to set the threshold at which the onboard temperature sensor's over-temperature warning signal (OS#/ALERT#) will trigger. The default setting is 110°C (max value) which corresponds to an LED temperature of approximately 125°C.", 11, "1A-LEDHelp")
//        Help.registerTarget(osAlertLabel, "This indicator will turn red when the onboard temperature sensor detects a board temperature near the 3rd onboard LED higher than the temperature threshold set in the input box above.", 12, "1A-LEDHelp")
//        Help.registerTarget(tempGaugeLabel, "This gauge shows the board temperature near the ground pad of the 3rd onboard LED.", 13, "1A-LEDHelp")
    }

    //control properties
    property var control_states_ldo_enable: platformInterface.control_states.ldo_en
    onControl_states_ldo_enableChanged: {
        if(control_states_ldo_enable === "on")
            enableLDO.checked = true
        else enableLDO.checked = false
    }

    property var control_states_load_enable: platformInterface.control_states.load_en
    onControl_states_load_enableChanged: {
        if(control_states_load_enable === "on")
            loadSwitch.checked = true
        else loadSwitch.checked = false
    }

    property var control_states_vin_vr_set: platformInterface.control_states.vin_vr_set
    onControl_states_vin_vr_setChanged: {
        buckVoltageSlider.value = control_states_vin_vr_set
    }

    property var control_states_iout_set: platformInterface.control_states.iout_set
    onControl_states_iout_setChanged: {
        outputLoadCurrentSlider.value = control_states_iout_set
    }

    property var control_states_vin_vr_select: platformInterface.control_states.vin_vr_sel
    onControl_states_vin_vr_selectChanged: {
        if(control_states_vin_vr_select !== "") {
            for(var i = 0; i < ldoInputComboBox.model.length; ++i){
                if(control_states_vin_vr_select === ldoInputComboBox.model[i]){
                    ldoInputComboBox.currentIndex = i
                    return
                }
            }
        }
    }

    Text {
        id: boardTitle
        Layout.alignment: Qt.AlignCenter
        text: "NCV48220 LDO Charge Pump"
        font.bold: true
        font.pixelSize: ratioCalc * 40
        Layout.topMargin: 10

    }

    RowLayout {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height/2

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2

            color: "transparent"
            Layout.alignment: Qt.AlignCenter

            ColumnLayout {
                anchors.top: parent.top
                width: parent.width - 25
                height: parent.height
                spacing: 5
                Text {
                    id:setting
                    text: "Settings"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    Layout.topMargin: 20
                    color: "#696969"
                    Layout.leftMargin: 20

                }

                Rectangle {
                    id: line3
                    Layout.preferredHeight: 2
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width
                    border.color: "lightgray"
                    radius: 2
                }

                Rectangle {
                    color:"transparent"
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/4

                    RowLayout {
                        anchors.fill: parent

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter

                            SGAlignedLabel {
                                id: enableLDOLabel
                                target: enableLDO
                                text: "Enable LDO"
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: enableLDO
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    onClicked: {
                                        if(checked === true){
                                            platformInterface.enable_ldo.update(1)
                                        }
                                        else{
                                            platformInterface.enable_ldo.update(0)
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter

                            SGAlignedLabel {
                                id: loadSwitchOnLabel
                                target: loadSwitch
                                text: "Enable Onboard Load"
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: loadSwitch
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    onClicked: {
                                        if(checked === true){
                                            platformInterface.enable_load.update(1)
                                        }
                                        else{
                                            platformInterface.enable_load.update(0)
                                        }
                                    }
                                }
                            }
                        }
                    } // switch setting end
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill:parent
                            Rectangle {
                                id: outputLoadCurrentSliderContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGAlignedLabel {
                                    id: outputLoadCurrentLabel
                                    target: outputLoadCurrentSlider
                                    text: "Output Load Current"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    font.bold : true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    anchors.centerIn: parent

                                    SGSlider {
                                        id: outputLoadCurrentSlider
                                        width: outputLoadCurrentSliderContainer.width/1.2
                                        live: false
                                        from: 0
                                        to: 500
                                        stepSize: 0.1
                                        fromText.text: "0mA"
                                        toText.text: "500mA"
                                        value: 15
                                        inputBox.validator: DoubleValidator {
                                            top: outputLoadCurrentSlider.to
                                            bottom: outputLoadCurrentSlider.from
                                        }
                                        onUserSet: platformInterface.set_iout.update(value)
                                    }
                                }
                            }

                            Rectangle {
                                id: buckVoltageSliderContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGAlignedLabel {
                                    id: buckVoltageLabel
                                    target: buckVoltageSlider
                                    text: "DC-DC Buck Output Voltage"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    font.bold : true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    anchors.centerIn: parent
                                    SGSlider {
                                        id: buckVoltageSlider
                                        width: buckVoltageSliderContainer.width/1.2
                                        live: false
                                        from: 2.5
                                        to: 15
                                        stepSize: 0.01
                                        fromText.text: "2.5V"
                                        toText.text: "15V"
                                        value: 0
                                        inputBox.validator: DoubleValidator {
                                            top: buckVoltageSlider.to
                                            bottom: buckVoltageSlider.from
                                        }
                                        onUserSet: platformInterface.set_vin_vr.update(value)
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: ldoInputContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        SGAlignedLabel {
                            id: ldoInputLabel
                            target: ldoInputComboBox
                            text: "LDO Input Voltage Selection"
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGComboBox {
                                id: ldoInputComboBox
                                model: ["Bypass Input Regulator", "DC-DC Buck Input Regulator", "Off"]
                                onActivated: {
                                    if(currentIndex == 0) {
                                        platformInterface.select_vin_vr.update("bypass")
                                    }
                                    else if(currentIndex == 1) {
                                        platformInterface.select_vin_vr.update("buck")
                                    }
                                    else {
                                        platformInterface.select_vin_vr.update("off")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignCenter
            Layout.margins: 10
            color: "transparent"
            Text {
                id:telemetry
                text: "Telemetry"
                font.bold: true
                font.pixelSize: ratioCalc * 20
                Layout.topMargin: 20
                color: "#696969"
                Layout.leftMargin: 20
                anchors {
                    top: parent.top
                    topMargin: 15
                }
            }

            Rectangle {
                id: line4
                anchors.top: telemetry.bottom
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: telemetry.bottom
                    topMargin: 10
                }
            }

            GridLayout {
                width: parent.width - 25
                height: (parent.height - telemetry.contentHeight - line4.height) - 100
                rows: 2
                columns: 3
                anchors {
                    top: line4.bottom
                    topMargin: 20
                }

                SGAlignedLabel {
                    id: vinvrLabel
                    target: vinVr
                    text:  "<b>LDO CP Input Voltage<br>(VIN_VR)</b>"
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    SGInfoBox {
                        id: vinVr
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        height: 40 * ratioCalc
                        width: 100 * ratioCalc
                        unit: "<b>V</b>"
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        text: platformInterface.telemetry.vin_vr
                    }
                }

                SGAlignedLabel {
                    id: vinLabel
                    target: vin
                    text:  "<b>Board Input Voltage<br>(VIN)</b>"
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    SGInfoBox {
                        id: vin
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        height: 40 * ratioCalc
                        width: 100 * ratioCalc
                        unit: "<b>V</b>"
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        text: platformInterface.telemetry.vin
                    }

                }

                SGAlignedLabel {
                    id: inputCurrentLabel
                    target: inputCurrent
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>Input Current<br>(IIN)</b>"

                    SGInfoBox {
                        id: inputCurrent
                        height: 40 * ratioCalc
                        width: 110* ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>mA</b>"
                        text: platformInterface.telemetry.iin
                    }

                }

                SGAlignedLabel {
                    id: vcpLabel
                    target: vcp
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>Charge Pump Output Voltage<br>(VCP)</b>"

                    SGInfoBox {
                        id: vcp
                        height: 40 * ratioCalc
                        width: 100* ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vcp
                    }
                }

                SGAlignedLabel {
                    id: voutVrLabel
                    target: voutVr
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>LDO CP Output Voltage<br>(VOUT_VR)</b>"

                    SGInfoBox {
                        id: voutVr
                        height: 40 * ratioCalc
                        width: 100* ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vout
                    }
                }

                SGAlignedLabel {
                    id: outputCurrentLabel
                    target: outputCurrent
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>Output Current<br>(IOUT)</b>"

                    SGInfoBox {
                        id: outputCurrent
                        height: 40 * ratioCalc
                        width: 110*  ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>mA</b>"
                        text: platformInterface.telemetry.iout
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height/2
        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignCenter
            Layout.margins: 10
            color: "transparent"
            Text {
                id: interrupts
                text: "Interrupts"
                font.bold: true
                font.pixelSize: ratioCalc * 20
                Layout.topMargin: 20
                color: "#696969"
                Layout.leftMargin: 20
            }

            Rectangle {
                id: line2
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: interrupts.bottom
                    topMargin: 10
                }
            }
            GridLayout {
                width: parent.width - 25
                height: (parent.height - interrupts.contentHeight - line2.height) - 100
                rows: 2
                columns: 2
                anchors {
                    top: line2.bottom
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    SGAlignedLabel {
                        id:powerGoodLabel
                        target: powerGoodLight
                        alignment: SGAlignedLabel.SideBottomCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2

                        text: "<b>Power Good</b>"

                        SGStatusLight {
                            id: powerGoodLight
                            anchors.centerIn: parent

                            property bool powerGoodNoti: platformInterface.int_vin_vr_pg.value
                            onPowerGoodNotiChanged: {
                                powerGoodLight.status = (powerGoodNoti === true) ? SGStatusLight.Green : SGStatusLight.Off
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    SGAlignedLabel {
                        id: chargePumpLabel
                        target: chargePumpOnLight
                        alignment: SGAlignedLabel.SideBottomCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "<b>Charge Pump On</b>"

                        SGStatusLight {
                            id: chargePumpOnLight
                            anchors.centerIn: parent

                            property bool chargePumpOnNoti: platformInterface.int_cp_on.value
                            onChargePumpOnNotiChanged: {
                                chargePumpOnLight.status = (chargePumpOnNoti === true) ? SGStatusLight.Green : SGStatusLight.Off
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    SGAlignedLabel {
                        id:roMCULabel
                        target: roMcuLight
                        alignment: SGAlignedLabel.SideBottomCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "<b>RO</b>"

                        SGStatusLight {
                            id: roMcuLight
                            anchors.centerIn: parent
                            property bool roMcuNoti: platformInterface.int_ro_mcu.value
                            onRoMcuNotiChanged: {
                                roMcuLight.status = (roMcuNoti === true) ? SGStatusLight.Red : SGStatusLight.Off
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    SGAlignedLabel {
                        id:osAlertabel
                        target: osAlertLight
                        alignment: SGAlignedLabel.SideBottomCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "<b>OS#/ALERT#</b>"

                        SGStatusLight {
                            id: osAlertLight
                            anchors.centerIn: parent

                            property bool osAlertNoti: platformInterface.int_os_alert.value
                            onOsAlertNotiChanged: {
                                osAlertLight.status = (osAlertNoti === true) ? SGStatusLight.Red : SGStatusLight.Off
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignCenter
            color: "transparent"
            Text {
                id: boardTempText
                text: "Board Temperature And Power Loss"
                font.bold: true
                font.pixelSize: ratioCalc * 20
                Layout.topMargin: 20
                color: "#696969"
                Layout.leftMargin: 20
            }
            Rectangle {
                id: line10
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: boardTempText.bottom
                    topMargin: 10
                }
            }

            GridLayout {
                rows: 1
                columns: 2
                width: parent.width - 25
                height: (parent.height - boardTempText.contentHeight - line10.height) - 100
                anchors {
                    top: line10.bottom
                    topMargin: 10
                }
                Rectangle {
                    id: tempgaugeContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    SGAlignedLabel {
                        id: tempLabel
                        target: tempGauge
                        text: "Board Temperature"
                        margin: -20
                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter

                        SGCircularGauge {
                            id: tempGauge
                            height: tempgaugeContainer.height - tempLabel.contentHeight - 10
                            width: tempgaugeContainer.width
                            minimumValue: 0
                            maximumValue: 150
                            tickmarkStepSize: 20
                            gaugeFillColor1: "blue"
                            gaugeFillColor2: "red"
                            unitText: "°C"
                            unitTextFontSizeMultiplier: ratioCalc * 2.2
                            property var temp_change: platformInterface.telemetry.temperature
                            onTemp_changeChanged: {
                                value = temp_change
                            }
                            valueDecimalPlaces: 1

                            Behavior on value { NumberAnimation { duration: 300 } }
                            function lerpColor (color1, color2, x){
                                if (Qt.colorEqual(color1, color2)){
                                    return color1;
                                } else {
                                    return Qt.rgba(
                                                color1.r * (1 - x) + color2.r * x,
                                                color1.g * (1 - x) + color2.g * x,
                                                color1.b * (1 - x) + color2.b * x, 1
                                                );
                                }
                            }

                        }
                    }
                }

                Rectangle {
                    id: powerLossContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    SGAlignedLabel {
                        id: powerLossLabel
                        target: powerLoss
                        text: "LDO Power Loss"
                        margin: -20
                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGCircularGauge {
                            id: powerLoss
                            height: powerLossContainer.height - powerLossLabel.contentHeight - 10
                            width: powerLossContainer.width
                            minimumValue: 0
                            maximumValue: 3
                            tickmarkStepSize: 0.25
                            gaugeFillColor1: "blue"
                            gaugeFillColor2: "red"
                            unitText: "W"
                            unitTextFontSizeMultiplier: ratioCalc * 2.2
                            value: platformInterface.telemetry.ploss
                            valueDecimalPlaces: 3

                        }
                    }
                }
            }
        }
    }
}
