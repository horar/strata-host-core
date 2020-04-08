import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help


ColumnLayout {
    id: root
    anchors.leftMargin: -25
    anchors.rightMargin: 25
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    spacing: 10

    property string vinState: ""
    property var read_vin: platformInterface.status_voltage_current.vingood
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status = SGStatusLight.Green
            vinState = "over"
            vinLabel.text = "VIN Ready \n ("+vinState + " 4.5V)"


        }
        else {
            ledLight.status = SGStatusLight.Red
            vinState = "under"
            vinLabel.text = "VIN Ready \n ("+vinState +" 4.5V)"

        }
    }



    Text {
        id: boardTitle
        Layout.alignment: Qt.AlignHCenter
        text: multiplePlatform.partNumber
        font.bold: true
        font.pixelSize: ratioCalc * 30
        topPadding: 5
    }

    Rectangle {
        id: mainSetting
        Layout.fillWidth: true
        Layout.preferredHeight:root.height - boardTitle.contentHeight - 20
        Layout.alignment: Qt.AlignCenter

        Rectangle{
            id: mainSettingContainer
            anchors.fill: parent
            anchors {
                bottom: parent.bottom
                bottomMargin: 30
            }
            ColumnLayout{
                anchors {
                    margins: 15
                    fill: parent
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/1.8


                    RowLayout {
                        anchors.fill: parent
                        spacing: 20

                        Rectangle {
                            id: inputContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            Text {
                                id: inputContainerHeading
                                text: "Input"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line3
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: inputContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout {
                                anchors {
                                    top: line3.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5

                                Rectangle {
                                    Layout.preferredWidth: parent.width/1.5
                                    Layout.preferredHeight: 40
                                    Layout.alignment: Qt.AlignCenter
                                    Rectangle {
                                        id: warningBox
                                        color: "red"
                                        anchors.fill: parent

                                        Text {
                                            id: warningText
                                            anchors.centerIn: warningBox
                                            text: "<b>DO NOT Exceed LDO Input Voltage more than 65V</b>"
                                            font.pixelSize:  ratioCalc * 12
                                            color: "white"
                                        }

                                        Text {
                                            id: warningIconleft
                                            anchors {
                                                right: warningText.left
                                                verticalCenter: warningText.verticalCenter
                                                rightMargin: 5
                                            }
                                            text: "\ue80e"
                                            font.family: Fonts.sgicons
                                            font.pixelSize:  ratioCalc * 14
                                            color: "white"
                                        }

                                        Text {
                                            id: warningIconright
                                            anchors {
                                                left: warningText.right
                                                verticalCenter: warningText.verticalCenter
                                                leftMargin: 5
                                            }
                                            text: "\ue80e"
                                            font.family: Fonts.sgicons
                                            font.pixelSize:  ratioCalc * 14
                                            color: "white"
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
                                                id: vinLabel
                                                target: ledLight
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                font.bold : true
                                                SGStatusLight {
                                                    id: ledLight
                                                    height: 40 * ratioCalc
                                                    width: 40 * ratioCalc
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: inputVoltageContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: inputVoltageLabel
                                                target: inputVoltage
                                                text: "Input Voltage"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: inputVoltage
                                                    unit: "V"
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    width: 100 * ratioCalc
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var inputVoltageValue: platformInterface.status_voltage_current.vin.toFixed(2)
                                                    onInputVoltageValueChanged: {
                                                        inputVoltage.text = inputVoltageValue
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: inputCurrentConatiner
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: inputCurrentLabel
                                                target: inputCurrent
                                                text: "Input Current"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: inputCurrent
                                                    //text: platformInterface.status_voltage_current.iin.toFixed(2)
                                                    unit: "A"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    //boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var inputCurrentValue: platformInterface.status_voltage_current.iin.toFixed(2)
                                                    onInputCurrentValueChanged: {
                                                        inputCurrent.text = inputCurrentValue
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
                                            id: inputVCCContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: inputVCCLabel
                                                target: inputVCC
                                                text: "VCC"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: inputVCC
                                                    //text: platformInterface.status_voltage_current.vin.toFixed(2)
                                                    unit: "V"
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    width: 100 * ratioCalc

                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var vccValue: platformInterface.status_voltage_current.vcc.toFixed(2)
                                                    onVccValueChanged: {
                                                        inputVCC.text = vccValue
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: pvccConatiner
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: pvccLabel
                                                target: pvccValue
                                                text: "PVCC"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: pvccValue
                                                    property var pvccValueMonitor: platformInterface.status_voltage_current.pvcc.toFixed(2)
                                                    onPvccValueMonitorChanged: {
                                                        text = pvccValueMonitor
                                                    }

                                                    unit: "V"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    //boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                }
                                            }

                                        }
                                        Rectangle {
                                            id: vbstConatiner
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: vbstLabel
                                                target: vbstValue
                                                text: "VBST"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: vbstValue
                                                    property var vboostValue: platformInterface.status_voltage_current.vboost.toFixed(2)
                                                    onVboostValueChanged: {
                                                        vbstValue.text = vboostValue
                                                    }
                                                    unit: "V"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    //boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
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

                            Text {
                                id: outputContainerHeading
                                text: "Output"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line4
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: outputContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout {
                                anchors {
                                    top: line4.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10
                                        Rectangle {
                                            id: pgoodLightContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: pgoodLabel
                                                target: pgoodLight
                                                text:  "PGood"
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGStatusLight {
                                                    id: pgoodLight
                                                    height: 40 * ratioCalc
                                                    width: 40 * ratioCalc

                                                    property var read_pgood: platformInterface.status_pgood.pgood
                                                    onRead_pgoodChanged: {
                                                        if(read_pgood === "good")
                                                            pgoodLight.status = SGStatusLight.Green
                                                        else  pgoodLight.status = SGStatusLight.Red
                                                    }

                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: outputVoltageContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: outputVoltageLabel
                                                target: outputVoltage
                                                text: "Output Voltage"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: outputVoltage
                                                    //text: platformInterface.status_voltage_current.vin.toFixed(2)
                                                    unit: "V"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var ouputVoltageValue:  platformInterface.status_voltage_current.vout.toFixed(2)
                                                    onOuputVoltageValueChanged: {
                                                        outputVoltage.text = ouputVoltageValue
                                                    }


                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: outputCurrentLabel
                                                target: outputCurrent
                                                text: "Output Current"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: outputCurrent
                                                    //text: platformInterface.status_voltage_current.iin.toFixed(2)
                                                    unit: "A"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var ouputCurrentValue:  platformInterface.status_voltage_current.iout.toFixed(2)
                                                    onOuputCurrentValueChanged: {
                                                        text = ouputCurrentValue
                                                    }

                                                }
                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    id:frequencyContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGAlignedLabel {
                                        id: frequencyLabel
                                        target: frequencySlider
                                        text: "Switch Frequency"
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true
                                        horizontalAlignment: Text.AlignHCenter

                                        SGSlider{
                                            id: frequencySlider
                                            fontSizeMultiplier: ratioCalc * 0.8
                                            fromText.text: "100 Khz"
                                            toText.text: "1.2 Mhz"
                                            from: 100
                                            to: 1200
                                            live: false
                                            stepSize: 100
                                            width: frequencyContainer.width/1.2

                                            inputBoxWidth: frequencyContainer.width/8
                                            inputBox.validator: DoubleValidator {
                                                top: frequencySlider.to
                                                bottom: frequencySlider.from
                                            }
                                            onUserSet: {
                                                platformInterface.switchFrequency = value
                                                platformInterface.set_switching_frequency.update(value)
                                            }

                                        }

                                    }

                                }

                                Rectangle {
                                    id:outputContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: outputLabel
                                        target: selectOutputSlider
                                        text: "Select Output"
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true
                                        horizontalAlignment: Text.AlignHCenter

                                        SGSlider{
                                            id: selectOutputSlider
                                            width: outputContainer.width/1.2
                                            inputBoxWidth: outputContainer.width/8
                                            fontSizeMultiplier: ratioCalc * 0.8
                                            fromText.text: "2 V"
                                            toText.text: "28 V"
                                            from: 2
                                            to: 28
                                            stepSize: 0.1
                                            live: false

                                            inputBox.validator: DoubleValidator {
                                                top: selectOutputSlider.to
                                                bottom: selectOutputSlider.from
                                            }
                                            onUserSet: {
                                                platformInterface.set_output_voltage.update(value)
                                            }
                                        }
                                    }

                                }

                                Rectangle {
                                    id:ocpContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGAlignedLabel {
                                        id: ocpLabel
                                        target: ocpSlider
                                        text: "OCP Threshold"
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true
                                        horizontalAlignment: Text.AlignHCenter

                                        SGSlider{
                                            id: ocpSlider
                                            width: ocpContainer.width/1.2
                                            inputBoxWidth: ocpContainer.width/8
                                            fontSizeMultiplier: ratioCalc * 0.8
                                            fromText.text: "0 A"
                                            toText.text: "13 A"
                                            from: 0
                                            to: 13
                                            stepSize: 0.5
                                            //handleSize: 30
                                            live: false
                                            inputBox.validator: DoubleValidator {
                                                top: ocpSlider.to
                                                bottom: ocpSlider.from
                                            }
                                            onUserSet: {
                                                platformInterface.set_ocp.update(value)

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
                        spacing: 20
                        Rectangle {
                            id: gaugeReading
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"

                            Text {
                                id: gaugeContainerHeading
                                text: "Board Temperature, Power Loss, Output Power & Efficiency"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line1
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: gaugeContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            RowLayout {
                                anchors {
                                    top: line1.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout {
                                        anchors.fill:parent

                                        Rectangle {
                                            id: efficiencyGaugeContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"
                                            SGAlignedLabel {
                                                id: efficiencyGaugeLabel
                                                target: efficiencyGauge
                                                text: "Efficiency"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter
                                                SGCircularGauge {
                                                    id: efficiencyGauge
                                                    gaugeFillColor1: Qt.rgba(1,0,0,1)
                                                    gaugeFillColor2: Qt.rgba(0,1,.25,1)
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    tickmarkStepSize: 10
                                                    width: efficiencyGaugeContainer.width
                                                    height: efficiencyGaugeContainer.height/1.3

                                                    unitText: "%"
                                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                                                    //value: platformInterface.status_voltage_current.efficiency
                                                    property var efficiencyValue: platformInterface.status_voltage_current.efficiency
                                                    onEfficiencyValueChanged: {
                                                        value = efficiencyValue
                                                    }

                                                    // Behavior on value { NumberAnimation { duration: 300 } }

                                                }
                                            }



                                        }

                                        Rectangle {
                                            id: powerDissipatedContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"

                                            SGAlignedLabel {
                                                id: powerDissipatedLabel
                                                target: powerDissipatedGauge
                                                text: "Power Loss"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter
                                                SGCircularGauge {
                                                    id: powerDissipatedGauge
                                                    gaugeFillColor1: Qt.rgba(0,1,.25,1)
                                                    gaugeFillColor2: Qt.rgba(1,0,0,1)
                                                    minimumValue: 0
                                                    maximumValue: 5
                                                    tickmarkStepSize: 0.5
                                                    width: powerDissipatedContainer.width
                                                    height: powerDissipatedContainer.height/1.3
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                                                    valueDecimalPlaces: 2
                                                    property var powerDissipatedValue: platformInterface.status_voltage_current.power_dissipated
                                                    onPowerDissipatedValueChanged: {
                                                        value = powerDissipatedValue
                                                    }
                                                    //Behavior on value { NumberAnimation { duration: 300 } }
                                                }
                                            }
                                        }


                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    RowLayout {
                                        anchors.fill:parent

                                        Rectangle {
                                            id: powerOutputContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: powerOutputLabel
                                                target: powerOutputGauge
                                                text: "Output Power"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter
                                                SGCircularGauge {
                                                    id: powerOutputGauge
                                                    gaugeFillColor1: Qt.rgba(0,0.5,1,1)
                                                    gaugeFillColor2: Qt.rgba(1,0,0,1)
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    tickmarkStepSize: 20
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                                                    width: powerOutputContainer.width
                                                    height: powerOutputContainer.height/1.3
                                                    valueDecimalPlaces: 2

                                                    property var outputPowerValue: platformInterface.status_voltage_current.output_power
                                                    onOutputPowerValueChanged: {
                                                        value = outputPowerValue
                                                    }

                                                    //Behavior on value { NumberAnimation { duration: 300 } }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: tempGaugeContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: tempGaugeLabel
                                                target: tempGauge
                                                text: "Board Temperature"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: tempGauge
                                                    gaugeFillColor1: Qt.rgba(0,1,.25,1)
                                                    gaugeFillColor2: Qt.rgba(1,0,0,1)
                                                    minimumValue: -55
                                                    maximumValue: 125
                                                    tickmarkStepSize: 20
                                                    //outerColor: "#999"
                                                    unitText: "°C"
                                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                                                    width: tempGaugeContainer.width
                                                    height: tempGaugeContainer.height/1.3

                                                    property var tempValue: platformInterface.status_temperature_sensor.temperature
                                                    onTempValueChanged: {
                                                        value = tempValue
                                                    }
                                                    //Behavior on value { NumberAnimation { duration: 300 } }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: parent.height
                                    Layout.preferredWidth: parent.width/7

                                    SGAlignedLabel {
                                        id: osAlertLabel
                                        target: osALERT
                                        text:  "OS/ALERT"
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true
                                        SGStatusLight {
                                            id: osALERT
                                            height: 40 * ratioCalc
                                            width: 40 * ratioCalc

                                            property var status_os_alert: platformInterface.status_os_alert.os_alert
                                            onStatus_os_alertChanged: {
                                                if(osALERT === true)
                                                    osALERT.status = SGStatusLight.Red
                                                else  osALERT.status = SGStatusLight.Off
                                            }

                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: controlContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            Text {
                                id: controlContainerHeading
                                text: "Control"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line2
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: controlContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout {
                                anchors {
                                    top: line2.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10
                                        Rectangle {
                                            id:enableContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGAlignedLabel {
                                                id: enableSwitchLabel
                                                target: enableSwitch
                                                text: "Enable (EN)"
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGSwitch {
                                                    id: enableSwitch

                                                    labelsInside: true
                                                    checkedLabel: "On"
                                                    uncheckedLabel:   "Off"
                                                    textColor: "black"              // Default: "black"
                                                    handleColor: "white"            // Default: "white"
                                                    grooveColor: "#ccc"             // Default: "#ccc"
                                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                                    checked: platformInterface.enabled
                                                    fontSizeMultiplier: ratioCalc
                                                    onToggled: {
                                                        platformInterface.enabled = checked
                                                        if(checked){
                                                            platformInterface.set_enable.update("on")
                                                            frequencyContainer.enabled = false
                                                            frequencyContainer.opacity = 0.5
                                                            vccContainer.enabled = false
                                                            vccContainer.opacity = 0.5
                                                        }
                                                        else{
                                                            platformInterface.set_enable.update("off")
                                                            frequencyContainer.enabled = true
                                                            frequencyContainer.opacity = 1.0
                                                            vccContainer.enabled = true
                                                            vccContainer.opacity = 1.0
                                                        }

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id:hiccupContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGAlignedLabel {
                                                id: hiccupLabel
                                                target: hiccupSwitch
                                                text: "Hiccup Enable"
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGSwitch {
                                                    id: hiccupSwitch
                                                    labelsInside: true
                                                    checkedLabel: "On"
                                                    uncheckedLabel:   "Off"
                                                    textColor: "black"              // Default: "black"
                                                    handleColor: "white"            // Default: "white"
                                                    grooveColor: "#ccc"             // Default: "#ccc"
                                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                                    fontSizeMultiplier: ratioCalc
                                                    onToggled: {
                                                        if(checked){
                                                            platformInterface.enable_hiccup_mode.update("on")
                                                        }
                                                        else platformInterface.enable_hiccup_mode.update("off")
                                                    }

                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true


                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 10
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGAlignedLabel {
                                                        id: syncLabel
                                                        target: syncCombo
                                                        text: "Sync Mode"
                                                        horizontalAlignment: Text.AlignHCenter
                                                        font.bold : true
                                                        alignment: SGAlignedLabel.SideTopLeft
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        fontSizeMultiplier: ratioCalc
                                                        SGComboBox {
                                                            id:  syncCombo
                                                            fontSizeMultiplier: ratioCalc
                                                            //borderColor: "black"
                                                            //textColor: "black"          // Default: "black"
                                                            //indicatorColor: "black"
                                                            model: [ "Master", "Slave" ]
                                                            onActivated: {
                                                                platformInterface.set_sync_mode.update(currentText.toLowerCase())
                                                                if(currentIndex === 0) {
                                                                    syncTextEdit.enabled = false
                                                                    syncTextEdit.opacity = 0.5
                                                                }
                                                                else {
                                                                    syncTextEdit.enabled = true
                                                                    syncTextEdit.opacity = 1.0
                                                                }
                                                            }
                                                        }
                                                        SGSubmitInfoBox {
                                                            id: syncTextEdit
                                                            anchors.left: parent.right
                                                            anchors.leftMargin: 10
                                                            opacity: 0.5
                                                            enabled: false


                                                            fontSizeMultiplier: ratioCalc
                                                            width: syncCombo.width
                                                            infoBoxHeight: syncCombo.height

                                                            anchors.verticalCenter: syncCombo.verticalCenter
                                                            //anchors.verticalCenterOffset: 10

                                                            placeholderText: "100-1000"
                                                            IntValidator {
                                                                top: 1000
                                                                bottom: 100
                                                            }

                                                            onEditingFinished: {
                                                                platformInterface.set_sync_slave_frequency.update(parseInt(syncTextEdit.text))
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
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: modeLabel
                                                target: modeCombo
                                                text: "Operating Mode"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold : true
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                SGComboBox {
                                                    id:  modeCombo
                                                    //                                                    borderColor: "black"
                                                    //                                                    textColor: "black"          // Default: "black"
                                                    //                                                    indicatorColor: "black"
                                                    model: [ "DCM" , "FCCM"]
                                                    fontSizeMultiplier: ratioCalc
                                                    onActivated: {
                                                        if(currentIndex == 0){
                                                            platformInterface.select_mode.update("dcm")
                                                        }
                                                        else  {
                                                            platformInterface.select_mode.update("fccm")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: softStartLabel
                                                target: softStartCombo
                                                text: "Soft Start"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold : true
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                SGComboBox {
                                                    id:  softStartCombo
                                                    //                                                    borderColor: "black"
                                                    //                                                    textColor: "black"          // Default: "black"
                                                    //                                                    indicatorColor: "black"
                                                    model: [ "1.2ms" , "2.4ms"]
                                                    fontSizeMultiplier: ratioCalc
                                                    onActivated: {
                                                        platformInterface.set_soft_start.update(currentText)

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: vccContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: vccLabel
                                                target: vccCombo
                                                text: "VCC Source"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold : true
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                SGComboBox {
                                                    id:  vccCombo
                                                    model: [ "PVCC" , "USB 5V"]
                                                    fontSizeMultiplier: ratioCalc
                                                    onActivated: {
                                                        platformInterface.select_VCC_mode.update(currentText.toLowerCase())
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
