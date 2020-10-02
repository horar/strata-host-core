import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0

CustomControl {
    id: root
    title: qsTr("PWM Heat Generator & \n I2C Temp Sensor")

    // UI state & notification
    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(pwmsliderLabel, "This sets the duty cycle of the PWM signal to the heat generator. Higher duty cycle will generate more heat.", 0, "helloStrata_TempSensor_Help")
            Help.registerTarget(alertLEDLabel, "This LED will turn on if the temperature read by the sensor exceeds Threshold temperature value. There is a 5 degree hysteresis on OS/ALERT, falling 5 degrees below threshold value will de-assert OS/ALERT.", 1, "helloStrata_TempSensor_Help")
            Help.registerTarget(osThresboxLabel, "This will set temperature threshold value which will trigger OS/ALERT.", 2, "helloStrata_TempSensor_Help")
            Help.registerTarget(gauge, "This gauge displays board temperature in degree celcius near the heat generator.", 3, "helloStrata_TempSensor_Help")

        }
    }

    // UI state
    // Periodic notification
    property var tempValue: platformInterface.temp.value
    onTempValueChanged: {
        gauge.value = tempValue
    }

    property var alert: platformInterface.temp_os_alert.value
    onAlertChanged: {
        alertLED.status = alert ? SGStatusLight.Red : SGStatusLight.Off
    }

    // Control values for temp
    property var temp_ctl_value_duty: platformInterface.temp_ctl_value.duty
    onTemp_ctl_value_dutyChanged: {
        pwmslider.value = (temp_ctl_value_duty*100).toFixed(0)
    }

    // Control values for alert
    property var temp_ctl_value_os_alert: platformInterface.temp_ctl_value.os_alert
    onTemp_ctl_value_os_alertChanged: {
        alertLED.status = temp_ctl_value_os_alert ? SGStatusLight.Red : SGStatusLight.Off
    }

    property var temp_ctl_value_tos: platformInterface.temp_ctl_value.tos
    onTemp_ctl_value_tosChanged: {
        osThres.text = temp_ctl_value_tos.toString()
    }

    contentItem: RowLayout {
        id: content
        anchors.fill: parent
        spacing: 5 * factor


        ColumnLayout {
            id: leftContent
            Layout.alignment: Qt.AlignCenter

            spacing: defaultPadding
            SGAlignedLabel {
                id: pwmsliderLabel
                target: pwmslider
                text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                fontSizeMultiplier: factor
                CustomSlider {
                    id: pwmslider
                    width: (content.parent.maximumWidth - 10 * factor) * 0.5
                    live: false
                    textColor: "black"
                    stepSize: 1
                    from: 0
                    to: 100
                    fromText.text: "0 %"
                    toText.text: "100 %"
                    inputBox.validator: IntValidator { top: 100; bottom: 0 }
                    fontSizeMultiplier: factor
                    onUserSet: { platformInterface.temp_duty.update(value/100)  }
                    property int slider_value: platformInterface.duty_slider_value
                    onSlider_valueChanged:  { pwmslider.value = slider_value }

                }
            }
            RowLayout {
                spacing: 40 * factor
                SGAlignedLabel {
                    id: alertLEDLabel
                    Layout.alignment: Qt.AlignHCenter
                    target: alertLED
                    text: "<b>" + qsTr("OS/ALERT") + "</b>"
                    fontSizeMultiplier: factor
                    alignment: SGAlignedLabel.SideTopCenter
                    SGStatusLight {
                        id: alertLED
                        width: 40 * factor
                    }
                }

                SGAlignedLabel {
                    id: osThresboxLabel
                    target: osThres
                    text: "OS/ALERT \n Threshold"
                    font.bold: true
                    fontSizeMultiplier: factor
                    Layout.alignment: Qt.AlignHCenter
                    alignment: SGAlignedLabel.SideTopCenter
                    SGSubmitInfoBox {
                        id: osThres
                        height: 30 * factor
                        width: 105 * factor
                        textColor: "black"
                        unit: "˚c"
                        text: "50"
                        placeholderText: "-55 to 125"
                        fontSizeMultiplier: factor

                        validator: IntValidator {
                            bottom: -55
                            top: 125
                        }

                        property var theLastValueIs: 0
                        onEditingFinished : {
                            if(theLastValueIs !== text) {
                                platformInterface.set_temp_threshold.update(Number(text))
                                theLastValueIs = text
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                SGCircularGauge {
                    id: gauge
                    anchors.centerIn: parent
                    Layout.minimumHeight: 100
                    Layout.minimumWidth: 100
                    width: parent.width
                    height: Math.min(width, content.height)
                    unitText: "°C"
                    unitTextFontSizeMultiplier: factor + 1
                    value: 30
                    tickmarkStepSize: 10
                    minimumValue: -55
                    maximumValue: 125
                }
            }
        }
    }
}
