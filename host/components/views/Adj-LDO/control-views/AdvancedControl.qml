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

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

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
                                Layout.leftMargin: 10
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
                        Layout.preferredWidth: parent.width/1.5
                        Rectangle {
                            id: powerOutpugaugeContainer
                            width: parent.width/2
                            height: parent.height
                            anchors.centerIn: parent
                            SGAlignedLabel {
                                id: ouputPowerLabel
                                target: powerOutputGauge
                                text: "System Input Power"
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
                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                    Behavior on value { NumberAnimation { duration: 300 } }

                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color:"yellow"

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
                                color: "red"

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
                                                height: buckLDOOutputInputCurrentContainer.height/2
                                                width: (buckLDOOutputInputCurrentContainer.width - buckLDOOutputInputCurrentLabel.contentWidth)/2 + 25
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
                                            //anchors.centerIn: parent
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
                                color:"pink"
                            }
                        }

                    }

                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "pink"
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "green"
        }

    }

}



