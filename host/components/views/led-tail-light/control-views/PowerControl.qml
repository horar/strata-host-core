import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    property string voltageType: "Boost"

    RowLayout {
        width: parent.width - 10
        height: parent.height/1.5
        anchors.centerIn: parent
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: vledInputVoltageLabel
                                target: vledInputVoltage
                                text: "VLED Input\nVoltage"
                                alignment: SGAlignedLabel.SideTopLeft

                                anchors {
                                    top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: vledInputVoltage
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    checked: false
                                }
                            }

                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: vedInputVoltageTypeLabel
                                target: vedInputVoltageType
                                text: "VED Input Voltage \nType"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors {
                                    top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGComboBox {
                                    id: vedInputVoltageType
                                    fontSizeMultiplier: ratioCalc

                                    model: ["Boost", "Buck", "Bypass"]
                                    onCurrentIndexChanged: {
                                        if(currentIndex === 0) {
                                            voltageType = "Boost"
                                            voltageSet.to = 12
                                            voltageSet.from = 5.5
                                            voltageSet.toText.text = "12V"
                                            voltageSet.fromText.text = "5.5V"
                                        }
                                        else if (currentIndex === 1) {
                                            voltageType = "Buck"
                                            voltageSet.to = 18
                                            voltageSet.from = 2
                                            voltageSet.toText.text = "18V"
                                            voltageSet.fromText.text = "2V"
                                        }
                                        else if (currentIndex === 2) {
                                            voltageSet.enabled = false
                                            voltageSet.opacity = 0.5
                                        }


                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id:boostOCPLabel
                                target: boostOCP
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors {
                                    top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                text: "Boost\nOCP"
                                font.bold: true

                                SGStatusLight {
                                    id: boostOCP

                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: voltageSetContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: voltageSetLabel
                        target: voltageSet
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        alignment: SGAlignedLabel.SideTopLeft
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.top: parent.top
                        text: voltageType + " Voltage Set"
                        SGSlider {
                            id: voltageSet
                            width: voltageSetContainer.width/1.5
                            live: false
                            fontSizeMultiplier: ratioCalc * 1.2
                            to: 18
                            from: 2
                            stepSize: 1
                            toText.text: "18V"
                            fromText.text: "2V"
                            value: 7
                        }

                    }

                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: vsVoltageSelectLabel
                        target: vsVoltageSelect
                        text: "VS Voltage Select"
                        alignment: SGAlignedLabel.SideTopLeft

                        anchors {
                            top:parent.top
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: vsVoltageSelect
                            labelsInside: true
                            checkedLabel: "VLED"
                            uncheckedLabel: "5V"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc * 1.2
                            checked: false
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width/1.5
            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.preferredHeight: parent.height/2
                    Layout.fillWidth: true
                    //color: "red"


                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            // color: "gray"

                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: vLEDLabel
                                        text: "LED Voltage\n(VLED)"
                                        target: vLED
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors {
                                            top:parent.top
                                            left: parent.left
                                            verticalCenter: parent.verticalCenter
                                            leftMargin: 20
                                        }
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: vLED
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>V</b>"
                                            text: "12.5"
                                            boxFont.family: Fonts.digitalseven
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: supplyVoltageLabel
                                        text: "Supply Voltage\n(VS)"
                                        target: supplyVoltage
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors {
                                            top:parent.top
                                            left: parent.left
                                            verticalCenter: parent.verticalCenter
                                            leftMargin: 20
                                        }
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: supplyVoltage
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>V</b>"
                                            text: "5"
                                            boxFont.family: Fonts.digitalseven
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: digitalVoltageLabel
                                        text: "Digital Voltage\n(VDD)"
                                        target: digitalVoltage
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors {
                                            top:parent.top
                                            left: parent.left
                                            verticalCenter: parent.verticalCenter
                                            leftMargin: 20
                                        }
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: digitalVoltage
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: batteryVoltageLabel
                                        text: "Battery Voltage\n(VBAT)"
                                        target: batteryVoltage
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors {
                                            top:parent.top
                                            left: parent.left
                                            verticalCenter: parent.verticalCenter
                                            leftMargin: 20
                                        }
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: batteryVoltage
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>V</b>"
                                            text: "14.4"
                                            boxFont.family: Fonts.digitalseven
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
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: ledCurrentLabel
                                        text: "LED Current\n(ILED)"
                                        target: ledCurrent
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: ledCurrent
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: supplyCurrentLabel
                                        text: "Supply Current\n(IS)"
                                        target: supplyCurrent
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: supplyCurrent
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: digitalCurrentLabel
                                        text: "Digital Current\n(IDD)"
                                        target: digitalCurrent
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: digitalCurrent
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: voltageLabel
                                        text: "Voltage\n(VCC)"
                                        target: voltage
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: voltage
                                            height:  35 * ratioCalc
                                            width: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            text: "500"
                                            boxFont.family: Fonts.digitalseven
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

                        Rectangle{
                            id: ledDriverTempTopContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: ledDriverTempTopLabel
                                target: ledDriverTempTop
                                text: "LED Driver Temp Top \n (°C)"
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: ledDriverTempTop
                                    width: ledDriverTempTopContainer.width
                                    height: ledDriverTempTopContainer.height - ledDriverTempTopLabel.contentHeight
                                    tickmarkStepSize: 10
                                    minimumValue: 0
                                    maximumValue: 150
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "°C"
                                    unitTextFontSizeMultiplier: ratioCalc * 2.5
                                    valueDecimalPlaces: 0
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

                        Rectangle{
                            id: ledDriverTempBottomContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: ledDriverTempBottomLabel
                                target: ledDriverTempBottom
                                text: "LED Driver Temp Bottom \n (°C)"
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: ledDriverTempBottom
                                    width: ledDriverTempBottomContainer.width
                                    height: ledDriverTempBottomContainer.height - ledDriverTempBottomLabel.contentHeight
                                    tickmarkStepSize: 10
                                    minimumValue: 0
                                    maximumValue: 150
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "°C"
                                    unitTextFontSizeMultiplier: ratioCalc * 2.5
                                    valueDecimalPlaces: 0
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
                        Rectangle{
                            id: tempGaugeContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: tempGaugeLabel
                                target: tempGauge
                                text: "LED Temperature \n (°C)"
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: tempGauge
                                    width: tempGaugeContainer.width
                                    height: tempGaugeContainer.height - tempGaugeLabel.contentHeight
                                    tickmarkStepSize: 10
                                    minimumValue: 0
                                    maximumValue: 150
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "°C"
                                    unitTextFontSizeMultiplier: ratioCalc * 2.5
                                    valueDecimalPlaces: 0
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

                        Rectangle{
                            id: powerLossContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: powerLossGaugeLabel
                                target: powerLoss
                                text: "Total Power Loss \n (W)"
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: powerLoss
                                    width: powerLossContainer.width
                                    height: powerLossContainer.height - powerLossGaugeLabel.contentHeight
                                    tickmarkStepSize: 0.5
                                    minimumValue: 0
                                    maximumValue: 5
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "W"
                                    unitTextFontSizeMultiplier: ratioCalc * 2.5
                                    valueDecimalPlaces: 0
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

                    }

                }




            }
        }
    }
}

