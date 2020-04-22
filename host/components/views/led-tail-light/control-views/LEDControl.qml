import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    //   anchors.centerIn: parent
    //    height: parent.height
    //    width: parent.width/parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

    //    property var led_OL_value: platformInterface.led_OL_value.value
    //    onLed_OL_valueChanged: {
    //        if(led_OL_value === true)
    //            ol.status = SGStatusLight.Red
    //        else ol.status = SGStatusLight.Off
    //    }

    //    property var led_DIAGERR_value: platformInterface.led_DIAGERR_value.value
    //    onLed_DIAGERR_valueChanged: {
    //        if(led_DIAGERR_value === true)
    //            diagree.status = SGStatusLight.Red
    //        else diagree.status = SGStatusLight.Off
    //    }

    //    property var led_TSD_value: platformInterface.led_TSD_value.value
    //    onLed_TSD_valueChanged: {
    //        if(led_TSD_value === true)
    //            tsd.status = SGStatusLight.Red
    //        else tsd.status = SGStatusLight.Off
    //    }

    //    property var led_TW_value: platformInterface.led_TW_value.value
    //    onLed_TW_valueChanged: {
    //        if(led_TW_value === true)
    //            tw.status = SGStatusLight.Red
    //        else tw.status = SGStatusLight.Off
    //    }

    //    property var led_diagRange_value: platformInterface.led_diagRange_value.value
    //    onLed_diagRange_valueChanged: {
    //        if(led_diagRange_value === true)
    //            diagRange.status = SGStatusLight.Red
    //        else diagRange.status = SGStatusLight.Off
    //    }

    //    property var led_UV_value: platformInterface.led_UV_value.value
    //    onLed_UV_valueChanged: {
    //        if(led_UV_value === true)
    //            uv.status = SGStatusLight.Red
    //        else uv.status = SGStatusLight.Off
    //    }

    //    property var led_I2Cerr_value: platformInterface.led_I2Cerr_value.value
    //    onLed_I2Cerr_valueChanged: {
    //        if(led_I2Cerr_value === true)
    //            i2Cerr.status = SGStatusLight.Red
    //        else i2Cerr.status = SGStatusLight.Off
    //    }

    //    property var led_SC_Iset_value: platformInterface.led_SC_Iset_value.value
    //    onLed_SC_Iset_valueChanged: {
    //        if(led_SC_Iset_value === true)
    //            scIset.status = SGStatusLight.Red
    //        else scIset.status = SGStatusLight.Off
    //    }

    //    property var led_ch_enable_read_values: platformInterface.led_ch_enable_read_values.values
    //    onLed_ch_enable_read_valuesChanged: {
    //        if(led_ch_enable_read_values[0] === true)
    //            scIset.status = SGStatusLight.Red

    //    }

    property var led_out_en_state: platformInterface.led_out_en_state.state
    onLed_out_en_stateChanged: {
        if(led_out_en_state === "enabled") {
            out0ENLED.enabled = true
            out0ENLED.opacity = 1.0

            out1ENLED.enabled = true
            out1ENLED.opacity = 1.0

            out2ENLED.enabled = true
            out2ENLED.opacity = 1.0

            out3ENLED.enabled = true
            out3ENLED.opacity = 1.0

            out4ENLED.enabled = true
            out4ENLED.opacity = 1.0

            out5ENLED.enabled = true
            out5ENLED.opacity = 1.0

            out6ENLED.enabled = true
            out6ENLED.opacity = 1.0

            out7ENLED.enabled = true
            out7ENLED.opacity = 1.0

            out8ENLED.enabled = true
            out8ENLED.opacity = 1.0

            out9ENLED.enabled = true
            out9ENLED.opacity = 1.0

            out10ENLED.enabled = true
            out10ENLED.opacity = 1.0

            out11ENLED.enabled = true
            out11ENLED.opacity = 1.0

        }
        else if (led_out_en_state === "disabled") {
            out0ENLED.enabled = false
            out0ENLED.opacity = 1.0

            out1ENLED.enabled = false
            out1ENLED.opacity = 1.0

            out2ENLED.enabled = false
            out2ENLED.opacity = 1.0

            out3ENLED.enabled = false
            out3ENLED.opacity = 1.0

            out4ENLED.enabled = false
            out4ENLED.opacity = 1.0

            out5ENLED.enabled = false
            out5ENLED.opacity = 1.0

            out6ENLED.enabled = false
            out6ENLED.opacity = 1.0

            out7ENLED.enabled = false
            out7ENLED.opacity = 1.0

            out8ENLED.enabled = false
            out8ENLED.opacity = 1.0

            out9ENLED.enabled = false
            out9ENLED.opacity = 1.0

            out10ENLED.enabled = false
            out10ENLED.opacity = 1.0

            out11ENLED.enabled = false
            out11ENLED.opacity = 1.0

        }
        else {
            out0ENLED.enabled = false
            out0ENLED.opacity = 0.5

            out1ENLED.enabled = false
            out1ENLED.opacity = 0.5

            out2ENLED.enabled = false
            out2ENLED.opacity = 0.5

            out3ENLED.enabled = false
            out3ENLED.opacity = 0.5

            out4ENLED.enabled = false
            out4ENLED.opacity = 0.5

            out5ENLED.enabled = false
            out5ENLED.opacity = 0.5

            out6ENLED.enabled = false
            out6ENLED.opacity = 0.5

            out7ENLED.enabled = false
            out7ENLED.opacity = 0.5

            out8ENLED.enabled = false
            out8ENLED.opacity = 0.5

            out9ENLED.enabled = false
            out9ENLED.opacity = 0.5

            out10ENLED.enabled = false
            out10ENLED.opacity = 0.5

            out11ENLED.enabled = false
            out11ENLED.opacity = 0.5
        }
    }

    property var led_out_en_values: platformInterface.led_out_en_values.values
    onLed_out_en_valuesChanged:  {
        if(led_out_en_values[0] === true)
            out0ENLED.checked = true
        else out0ENLED.checked = false

        if(led_out_en_values[1] === true)
            out1ENLED.checked = true
        else out1ENLED.checked = false

        if(led_out_en_values[2] === true)
            out2ENLED.checked = true
        else out2ENLED.checked = false

        if(led_out_en_values[3] === true)
            out3ENLED.checked = true
        else out3ENLED.checked = false

        if(led_out_en_values[4] === true)
            out4ENLED.checked = true
        else out4ENLED.checked = false

        if(led_out_en_values[5] === true)
            out5ENLED.checked = true
        else out5ENLED.checked = false

        if(led_out_en_values[6] === true)
            out6ENLED.checked = true
        else out6ENLED.checked = false

        if(led_out_en_values[7] === true)
            out7ENLED.checked = true
        else out7ENLED.checked = false

        if(led_out_en_values[8] === true)
            out8ENLED.checked = true
        else out8ENLED.checked = false

        if(led_out_en_values[9] === true)
            out9ENLED.checked = true
        else out9ENLED.checked = false

        if(led_out_en_values[10] === true)
            out10ENLED.checked = true
        else out10ENLED.checked = false

        if(led_out_en_values[11] === true)
            out11ENLED.checked = true
        else out11ENLED.checked = false
    }



    property var led_ext_values: platformInterface.led_ext_values.values
    onLed_ext_valuesChanged:  {
        if(led_ext_values[0] === true)
            out0interExterLED.checked = true
        else out0interExterLED.checked = false

        if(led_ext_values[1] === true)
            out1interExterLED.checked = true
        else out1interExterLED.checked = false

        if(led_ext_values[2] === true)
            out2interExterLED.checked = true
        else out2interExterLED.checked = false

        if(led_ext_values[3] === true)
            out3interExterLED.checked = true
        else out3interExterLED.checked = false

        if(led_ext_values[4] === true)
            out4interExterLED.checked = true
        else out4interExterLED.checked = false

        if(led_ext_values[5] === true)
            out5interExterLED.checked = true
        else out5interExterLED.checked = false

        if(led_ext_values[6] === true)
            out6interExterLED.checked = true
        else out6interExterLED.checked = false

        if(led_ext_values[7] === true)
            out7interExterLED.checked = true
        else out7interExterLED.checked = false

        if(led_ext_values[8] === true)
            out8interExterLED.checked = true
        else out8interExterLED.checked = false

        if(led_ext_values[9] === true)
            out9interExterLED.checked = true
        else out9interExterLED.checked = false

        if(led_ext_values[10] === true)
            out10interExterLED.checked = true
        else out10interExterLED.checked = false

        if(led_ext_values[11] === true)
            out11interExterLED.checked = true
        else out11interExterLED.checked = false
    }

    property var led_fault_status_values: platformInterface.led_fault_status_values.values
    onLed_fault_status_valuesChanged: {
        if(led_fault_status_values[0] === false)
            out0faultStatusLED.status = SGStatusLight.Off
        else  out0faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[1] === false)
            out1faultStatusLED.status = SGStatusLight.Off
        else  out1faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[2] === false)
            out2faultStatusLED.status = SGStatusLight.Off
        else  out2faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[3] === false)
            out3faultStatusLED.status = SGStatusLight.Off
        else  out3faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[4] === false)
            out4faultStatusLED.status = SGStatusLight.Off
        else  out4faultStatusLED.status = SGStatusLight.Red


        if(led_fault_status_values[5] === false)
            out5faultStatusLED.status = SGStatusLight.Off
        else  out5faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[6] === false)
            out6faultStatusLED.status = SGStatusLight.Off
        else  out6faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[7] === false)
            out7faultStatusLED.status = SGStatusLight.Off
        else  out7faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[8] === false)
            out8faultStatusLED.status = SGStatusLight.Off
        else  out8faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[9] === false)
            out9faultStatusLED.status = SGStatusLight.Off
        else  out9faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[10] === false)
            out10faultStatusLED.status = SGStatusLight.Off
        else  out10faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[11] === false)
            out11faultStatusLED.status = SGStatusLight.Off
        else  out11faultStatusLED.status = SGStatusLight.Red

    }

    property var led_pwm_enable_values: platformInterface.led_pwm_enable_values.values
    onLed_pwm_enable_valuesChanged: {
        if(led_pwm_enable_values[0] === true)
            out0pwmEnableLED.checked = true
        else out0pwmEnableLED.checked = false

        if(led_pwm_enable_values[1] === true)
            out1pwmEnableLED.checked = true
        else out1pwmEnableLED.checked = false

        if(led_pwm_enable_values[2] === true)
            out2pwmEnableLED.checked = true
        else out2pwmEnableLED.checked = false

        if(led_pwm_enable_values[3] === true)
            out3pwmEnableLED.checked = true
        else out3pwmEnableLED.checked = false

        if(led_pwm_enable_values[4] === true)
            out4pwmEnableLED.checked = true
        else out4pwmEnableLED.checked = false

        if(led_pwm_enable_values[5] === true)
            out5pwmEnableLED.checked = true
        else out5pwmEnableLED.checked = false

        if(led_pwm_enable_values[6] === true)
            out6pwmEnableLED.checked = true
        else out6pwmEnableLED.checked = false

        if(led_pwm_enable_values[7] === true)
            out7pwmEnableLED.checked = true
        else out7pwmEnableLED.checked = false

        if(led_pwm_enable_values[8] === true)
            out8pwmEnableLED.checked = true
        else out8pwmEnableLED.checked = false

        if(led_pwm_enable_values[9] === true)
            out9pwmEnableLED.checked = true
        else out9pwmEnableLED.checked = false

        if(led_pwm_enable_values[10] === true)
            out10pwmEnableLED.checked = true
        else out10pwmEnableLED.checked = false

        if(led_pwm_enable_values[11] === true)
            out11pwmEnableLED.checked = true
        else out11pwmEnableLED.checked = false

    }

    property var led_pwm_enable_state: platformInterface.led_pwm_enable_state.state
    onLed_pwm_enable_stateChanged: {
        if(led_pwm_enable_state === "enabled") {
            out0pwmEnableLED.enabled = true
            out0pwmEnableLED.opacity = 1.0

            out1pwmEnableLED.enabled = true
            out1pwmEnableLED.opacity = 1.0

            out2pwmEnableLED.enabled = true
            out2pwmEnableLED.opacity = 1.0

            out3pwmEnableLED.enabled = true
            out3pwmEnableLED.opacity = 1.0

            out4pwmEnableLED.enabled = true
            out4pwmEnableLED.opacity = 1.0

            out5pwmEnableLED.enabled = true
            out5pwmEnableLED.opacity = 1.0

            out6pwmEnableLED.enabled = true
            out6pwmEnableLED.opacity = 1.0

            out7pwmEnableLED.enabled = true
            out7pwmEnableLED.opacity = 1.0

            out8pwmEnableLED.enabled = true
            out8pwmEnableLED.opacity = 1.0

            out9pwmEnableLED.enabled = true
            out9pwmEnableLED.opacity = 1.0

            out10pwmEnableLED.enabled = true
            out10pwmEnableLED.opacity = 1.0

            out11pwmEnableLED.enabled = true
            out11pwmEnableLED.opacity = 1.0

        }
        else if (led_pwm_enable_state === "disabled") {
            out0pwmEnableLED.enabled = false
            out0pwmEnableLED.opacity = 1.0

            out1pwmEnableLED.enabled = false
            out1pwmEnableLED.opacity = 1.0

            out2pwmEnableLED.enabled = false
            out2pwmEnableLED.opacity = 1.0

            out3pwmEnableLED.enabled = false
            out3pwmEnableLED.opacity = 1.0

            out4pwmEnableLED.enabled = false
            out4pwmEnableLED.opacity = 1.0

            out5pwmEnableLED.enabled = false
            out5pwmEnableLED.opacity = 1.0

            out6pwmEnableLED.enabled = false
            out6pwmEnableLED.opacity = 1.0

            out7pwmEnableLED.enabled = false
            out7pwmEnableLED.opacity = 1.0

            out8pwmEnableLED.enabled = false
            out8pwmEnableLED.opacity = 1.0

            out9pwmEnableLED.enabled = false
            out9pwmEnableLED.opacity = 1.0

            out10pwmEnableLED.enabled = false
            out10pwmEnableLED.opacity = 1.0

            out11pwmEnableLED.enabled = false
            out11pwmEnableLED.opacity = 1.0

        }
        else {
            out0pwmEnableLED.enabled = false
            out0pwmEnableLED.opacity = 0.5

            out1pwmEnableLED.enabled = false
            out1pwmEnableLED.opacity = 0.5

            out2pwmEnableLED.enabled = false
            out2pwmEnableLED.opacity = 0.5

            out3pwmEnableLED.enabled = false
            out3pwmEnableLED.opacity = 0.5

            out4pwmEnableLED.enabled = false
            out4pwmEnableLED.opacity = 0.5

            out5pwmEnableLED.enabled = false
            out5pwmEnableLED.opacity = 0.5

            out6pwmEnableLED.enabled = false
            out6pwmEnableLED.opacity = 0.5

            out7pwmEnableLED.enabled = false
            out7pwmEnableLED.opacity = 0.5

            out8pwmEnableLED.enabled = false
            out8pwmEnableLED.opacity = 0.5

            out9pwmEnableLED.enabled = false
            out9pwmEnableLED.opacity = 0.5

            out10pwmEnableLED.enabled = false
            out10pwmEnableLED.opacity = 0.5

            out11pwmEnableLED.enabled = false
            out11pwmEnableLED.opacity = 0.5
        }
    }

    property var led_pwm_duty_values: platformInterface.led_pwm_duty_values.values
    onLed_pwm_duty_valuesChanged: {
        out0duty.value = led_pwm_duty_values[0]
        out1duty.value = led_pwm_duty_values[1]
        out2duty.value = led_pwm_duty_values[2]
        out3duty.value = led_pwm_duty_values[3]
        out4duty.value = led_pwm_duty_values[4]

        out5duty.value = led_pwm_duty_values[5]
        out6duty.value = led_pwm_duty_values[6]
        out7duty.value = led_pwm_duty_values[7]

        out8duty.value = led_pwm_duty_values[8]
        out9duty.value = led_pwm_duty_values[9]
        out10duty.value = led_pwm_duty_values[10]
        out11duty.value = led_pwm_duty_values[11]
    }

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: leftSetting
            Layout.fillHeight: true
            Layout.preferredWidth: root.width/3
            // color: "red"

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //color: "red"
                    SGAlignedLabel {
                        id: enableOutputLabel
                        target: enableOutput
                        // text: "Output Enable (OEN)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: enableOutput
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
//                            textColor: "black"              // Default: "black"
//                            handleColor: "white"            // Default: "white"
//                            grooveColor: "#ccc"             // Default: "#ccc"
//                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false

                            property var led_oen_caption: platformInterface.led_oen_caption.caption
                            onLed_oen_captionChanged : {
                                enableOutputLabel.text = led_oen_caption
                            }

                            property var led_oen_state: platformInterface.led_oen_state.state
                            onLed_oen_stateChanged : {
                                if(led_oen_state === "enabled" ) {
                                    enableOutput.enabled = true
                                    enableOutput.opacity = 1.0

                                }
                                else if(led_oen_state === "disabled") {
                                    enableOutput.enabled = false
                                    enableOutput.opacity = 1.0
                                   // enableOutput.uncheckedLabel.opacity = 1.0
                                }
                                else {
                                    enableOutput.enabled = false
                                    enableOutput.opacity = 0.5
                                   // enableOutput.uncheckedLabel.opacity = 0.0

                                }
                            }

                            property var led_oen_value: platformInterface.led_oen_value.value
                            onLed_oen_valueChanged : {
                                if(led_oen_value === true)
                                    enableOutput.checked = true
                                else  enableOutput.checked = false


                            }


                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: lockPWMDutyLabel
                        target: lockPWMDuty
                        text: "Lock PWM Duty Together"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: lockPWMDuty
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: lockPWMDutyENLabel
                        target: lockPWMDutyEN
                        text: "Lock PWM EN Together"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter

                        SGSwitch {
                            id: lockPWMDutyEN
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: pwmLinearLogLabel
                        target: pwmLinearLog
                        text: "PWM Linear/Log"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        //horizontalAlignment: Text.AlignHCenter

                        SGSwitch {
                            id: pwmLinearLog
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //color: "red"

                    SGAlignedLabel {
                        id: autoFaultRecoveryLabel
                        target: autoFaultRecovery
                        text: "Auto Fault Recovery"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: autoFaultRecovery
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: label
                        target: labelSwitch
                        text: "?"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: labelSwitch
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: pwmFrequencyLabel
                        target: pwmFrequency
                        text: "PWM Frequency (Hz)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGComboBox {
                            id: pwmFrequency
                            fontSizeMultiplier: ratioCalc
                            model: ["150", "250", "300"]
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: openLoadLabel
                        target: openLoadDiagnostic
                        text: "I2C Open Load\nDiagnostic"
                        alignment: SGAlignedLabel.SideLeftCenter

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGComboBox {
                            id: openLoadDiagnostic
                            fontSizeMultiplier: ratioCalc
                            model: ["No Diagnostic", "Auto Retry", "Detect Only", "No Regulations\nChange"]
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rightSetting
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"

            ColumnLayout{
                anchors.fill: parent
                anchors.right: parent.right
                anchors.rightMargin: 15


                Rectangle {
                    Layout.preferredHeight: parent.height/1.2
                    Layout.fillWidth: true
                    //color: "red"
                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //color: "grey"
                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width/12
                                    //color: "blue"
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id: ledoutEnLabel
                                                //text: "<b>" + qsTr("OUT EN") + "</b>"
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter

                                                property var led_out_en_caption: platformInterface.led_out_en_caption.caption
                                                onLed_out_en_captionChanged: {
                                                    ledoutEnLabel.text =   led_out_en_caption
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id: externalLED
                                                //text: "Internal \n External LED"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter


                                                property var led_ext_caption: platformInterface.led_ext_caption.caption
                                                onLed_ext_captionChanged: {
                                                    externalLED.text =   led_ext_caption
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id: pwmEnableText
                                                // text: "<b>" + qsTr("PWM Enable") + "</b>"
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                property var led_pwm_enable_caption: platformInterface.led_pwm_enable_caption.caption
                                                onLed_pwm_enable_captionChanged: {
                                                    pwmEnableText.text =  led_pwm_enable_caption
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id:faultText
                                                // text: "<b>" + qsTr("Fault Status") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                font.bold: true

                                                property var led_fault_status_caption: platformInterface.led_fault_status_caption.caption
                                                onLed_fault_status_captionChanged: {
                                                    faultText.text =  led_fault_status_caption
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            // color: "red"
                                            SGText {
                                                id: pwmDutyText
                                                font.bold: true
                                                //text: "<b>" + qsTr("PWM Duty (%)") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter

                                                property var led_pwm_duty_caption: platformInterface.led_pwm_duty_caption.caption
                                                onLed_pwm_duty_captionChanged: {
                                                    pwmDutyText.text = led_pwm_duty_caption
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    //color: "blue"

                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                id: text1
                                                text: "<b>" + qsTr("OUT0") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            // color: "blue"


                                            SGSwitch {
                                                id: out0ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {


                                                id: out0interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGSwitch {
                                                id: out0pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }


                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out0faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out0duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out0duty.from = led_pwm_duty_scales[0]
                                                    out0duty.to = led_pwm_duty_scales[1]
                                                    out0duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out0duty.enabled = true
                                                        out0duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out0duty.enabled = false
                                                        out0duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out0duty.enabled = false
                                                        out0duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10

                                            SGText {
                                                text: "<b>" + qsTr("OUT1") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out1ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGSwitch {
                                                id: out1interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out1pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out1faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out1duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out1duty.from = led_pwm_duty_scales[0]
                                                    out1duty.to = led_pwm_duty_scales[1]
                                                    out1duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out1duty.enabled = true
                                                        out1duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out1duty.enabled = false
                                                        out1duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out1duty.enabled = false
                                                        out1duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT2") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out2ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out2interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out2pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out2faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            // color: "red"

                                            CustomizeRGBSlider {
                                                id: out2duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out2duty.from = led_pwm_duty_scales[0]
                                                    out2duty.to = led_pwm_duty_scales[1]
                                                    out2duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out2duty.enabled = true
                                                        out2duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out2duty.enabled = false
                                                        out2duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out2duty.enabled = false
                                                        out2duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT3") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGSwitch {
                                                id: out3ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out3interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out3pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out3faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out3duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out3duty.from = led_pwm_duty_scales[0]
                                                    out3duty.to = led_pwm_duty_scales[1]
                                                    out3duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out3duty.enabled = true
                                                        out3duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out3duty.enabled = false
                                                        out3duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out3duty.enabled = false
                                                        out3duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT4") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out4ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out4interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out4pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out4faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out4duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out4duty.from = led_pwm_duty_scales[0]
                                                    out4duty.to = led_pwm_duty_scales[1]
                                                    out4duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out4duty.enabled = true
                                                        out4duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out4duty.enabled = false
                                                        out4duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out4duty.enabled = false
                                                        out4duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT5") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out5ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out5interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out5pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out5faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }

                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out5duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out5duty.from = led_pwm_duty_scales[0]
                                                    out5duty.to = led_pwm_duty_scales[1]
                                                    out5duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out5duty.enabled = true
                                                        out5duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out5duty.enabled = false
                                                        out5duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out5duty.enabled = false
                                                        out5duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT6") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGSwitch {
                                                id: out6ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out6interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out6pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out6faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out6duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out6duty.from = led_pwm_duty_scales[0]
                                                    out6duty.to = led_pwm_duty_scales[1]
                                                    out6duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out6duty.enabled = true
                                                        out6duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out6duty.enabled = false
                                                        out6duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out6duty.enabled = false
                                                        out6duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT7") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out7ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out7interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out7pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out7faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out7duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0

                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out7duty.from = led_pwm_duty_scales[0]
                                                    out7duty.to = led_pwm_duty_scales[1]
                                                    out7duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out7duty.enabled = true
                                                        out7duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out7duty.enabled = false
                                                        out7duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out7duty.enabled = false
                                                        out7duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT8") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out8ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out8interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out8pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out8faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out8duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out8duty.from = led_pwm_duty_scales[0]
                                                    out8duty.to = led_pwm_duty_scales[1]
                                                    out8duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out8duty.enabled = true
                                                        out8duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out8duty.enabled = false
                                                        out8duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out8duty.enabled = false
                                                        out8duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT9") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out9ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out9interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out9pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out9faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out9duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out9duty.from = led_pwm_duty_scales[0]
                                                    out9duty.to = led_pwm_duty_scales[1]
                                                    out9duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out9duty.enabled = true
                                                        out9duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out9duty.enabled = false
                                                        out9duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out9duty.enabled = false
                                                        out9duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT10") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out10ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out10interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out10pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out10faultStatusLED
                                                width: 30
                                                anchors.left: parent.left
                                                anchors.leftMargin: 5
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out10duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out10duty.from = led_pwm_duty_scales[0]
                                                    out10duty.to = led_pwm_duty_scales[1]
                                                    out10duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out10duty.enabled = true
                                                        out10duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out10duty.enabled = false
                                                        out10duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out10duty.enabled = false
                                                        out10duty.opacity = 0.5
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT11") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out11ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out11interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out11pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out11faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out11duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                value: 50
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out11duty.from = led_pwm_duty_scales[0]
                                                    out11duty.to = led_pwm_duty_scales[1]
                                                    out11duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out11duty.enabled = true
                                                        out11duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out11duty.enabled = false
                                                        out11duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out11duty.enabled = false
                                                        out11duty.opacity = 0.5
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: gobalCurrentSetContainer
                            Layout.preferredHeight: parent.height/10
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: gobalCurrentSetLabel
                                target: gobalCurrentSetSlider
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                //text: "Gobal Current Set (ISET)"
                                SGSlider {
                                    id: gobalCurrentSetSlider
                                    width: gobalCurrentSetContainer.width/1.5
                                    live: false
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    //                                    to: 60
                                    //                                    from: 0
                                    // stepSize: 1
                                    //                                    toText.text: "60mA"
                                    //                                    fromText.text: "0mA"
                                }

                                property var led_iset_caption: platformInterface.led_iset_caption.caption
                                onLed_iset_captionChanged:{
                                    gobalCurrentSetLabel.text = led_iset_caption
                                }

                                property var led_iset_scales: platformInterface.led_iset_scales.scales
                                onLed_iset_scalesChanged: {
                                    gobalCurrentSetSlider.toText.text = led_iset_scales[0] + "mA"
                                    gobalCurrentSetSlider.to = led_iset_scales[0]
                                    gobalCurrentSetSlider.fromText.text = led_iset_scales[1] + "mA"
                                    gobalCurrentSetSlider.from = led_iset_scales[1]
                                    gobalCurrentSetSlider.stepSize = led_iset_scales[2]

                                }

                                property var led_iset_state: platformInterface.led_iset_state.state
                                onLed_iset_stateChanged:{
                                    if(led_iset_state === "enabled") {
                                        gobalCurrentSetLabel.enabled = true
                                        gobalCurrentSetLabel.opacity = 1.0
                                    }
                                    else if (led_iset_state === "disabled") {
                                        gobalCurrentSetLabel.enabled = false
                                        gobalCurrentSetLabel.opacity = 1.0
                                    }
                                    else  {
                                        gobalCurrentSetLabel.enabled = false
                                        gobalCurrentSetLabel.opacity = 0.5
                                    }

                                }


                                property var led_iset_value: platformInterface.led_iset_value.value
                                onLed_iset_valueChanged: {
                                    gobalCurrentSetSlider.value = led_iset_value
                                }



                            }
                        }
                    }
                }


                Rectangle {
                    id: i2cStatusSettingContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //  color: "red"

                    SGText{
                        id: i2cStatusLable
                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "I2C Status Registers"
                        font.bold: true
                        anchors.top: parent. top
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    Rectangle {
                        id: i2cLEDS
                        anchors.top: i2cStatusLable.bottom
                        anchors.centerIn: parent
                        width: parent.width - 100
                        height: parent.height - i2cStatusLable.contentHeight
                        color: "transparent"

                        RowLayout{
                            anchors.fill: parent

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: scIsetLabel
                                    target: scIset
                                    //text:  "SC_Iset"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: scIset
                                        width: 30

                                        property var led_sc_iset_caption: platformInterface.led_sc_iset_caption.caption
                                        onLed_sc_iset_captionChanged: {
                                            scIsetLabel.text =  led_sc_iset_caption
                                        }

                                        property var led_sc_iset_state: platformInterface.led_sc_iset_state.state
                                        onLed_sc_iset_stateChanged: {
                                            if(led_sc_iset_state === "enabled") {
                                                scIsetLabel.enabled = true
                                                scIsetLabel.opacity = 1.0
                                            }
                                            else if (led_sc_iset_state === "disabled") {
                                                scIsetLabel.enabled = false
                                                scIsetLabel.opacity = 1.0
                                            }
                                            else  {
                                                scIsetLabel.enabled = false
                                                scIsetLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_sc_iset_value: platformInterface.led_sc_iset_value.value
                                        onLed_sc_iset_valueChanged: {
                                            if(led_sc_iset_value === false) {
                                                scIset.status = SGStatusLight.Off
                                            }
                                            else  scIset.status = SGStatusLight.Red
                                        }



                                    }
                                }

                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: i2CerrLabel
                                    target: i2Cerr
                                    //text:  "I2Cerr"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: i2Cerr
                                        width: 30

                                        property var led_i2cerr_caption: platformInterface.led_i2cerr_caption.caption
                                        onLed_i2cerr_captionChanged: {
                                            i2CerrLabel.text =  led_i2cerr_caption
                                        }

                                        property var led_i2cerr_state: platformInterface.led_i2cerr_state.state
                                        onLed_i2cerr_stateChanged: {
                                            if(led_i2cerr_state === "enabled") {
                                                i2CerrLabel.enabled = true
                                                i2CerrLabel.opacity = 1.0
                                            }
                                            else if (led_i2cerr_state === "disabled") {
                                                i2CerrLabel.enabled = false
                                                i2CerrLabel.opacity = 1.0
                                            }
                                            else  {
                                                i2CerrLabel.enabled = false
                                                i2CerrLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_i2cerr_value: platformInterface.led_i2cerr_value.value
                                        onLed_i2cerr_valueChanged: {
                                            if(led_i2cerr_value === false) {
                                                i2Cerr.status = SGStatusLight.Off
                                            }
                                            else  i2Cerr.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: uvLabel
                                    target: uv
                                    //text:  "UV"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: uv
                                        width: 30

                                        property var led_uv_caption: platformInterface.led_uv_caption.caption
                                        onLed_uv_captionChanged: {
                                            uvLabel.text =  led_uv_caption
                                        }

                                        property var led_uv_state: platformInterface.led_uv_state.state
                                        onLed_uv_stateChanged: {
                                            if(led_uv_state === "enabled") {
                                                uvLabel.enabled = true
                                                uvLabel.opacity = 1.0
                                            }
                                            else if (led_uv_state === "disabled") {
                                                uvLabel.enabled = false
                                                uvLabel.opacity = 1.0
                                            }
                                            else  {
                                                uvLabel.enabled = false
                                                uvLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_uv_value: platformInterface.led_uv_value.value
                                        onLed_uv_valueChanged: {
                                            if(led_uv_value === false)
                                                uv.status = SGStatusLight.Off

                                            else  uv.status = SGStatusLight.Red
                                        }

                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: diagRangeLabel
                                    target: diagRange
                                    //text:  "diagRange"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagRange
                                        width: 30

                                        property var led_diagrange_caption: platformInterface.led_diagrange_caption.caption
                                        onLed_diagrange_captionChanged: {
                                            diagRangeLabel.text =  led_diagrange_caption
                                        }

                                        property var led_diagrange_state: platformInterface.led_diagrange_state.state
                                        onLed_diagrange_stateChanged: {
                                            if(led_diagrange_state === "enabled") {
                                                diagRangeLabel.enabled = true
                                                diagRangeLabel.opacity = 1.0
                                            }
                                            else if (led_diagrange_state === "disabled") {
                                                diagRangeLabel.enabled = false
                                                diagRangeLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagRangeLabel.enabled = false
                                                diagRangeLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_diagrange_value: platformInterface.led_diagrange_value.value
                                        onLed_diagrange_valueChanged: {
                                            if(led_diagrange_value === false)
                                                diagRange.status = SGStatusLight.Off

                                            else  diagRange.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: twLabel
                                    target: tw

                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tw
                                        width: 30

                                        property var led_tw_caption: platformInterface.led_tw_caption.caption
                                        onLed_tw_captionChanged: {
                                            twLabel.text =  led_tw_caption
                                        }

                                        property var led_tw_state: platformInterface.led_tw_state.state
                                        onLed_tw_stateChanged: {
                                            if(led_tw_state === "enabled") {
                                                twLabel.enabled = true
                                                twLabel.opacity = 1.0
                                            }
                                            else if (led_tw_state === "disabled") {
                                                twLabel.enabled = false
                                                twLabel.opacity = 1.0
                                            }
                                            else  {
                                                twLabel.enabled = false
                                                twLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_tw_value: platformInterface.led_tw_value.value
                                        onLed_tw_valueChanged: {
                                            if(led_tw_value === false)
                                                tw.status = SGStatusLight.Off

                                            else  tw.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: tsdLabel
                                    target: tsd

                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tsd
                                        width: 30

                                        property var led_tsd_caption: platformInterface.led_tsd_caption.caption
                                        onLed_tsd_captionChanged: {
                                            tsdLabel.text =  led_tsd_caption
                                        }

                                        property var led_tsd_state: platformInterface.led_tsd_state.state
                                        onLed_tsd_stateChanged: {
                                            if(led_tsd_state === "enabled") {
                                                tsdLabel.enabled = true
                                                tsdLabel.opacity = 1.0
                                            }
                                            else if (led_tsd_state === "disabled") {
                                                tsdLabel.enabled = false
                                                tsdLabel.opacity = 1.0
                                            }
                                            else  {
                                                tsdLabel.enabled = false
                                                tsdLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_tsd_value: platformInterface.led_tsd_value.value
                                        onLed_tsd_valueChanged: {
                                            if(led_tsd_value === false)
                                                tsd.status = SGStatusLight.Off

                                            else  tsd.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: diagerrLabel
                                    target: diagerr

                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagerr
                                        width: 30

                                        property var led_diagerr_caption: platformInterface.led_diagerr_caption.caption
                                        onLed_diagerr_captionChanged: {
                                            diagerrLabel.text =  led_diagerr_caption
                                        }

                                        property var led_diagerr_state: platformInterface.led_tsd_state.state
                                        onLed_diagerr_stateChanged: {
                                            if(led_diagerr_state === "enabled") {
                                                diagerrLabel.enabled = true
                                                diagerrLabel.opacity = 1.0
                                            }
                                            else if (led_diagerr_state === "disabled") {
                                                diagerrLabel.enabled = false
                                                diagerrLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagerrLabel.enabled = false
                                                diagerrLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_diagerr_value: platformInterface.led_diagerr_value.value
                                        onLed_diagerr_valueChanged: {
                                            if(led_diagerr_value === false)
                                                diagerr.status = SGStatusLight.Off

                                            else  diagerr.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: olLabel
                                    target: ol

                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: ol
                                        width: 30

                                        property var led_ol_caption: platformInterface.led_ol_caption.caption
                                        onLed_ol_captionChanged: {
                                            olLabel.text =  led_ol_caption
                                        }

                                        property var led_ol_state: platformInterface.led_ol_state.state
                                        onLed_ol_stateChanged: {
                                            if(led_ol_state === "enabled") {
                                                olLabel.enabled = true
                                                olLabel.opacity = 1.0
                                            }
                                            else if (led_ol_state === "disabled") {
                                                olLabel.enabled = false
                                                olLabel.opacity = 1.0
                                            }
                                            else  {
                                                olLabel.enabled = false
                                                olLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_ol_value: platformInterface.led_ol_value.value
                                        onLed_ol_valueChanged: {
                                            if(led_ol_value === false)
                                                ol.status = SGStatusLight.Off

                                            else  ol.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width/8
                                SGButton {
                                    id:  exportButton
                                    text: qsTr("Export Registers")
                                    anchors.verticalCenter: parent.verticalCenter
                                    fontSizeMultiplier: ratioCalc
                                    color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                    hoverEnabled: true
                                    MouseArea {
                                        hoverEnabled: true
                                        anchors.fill: parent
                                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

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



