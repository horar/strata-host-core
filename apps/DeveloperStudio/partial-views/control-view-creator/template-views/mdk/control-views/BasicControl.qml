import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/js/help_layout_manager.js" as Help
import "../widgets"

Item {
    id: basicControl

    Component.onCompleted: {
        Help.registerTarget(actualSpeed, "Place holder for Basic control view help messages", 1, "BasicControlHelp")
        Help.registerTarget(busVoltage, "Place holder for Basic control view help messages", 2, "BasicControlHelp")
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }

        SGText {
            id: title
            text: "4kW 650V Industrial Motor Control with IPM & UCB"
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            fontSizeMultiplier: 3
            fontSizeMode: Text.Fit // fills space with text up to fontSizeMultiplier
        }

        SGText {
            id: subTitle
            text: "Part of the Motor Development Kit (MDK) Family"
            color: "grey"
            Layout.alignment: Qt.AlignHCenter
            fontSizeMultiplier: 2
        }

        RowLayout {
            spacing: 50
            Layout.leftMargin: 30
            Layout.rightMargin: 30

            CircGauge {
                id: inputPower
                minimumValue: 0
                maximumValue: 1000
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                Layout.preferredWidth: 250
                Layout.alignment: Qt.AlignHCenter
                text: "Input Power"
                unitText: "W"

                gaugeFillColor1: "yellow"
                gaugeFillColor2: "red"
            }

            CircGauge {
                id: actualSpeed
                minimumValue: 0
                maximumValue: 10000
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredHeight: 350
                Layout.preferredWidth: 350
                Layout.alignment: Qt.AlignHCenter
                text: "Actual Speed"
                unitText: "RPM"
                value: 1234 // to be connected to actual speed value from board

                gaugeFillColor1: "yellow"
                gaugeFillColor2: "red"
            }

            CircGauge {
                minimumValue: 0
                maximumValue: 100
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                Layout.preferredWidth: 250
                Layout.alignment: Qt.AlignHCenter
                text: "Board Temp"
                unitText: "°C"
                value: 25
                gaugeFillColor1: "#0cf"
                gaugeFillColor2: "red"

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

        RowLayout {
            id: readoutRow
            Layout.margins: 20

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: basicControl.width

                ColumnLayout {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter

                    DigitalReadout {
                        id: busVoltage
                        text: "DC Bus Voltage"
                        value: (100).toFixed(2)
                        unit: "V"
                    }

                    DigitalReadout {
                        text: "DC Bus Current"
                    }

                    DigitalReadout {
                        text: "Your Readout Here"
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: basicControl.width
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter

                    DigitalReadout {
                        text: "Motor Current"
                    }

                    DigitalReadout {
                        text: "FOC Current, Id"
                    }

                    DigitalReadout {
                        text: "FOC Current, Iq"
                    }

                    DigitalReadout {
                        text: "Your Readout Here"
                    }
                }
            }
        }
    }
}



