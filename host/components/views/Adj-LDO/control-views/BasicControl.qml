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


    ColumnLayout {
        anchors.fill :parent
        Text {
            text:  " NCP164/NCV8164 \n Low-noise, High PSRR Linear Reqgulator"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: ratioCalc * 20
            color: "black"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.height/2.8
            color: "transparent"

            RowLayout {
                anchors.fill: parent


                Rectangle {
                    id: tempGaugeContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: tempLabel
                        target: tempGauge
                        text: "Board \n Temperature"
                        margin: 0

                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier:  ratioCalc * 1.5
                        font.bold : true
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter

                        SGCircularGauge {
                            id: tempGauge
                            minimumValue: -55
                            maximumValue: 125
                            width: tempGaugeContainer.width
                            height: tempGaugeContainer.height/1.6
                            anchors.centerIn: parent
                            gaugeFillColor1: "blue"
                            gaugeFillColor2: "red"
                            tickmarkStepSize: 20
                            unitText: "˚C"

                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            //value:platformInterface.status_temperature_sensor.temperature
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
                    id: efficiencyGaugeContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: efficiencyLabel
                        target: efficiencyGauge
                        text: "Efficiency"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier:  ratioCalc * 1.5
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter
                        SGCircularGauge {
                            id: efficiencyGauge
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 10
                            gaugeFillColor1: "red"
                            gaugeFillColor2:  "green"
                            width: efficiencyGaugeContainer.width
                            height: efficiencyGaugeContainer.height/1.6
                            anchors.centerIn: parent
                            unitText: "%"
                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            //value: platformInterface.status_voltage_current.efficiency
                            Behavior on value { NumberAnimation { duration: 300 } }

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
                        fontSizeMultiplier:   ratioCalc * 1.5
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter

                        SGCircularGauge {
                            id: powerDissipatedGauge
                            minimumValue: 0
                            maximumValue: 1000
                            tickmarkStepSize: 100
                            gaugeFillColor1:"green"
                            gaugeFillColor2:"red"
                            width: powerDissipatedContainer.width
                            height: powerDissipatedContainer.height/1.6
                            anchors.centerIn: parent
                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            unitText: "W"
                            valueDecimalPlaces: 2
                            //value: platformInterface.status_voltage_current.power_dissipated
                            Behavior on value { NumberAnimation { duration: 300 } }
                        }
                    }
                }

                Rectangle {
                    id: outputPowerContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGAlignedLabel {
                        id: ouputPowerLabel
                        target: powerOutputGauge
                        text: "Output Power"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter
                        SGCircularGauge {
                            id: powerOutputGauge
                            minimumValue: 0
                            maximumValue:  3000
                            tickmarkStepSize: 300
                            gaugeFillColor1:"green"
                            gaugeFillColor2:"red"
                            width: outputPowerContainer.width
                            height: outputPowerContainer.height/1.6
                            anchors.centerIn: parent
                            unitText: "mW"
                            valueDecimalPlaces: 2
                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            Behavior on value { NumberAnimation { duration: 300 } }

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
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    ColumnLayout {
                        anchors.fill: parent
                        Text {
                            id: inputConfigurationText
                            font.bold: true
                            text: "Input Configuration"
                            font.pixelSize: ratioCalc * 20
                            Layout.topMargin: 20
                            color: "#696969"
                            Layout.leftMargin: 20

                        }
                        Rectangle {
                            id: line
                            Layout.preferredHeight: 2
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: parent.width
                            border.color: "lightgray"
                            radius: 2
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 20
                            SGAlignedLabel {
                                id: vinSelectionLabel
                                target: vinSelectionContainer
                                text: "VIN selection"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                //anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true

                                SGRadioButtonContainer {
                                    id: vinSelectionContainer
                                    columnSpacing: 10
                                    rowSpacing: 10

                                    SGRadioButton {
                                        id: usb5V
                                        text: "USB 5V"

                                    }

                                    SGRadioButton {
                                        id: external
                                        text: "External"

                                    }
                                }
                            }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 20

                            SGAlignedLabel {
                                id: vinLabel
                                target: ledLight
                                text:  "VIN Ready\n(above 1.6V)"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGStatusLight {
                                    id: ledLight

                                }
                            }

                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 20
                            SGAlignedLabel {
                                id: intputeEableSwitchLabel
                                target: inputEnableSwitch
                                text: "Enable (EN)"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGSwitch {
                                    id: inputEnableSwitch
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel:   "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"

                                }
                            }

                        }

                        Rectangle {
                            id: setLDOSlider
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 20
                            SGAlignedLabel {
                                id: ldoInputVolLabel
                                target: ldoInputVol
                                text:"Set LDO\nInput Voltage"
                                horizontalAlignment: Text.AlignHCenter

                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGSlider {
                                    id:ldoInputVol
                                    width: setLDOSlider.width - ldoInputVolLabel.contentWidth - 50
                                    textColor: "black"
                                    stepSize: 0.1
                                    from: 0.6
                                    to: 5.5
                                    fromText.text: "0.6V"
                                    toText.text: "5.5V"
                                    //fontSizeMultiplier: ratioCalc * 1.2
                                }

                            }
                        }

                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors {
                            fill:parent
                            left: parent.left
                            leftMargin: 10

                        }

                        color: "transparent"

                        ColumnLayout {
                            id: inputReadingContainer
                            anchors.fill: parent
                            Text {
                                id: inputReadingText
                                font.bold: true
                                text: "Input Reading"
                                font.pixelSize: ratioCalc * 20
                                Layout.topMargin: 20
                                color: "#696969"
                                Layout.leftMargin: 20

                            }
                            Rectangle {
                                id: line2
                                Layout.preferredHeight: 2
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: inputReadingContainer.width
                                border.color: "lightgray"
                                radius: 2
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "green"
                                Rectangle {
                                    id: warningBox
                                    color: "red"
                                    anchors.fill: parent

                                    Text {
                                        id: warningText
                                        anchors.centerIn: warningBox
                                        text: "<b>DO NOT exceed input voltage more than 5.5V</b>"
                                        font.pixelSize:  ratioCalc * 14
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
                                        font.pixelSize:  ratioCalc * 20
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
                                        font.pixelSize:  ratioCalc * 20
                                        color: "white"
                                    }
                                }


                            }

                            Rectangle {
                                id: inputContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGAlignedLabel {
                                    id: inputVoltageLabel
                                    target: inputVoltage
                                    text: "Input Voltage"
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.5
                                    font.bold : true

                                    SGInfoBox {
                                        id: inputVoltage
                                        unit: "V"
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                        height: inputContainer.height/1.3
                                        width: (inputContainer.width - inputVoltageLabel.contentWidth)/2
                                        boxColor: "lightgrey"
                                        boxFont.family: Fonts.digitalseven
                                        unitFont.bold: true

                                    }
                                }
                            }

                            Rectangle {
                                id:inputCurrentContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                 Layout.leftMargin: 15
                                SGAlignedLabel {
                                    id: inputCurrentLabel
                                    target: inputCurrent
                                    text: "Input Current"
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.5
                                    font.bold : true

                                    SGInfoBox {
                                        id: inputCurrent
                                        unit: "mA"
                                        height: inputCurrentContainer.height/1.3
                                        width: (inputCurrentContainer.width - inputCurrentLabel.contentWidth)/2 + 25
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                        boxColor: "lightgrey"
                                        boxFont.family: Fonts.digitalseven
                                        unitFont.bold: true

                                    }
                                }
                            }

                            Text {
                                id: ouputReadingText
                                font.bold: true
                                text: "Output Reading"
                                font.pixelSize: ratioCalc * 20
                                Layout.topMargin: 20
                                color: "#696969"
                                Layout.leftMargin: 20

                            }
                            Rectangle {
                                id: line3
                                Layout.preferredHeight: 2
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: inputReadingContainer.width
                                border.color: "lightgray"
                                radius: 2
                            }

                            Rectangle {
                                id: outputContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGAlignedLabel {
                                    id: ouputVoltageLabel
                                    target: outputVoltage
                                    text: "Output Voltage"
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.5
                                    font.bold : true
                                    SGInfoBox {
                                        id: outputVoltage
                                        unit: "V"
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                        boxColor: "lightgrey"
                                        height: outputContainer.height/1.3
                                        width: (outputContainer.width - ouputVoltageLabel.contentWidth)/2
                                        boxFont.family: Fonts.digitalseven
                                        unitFont.bold: true
                                    }
                                }
                            }
                            Rectangle {
                                id: outputCurrentContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 10
                                SGAlignedLabel {
                                    id: ouputCurrentLabel
                                    target: ouputCurrent
                                    text:  "Output Current"
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.5
                                    font.bold : true
                                    SGInfoBox {
                                        id: ouputCurrent
                                        unit: "mA"
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                        height: outputCurrentContainer.height/1.3
                                        width: (outputCurrentContainer.width - ouputCurrentLabel.contentWidth)/2 + 20
                                        boxColor: "lightgrey"
                                        boxFont.family: Fonts.digitalseven
                                        unitFont.bold: true

                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        id: ouputConfigurationContainer
                        anchors.fill: parent
                        Text {
                            id: ouputConfigurationText
                            font.bold: true
                            text: "Output Configuration"
                            font.pixelSize: ratioCalc * 20
                            Layout.topMargin: 20
                            color: "#696969"
                            Layout.leftMargin: 20

                        }
                        Rectangle {
                            id: line4
                            Layout.preferredHeight: 2
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: inputReadingContainer.width
                            border.color: "lightgray"
                            radius: 2
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: loadSelectionLabel
                                target: loadSelectionContainer
                                text: "Load selection"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                //anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true

                                SGRadioButtonContainer {
                                    id: loadSelectionContainer
                                    columnSpacing: 10
                                    rowSpacing: 10

                                    SGRadioButton {
                                        id: onboard
                                        text: "Onboard"

                                    }

                                    SGRadioButton {
                                        id: outputexternal
                                        text: "External"

                                    }
                                }
                            }
                        }
                        Rectangle {
                            id:setCurrentContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: setCurrentLabel
                                target: setCurrent
                                text:"Set Current"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGSlider {
                                    id:setCurrent
                                    width: setCurrentContainer.width - setCurrentLabel.contentWidth - 50
                                    textColor: "black"
                                    stepSize: 50
                                    from: 0
                                    to: 300
                                    fromText.text: "0mA"
                                    toText.text: "300mA"
                                }

                            }


                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ouputEnableSwitchLabel
                                target: outputEnableSwitch
                                text: "Enable (EN)"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGSwitch {
                                    id: outputEnableSwitch
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel:   "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"

                                }
                            }

                        }

                        Rectangle {
                            id: ouputsetLDOSlider
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ouputldoInputVolLabel
                                target: outputldoInputVol
                                text:"Set LDO\nOutput Voltage"
//                                horizontalAlignment: Text.AlignHCenter

                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGSlider {
                                    id:outputldoInputVol
                                    width: ouputsetLDOSlider.width - ouputldoInputVolLabel.contentWidth - 50
                                    textColor: "black"
                                    stepSize: 0.5
                                    from: 1.2
                                    to: 5.2
                                    fromText.text: "1.2V"
                                    toText.text: "5.5V"
                                }

                            }
                        }
                    }

                }
            }
        }
    }
}
