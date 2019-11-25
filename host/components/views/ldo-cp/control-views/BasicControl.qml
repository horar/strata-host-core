import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

ColumnLayout {
    id: root

    property double outputCurrentLoadValue: 0
    property double dcdcBuckVoltageValue: 0

    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Text {
        id: boardTitle
        Layout.alignment: Qt.AlignCenter
        text: "NCV48220 LDO Charge Pump"
        font.bold: true
        font.pixelSize: ratioCalc * 40
        Layout.topMargin: 10

    }

    Text {
        text: "Interrupts"
        font.bold: true
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
        Layout.preferredWidth: parent.width
        Layout.topMargin: 15
        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            SGAlignedLabel {
                id:powerGoodLabel
                target: powerGoodLight
                alignment: SGAlignedLabel.SideBottomCenter
                anchors.centerIn: parent
                fontSizeMultiplier: ratioCalc * 1.2

                text: "<b>Power Good</b>"

                SGStatusLight {
                    id: powerGoodLight

                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    status: platformInterface.int_vin_vr_pg.value ? SGStatusLight.Green : SGStatusLight.Red
                }
            }
        }

        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            SGAlignedLabel {
                id: chargePumpLabel
                target: chargePumpOnLight
                alignment: SGAlignedLabel.SideBottomCenter
                anchors.centerIn: parent
                fontSizeMultiplier: ratioCalc * 1.2
                text: "<b>Charge Pump On</b>"

                SGStatusLight {
                    id: chargePumpOnLight
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    status: platformInterface.int_cp_on.value ? SGStatusLight.Green : SGStatusLight.Off
                }
            }

        }

        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            SGAlignedLabel {
                id:roMCULabel
                target: ro_mcuLight
                alignment: SGAlignedLabel.SideBottomCenter
                anchors.centerIn: parent
                fontSizeMultiplier: ratioCalc * 1.2
                text: "<b>RO</b>"

                SGStatusLight {
                    id: ro_mcuLight
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    status: platformInterface.int_ro_mcu.value ? SGStatusLight.Red : SGStatusLight.Off
                }
            }
        }

        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            SGAlignedLabel {
                id:osAlertabel
                target: osAlertLight
                alignment: SGAlignedLabel.SideBottomCenter
                anchors.centerIn: parent
                fontSizeMultiplier: ratioCalc * 1.2
                text: "<b>OS#/ALERT#</b>"

                SGStatusLight {
                    id: osAlertLight
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    status: platformInterface.int_os_alert.value ? SGStatusLight.Red : SGStatusLight.Off
                }
            }
        }
    }

    Text {
        text: "Board Temperature And Power Loss"
        font.bold: true
        font.pixelSize: ratioCalc * 20
        Layout.topMargin: 20
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
        Layout.preferredWidth: parent.width
        Layout.maximumHeight:(parent.height/4.5)

        Rectangle {
            id: tempgaugeContainer
            Layout.preferredWidth: parent.width/2
            Layout.preferredHeight: parent.height
            SGAlignedLabel {
                id: tempLabel
                target: tempGauge
                text: "Board Temperature"
                margin: 0
                anchors.fill:parent

                anchors.centerIn: parent
                alignment: SGAlignedLabel.SideBottomCenter
                fontSizeMultiplier: ratioCalc * 1.2
                font.bold : true
                horizontalAlignment: Text.AlignHCenter

                SGCircularGauge {
                    id: tempGauge
                    height: tempgaugeContainer.height
                    minimumValue: 0
                    maximumValue: 150
                    tickmarkStepSize: 20
                    gaugeFillColor1: "blue"
                    gaugeFillColor2: "red"
                    unitText: "°C"
                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                    value: platformInterface.telemetry.temperature
                    valueDecimalPlaces: 1

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
            id: powerLossContainer
            Layout.preferredWidth: parent.width/2
            Layout.preferredHeight: parent.height

            SGAlignedLabel {
                id: powerLossLabel
                target: powerLoss
                text: "LDO Power Loss"
                margin: 0
                anchors.fill:parent
                anchors.centerIn: parent
                alignment: SGAlignedLabel.SideBottomCenter
                fontSizeMultiplier: ratioCalc * 1.2
                font.bold : true
                horizontalAlignment: Text.AlignHCenter

                SGCircularGauge {
                    id: powerLoss
                    height: tempgaugeContainer.height
                    minimumValue: 0
                    maximumValue: 3
                    tickmarkStepSize: 0.5
                    gaugeFillColor1: "blue"
                    gaugeFillColor2: "red"
                    unitText: "W"
                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                    value: platformInterface.telemetry.ploss
                    valueDecimalPlaces: 3

                }

            }

        }
    }

    RowLayout {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height/2.5

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2

            color: "transparent"
            Layout.alignment: Qt.AlignCenter

            ColumnLayout {
                anchors.top: parent.top
                width: parent.width - 25
                height: parent.height
                spacing: 5
                Text {
                    id:setting
                    text: "Settings"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    Layout.topMargin: 20
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

                Rectangle {
                    color:"transparent"
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/4

                    RowLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter
                            color: "transparent"

                            SGAlignedLabel {
                                id: enableSwLabel
                                target: enableSw
                                text: "Enable SW"
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: enableSw
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel:   "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"

                                    checked: false
                                    onCheckedChanged: {
                                        if(checked === true){
                                            platformInterface.enable_sw.update(1)
                                        }
                                        else{
                                            platformInterface.enable_sw.update(0)
                                        }
                                    }
                                }

                            }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter

                            SGAlignedLabel {
                                id: enableLDOLabel
                                target: enableLDO
                                text: "Enable LDO"
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: enableLDO
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    onCheckedChanged: {
                                        if(checked === true){
                                            platformInterface.enable_ldo.update(1)
                                        }
                                        else{
                                            platformInterface.enable_ldo.update(0)
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter

                            SGAlignedLabel {
                                id: loadSwitchOLabel
                                target: loadSwitch
                                text: "Onboard Load Enable"
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: loadSwitch
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel:   "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    onCheckedChanged: {
                                        if(checked === true){
                                            platformInterface.enable_vin_vr.update(1)
                                        }
                                        else{
                                            platformInterface.enable_vin_vr.update(0)
                                        }
                                    }
                                }
                            }
                        }
                    } // switch setting end

                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        Layout.preferredWidth: parent.width/1.5
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill:parent
                            Rectangle {

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 10
                                Rectangle {
                                    id: outputCurrentSlider
                                    anchors.fill: parent


                                    SGAlignedLabel {
                                        id: outputCurrentLoadLabel
                                        target: outputCurrentLoadSlider
                                        text: "Output Load Current"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        Layout.topMargin: 10


                                        SGSlider {
                                            id: outputCurrentLoadSlider
                                            width: outputCurrentSlider.width/1.5
                                            live: false
                                            from: 0
                                            to: 500
                                            stepSize: 0.1
                                            fromText.text: "0mA"
                                            toText.text: "500mA"
                                            value: 0
                                            inputBox.validator: DoubleValidator {
                                                top: outputCurrentLoadSlider.to
                                                bottom: outputCurrentLoadSlider.from
                                            }
                                            onValueChanged: {
                                                outputCurrentLoadValue = (value / 500.0)
                                            onUserSet: platformInterface.vdac_iout.update(value)
                                            }
                                        }
                                    }
                                }

                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 10
                                Rectangle {
                                    id: buckVoltageSliderContainer
                                    anchors.fill: parent

                                    SGAlignedLabel {
                                        id: buckVoltageLabel
                                        target: buckVoltageSlider
                                        text: "DC-DC Buck Output Voltage"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGSlider {
                                            id: buckVoltageSlider
                                            width: buckVoltageSliderContainer.width/1.5
                                            live: false
                                            from: 2.5
                                            to: 15
                                            stepSize: 0.01
                                            fromText.text: "2.5V"
                                            toText.text: "15V"
                                            value: 0
                                            inputBox.validator: DoubleValidator {
                                                top: buckVoltageSlider.to
                                                bottom: buckVoltageSlider.from
                                            }
                                            onUserSet: platformInterface.vdac_vin.update(value)
                                        }
                                    }
                                }

                            }
                        }

                    }

                    Rectangle {
                        id: ldoInputContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        SGAlignedLabel {
                            id: ldoInputLabel
                            target: ldoInputComboBox
                            text: "LDO Input Voltage Selection"

                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGComboBox {
                                id: ldoInputComboBox
                                width: ldoInputContainer.width
                                anchors.centerIn: ldoInputContainer
                                model: ["Bypass Input Regulator", "DC-DC Buck Input Regulator", "Off"]
                                onActivated: {
                                    if(currentIndex == 0) {
                                        platformInterface.select_vin_vr.update("bypass")
                                    }
                                    else if(currentIndex == 1) {
                                        platformInterface.select_vin_vr.update("buck")
                                    }
                                    else {
                                        platformInterface.select_vin_vr.update("off")
                                    }
                                }
                            }
                        }
                    }
                }


            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignCenter
            Layout.margins: 10
            color: "transparent"
            Text {
                id:telemetry
                text: "Telemetry"
                font.bold: true
                font.pixelSize: ratioCalc * 20
                Layout.topMargin: 20
                color: "#696969"
                Layout.leftMargin: 20
                anchors {
                    top: parent.top
                    topMargin: 15
                }
            }

            Rectangle {
                id: line4
                anchors.top: telemetry.bottom
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: telemetry.bottom
                    topMargin: 10
                }
            }

            GridLayout {
                width: parent.width - 25
                height: (parent.height - telemetry.contentHeight - line4.height) - 100
                rows: 2
                columns: 3
                anchors {
                    top: line4.bottom
                    topMargin: 20

                }

                SGAlignedLabel {
                    id: vinvrLabel
                    target: vinvr
                    text:  "<b>LDO CP Input Voltage<br>(VIN_VR)</b>"
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    SGInfoBox {
                        id: vinvr
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        height: 40 * ratioCalc
                        width: 100 * ratioCalc
                        unit: "<b>V</b>"
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        text: platformInterface.telemetry.vin_vr
                    }
                }

                SGAlignedLabel {
                    id: vinLabel
                    target: vin
                    text:  "<b>Board Input Voltage<br>(VIN)</b>"
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    SGInfoBox {
                        id: vin
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        height: 40 * ratioCalc
                        width: 100 * ratioCalc
                        unit: "<b>V</b>"
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        text: platformInterface.telemetry.vin
                    }

                }

                SGAlignedLabel {
                    id: inputCurrentLabel
                    target: inputCurrent
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>Input Current<br>(IIN)</b>"

                    SGInfoBox {
                        id: inputCurrent
                        height: 40 * ratioCalc
                        width: 110* ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>mA</b>"
                        text: platformInterface.telemetry.iin
                    }

                }

                SGAlignedLabel {
                    id: vcpLabel
                    target: vcp
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>Charge Pump Output Voltage<br>(VCP)</b>"

                    SGInfoBox {
                        id: vcp
                        height: 40 * ratioCalc
                        width: 100* ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vcp
                    }
                }

                SGAlignedLabel {
                    id: voutVrLabel
                    target: voutvr
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>LDO CP Output Voltage<br>(VOUT_VR)</b>"

                    SGInfoBox {
                        id: voutvr
                        height: 40 * ratioCalc
                        width: 100* ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vout
                    }
                }

                SGAlignedLabel {
                    id: outputCurrentLabel
                    target: outputCurrent
                    font.bold: true
                    alignment: SGAlignedLabel.SideTopLeft
                    fontSizeMultiplier: ratioCalc * 1.2
                    text: "<b>Output Current<br>(IOUT)</b>"

                    SGInfoBox {
                        id: outputCurrent
                        height: 40 * ratioCalc
                        width: 110*  ratioCalc
                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                        boxColor: "lightgrey"
                        boxFont.family: Fonts.digitalseven
                        unit: "<b>mA</b>"
                        text: platformInterface.telemetry.iout
                    }
                }
            }
        }
    }
}
