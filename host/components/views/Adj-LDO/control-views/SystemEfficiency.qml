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

    property var telemetry_notification: platformInterface.telemetry
    onTelemetry_notificationChanged: {
        inputPowerGauge.value = telemetry_notification.pin_ldo
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
                                        height: systemVoltageContainer.height/3
                                        width: (systemVoltageContainer.width - systemVoltageLabel.contentWidth)/2
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
                                        height: systemCurrentContainer.height/2
                                        width: (systemCurrentContainer.width - systemCurrentLabel.contentWidth)/2
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
                                    id: outputPowerLabel
                                    target: powerOutputGauge
                                    text: "System \n Input Power"
                                    margin: 0
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideBottomCenter
                                    fontSizeMultiplier: ratioCalc
                                    font.bold : true
                                    horizontalAlignment: Text.AlignHCenter
                                    SGCircularGauge {
                                        id: powerOutputGauge
                                        minimumValue: 0
                                        maximumValue:  1000
                                        tickmarkStepSize: 100
                                        gaugeFillColor1:"green"
                                        height: powerOutputgaugeContainer.height - outputPowerLabel.contentHeight
                                        gaugeFillColor2:"red"
                                        unitText: "mW"
                                        valueDecimalPlaces: 2
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
                                        valueDecimalPlaces: 2
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
                                            target: buckLDOOutputInputVoltage
                                            text: "Voltage"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true

                                            SGInfoBox {
                                                id: buckLDOOutputInputVoltage
                                                unit: "V"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height: buckLDOOutputInputContainer.height/2
                                                width: (buckLDOOutputInputContainer.width - buckLDOOutputInputLabel.contentWidth)/2
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
                                                height: buckLDOOutputInputCurrentContainer.height/1.5
                                                width: (buckLDOOutputInputCurrentContainer.width - buckLDOOutputInputCurrentLabel.contentWidth)/2 + 20
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
                                                }

                                                SGRadioButton {
                                                    id: pfmLightLoad
                                                    text: "Automatic  \n PWM/PFM"
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
                                                maximumValue:  1000
                                                tickmarkStepSize: 100
                                                gaugeFillColor1:"green"
                                                height: ldoInputPowergaugeContainer.height - inputPowerLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "mW"
                                                valueDecimalPlaces: 2
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
                                            target:syncBuckEfficiencygauge
                                            text: "Sync Buck \n Efficiency"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: syncBuckEfficiencygauge
                                                minimumValue: 0
                                                maximumValue:  100
                                                tickmarkStepSize: 10
                                                gaugeFillColor1:"green"
                                                height: syncBuckEfficiencyContainer.height - syncBuckEfficiencyLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "%"
                                                valueDecimalPlaces: 2
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
                                                height: ldoSystemOutputVoltageContainer.height/2
                                                width: (ldoSystemOutputVoltageContainer.width - ldoSystemOutputVoltageLabel.contentWidth)/2
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
                                                height: ldoSystemOutputCurrentContainer.height/2
                                                width: (ldoSystemOutputCurrentContainer.width - ldoSystemOutputCurrentLabel.contentWidth)/2 + 25
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
                                        id: ldogaugeContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: ldoLabel
                                            target:ldoGauge
                                            text: "LDO \n Efficiency"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: ldoGauge
                                                minimumValue: 0
                                                maximumValue:  1000
                                                tickmarkStepSize: 100
                                                gaugeFillColor1:"green"
                                                height: ldogaugeContainer.height - ldoLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "mW"
                                                valueDecimalPlaces: 2
                                                unitTextFontSizeMultiplier: ratioCalc * 2.1
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id:systemOutputPowerContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: systemOutputPowerLabel
                                            target:systemOutputPowerGauge
                                            text: "System \n Output Power"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: systemOutputPowerGauge
                                                minimumValue: 0
                                                maximumValue:  100
                                                tickmarkStepSize: 10
                                                gaugeFillColor1:"green"
                                                height: systemOutputPowerContainer.height - systemOutputPowerLabel.contentHeight
                                                gaugeFillColor2:"red"
                                                unitText: "%"
                                                valueDecimalPlaces: 2
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
                            text: "Set LDO Input Voltage"
                            font.bold: true
                            alignment: SGAlignedLabel.SideTopCenter
                            fontSizeMultiplier: ratioCalc
                            anchors.centerIn: parent

                            SGSlider{
                                id: setInputVoltageSlider
                                width: setInputVoltageContainer.width - 10

                                from: 1.6
                                to:  5.5
                                fromText.text: "1.6V"
                                toText.text: "5.5V"
                                stepSize: 0.1
                                live: false
                                fontSizeMultiplier: ratioCalc * 1.1
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
                            text: "Set LDO Output Voltage"
                            font.bold: true
                            alignment: SGAlignedLabel.SideTopCenter
                            fontSizeMultiplier: ratioCalc
                            anchors.centerIn: parent

                            SGSlider{
                                id: setOutputVoltageSlider
                                width: setOutputVoltageContainer.width - 10

                                from: 1.6
                                to:  5.5
                                fromText.text: "1.6V"
                                toText.text: "5.5V"
                                stepSize: 0.1
                                live: false
                                fontSizeMultiplier: ratioCalc * 1.1
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
                            text: "Set LDO Output Current"
                            font.bold: true
                            alignment: SGAlignedLabel.SideTopCenter
                            fontSizeMultiplier: ratioCalc
                            anchors.centerIn: parent

                            SGSlider{
                                id: setOutputCurrentSlider
                                width: setOutputVoltageContainer.width - 10
                                from: 1.6
                                to:  5.5
                                fromText.text: "1.6V"
                                toText.text: "5.5V"
                                stepSize: 0.1
                                live: false
                                fontSizeMultiplier: ratioCalc * 1.1
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
                                            text: "Board Input Voltage\n Selection"
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
                                            text: "LDO Package Selection"
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
                                            text: "LDO Selection"
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
