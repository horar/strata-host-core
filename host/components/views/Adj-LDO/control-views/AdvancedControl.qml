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
                                    fontSizeMultiplier: ratioCalc * 1.5
                                    font.bold : true

                                    SGInfoBox {
                                        id: systemInputVoltage
                                        unit: "V"
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                        height: systemVoltageContainer.height/2
                                        width: (systemVoltageContainer.width - systemVoltageLabel.contentWidth)/2
                                        boxColor: "lightgrey"
                                        boxFont.family: Fonts.digitalseven
                                        unitFont.bold: true

                                    }
                                }
                            }

                            Rectangle {
                                id:sytemCurrentContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 15
                                SGAlignedLabel {
                                    id: systemCurrentLabel
                                    target: sytemCurrent
                                    text: "Current"
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.5
                                    font.bold : true

                                    SGInfoBox {
                                        id: sytemCurrent
                                        unit: "mA"
                                        height: sytemCurrentContainer.height/2
                                        width: (sytemCurrentContainer.width - systemCurrentLabel.contentWidth)/2 + 25
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
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Rectangle {
                            id: powerOutpugaugeContainer
                            width: parent.width/2
                            height: parent.height
                            anchors.centerIn: parent
                            SGAlignedLabel {
                                id: ouputPowerLabel
                                target: powerOutputGauge
                                text: "System \n Input Power"
                                margin: 0
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter
                                SGCircularGauge {
                                    id: powerOutputGauge
                                    minimumValue: 0
                                    maximumValue:  1000
                                    tickmarkStepSize: 100
                                    gaugeFillColor1:"green"
                                    height: powerOutpugaugeContainer.height - ouputPowerLabel.contentHeight
                                    gaugeFillColor2:"red"
                                    unitText: "mW"
                                    valueDecimalPlaces: 2
                                    unitTextFontSizeMultiplier: ratioCalc * 2.1
                                    //Behavior on value { NumberAnimation { duration: 300 } }

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
                                            fontSizeMultiplier: ratioCalc * 1.5
                                            font.bold : true

                                            SGInfoBox {
                                                id: buckLDOOutputInputVoltage
                                                unit: "V"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height: buckLDOOutputInputContainer.height/1.5
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
                                            fontSizeMultiplier: ratioCalc * 1.5
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
                                        id: sgModeContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: sbModeLabel
                                            target: sbModeRatioButton
                                            text: "VIN selection"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc * 1.5
                                            font.bold : true

                                            SGRadioButtonContainer {
                                                id: sbModeRatioButton
                                                columnSpacing: 10
                                                rowSpacing: 10

                                                SGRadioButton {
                                                    id: forcedPWM
                                                    text: "Forced \n PWM"

                                                }

                                                SGRadioButton {
                                                    id: pfmLightLoad
                                                    text: "PFM Light \n Load"

                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width/1.8
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
                                            fontSizeMultiplier: ratioCalc * 1.5
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
                                            fontSizeMultiplier: ratioCalc * 1.5
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
                            id: ldoSytemOuputText
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
                                        id: ldoSystemOuputVoltageContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: ldoSystemOuputVoltageLabel
                                            target: ldoSystemInputVoltage
                                            text: "Voltage"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc * 1.5
                                            font.bold : true

                                            SGInfoBox {
                                                id: ldoSystemInputVoltage
                                                unit: "V"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height: ldoSystemOuputVoltageContainer.height/2
                                                width: (ldoSystemOuputVoltageContainer.width - ldoSystemOuputVoltageLabel.contentWidth)/2
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                unitFont.bold: true

                                            }
                                        }
                                    }

                                    Rectangle {
                                        id:ldoSytemOuputCurrentContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.leftMargin: 12
                                        SGAlignedLabel {
                                            id: ldoSystemOuputCurrentLabel
                                            target: ldoSytemInputCurrent
                                            text: "Current"
                                            alignment: SGAlignedLabel.SideLeftCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc * 1.5
                                            font.bold : true

                                            SGInfoBox {
                                                id: ldoSytemInputCurrent
                                                unit: "mA"
                                                height: ldoSytemOuputCurrentContainer.height/2
                                                width: (ldoSytemOuputCurrentContainer.width - ldoSystemOuputCurrentLabel.contentWidth)/2 + 25
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
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width/1.8
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
                                            fontSizeMultiplier: ratioCalc * 1.5
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
                                        id:sytemOuputPowerContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: sytemOuputPowerLabel
                                            target:sytemOuputPowerGauge
                                            text: "System \n Ouput Power"
                                            margin: 0
                                            anchors.centerIn: parent
                                            alignment: SGAlignedLabel.SideBottomCenter
                                            fontSizeMultiplier: ratioCalc * 1.5
                                            font.bold : true
                                            horizontalAlignment: Text.AlignHCenter
                                            SGCircularGauge {
                                                id: sytemOuputPowerGauge
                                                minimumValue: 0
                                                maximumValue:  100
                                                tickmarkStepSize: 10
                                                gaugeFillColor1:"green"
                                                height: sytemOuputPowerContainer.height - sytemOuputPowerLabel.contentHeight
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
                            fontSizeMultiplier: ratioCalc * 1.5
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
                            fontSizeMultiplier: ratioCalc * 1.5
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
                            fontSizeMultiplier: ratioCalc * 1.5
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
                        id: totalSystemEfficiencyContainer
                        Layout.preferredHeight: parent.height/2
                        Layout.fillWidth: true
                        color: "white"

                        SGAlignedLabel {
                            id: totalSystemEfficiencyLabel
                            target:totalSystemEfficiencyGauge
                            text: "Total \n Sytem Efficiency"
                            margin: 0
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideBottomCenter
                            fontSizeMultiplier: ratioCalc * 1.5
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
    }
}



