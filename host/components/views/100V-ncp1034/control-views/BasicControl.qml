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

    Component.onCompleted: {
        platformInterface.get_status_command.update()
    }

    property var control_states: platformInterface.control_states
    onControl_statesChanged: {
        enableSwitch.checked = control_states.buck_enabled
        setExternalVCC.checked = control_states.ldo_enabled ? false : true
        outputVoltAdjustment.checked = control_states.dac_enabled

        if(control_states.rt_mode === 0)
            setSwitchFreq.checked = true
        else   setSwitchFreq.checked = false

        if(control_states.ss_set === 0){
            softStart.currentIndex = 0
        }
        if(control_states.ss_set === 1){
            softStart.currentIndex = 1
        }
        if(control_states.ss_set === 2){
            softStart.currentIndex = 2
        }
        if(control_states.ss_set === 3){
            softStart.currentIndex = 3
        }

        outputVolslider.value = control_states.vout_set.toFixed(2)

    }

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
                            ColumnLayout{
                                anchors.fill: parent


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
                                                text: "Enable Buck"
                                                alignment: SGAlignedLabel.SideLeftCenter
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

                                                    onToggled: {
                                                        platformInterface.enable_buck.update(checked)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: setSwitchFreqLabel
                                        target: setSwitchFreq
                                        text: "Set Switching \n Frequency"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: setSwitchFreq
                                            anchors.verticalCenter: parent.verticalCenter
                                            labelsInside: true
                                            checkedLabel: "100 kHz"
                                            uncheckedLabel:   "Manual"
                                            textColor: "black"              // Default: "black"
                                            handleColor: "white"            // Default: "white"
                                            grooveColor: "#ccc"             // Default: "#ccc"
                                            grooveFillColor: "#0cf"         // Default: "#0cf"
                                            onToggled: {
                                                if(checked){
                                                    platformInterface.set_rt_mode.update(0)
                                                }
                                                else  platformInterface.set_rt_mode.update(1)
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
                                        text: "Soft Start (ms)"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors {
                                            centerIn: parent
                                        }
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGComboBox {
                                            id: softStart
                                            fontSizeMultiplier: ratioCalc
                                            model: ["1", "5.5", "11", "15.5"]
                                            onCurrentIndexChanged: {
                                                platformInterface.set_ss.update(currentIndex)
                                            }
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
                                        text:"Set Output Voltage"
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSlider {
                                            id: outputVolslider
                                            width: outputVolContainer.width/1.1
                                            inputBoxWidth: outputVolContainer.width/6
                                            textColor: "black"
                                            stepSize: 0.01
                                            from: 5.00
                                            to: 24.00
                                            live: false
                                            inputBox.validator: DoubleValidator { }
                                            inputBox.text: outputVolslider.value.toFixed(2)

                                            fromText.text: "5V"
                                            toText.text: "24V"
                                            fromText.fontSizeMultiplier: 0.9
                                            toText.fontSizeMultiplier: 0.9
                                            onUserSet: {
                                                platformInterface.set_vout.update(value.toFixed(2))
                                                 inputBox.text = value.toFixed(2)

                                            }
                                            onValueChanged: {
                                                inputBox.text = value
                                            }
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
                                Text {
                                    id: manualText
                                    font.bold: true
                                    text: "Advanced Settings"
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
                                    id: outputVoltAdjustmentContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: setoutputVoltAdjustmentLabel
                                        target: outputVoltAdjustment
                                        text: "Output Voltage \n Adjustment"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: outputVoltAdjustment
                                            anchors.verticalCenter: parent.verticalCenter
                                            labelsInside: true
                                            checkedLabel: "On"
                                            uncheckedLabel:   "Off"
                                            textColor: "black"              // Default: "black"
                                            handleColor: "white"            // Default: "white"
                                            grooveColor: "#ccc"             // Default: "#ccc"
                                            grooveFillColor: "#0cf"         // Default: "#0cf"
                                            onToggled: {
                                                platformInterface.enable_dac.update(checked)
                                            }
                                        }
                                    }
                                }

                                /*Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: setDefaultVINLabel
                                        target: defaultVINLimits
                                        text: "Default VIN \n Limits"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: defaultVINLimits
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
                                }*/

                                /*Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: setDefaultVOUTLabel
                                        target: defaultVOUT
                                        text: "Default VOUT \n Limits"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: defaultVOUT
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
                                }*/

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: setExternalVCCLabel
                                        target: setExternalVCC
                                        text: "External VCC \n Supply"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: setExternalVCC
                                            anchors.verticalCenter: parent.verticalCenter
                                            labelsInside: true
                                            checkedLabel: "On"
                                            uncheckedLabel:   "Off"
                                            textColor: "black"              // Default: "black"
                                            handleColor: "white"            // Default: "white"
                                            grooveColor: "#ccc"             // Default: "#ccc"
                                            grooveFillColor: "#0cf"         // Default: "#0cf"
                                            onToggled: {
                                                platformInterface.enable_ldo.update(checked)
                                            }
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
                                                                    property var periodic_telemetry_vout: platformInterface.periodic_telemetry.vout
                                                                    onPeriodic_telemetry_voutChanged: {
                                                                        outputVoltage.text = periodic_telemetry_vout.toFixed(2)
                                                                    }
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
                                                                    text: "12.00"
                                                                    property var periodic_telemetry_vcc: platformInterface.periodic_telemetry.vcc
                                                                    onPeriodic_telemetry_vccChanged: {
                                                                        vccVoltage.text = periodic_telemetry_vcc.toFixed(2)
                                                                    }
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
                                                                    text: "60.00"


                                                                    property var periodic_telemetry_vin: platformInterface.periodic_telemetry.vin
                                                                    onPeriodic_telemetry_vinChanged: {
                                                                        inputVoltage.text = periodic_telemetry_vin.toFixed(2)
                                                                    }
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
                                                                    unit: "A"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "1.000"
                                                                    property var periodic_telemetry_iout: platformInterface.periodic_telemetry.iout
                                                                    onPeriodic_telemetry_ioutChanged: {
                                                                        outputCurrent.text = periodic_telemetry_iout.toFixed(3)
                                                                    }
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
                                                                    text: "5.00"
                                                                    property var periodic_telemetry_icc: platformInterface.periodic_telemetry.icc
                                                                    onPeriodic_telemetry_iccChanged: {
                                                                        vccCurrent.text = periodic_telemetry_icc.toFixed(2)
                                                                    }
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
                                                                    unit: "A"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 100 * ratioCalc
                                                                    boxColor: "lightgrey"
                                                                    boxFont.family: Fonts.digitalseven
                                                                    unitFont.bold: true
                                                                    text: "0.200"
                                                                    property var periodic_telemetry_iin: platformInterface.periodic_telemetry.iin
                                                                    onPeriodic_telemetry_iinChanged: {
                                                                        inputCurrent.text = periodic_telemetry_iin.toFixed(3)
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
                                    id: line5
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
                                            id: inputpowerGaugeContainer
                                            //color: "green"
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: inputpowerGaugeLabel
                                                target: inputpowerGauge
                                                text: "Input \n Power"
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: inputpowerGauge
                                                    width: inputpowerGaugeContainer.width
                                                    height: inputpowerGaugeContainer.height - inputpowerGaugeLabel.contentHeight
                                                    tickmarkStepSize: 10
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    value: 50
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 2
                                                    property var periodic_telemetry_pin: platformInterface.periodic_telemetry.pin
                                                    onPeriodic_telemetry_pinChanged: {
                                                        inputpowerGauge.value = periodic_telemetry_pin.toFixed(2)
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: buckOutputPowerGaugeContainer

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id:  buckOutputPowerGaugeLabel
                                                target:  buckOutputPowerGauge
                                                text: "Buck \n Output Power"
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: buckOutputPowerGauge
                                                    width: buckOutputPowerGaugeContainer.width
                                                    height: buckOutputPowerGaugeContainer.height - buckOutputPowerGaugeLabel.contentHeight
                                                    tickmarkStepSize: 10
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    value:  10
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 2
                                                    property var periodic_telemetry_pout: platformInterface.periodic_telemetry.pout
                                                    onPeriodic_telemetry_poutChanged: {
                                                        buckOutputPowerGauge.value = periodic_telemetry_pout.toFixed(2)
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: effGaugeContainer

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: effGaugeLabel
                                                target: effGauge
                                                text: "Buck \n Efficiency"
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: effGauge
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    value: 100

                                                    width: effGaugeContainer.width
                                                    height: effGaugeContainer.height - effGaugeLabel.contentHeight

                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    tickmarkStepSize: 10
                                                    unitText: "%"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 1
                                                    property var periodic_telemetry_eff: platformInterface.periodic_telemetry.eff
                                                    onPeriodic_telemetry_effChanged: {
                                                        effGauge.value = periodic_telemetry_eff
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: ldoTempContainer

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: ldoTempLabel
                                                target: ldoTemp
                                                text: "VCC \n LDO Temperature"
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: ldoTemp
                                                    width: ldoTempContainer.width
                                                    height: ldoTempContainer.height - ldoTempLabel.contentHeight
                                                    tickmarkStepSize: 15
                                                    minimumValue: 0
                                                    maximumValue: 150
                                                    value: 50
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "˚C"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 1
                                                    property var periodic_telemetry_ldo_temp: platformInterface.periodic_telemetry.ldo_temp
                                                    onPeriodic_telemetry_ldo_tempChanged: {
                                                        ldoTemp.value = periodic_telemetry_ldo_temp
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: boardTempContainer

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: boardTempLabel
                                                target: boardTemp
                                                text: "Board \n Temperature"
                                                margin: -15
                                                anchors.top: parent.top
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: boardTemp
                                                    width: boardTempContainer.width
                                                    height: boardTempContainer.height - boardTempLabel.contentHeight
                                                    tickmarkStepSize: 15
                                                    minimumValue: 0
                                                    maximumValue: 150
                                                    value: 50
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "˚C"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
                                                    valueDecimalPlaces: 1

                                                    property var periodic_telemetry_board_temp: platformInterface.periodic_telemetry.board_temp
                                                    onPeriodic_telemetry_board_tempChanged: {
                                                        boardTemp.value = periodic_telemetry_board_temp
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: parent.height/6

                            ColumnLayout{
                                anchors.fill: parent
                                Text {
                                    id: statusIndicator
                                    font.bold: true
                                    text: "Status Indicators"
                                    font.pixelSize: ratioCalc * 20
                                    Layout.topMargin: 10
                                    color: "#696969"
                                    Layout.leftMargin: 20
                                }

                                Rectangle {
                                    id: line6
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
                                            SGAlignedLabel {
                                                id: vinLedLabel
                                                target: vinLed
                                                alignment: SGAlignedLabel.SideLeftCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "VIN"
                                                font.bold: true

                                                SGStatusLight {
                                                    id: vinLed
                                                    width: 30
                                                }

                                                property var pg_vin: platformInterface.pg_vin.value
                                                onPg_vinChanged:  {
                                                    //if(pg_vin === "false")
                                                    if(pg_vin)
                                                        vinLed.status = SGStatusLight.Green
                                                    else vinLed.status = SGStatusLight.Red
                                                }
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: voutLedLabel
                                                target: voutLed
                                                alignment: SGAlignedLabel.SideLeftCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "VOUT "
                                                font.bold: true

                                                SGStatusLight {
                                                    id: voutLed
                                                    width: 30
                                                }

                                                property var pg_vout: platformInterface.pg_vout.value
                                                onPg_voutChanged:  {
                                                    //if(pg_vout === "false")
                                                    if(pg_vout)
                                                        voutLed.status = SGStatusLight.Green
                                                    else voutLed.status = SGStatusLight.Red
                                                }
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: vccLedLabel
                                                target: vccLed
                                                alignment: SGAlignedLabel.SideLeftCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "VCC "
                                                font.bold: true

                                                SGStatusLight {
                                                    id: vccLed
                                                    width: 30
                                                }

                                                property var pg_vcc: platformInterface.pg_vcc.value
                                                onPg_vccChanged:  {
                                                    //if(pg_vcc === "false")
                                                    if (pg_vcc)
                                                        vccLed.status = SGStatusLight.Green
                                                    else vccLed.status = SGStatusLight.Red
                                                }
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: tempAlertLabel
                                                target: tempAlertLed
                                                alignment: SGAlignedLabel.SideLeftCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Temperature \n Alert "
                                                font.bold: true

                                                SGStatusLight {
                                                    id: tempAlertLed
                                                    width: 30
                                                }

                                                property var temp_alert: platformInterface.temp_alert.value
                                                onTemp_alertChanged:  {
                                                    //if(temp_alert === "true")
                                                    if (temp_alert)
                                                        tempAlertLed.status = SGStatusLight.Red
                                                    else tempAlertLed.status = SGStatusLight.Off
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
