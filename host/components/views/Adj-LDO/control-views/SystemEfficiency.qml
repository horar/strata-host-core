import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.fonts 1.0

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Component.onCompleted: {
        platformInterface.get_all_states.send()
    }

    property var telemetry_notification: platformInterface.telemetry
    onTelemetry_notificationChanged: {
        inputPowerGauge.value = telemetry_notification.pin_ldo //LDO input power
        syncBuckEfficiencyGauge.value = telemetry_notification.eff_sb ////Sync buck regulator input power
        ldoEfficiencyGauge.value = telemetry_notification.eff_ldo ////LDO efficiency
        totalSystemEfficiencyGauge.value = telemetry_notification.eff_tot
        systemInputPowerGauge.value = telemetry_notification.pin_sb
        systemPowerOutputGauge.value  = telemetry_notification.pout_ldo




        buckLDOInputVoltage.text = telemetry_notification.vin_ldo
        systemInputVoltage.text = telemetry_notification.vin_sb
        systemCurrent.text = telemetry_notification.iin
        buckLDOOutputCurrent.text = telemetry_notification.iout
        ldoSystemInputVoltage.text = telemetry_notification.vout_ldo
        ldoSystemInputCurrent.text = telemetry_notification.iout











    }

    property var control_states: platformInterface.control_states
    onControl_statesChanged: {
        if(control_states.vin_sel === "USB 5V")  baordInputComboBox.currentIndex = 0
        else if(control_states.vin_sel === "External") baordInputComboBox.currentIndex = 1
        else if (control_states.vin_sel === "Off") baordInputComboBox.currentIndex = 2

        if(control_states.vin_ldo_sel === "Bypass") ldoInputComboBox.currentIndex = 0
        else if (control_states.vin_ldo_sel === "Buck Regulator") ldoInputComboBox.currentIndex = 1
        else if (control_states.vin_ldo_sel === "Off") ldoInputComboBox.currentIndex = 2


        if(control_states.ldo_sel === "TSOP5")  ldoPackageComboBox.currentIndex = 0
        else if(control_states.ldo_sel === "DFN6") ldoPackageComboBox.currentIndex = 1
        else if (control_states.ldo_sel === "DFN8") ldoPackageComboBox.currentIndex = 2



        setInputVoltageSlider.value = control_states.vin_ldo_set
        setOutputVoltageSlider.value = control_states.vout_ldo_set

        if(control_states.sb_mode === "pwm") forcedPWM.checked = true
        else if (control_states.sb_mode === "auto") pfmLightLoad.checked = true

    }


    RowLayout {
        anchors.fill: parent
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width/1.5



            ColumnLayout {
                anchors.fill: parent
                Text {
                    id: inputConfigurationText
                    font.bold: true
                    text: "System Input"
                    font.pixelSize: ratioCalc * 20
                    Layout.topMargin: 10
                    color: "#696969"
                    Layout.leftMargin: 20

                }

                Rectangle {
                    id: line
                    Layout.preferredHeight: 2
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width + 10
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
                            anchors.fill:parent
                            Rectangle {
                                id: systemVoltageContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGAlignedLabel {
                                    id: systemVoltageLabel
                                    target: systemInputVoltage
                                    text: "Voltage"
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc
                                    font.bold : true

                                    SGInfoBox {
                                        id: systemInputVoltage
                                        unit: "V"
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                                        width: 120 * ratioCalc
                                        boxColor: "lightgrey"
                                        boxFont.family: Fonts.digitalseven
                                        unitFont.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                id:systemCurrentContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 12

                                SGAlignedLabel {
                                    id: systemCurrentLabel
                                    target: systemCurrent
                                    text: "Current"
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc
                                    font.bold : true

                                    SGInfoBox {
                                        id: systemCurrent
                                        unit: "mA"
                                        width: 140 * ratioCalc
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
                                    margin: 0
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideBottomCenter
                                    fontSizeMultiplier: ratioCalc
                                    font.bold : true
                                    horizontalAlignment: Text.AlignHCenter
                                    SGCircularGauge {
                                        id: systemInputPowerGauge
                                        minimumValue: 0
                                        maximumValue:  4.01
                                        tickmarkStepSize: 0.5
                                        gaugeFillColor1:"green"
                                        height: powerOutputgaugeContainer.height - systemInputPowerLabel.contentHeight
                                        gaugeFillColor2:"red"
                                        unitText: "W"
                                        valueDecimalPlaces: 3
                                        unitTextFontSizeMultiplier: ratioCalc * 2.1
                                        //Behavior on value { NumberAnimation { duration: 300 } }
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
                                    text: "Total \n System Efficiency"
                                    margin: 0
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideBottomCenter
                                    fontSizeMultiplier: ratioCalc
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
                                        unitTextFontSizeMultiplier: ratioCalc * 2.1
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
                        anchors.fill:parent
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
                            Layout.preferredHeight: 2
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: parent.width
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
                                    anchors.fill:parent
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
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                width: 120 * ratioCalc
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
                                        Layout.leftMargin: 12
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
                                                width: 140 * ratioCalc
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                unitFont.bold: true
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: sbModeContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: sbModeLabel
                                            target: sbModeRatioButton
                                            text: "Sync Buck Mode"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGRadioButtonContainer {
                                                id: sbModeRatioButton
                                                rows: 1

                                                SGRadioButton {
                                                    id: forcedPWM
                                                    text: "Forced \n PWM"
                                                    onToggled: {
                                                        if(checked) {
                                                            platformInterface.set_sb_mode.update("pwm")
                                                        }
                                                        else   platformInterface.set_sb_mode.update("auto")
                                                    }
                                                }

                                                SGRadioButton {
                                                    id: pfmLightLoad
                                                    text: "Automatic \n PWM/PFM"
                                                    onToggled: {
                                                        if(checked) {
                                                            platformInterface.set_sb_mode.update("auto")
                                                        }
                                                        else   platformInterface.set_sb_mode.update("pwm")
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
                                            text: "LDO \n Input Power"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: inputPowerGauge
                                                minimumValue: 0
                                                maximumValue:  3.01
                                                tickmarkStepSize: 0.2
                                                gaugeFillColor1:"green"
                                                height: ldoInputPowergaugeContainer.height - inputPowerLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "W"
                                                valueDecimalPlaces: 3
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
                                                //Behavior on value { NumberAnimation { duration: 300 } }
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
                                            text: "Sync Buck \n Efficiency"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc
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
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
                                                //Behavior on value { NumberAnimation { duration: 300 } }
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
                            Layout.preferredHeight: 2
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: parent.width + 2
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
                                    anchors.fill:parent
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
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                width: 120 * ratioCalc
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
                                        Layout.leftMargin: 12
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
                                                width: 140 * ratioCalc
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
                                color: "transparent"
                                RowLayout {
                                    anchors.fill:parent
                                    Rectangle {
                                        id:systemOutputPowerContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: systemOutputPowerLabel
                                            target:systemPowerOutputGauge
                                            text: "System \n Output Power"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: systemPowerOutputGauge
                                                minimumValue: 0
                                                maximumValue:  3.01
                                                tickmarkStepSize: 0.2
                                                gaugeFillColor1:"green"
                                                height: systemOutputPowerContainer.height - systemOutputPowerLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "W"
                                                valueDecimalPlaces: 3
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: ldogaugeContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: ldoLabel
                                            target:ldoEfficiencyGauge
                                            text: "LDO \n Efficiency"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: ldoEfficiencyGauge
                                                minimumValue: 0
                                                maximumValue:  100
                                                tickmarkStepSize: 10
                                                gaugeFillColor1:"green"
                                                height: ldogaugeContainer.height - ldoLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "%"
                                                valueDecimalPlaces: 1
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
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
            Layout.preferredWidth: 2
            Layout.leftMargin: 5
            border.color: "lightgray"
            radius: 2
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"

            Rectangle {
                width: parent.width
                height: parent.height/1.2
                anchors.centerIn: parent
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20
                    Rectangle {
                        id:setInputVoltageContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        SGAlignedLabel {
                            id: setInputVoltageLabel
                            target: setInputVoltageSlider
                            text: "Set LDO Input\nVoltage"
                            font.bold: true
                            alignment: SGAlignedLabel.SideTopLeft
                            fontSizeMultiplier: ratioCalc
                            anchors.centerIn: parent

                            SGSlider{
                                id: setInputVoltageSlider
                                width: setInputVoltageContainer.width - 10

                                from: 0.6
                                to:  5
                                fromText.text: "0.6V"
                                toText.text: "5V"
                                stepSize: 0.01
                                live: false
                                // fontSizeMultiplier: ratioCalc * 1.1
                                inputBoxWidth: setInputVoltageContainer.width/6
                                onUserSet: {
                                    platformInterface.set_vin_ldo.update(value.toFixed(2))
                                }
                            }
                        }
                    }

                    Rectangle {
                        id:setOutputVoltageContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        SGAlignedLabel {
                            id: seOutputVoltageLabel
                            target: setOutputVoltageSlider
                            text: "Set LDO Output\nVoltage"
                            font.bold: true
                            alignment: SGAlignedLabel.SideTopLeft
                            fontSizeMultiplier: ratioCalc
                            anchors.centerIn: parent

                            SGSlider{
                                id: setOutputVoltageSlider
                                width: setOutputVoltageContainer.width - 10

                                from: 1.1
                                to:  5
                                fromText.text: "1.1V"
                                toText.text: "5V"
                                stepSize: 0.01
                                live: false
                                inputBoxWidth: setOutputVoltageContainer.width/6
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
                        color: "transparent"

                        SGAlignedLabel {
                            id: seOutputCurrentLabel
                            target: setOutputCurrentSlider
                            text: "Set LDO Output\nCurrent"
                            font.bold: true
                            alignment: SGAlignedLabel.SideTopLeft
                            fontSizeMultiplier: ratioCalc
                            anchors.centerIn: parent

                            SGSlider{
                                id: setOutputCurrentSlider
                                width: setOutputVoltageContainer.width - 10
                                from: 0
                                to:  650
                                live: false
                                fromText.text: "0mA"
                                toText.text: "650mA"
                                stepSize: 0.1
                                inputBoxWidth: setOutputCurrentContainer.width/6
                                onUserSet: platformInterface.set_load.update(parseInt(value))

                            }
                        }
                    }

                    Rectangle {
                        //id: totalSystemEfficiencyContainer
                        Layout.preferredHeight: parent.height/2
                        Layout.fillWidth: true
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
                                            target: baordInputComboBox
                                            text: "Board Input Voltage\nSelection"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.verticalCenter: parent.verticalCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGComboBox {
                                                id: baordInputComboBox
                                                fontSizeMultiplier: ratioCalc * 0.9
                                                model: ["USB 5V", "External", "Off"]
                                                onActivated: {
                                                    platformInterface.select_vin.update(currentText)

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
                                            text: "LDO Input Voltage\n Selection"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.verticalCenter: parent.verticalCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGComboBox {
                                                id: ldoInputComboBox
                                                fontSizeMultiplier: ratioCalc * 0.9
                                                model: ["Bypass", "Buck Regulator", "Off"]
                                                onActivated: {
                                                    platformInterface.select_vin_ldo.update(currentText)

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
                                        color: "transparent"

                                        SGAlignedLabel {
                                            id: ldoPackageLabel
                                            target: ldoPackageComboBox
                                            text: "LDO Package\nSelection"
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
                                        SGAlignedLabel {
                                            id: loadSelectionLabel
                                            target: loadSelectionComboBox
                                            text: "LDO\nSelection"
                                            alignment: SGAlignedLabel.SideTopLeft
                                            anchors.verticalCenter: parent.verticalCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGComboBox {
                                                id: loadSelectionComboBox
                                                fontSizeMultiplier: ratioCalc * 0.9

                                                model: ["Onboard", "External", "Parallel"]
                                                onActivated: {

                                                    if(currentIndex === 0) {
                                                        platformInterface.set_load_enable.update("on")
                                                        platformInterface.ext_load_conn.update(false)

                                                    }
                                                    else if (currentIndex === 1) {
                                                        platformInterface.set_load_enable.update("off")
                                                        platformInterface.ext_load_conn.update(true)
                                                    }
                                                    else if(currentIndex === 2) {
                                                        platformInterface.set_load_enable.update("on")
                                                        platformInterface.ext_load_conn.update(true)
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
