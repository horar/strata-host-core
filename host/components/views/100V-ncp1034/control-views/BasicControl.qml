import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import QtQuick.Controls 2.12
import QtQuick.Window 2.3
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width/1200
    property real initialAspectRatio: Screen.width/Screen.height
    anchors.centerIn: parent
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height


    ColumnLayout {
        anchors.fill :parent

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: (parent.height - 9) * (1/11)
            color: "transparent"
            Text {
                text:  "100V Synchronous Buck Converter \n NCP1034"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: ratioCalc * 20
                color: "black"
                anchors.centerIn: parent
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout{
                anchors.fill: parent
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/3

                    ColumnLayout{
                        anchors.fill: parent
                        Text {
                            id: controlText
                            font.bold: true
                            text: "Controls"
                            font.pixelSize: ratioCalc * 20
                            Layout.topMargin: 10
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
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            RowLayout {
                                anchors.fill: parent
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: eableSwitchLabel
                                        target: enableSwitch
                                        text: "Enable"
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: enableSwitch
                                            anchors.verticalCenter: parent.verticalCenter
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
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: disableSwitchLabel
                                        target: disableSwitch
                                        text: "Disable DAC"
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: disableSwitch
                                            anchors.verticalCenter: parent.verticalCenter
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
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            //color: "green"
                            RowLayout {
                                anchors.fill: parent
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: syncSwitchLabel
                                        target: syncSwitch
                                        text: "Disable LDO"
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: syncSwitch
                                            anchors.verticalCenter: parent.verticalCenter
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

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: setFreqLabel
                                        target: setFreq
                                        text: "Set Frequency"
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: setFreq
                                            anchors.verticalCenter: parent.verticalCenter
                                            labelsInside: true
                                            checkedLabel: "100kHz"
                                            uncheckedLabel:   "Manual"
                                            textColor: "black"              // Default: "black"
                                            handleColor: "white"            // Default: "white"
                                            grooveColor: "#ccc"             // Default: "#ccc"
                                            grooveFillColor: "#0cf"         // Default: "#0cf"

                                        }
                                    }
                                }
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: softSTtartLabel
                                target: softStart
                                text: "Soft Start "
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors {
                                    centerIn: parent
                                }
                                fontSizeMultiplier: ratioCalc
                                font.bold : true

                                SGComboBox {
                                    id: softStart
                                    fontSizeMultiplier: ratioCalc
                                    model: ["1 ms", "2 ms", "5 ms", "10 ms", "15 ms"]

                                }
                            }
                        }

                        Item {
                            id: outputVolContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: outputVolLabel
                                target: outputVolslider
                                text:"Output Voltage"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                font.bold : true

                                SGSlider {
                                    id: outputVolslider
                                    width: outputVolContainer.width/1.1
                                    inputBoxWidth: outputVolContainer.width/6
                                    textColor: "black"
                                    stepSize: 0.5
                                    from: 5
                                    to: 24
                                    live: false
                                    fromText.text: "5V"
                                    toText.text: "24V"
                                    fromText.fontSizeMultiplier: 0.9
                                    toText.fontSizeMultiplier: 0.9


                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout{
                        anchors.fill: parent

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            RowLayout{
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    ColumnLayout{
                                        anchors.fill: parent
                                        Text {
                                            id: telemetryText
                                            font.bold: true
                                            text: "Telemetry"
                                            font.pixelSize: ratioCalc * 20
                                            Layout.topMargin: 10
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

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            RowLayout{
                                                anchors.fill: parent
                                                Item {

                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    ColumnLayout{
                                                        anchors.fill: parent
                                                        Item {

                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true
                                                            SGAlignedLabel {
                                                                id: outputVoltageLabel
                                                                target: outputVoltage
                                                                text: "Output Voltage \n(VOUT)"
                                                                alignment: SGAlignedLabel.SideTopLeft
                                                                anchors {
                                                                    left: parent.left
                                                                    leftMargin: 20
                                                                    verticalCenter: parent.verticalCenter
                                                                }
                                                                fontSizeMultiplier: ratioCalc
                                                                font.bold : true

                                                                SGInfoBox {
                                                                    id: outputVoltage
                                                                    unit: "V"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "14.5"
                                                                }
                                                            }
                                                        }
                                                        Item {

                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true
                                                            SGAlignedLabel {
                                                                id: vccVoltageLabel
                                                                target: vccVoltage
                                                                text: "VCC Voltage \n(VCC)"
                                                                alignment: SGAlignedLabel.SideTopLeft
                                                                anchors {
                                                                    left: parent.left
                                                                    leftMargin: 20
                                                                    verticalCenter: parent.verticalCenter
                                                                }
                                                                fontSizeMultiplier: ratioCalc
                                                                font.bold : true

                                                                SGInfoBox {
                                                                    id: vccVoltage
                                                                    unit: "V"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "12"
                                                                }
                                                            }
                                                        }
                                                        Item {

                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true
                                                            SGAlignedLabel {
                                                                id: inputVoltageLabel
                                                                target: inputVoltage
                                                                text: "Input Voltage \n(VIN)"
                                                                alignment: SGAlignedLabel.SideTopLeft
                                                                anchors {
                                                                    left: parent.left
                                                                    leftMargin: 20
                                                                    verticalCenter: parent.verticalCenter
                                                                }
                                                                fontSizeMultiplier: ratioCalc
                                                                font.bold : true

                                                                SGInfoBox {
                                                                    id: inputVoltage
                                                                    unit: "V"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "80"
                                                                }
                                                            }
                                                        }

                                                    }
                                                }
                                                Item {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    ColumnLayout{
                                                        anchors.fill: parent
                                                        Item {
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true
                                                            SGAlignedLabel {
                                                                id: outputCurrentLabel
                                                                target: outputCurrent
                                                                text: "Output Current \n(I_OUT)"
                                                                alignment: SGAlignedLabel.SideTopLeft
                                                                anchors {
                                                                    left: parent.left
                                                                    leftMargin: 20
                                                                    verticalCenter: parent.verticalCenter
                                                                }
                                                                fontSizeMultiplier: ratioCalc
                                                                font.bold : true

                                                                SGInfoBox {
                                                                    id: outputCurrent
                                                                    unit: "mA"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "900"
                                                                }
                                                            }
                                                        }
                                                        Item {
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true
                                                            SGAlignedLabel {
                                                                id: vccCurrentLabel
                                                                target: vccCurrent
                                                                text: "VCC Current \n(I_CC)"
                                                                alignment: SGAlignedLabel.SideTopLeft
                                                                anchors {
                                                                    left: parent.left
                                                                    leftMargin: 20
                                                                    verticalCenter: parent.verticalCenter
                                                                }
                                                                fontSizeMultiplier: ratioCalc
                                                                font.bold : true

                                                                SGInfoBox {
                                                                    id: vccCurrent
                                                                    unit: "mA"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "200"
                                                                }
                                                            }
                                                        }
                                                        Item {
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true
                                                            SGAlignedLabel {
                                                                id: inputCurrentLabel
                                                                target: inputCurrent
                                                                text: "Input Current \n(I_IN)"
                                                                alignment: SGAlignedLabel.SideTopLeft
                                                                anchors {
                                                                    left: parent.left
                                                                    leftMargin: 20
                                                                    verticalCenter: parent.verticalCenter
                                                                }
                                                                fontSizeMultiplier: ratioCalc
                                                                font.bold : true

                                                                SGInfoBox {
                                                                    id: inputCurrent
                                                                    unit: "mA"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "500"

                                                                }
                                                            }
                                                        }

                                                    }
                                                }

                                            }


                                        }

                                    }

                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    ColumnLayout{
                                        anchors.fill: parent
                                        Text {
                                            id: remoteWarningText
                                            font.bold: true
                                            text: "Remote Warning"
                                            font.pixelSize: ratioCalc * 20
                                            Layout.topMargin: 10
                                            color: "#696969"
                                            Layout.leftMargin: 20
                                        }

                                        Rectangle {
                                            id: line3
                                            Layout.preferredHeight: 2
                                            Layout.alignment: Qt.AlignCenter
                                            Layout.preferredWidth: parent.width
                                            border.color: "lightgray"
                                            radius: 2
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGStatusLogBox{
                                                id: logFault

                                                width: parent.width - 20
                                                height: parent.height - 50
                                                title: "Status List"
                                                anchors.centerIn: parent
                                            }

                                        }

                                    }
                                }


                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout{
                                anchors.fill: parent
                                Text {
                                    id: tempAndPowerText
                                    font.bold: true
                                    text: "Temperature & Power"
                                    font.pixelSize: ratioCalc * 20
                                    Layout.topMargin: 10
                                    color: "#696969"
                                    Layout.leftMargin: 20
                                }

                                Rectangle {
                                    id: line4
                                    Layout.preferredHeight: 2
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.preferredWidth: parent.width
                                    border.color: "lightgray"
                                    radius: 2
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    RowLayout {
                                        anchors.fill: parent

                                        Item {
                                            id: powerGaugeContainer
                                            //color: "green"
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: powerLossGaugeLabel
                                                target: powerLossGauge
                                                text: "Power Loss "
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: powerLossGauge
                                                    width: powerGaugeContainer.width
                                                    height: powerGaugeContainer.height - powerLossGaugeLabel.contentHeight
                                                    tickmarkStepSize: 10
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    value: 50
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 0


                                                }
                                            }

                                        }
                                        Rectangle {
                                            id: vccGaugeContainer

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: vccPowerGaugeLabel
                                                target: vccpowerGauge
                                                text: "VCC Power "
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: vccpowerGauge
                                                    width: vccGaugeContainer.width
                                                    height: vccGaugeContainer.height - vccPowerGaugeLabel.contentHeight
                                                    tickmarkStepSize: 0.1
                                                    minimumValue: 0
                                                    maximumValue: 1
                                                    value:  0.5
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 1


                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: powerEffContainer

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: powerEffGaugeLabel
                                                target: powerEffGauge
                                                text: "Power Efficiency "
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: powerEffGauge
                                                    width: powerEffContainer.width
                                                    height: powerEffContainer.height - powerEffGaugeLabel.contentHeight
                                                    tickmarkStepSize: 10
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    value: 50
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "%"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 0


                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: tempGaugeContainer

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: tempGaugeLabel
                                                target: tempGauge
                                                text: "Board Temperature"
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: tempGauge
                                                    minimumValue: 0
                                                    maximumValue: 150
                                                    value: 100
                                                    width: tempGaugeContainer.width
                                                    height: tempGaugeContainer.height - tempGaugeLabel.contentHeight
                                                    anchors.centerIn: parent
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    tickmarkStepSize: 15
                                                    unitText: "˚C"
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
            }
        }
    }

}
