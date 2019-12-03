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

    Component.onCompleted: {
        platformInterface.get_all_states.send()
        Help.registerTarget(enableLDOLabel, "This switch enables the LDO.", 0, "LdoCpHelp")
        Help.registerTarget(loadSwitchOnLabel, "This switch turns on the onboard load.", 1, "LdoCpHelp")
        Help.registerTarget(outputLoadCurrentLabel, "This slider allows you to set the current pulled by the onboard load. The value may need to be reset to the desired level after recovery from a UVLO, short-circuit, or TSD event.", 2, "LdoCpHelp")
        Help.registerTarget(buckVoltageLabel, "This slider allows you to set the desired output voltage of the input buck regulator.", 3, "LdoCpHelp")
        Help.registerTarget(ldoInputLabel, "This combo box allows you to choose the input voltage option for the LDO. Do not use the input buck regulator with an input voltage higher than 18V. See the Platform Content for more information on input voltage configurations.", 4, "LdoCpHelp")
        Help.registerTarget(vinvrLabel, "This info box shows the input voltage to the LDO.", 5, "LdoCpHelp")
        Help.registerTarget(vinLabel, "This info box shows the input voltage to the board.", 6, "LdoCpHelp")
        Help.registerTarget(inputCurrentLabel, "This info box shows the input current to the board.", 7, "LdoCpHelp")
        Help.registerTarget(vcpLabel, "This info box shows the output voltage of the LDO's internal charge pump.", 8, "LdoCpHelp")
        Help.registerTarget(voutVrLabel, "This info box shows the output voltage of the LDO.", 9, "LdoCpHelp")
        Help.registerTarget(outputCurrentLabel, "This info box shows the output current of the LDO.", 10, "LdoCpHelp")
        Help.registerTarget(powerGoodLabel, "This indicator will be green when the input buck regulator is enabled and its power good signal is high.", 11, "LdoCpHelp")
        Help.registerTarget(chargePumpOnLabel, "This indicator will be green when the LDO's charge pump mode is activated.", 12, "LdoCpHelp")
        Help.registerTarget(roMCULabel, "This indicator will be red when the reset output of the LDO is low.", 13, "LdoCpHelp")
        Help.registerTarget(osAlertLabel, "This indicator will be red when the onboard temperature sensor (NCT375) senses a temperature near the LDO's ground pad greater than 55°C.", 14, "LdoCpHelp")
        Help.registerTarget(tempLabel, "This gauge shows the board temperature near the ground pad of LDO.", 15, "LdoCpHelp")
        Help.registerTarget(powerLossLabel, "This gauge shows the power loss in the LDO when enabled.", 16, "LdoCpHelp")
    }

    //control properties
    property var control_states_ldo_enable: platformInterface.control_states.ldo_en
    onControl_states_ldo_enableChanged: {
        if(control_states_ldo_enable === "on")
            enableLDO.checked = true
        else enableLDO.checked = false
    }

    property var control_states_load_enable: platformInterface.control_states.load_en
    onControl_states_load_enableChanged: {
        if(control_states_load_enable === "on")
            loadSwitch.checked = true
        else loadSwitch.checked = false
    }

    property var control_states_vin_vr_set: platformInterface.control_states.vin_vr_set
    onControl_states_vin_vr_setChanged: {
        buckVoltageSlider.value = control_states_vin_vr_set
    }

    property var control_states_iout_set: platformInterface.control_states.iout_set
    onControl_states_iout_setChanged: {
        outputLoadCurrentSlider.value = control_states_iout_set
    }

    property var control_states_vin_vr_select: platformInterface.control_states.vin_vr_sel
    onControl_states_vin_vr_selectChanged: {
        if(control_states_vin_vr_select !== "") {
            for(var i = 0; i < ldoInputComboBox.model.length; ++i){
                if(control_states_vin_vr_select === ldoInputComboBox.model[i]){
                    ldoInputComboBox.currentIndex = i
                    return
                }
            }
        }
    }

    Text {
        id: boardTitle
        Layout.alignment: Qt.AlignCenter
        text: "NCV48220 LDO Charge Pump"
        font.bold: true
        font.pixelSize: ratioCalc * 40
        Layout.topMargin: 10

    }

    Rectangle {
        id: topRowContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"

        RowLayout {
            id: topRow
            //Layout.preferredWidth: parent.width
            //Layout.preferredHeight: parent.height/2
            anchors {
                fill: parent
                //margins: 20
                //top: parent.top
                topMargin: 20
                //left: parent.left
                leftMargin: 20
                //right:parent.right
                rightMargin: 20
                //bottom: bottomRowContainer.top
                bottomMargin: 10
            }

            Rectangle {
                id: settingsContainer
                //Layout.preferredHeight: parent.height
                //Layout.preferredWidth: parent.width / 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                //Layout.leftMargin: 10
                //Layout.alignment: Qt.AlignCenter
                color: "transparent"

                Text {
                    id: settings
                    text: "Settings"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors {
                        top: parent.top
                        //topMargin: 20
                    }
                }

                Rectangle {
                    id: line1
                    height: 2
                    Layout.alignment: Qt.AlignCenter
                    width: parent.width
                    border.color: "lightgray"
                    radius: 2
                    anchors {
                        top: settings.bottom
                        topMargin: 10
                    }
                }

                ColumnLayout {
                    anchors {
                        top: line1.bottom
                        topMargin: 10
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    //width: parent.width * 0.9
                    //height: (parent.height - settings.contentHeight - line1.height) - 50
                    spacing: 5

                    Rectangle {
                        color:"transparent"
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredHeight: parent.height * 0.25

                        RowLayout {
                            anchors.fill: parent

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                //Layout.fillHeight: true
                                //Layout.alignment: Qt.AlignHCenter

                                SGAlignedLabel {
                                    id: enableLDOLabel
                                    target: enableLDO
                                    text: "Enable LDO"
                                    alignment: SGAlignedLabel.SideTopCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc// * 1.2
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
                                        fontSizeMultiplier: ratioCalc
                                        checked: false
                                        onClicked: {
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
                                //Layout.alignment: Qt.AlignHCenter

                                SGAlignedLabel {
                                    id: loadSwitchOnLabel
                                    target: loadSwitch
                                    text: "Enable Onboard Load"
                                    alignment: SGAlignedLabel.SideTopCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc// * 1.2
                                    font.bold : true

                                    SGSwitch {
                                        id: loadSwitch
                                        labelsInside: true
                                        checkedLabel: "On"
                                        uncheckedLabel: "Off"
                                        textColor: "black"              // Default: "black"
                                        handleColor: "white"            // Default: "white"
                                        grooveColor: "#ccc"             // Default: "#ccc"
                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                        fontSizeMultiplier: ratioCalc
                                        checked: false
                                        onClicked: {
                                            if(checked === true){
                                                platformInterface.enable_load.update(1)
                                            }
                                            else{
                                                platformInterface.enable_load.update(0)
                                            }
                                        }
                                    }
                                }
                            }
                        } // switch setting end
                    }

                    Rectangle {
                        color:"transparent"
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredHeight: parent.height * 0.75
                        RowLayout {
                            //Layout.fillWidth: true
                            //Layout.fillHeight: true
                            anchors.fill: parent
                            anchors.topMargin: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 5

                                    Rectangle {
                                        id: outputLoadCurrentSliderContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        SGAlignedLabel {
                                            id: outputLoadCurrentLabel
                                            target: outputLoadCurrentSlider
                                            text: "Set Output Load Current"
                                            fontSizeMultiplier: ratioCalc// * 1.2
                                            //height: parent.height - contentHeight
                                            font.bold : true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            //anchors.centerIn: parent
                                            anchors.fill:parent

                                            SGSlider {
                                                id: outputLoadCurrentSlider
                                                width: outputLoadCurrentSliderContainer.width/1.2
                                                live: false
                                                from: 0
                                                to: 500
                                                stepSize: 0.1
                                                fromText.text: "0mA"
                                                toText.text: "500mA"
                                                value: 15
                                                fontSizeMultiplier: ratioCalc
                                                inputBox.validator: DoubleValidator {
                                                    top: outputLoadCurrentSlider.to
                                                    bottom: outputLoadCurrentSlider.from
                                                }
                                                onUserSet: platformInterface.set_iout.update(value)
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: buckVoltageSliderContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"
                                        //                                Rectangle {
                                        //                                    id: buckVoltageSliderContainer
                                        //                                    //Layout.fillWidth: true
                                        //                                    //Layout.fillHeight: true
                                        //                                    anchors.fill: parent
                                        //                                    color: "transparent"
                                        SGAlignedLabel {
                                            id: buckVoltageLabel
                                            target: buckVoltageSlider
                                            text: "Set DC-DC Buck Output Voltage"
                                            fontSizeMultiplier: ratioCalc// * 1.2
                                            //height: parent.height - contentHeight
                                            font.bold : true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            //anchors.centerIn: parent
                                            anchors.fill:parent

                                            SGSlider {
                                                id: buckVoltageSlider
                                                width: buckVoltageSliderContainer.width/1.2
                                                live: false
                                                from: 2.5
                                                to: 15
                                                stepSize: 0.01
                                                fromText.text: "2.5V"
                                                toText.text: "15V"
                                                value: 0
                                                fontSizeMultiplier: ratioCalc
                                                inputBox.validator: DoubleValidator {
                                                    top: buckVoltageSlider.to
                                                    bottom: buckVoltageSlider.from
                                                }
                                                onUserSet: platformInterface.set_vin_vr.update(value)
                                            }
                                            //}
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: ldoInputContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: ldoInputLabel
                                    target: ldoInputComboBox
                                    text: "LDO Input Voltage Selection"
                                    alignment: SGAlignedLabel.SideTopCenter
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc// * 1.2
                                    font.bold : true

                                    SGComboBox {
                                        id: ldoInputComboBox
                                        fontSizeMultiplier: ratioCalc
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
            }

            Rectangle {
                id: telemetryContainer
                //Layout.preferredHeight: parent.height
                //Layout.preferredWidth: parent.width / 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                //Layout.alignment: Qt.AlignCenter
                //Layout.leftMargin: 10
                //Layout.rightMargin: 10
                color: "transparent"

                Text {
                    id:telemetry
                    text: "Telemetry"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors {
                        top: parent.top
                        //topMargin: 20
                    }
                }

                Rectangle {
                    id: line2
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
                    //width: parent.width * 0.9
                    //height: (parent.height - telemetry.contentHeight - line2.height) - 50
                    rows: 2
                    columns: 3
                    anchors {
                        top: line2.bottom
                        topMargin: 10
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
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
                        id: vinvrLabel
                        target: vinVr
                        text:  "<b>LDO CP Input Voltage<br>(VIN_VR)</b>"
                        font.bold: true
                        alignment: SGAlignedLabel.SideTopLeft
                        fontSizeMultiplier: ratioCalc * 1.2

                        SGInfoBox {
                            id: vinVr
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
                        target: voutVr
                        font.bold: true
                        alignment: SGAlignedLabel.SideTopLeft
                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "<b>LDO CP Output Voltage<br>(VOUT_VR)</b>"

                        SGInfoBox {
                            id: voutVr
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

    Rectangle {
        id: bottomRowContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"

        RowLayout {
            id: bottomRow
            //Layout.preferredWidth: parent.width
            //Layout.preferredHeight: parent.height/2
            anchors {
                fill: parent
                //margins: 20
                //top: parent.top
                topMargin: 5
                //left: parent.left
                leftMargin: 20
                //right:parent.right
                rightMargin: 20
                //bottom: bottomRowContainer.top
                bottomMargin: 20
            }
            Rectangle {
                id: interruptsContainer
                //Layout.preferredHeight: parent.height
                //Layout.preferredWidth: parent.width / 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                //Layout.leftMargin: 10
                color: "transparent"

                Text {
                    id: interrupts
                    text: "Interrupts"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                }

                Rectangle {
                    id: line3
                    height: 2
                    Layout.alignment: Qt.AlignCenter
                    width: parent.width
                    border.color: "lightgray"
                    radius: 2
                    anchors {
                        top: interrupts.bottom
                        topMargin: 10
                    }
                }

                GridLayout {
                    rows: 2
                    columns: 2
                    anchors {
                        top: line3.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        //bottomMargin: 50
                    }

                    Rectangle {
                        id: powerGoodContainer
                        Layout.preferredHeight: parent.height/2
                        Layout.preferredWidth: parent.width/2
                        color: "transparent"

                        SGAlignedLabel {
                            id:powerGoodLabel
                            target: powerGoodLight
                            alignment: SGAlignedLabel.SideBottomCenter
                            height: parent.height - contentHeight
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>Buck Regulator Power Good</b>"

                            SGStatusLight {
                                id: powerGoodLight
                                property bool powerGoodNoti: platformInterface.int_vin_vr_pg.value
                                onPowerGoodNotiChanged: {
                                    powerGoodLight.status = (powerGoodNoti === true) ? SGStatusLight.Green : SGStatusLight.Off
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: chargePumpOnContainer
                        Layout.preferredHeight: parent.height/2
                        Layout.preferredWidth: parent.width/2
                        color: "transparent"

                        SGAlignedLabel {
                            id: chargePumpOnLabel
                            target: chargePumpOnLight
                            alignment: SGAlignedLabel.SideBottomCenter
                            height: parent.height - contentHeight
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>Charge Pump On</b>"

                            SGStatusLight {
                                id: chargePumpOnLight
                                property bool chargePumpOnNoti: platformInterface.int_cp_on.value
                                onChargePumpOnNotiChanged: {
                                    chargePumpOnLight.status = (chargePumpOnNoti === true) ? SGStatusLight.Green : SGStatusLight.Off
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: roMCUContainer
                        Layout.preferredHeight: parent.height/2
                        Layout.preferredWidth: parent.width/2
                        color: "transparent"

                        SGAlignedLabel {
                            id:roMCULabel
                            target: roMcuLight
                            alignment: SGAlignedLabel.SideBottomCenter
                            height: parent.height - contentHeight
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>RO</b>"

                            SGStatusLight {
                                id: roMcuLight
                                property bool roMcuNoti: platformInterface.int_ro_mcu.value
                                onRoMcuNotiChanged: {
                                    roMcuLight.status = (roMcuNoti === true) ? SGStatusLight.Red : SGStatusLight.Off
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: osAlertContainer
                        Layout.preferredHeight: parent.height/2
                        Layout.preferredWidth: parent.width/2
                        color: "transparent"

                        SGAlignedLabel {
                            id:osAlertLabel
                            target: osAlertLight
                            height: parent.height - contentHeight
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideBottomCenter
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>OS#/ALERT#</b>"

                            SGStatusLight {
                                id: osAlertLight
                                property bool osAlertNoti: platformInterface.int_os_alert.value
                                onOsAlertNotiChanged: {
                                    osAlertLight.status = (osAlertNoti === true) ? SGStatusLight.Red : SGStatusLight.Off
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: boardTempContainer
                //Layout.preferredHeight: parent.height
                //Layout.preferredWidth: parent.width / 2
                //Layout.leftMargin: 10
                //Layout.rightMargin: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Text {
                    id: boardTempText
                    text: "Board Temperature And Power Loss"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    Layout.topMargin: 20
                    color: "#696969"
                    Layout.leftMargin: 20
                }

                Rectangle {
                    id: line4
                    height: 2
                    Layout.alignment: Qt.AlignCenter
                    width: parent.width
                    border.color: "lightgray"
                    radius: 2
                    anchors {
                        top: boardTempText.bottom
                        topMargin: 10
                    }
                }

                GridLayout {
                    rows: 1
                    columns: 2
                    anchors {
                        top: line4.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        //bottomMargin: 50 - columnSpacing
                    }

                    Rectangle {
                        id: tempgaugeContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        SGAlignedLabel {
                            id: tempLabel
                            target: tempGauge
                            text: "Board Temperature"
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideBottomCenter
                            margin: -15
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            //horizontalAlignment: Text.AlignHCenter

                            SGCircularGauge {
                                id: tempGauge
                                height: tempgaugeContainer.height - boardTempText.contentHeight - line4.height - parent.margin// - tempLabel.contentHeight
                                width: tempgaugeContainer.width
                                minimumValue: 0
                                maximumValue: 150
                                tickmarkStepSize: 10
                                gaugeFillColor1: "blue"
                                gaugeFillColor2: "red"
                                unitText: "°C"
                                unitTextFontSizeMultiplier: ratioCalc * 2.2
                                property var temp_change: platformInterface.telemetry.temperature
                                onTemp_changeChanged: {
                                    value = temp_change
                                }
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
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        SGAlignedLabel {
                            id: powerLossLabel
                            target: powerLoss
                            text: "LDO Power Loss"
                            margin: -15
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideBottomCenter
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true

                            SGCircularGauge {
                                id: powerLoss
                                height: powerLossContainer.height - boardTempText.contentHeight - line4.height - parent.margin// - powerLossLabel.contentHeight
                                width: powerLossContainer.width
                                minimumValue: 0
                                maximumValue: 3
                                tickmarkStepSize: 0.2
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
            }
        }
    }
}
