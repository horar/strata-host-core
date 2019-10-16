import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help
import "../components"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    //  anchors.fill: parent
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height


    spacing: 15


    Component.onCompleted: {
        Help.registerTarget(platformName, "This is the platform name.", 0, "1A-LEDHelp")
        Help.registerTarget(temperatureGauge, "This gauge shows the temperature of the ground pad of the 3rd onboard LED.", 1, "1A-LEDHelp")
        Help.registerTarget(enableSwitchContainer, "This switch enables the LED driver.", 2, "1A-LEDHelp")
        Help.registerTarget(vin_conn, "This info box shows the input voltage to the board. The voltage is sensed at the cathode of the catch diode.", 3, "1A-LEDHelp")
        Help.registerTarget(vin, "This info box shows the input voltage to the LEDs. The voltage is sensed directly at the anode of the 1st onboard LED.", 4, "1A-LEDHelp")
        Help.registerTarget(inputCurrent, "This info box shows the input current to the board.", 5, "1A-LEDHelp")
        Help.registerTarget(voutLED, "This info box shows the output voltage of the LEDs. This voltage is sensed directly at the cathode of the 3rd onboard LED.", 6, "1A-LEDHelp")
        Help.registerTarget(csCurrent, "This info box shows the approximate average value of the current through the CS resistor. This value will vary greatly at low DIM#_EN frequencies. See the FAQ for the relationship between this current and the average LED current.", 7, "1A-LEDHelp")
        Help.registerTarget(dutySlider, "This slider allows you to set the duty cycle of the DIM#_EN PWM signal. The duty cycle can be reduced to decrease the average LED current.", 8, "1A-LEDHelp")
        Help.registerTarget(freqSlider, "This slider allows you to set the frequency of the DIM#_EN PWM signal.", 9, "1A-LEDHelp")
        Help.registerTarget(ledConfig, "This combo box allows you to choose the operating mode for the LEDs. See the FAQ for more info on the different LED configurations.", 10, "1A-LEDHelp")
    }
    Text {
        id: platformName
        Layout.alignment: Qt.AlignHCenter
        text: "1A LED Driver"
        font.pixelSize: 50
    }



    property var lcsm_change:  platformInterface.telemetry.lcsm
    onLcsm_changeChanged: {
        csCurrent.text = lcsm_change
    }

    property var gcsm_change:  platformInterface.telemetry.gcsm
    onGcsm_changeChanged: {
        inputCurrent.text = gcsm_change
    }

    property var vin_change:  platformInterface.telemetry.vin
    onVin_changeChanged: {
        vin.text = vin_change
    }

    property var vout_change:  platformInterface.telemetry.vout
    onVout_changeChanged: {
        voutLED.text =  vout_change
    }

    //control property

    property var control_states_enable: platformInterface.control_states.enable
    onControl_states_enableChanged: {
        if(control_states_enable === "on")
            enableSwitch.checked = true
        else enableSwitch.checked = false
    }

    property var control_states_dim_en_duty: platformInterface.control_states.dim_en_duty

    onControl_states_dim_en_dutyChanged: {
        dutySlider.value = control_states_dim_en_duty
    }

    property var control_states_dim_en_freq: platformInterface.control_states.dim_en_freq

    onControl_states_dim_en_freqChanged: {
        freqSlider.value = control_states_dim_en_freq
    }

    property var control_states_led_config: platformInterface.control_states.led_config
    onControl_states_led_configChanged: {
        if(control_states_led_config !== "") {
            for(var i = 0; i < ledConfigCombo.model.length; ++i){
                if(control_states_led_config === ledConfigCombo.model[i]){
                    ledConfigCombo.currentIndex = i
                    return
                }
            }
        }
    }



    RowLayout {
        id: mainSetting
        Layout.fillWidth: true
        Layout.maximumHeight: parent.height / 1.5
        Layout.alignment: Qt.AlignCenter




        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            color:"transparent"


            ColumnLayout{
                anchors.fill: parent

                Rectangle {
                    id: enableSwitchContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    SGAlignedLabel {
                        id: enableSwitchLabel
                        target: enableSwitch
                        text: "Enable (EN)"
                        font.bold: true
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        SGSwitch{
                            id: enableSwitch
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel:   "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            checked: true
                            onToggled: {
                                checked ? platformInterface.set_enable.update("on") : platformInterface.set_enable.update("off")
                            }

                        }


                    }
                }

                Rectangle {
                    id: dutySliderContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    SGAlignedLabel {
                        id: dutyCycleLabel
                        target: dutySlider
                        text: "DIM#/EN Positive Duty Cycle"
                        font.bold: true
                        alignment: SGAlignedLabel.SideTopCenter
                        fontSizeMultiplier: ratioCalc * 1.5
                        anchors.centerIn: parent

                        SGSlider{
                            id: dutySlider
                            width: dutySliderContainer.width/1.5
                            from: 0
                            to: 100
                            fromText.text: "0 %"
                            toText.text: "100 %"
                            stepSize: 0.01

                            inputBox.validator: DoubleValidator {

                                top: dutySlider.to
                                bottom: dutySlider.from
                            }

                            //value: platformInterface.dim_en_duty_state.value
                            onMoved: {
                                platformInterface.set_dim_en_duty.update(value)
                            }
                            onUserSet: {
                                platformInterface.set_dim_en_duty.update(value)

                            }


                        }

                    }

                }

                Rectangle {
                    id: freqSliderContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: freqSliderLabel
                        target: freqSlider
                        text: "DIM#/EN Frequency"
                        alignment: SGAlignedLabel.SideTopCenter
                        fontSizeMultiplier: ratioCalc * 1.5
                        anchors.centerIn: parent
                        font.bold: true

                        SGSlider{
                            id: freqSlider
                            width: freqSliderContainer.width/1.5
                            from: 0
                            to: 20
                            stepSize: 0.01
                            value: 10
                            fromText.text: "0.1kHz"
                            toText.text: "20kHz"

                            inputBox.validator: DoubleValidator {
                                top: freqSlider.to
                                bottom: freqSlider.from
                            }

                            onMoved: {
                                platformInterface.set_dim_en_freq.update(value)
                            }
                            onUserSet:  {
                                platformInterface.set_dim_en_freq.update(value)
                            }

                        }
                    }
                }

                Rectangle {
                    id:ledConfig
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    SGAlignedLabel {
                        id: ledConfigLabel
                        target: ledConfigCombo
                        text: "LED Configuration"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2

                        SGComboBox {
                            id: ledConfigCombo
                            model: ["1 LED","2 LEDs","3 LEDs", "External LEDs", "Short"]
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            onActivated: {
                                if(currentIndex == 0)
                                    platformInterface.set_led.update("1_led")
                                else if(currentIndex == 1)
                                    platformInterface.set_led.update("2_leds")
                                else if (currentIndex == 2)
                                    platformInterface.set_led.update("3_leds")
                                else if(currentIndex == 3)
                                    platformInterface.set_led.update("external")
                                else  platformInterface.set_led.update("short")
                            }
                        }
                    }
                }


            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent
                        Rectangle {
                            id: vin_connContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                text: "<b>VIN_CONN</b>"
                                target: vin_conn
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5

                                font.bold : true

                                SGInfoBox {
                                    id: vin_conn
                                    height: vin_connContainer.height/2
                                    width: vin_connContainer.width/1.5
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vin_conn
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true
                                }
                            }
                        }
                        Rectangle {
                            id: vincontainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            SGAlignedLabel {
                                text: "<b>VIN</b>"
                                target: vin
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true

                                SGInfoBox {
                                    id: vin
                                    height: vincontainer.height/2
                                    width: vincontainer.width/1.5
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vin
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true
                                }
                            }
                        }
                        Rectangle {
                            id: inputCurrentContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"

                            SGAlignedLabel {
                                text: "<b>Input Current</b>"
                                target: inputCurrent
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true

                                SGInfoBox {
                                    id: inputCurrent
                                    height: inputCurrentContainer.height/2
                                    width: inputCurrentContainer.width/1.5
                                    unit: "<b>mA</b>"
                                    text: platformInterface.telemetry.gcsm
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
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
                            id: middleEmptyContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"white"
                        }
                        Rectangle {
                            id:  voutLEDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"white"
                            SGAlignedLabel {
                                text: "<b>VOUT_LED</b>"
                                target: voutLED
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGInfoBox {
                                    id: voutLED
                                    height: voutLEDContainer.height/2
                                    width: voutLEDContainer.width/1.5
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vout
                                    boxFont.family: Fonts.digitalseven
                                }

                            }
                        }

                        Rectangle {
                            id:  csCurrentContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"white"
                            SGAlignedLabel {
                                text: "<b>CS Current</b>"
                                target: csCurrent
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGInfoBox {
                                    id: csCurrent
                                    height: csCurrentContainer.height/2
                                    width: csCurrentContainer.width/1.5
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                    unit: "<b>mA</b>"
                                    text:  platformInterface.telemetry.lcsm
                                    boxFont.family: Fonts.digitalseven
                                }

                            }
                        }


                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/1.6
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: tempLabel
                                target: tempGauge
                                text: "Board \n Temperature"
                                margin: 0
                                anchors.top: parent.top
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: tempGauge
                                    property var temp_change: platformInterface.telemetry.temperature
                                    onTemp_changeChanged: {
                                        value = temp_change
                                    }

                                    tickmarkStepSize: 10
                                    minimumValue: 0
                                    maximumValue: 150
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "°C"
                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
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
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: vinLabel
                                target: osAlert
                                text:  "OS_ALERT"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true

                                property bool osAlertNoti: platformInterface.int_os_alert.value
                                onOsAlertNotiChanged: osAlert.status = osAlertNoti ? SGStatusLight.Red : SGStatusLight.Off

                                SGStatusLight {
                                    id: osAlert
                                }

                            }
                        }

                    }

                }
            }
        }

    }

    //    RowLayout {
    //        id: mainRow
    //        Layout.fillWidth: true
    //        Layout.preferredHeight: parent.height / 2
    //        Layout.alignment: Qt.AlignCenter
    //        spacing: 2
    //        //        SGCircularGauge{
    //        //            id: temperatureGauge
    //        //            Layout.preferredHeight: parent.height
    //        //            Layout.preferredWidth: parent.height

    //        //            tickmarkStepSize: 10
    //        //            minimumValue: 0
    //        //            maximumValue: 150
    //        //            value: platformInterface.telemetry.temperature
    //        //            Label {
    //        //                anchors {
    //        //                    bottom: enableSwitch.top
    //        //                    left: enableSwitch.left
    //        //                }

    //        //                text: "<b>Enable</b>"
    //        //            }
    //        //            SGSwitch{
    //        //                id: enableSwitch
    //        //                width: 65
    //        //                height: 30
    //        //                anchors {
    //        //                    centerIn: parent
    //        //                    verticalCenterOffset: parent.height / 3
    //        //                }

    //        //                checked: true
    //        //                onCheckedChanged: {
    //        //                    checked ? platformInterface.set_enable.update("on") : platformInterface.set_enable.update("off")
    //        //                }
    //        //            }
    //        //        }
    //        GridLayout {
    //            Layout.preferredWidth: 250
    //            Layout.preferredHeight: parent.height / 3

    //            rows: 3
    //            columns: 2
    //            Rectangle {
    ////                Layout.preferredHeight: 60
    ////                Layout.preferredWidth: 80
    //                Layout.fillHeight: true
    //                Layout.fillWidth: true
    //                Layout.alignment: Qt.AlignCenter
    //                color: "red"
    //                SGAlignedLabel {
    //                    text: "<b>VIN_CONN</b>"
    //                    target: vin_conn
    //                    alignment: SGAlignedLabel.SideTopCenter
    //                    anchors.centerIn: parent
    //                    fontSizeMultiplier: ratioCalc * 1.5
    //                    font.bold : true

    //                    SGInfoBox {
    //                        id: vin_conn
    //                        height: parent.height / 2
    //                        width: parent.width
    //                        unit: "<b>V</b>"
    //                        text: platformInterface.telemetry.vin_conn
    //                    }
    //                }
    //            }
    //            Item {
    //                Layout.preferredHeight: 60
    //                Layout.preferredWidth: 80
    //                Layout.alignment: Qt.AlignCenter
    //                Label {
    //                    text: "<b>VIN</b>"
    //                    anchors {
    //                        bottom: vin.top
    //                        left: vin.left
    //                    }
    //                }
    //                SGInfoBox {
    //                    id: vin
    //                    height: parent.height / 2
    //                    width: parent.width
    //                    unit: "V"
    //                    text: platformInterface.telemetry.vin
    //                }
    //            }
    //            Item {
    //                Layout.preferredHeight: 60
    //                Layout.preferredWidth: 80
    //                Layout.alignment: Qt.AlignCenter
    //                Label {
    //                    text: "<b>Input Current</b>"
    //                    anchors {
    //                        bottom: inputCurrent.top
    //                        left: inputCurrent.left
    //                    }
    //                }
    //                SGInfoBox {
    //                    id: inputCurrent
    //                    height: parent.height / 2
    //                    width: parent.width
    //                    unit: "<b>V</b>"
    //                    text: platformInterface.telemetry.gcsm

    //                }
    //            }
    //            Item {
    //                Layout.preferredHeight: 60
    //                Layout.preferredWidth: 80
    //                Layout.alignment: Qt.AlignCenter
    //                Label {
    //                    text: "<b>VOUT_LED</b>"
    //                    anchors {
    //                        bottom: voutLED.top
    //                        left: voutLED.left
    //                    }
    //                }
    //                SGInfoBox {
    //                    id: voutLED
    //                    height: parent.height / 2
    //                    width: parent.width
    //                    unit: "<b>V</b>"
    //                    text: platformInterface.telemetry.vout
    //                }
    //            }
    //            Item {
    //                Layout.preferredHeight: 60
    //                Layout.preferredWidth: 80
    //                Layout.alignment: Qt.AlignCenter
    //                Label {
    //                    text: "<b>CS Current</b>"
    //                    anchors {
    //                        bottom: csCurrent.top
    //                        left: csCurrent.left
    //                    }
    //                }
    //                SGInfoBox {
    //                    id: csCurrent
    //                    height: parent.height / 2
    //                    width: parent.width
    //                    unit: "<b>mA</b>"
    //                    text: platformInterface.telemetry.lcsm
    //                }
    //            }
    //            Item {
    //                Layout.preferredHeight: 60
    //                Layout.preferredWidth: 80
    //                Layout.alignment: Qt.AlignCenter
    //            }
    //        }
    //    } // row ends
    //    CustomSlider{
    //        id: dutySlider
    //        Layout.preferredWidth: mainRow.width
    //        Layout.alignment: Qt.AlignHCenter

    //        from: 0
    //        to: 1
    //        stepSize: 0.01
    //        startLabel: "0%"
    //        endLabel: "100%"
    //        value: platformInterface.dim_en_ctrl_state.value
    //        onValueChanged: {
    //            platformInterface.set_dim_en_duty.update(value)
    //        }
    //        Label {
    //            text: "<b>DIM#/EN Positive Duty Cycle</b>"
    //            anchors {
    //                bottom: parent.top
    //                left: parent.left
    //            }
    //        }
    //    }
    //    CustomSlider{
    //        id: freqSlider
    //        Layout.preferredWidth: mainRow.width
    //        Layout.alignment: Qt.AlignHCenter

    //        from: 0
    //        to: 20
    //        stepSize: 0.01
    //        value: 10
    //        startLabel: "0.1kHz"
    //        endLabel: "20kHz"
    //        onValueChanged: {
    //            platformInterface.set_dim_en_frequency.update(value)
    //        }
    //        Label {
    //            text: "<b>DIM#/EN Frequency</b>"
    //            anchors {
    //                bottom: parent.top
    //                left: parent.left
    //            }
    //        }
    //    }
    //    SGComboBox{
    //        id: ledConfig
    //        Label {
    //            text: "LED Configuration"
    //            anchors {
    //                bottom: parent.top
    //                left: parent.left
    //            }
    //        }
    //        Layout.preferredWidth: mainRow.width / 2
    //        Layout.alignment: Qt.AlignHCenter
    //        model: ["1 LED","2 LED","3 LED", "external LED"]
    //        onCurrentTextChanged: {
    //            platformInterface.set_led.update(currentText)
    //        }
    //    }
}



