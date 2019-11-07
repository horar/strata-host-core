import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    ColumnLayout {
        anchors.fill :parent
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
                        fontSizeMultiplier: ratioCalc * 1.1
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
                        fontSizeMultiplier:  ratioCalc * 1.1
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
                        fontSizeMultiplier:  ratioCalc * 1.1
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
                        fontSizeMultiplier: ratioCalc * 1.1
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
            color: "green"
        }
    }

}
