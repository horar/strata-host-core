import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

ColumnLayout {
    id: root
    anchors.fill: parent

    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    Component.onCompleted: {
        platformInterface.get_all_states.send()
        Help.registerTarget(enableLDOLabel, "This switch enables the LDO.", 0, "LdoCpHelp")
        Help.registerTarget(loadSwitchOnLabel, "This switch turns on the onboard load.", 1, "LdoCpHelp")
        Help.registerTarget(outputLoadCurrentLabel, "This slider allows you to set the current pulled by the onboard load. The value can be set while the load is disabled and the load current will automatically be adjusted as needed when the load is activated. The value may need to be reset to the desired level after recovery from a UVLO event.", 2, "LdoCpHelp")
        Help.registerTarget(cptestButton, "This button will trigger a function to apply a sinusoidal input voltage to the LDO to test its charge pump functionality. This test is intended to replicate the graph in Figure 26 of the NCV48220 datasheet (found on the Platform Content page). The test can only be initiated if the input voltage to the board is greater than or equal to 12V, the input buck regulator and LDO are enabled, and the output current is less than or equal to 150mA. For best results, it is recommended to pull a minimum load current of 10mA during the test.", 3, "LdoCpHelp")
        Help.registerTarget(buckVoltageLabel, "This slider allows you to set the desired input voltage of the LDO when being supplied by the input buck regulator. The value can be set while the input buck regulator is not being used and the voltage will automatically be adjusted as needed when the input buck regulator is activated.", 4, "LdoCpHelp")
        Help.registerTarget(ldoInputLabel, "This combo box allows you to choose the input voltage option for the LDO. The input buck regulator option cannot be used with an input voltage higher than 18V. If the input buck regulator is enabled and the input voltage increases above 18V, the regulator will immediately be turned off. See the Platform Content for more information on the available LDO input voltage configurations.", 5, "LdoCpHelp")
        Help.registerTarget(vinvrLabel, "This info box shows the input voltage to the LDO.", 7, "LdoCpHelp")
        Help.registerTarget(vinLabel, "This info box shows the input voltage to the board.", 6, "LdoCpHelp")
        Help.registerTarget(inputCurrentLabel, "This info box shows the input current to the board.", 8, "LdoCpHelp")
        Help.registerTarget(vcpLabel, "This info box shows the output voltage of the LDO's internal charge pump.", 9, "LdoCpHelp")
        Help.registerTarget(voutVrLabel, "This info box shows the output voltage of the LDO.", 10, "LdoCpHelp")
        Help.registerTarget(outputCurrentLabel, "This info box shows the output current of the LDO.", 11, "LdoCpHelp")
        Help.registerTarget(vinGoodLabel, "This indicator will be green when VIN is between 3.3V and 18V and the input buck regulator can be used.", 12, "LdoCpHelp")
        Help.registerTarget(vinVrGoodLabel, "This indicator will be red when the LDO's UVLO is triggered.", 13, "LdoCpHelp")
        Help.registerTarget(ldoCurrentLimitLabel, "This indicator will be red when the LDO's current limit or thermal shutdown protection is triggered.", 14, "LdoCpHelp")
        Help.registerTarget(ldoTempLabel, "This indicator will be red when the LDO's temperature is approximately 50°C and is unsafe to touch.", 15, "LdoCpHelp")
        Help.registerTarget(powerGoodLabel, "This indicator will be green when the input buck regulator is enabled and its power good signal is high.", 16, "LdoCpHelp")
        Help.registerTarget(chargePumpOnLabel, "This indicator will be green when the LDO is enabled and its charge pump mode is activated.", 17, "LdoCpHelp")
        Help.registerTarget(roMCULabel, "This indicator will be red when the LDO is enabled and its reset output is low.", 18, "LdoCpHelp")
        Help.registerTarget(osAlertLabel, "This indicator will be red when the onboard temperature sensor (NCT375) senses a temperature near the LDO's ground pad greater than 50°C, which corresponds to an approximate LDO junction temperature of 125°C at room temperature.", 19, "LdoCpHelp")
        Help.registerTarget(tempLabel, "This gauge shows the board temperature near the ground pad of the LDO.", 20, "LdoCpHelp")
        Help.registerTarget(powerLossLabel, "This gauge shows the power loss in the LDO when enabled. The value may not be accurate when the input buck regulator is being used and the LDO's charge pump mode is activated.", 21, "LdoCpHelp")
    }

    property string popup_message: ""

    property var config_running_state: platformInterface.config_running.value
    onConfig_running_stateChanged: {
        if(config_running_state === true) {
            popup_message = "A function to configure the previously selected board settings is already running. Please wait and try applying the settings again."
            warningPopup.open()
        }
    }

    property var cp_test_invalid_state: platformInterface.cp_test_invalid.value
    onCp_test_invalid_stateChanged: {
        if(cp_test_invalid_state === true) {
            popup_message = "To trigger the CP test, VIN must be greater than or equal to 12V, IOUT must be less than or equal to 150mA, the LDO input voltage must be set to the input buck regulator, and the LDO must be enabled."
            warningPopup.open()
        }
    }

    Popup{
        id: warningPopup
        width: root.width/2
        height: root.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainer
            width: warningPopup.width
            height: warningPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
            Rectangle {
                id:topBorder
                width: parent.width
                height: parent.height/7
                anchors{
                    top: parent.top
                    topMargin: 2
                    right: parent.right
                    rightMargin: 2
                    left: parent.left
                    leftMargin: 2
                }
                radius: 5
                color: "#c0c0c0"
                border.color: "#c0c0c0"
                border.width: 2
            }
        }

        Rectangle {
            id: warningPopupBox
            color: "transparent"
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainer.width - 50
            height: warningPopupContainer.height - 50

            Rectangle {
                id: messageContainerForPopup
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - selectionContainerForPopup.height
                Text {
                    id: warningTextForPopup
                    anchors.fill:parent
                    text: popup_message
                    verticalAlignment:  Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                }
            }

            Rectangle {
                id: selectionContainerForPopup
                width: parent.width/2
                height: parent.height/4.5
                anchors{
                    top: messageContainerForPopup.bottom
                    topMargin: 10
                    right: parent.right
                }
                color: "transparent"
                SGButton {
                    width: parent.width/3
                    height:parent.height
                    anchors.centerIn: parent
                    text: "OK"
                    color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                    roundedLeft: true
                    roundedRight: true

                    onClicked: {
                        warningPopup.close()
                    }
                }
            }
        }
    }

    //control properties
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

    Text {
        id: boardTitle
        Layout.alignment: Qt.AlignCenter
        text: "NCV48220 LDO Charge Pump"
        font.bold: true
        font.pixelSize: ratioCalc * 25
        Layout.topMargin: 10

    }

    Rectangle {
        id: topRowContainer
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height/1.75
        color: "transparent"

        RowLayout {
            id: topRow
            anchors {
                fill: parent
                topMargin: 10
                leftMargin: 20
                rightMargin: 20
                bottomMargin: 10
            }

            Rectangle {
                id: settingsContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "transparent"

                Text {
                    id: settings
                    text: "Settings"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors.top: parent.top
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
                        topMargin: 7
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
                    spacing: 5

                    Rectangle {
                        color:"transparent"
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.25

                        RowLayout {
                            anchors.fill: parent

                            Rectangle {
                                id: enableLDOContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

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
                        }
                    }

                    Rectangle {
                        color:"transparent"
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.75

                        RowLayout {
                            anchors.fill: parent
                            anchors.topMargin: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 15
                                    Rectangle {
                                        id: outputLoadCurrentSliderContainer
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        SGAlignedLabel {
                                            id: outputLoadCurrentLabel
                                            target: outputLoadCurrentSlider
                                            text: "Set Output Load Current"
                                            fontSizeMultiplier: ratioCalc// * 1.2
                                            font.bold : true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent

                                            SGSlider {
                                                id: outputLoadCurrentSlider
                                                width: outputLoadCurrentSliderContainer.width - 10
                                                live: false
                                                from: 0
                                                to: 500
                                                stepSize: 1
                                                fromText.text: "0mA"
                                                toText.text: "500mA"
                                                value: 15
                                                fontSizeMultiplier: ratioCalc * 0.8
                                                inputBox.validator: IntValidator {
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

                                        SGAlignedLabel {
                                            id: buckVoltageLabel
                                            target: buckVoltageSlider
                                            text: "Set DC-DC Buck Output Voltage"
                                            fontSizeMultiplier: ratioCalc// * 1.2
                                            font.bold : true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent

                                            SGSlider {
                                                id: buckVoltageSlider
                                                width: buckVoltageSliderContainer.width - 10
                                                live: false
                                                from: 2.5
                                                to: 15
                                                stepSize: 0.01
                                                fromText.text: "2.5V"
                                                toText.text: "15V"
                                                value: 0
                                                fontSizeMultiplier: ratioCalc * 0.8
                                                inputBox.validator: DoubleValidator {
                                                    top: buckVoltageSlider.to
                                                    bottom: buckVoltageSlider.from
                                                }
                                                onUserSet: platformInterface.set_vin_vr.update(value)
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGButton {
                                        id: cptestButton
                                        height: (preferredContentHeight * 2) + 10
                                        width: preferredContentWidth * 1.25
                                        text: qsTr("Trigger CP Test")
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                        hoverEnabled: true
                                        MouseArea {
                                            hoverEnabled: true
                                            anchors.fill: parent
                                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                            onClicked: {
                                                platformInterface.ldo_cp_test.update()
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: ldoInputContainer
                                    color: "transparent"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGAlignedLabel {
                                        id: ldoInputLabel
                                        target: ldoInputComboBox
                                        text: "LDO Input Voltage Selection"
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
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
            }

            Rectangle {
                id: telemetryContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Text {
                    id:telemetry
                    text: "Telemetry"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors.top: parent.top
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
                        topMargin: 7
                    }
                }

                ColumnLayout {
                    spacing: 20
                    anchors {
                        top: line2.bottom
                        topMargin: 10
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle{
                            id:vinContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: vinLabel
                                target: vin
                                text:  "<b>Board Input Voltage<br>(VIN)</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter


                                SGInfoBox {
                                    id: vin
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    width: 100 * ratioCalc
                                    unit: "<b>V</b>"
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    text: platformInterface.telemetry.vin
                                }
                            }
                        }

                        Rectangle{
                            id: vinvrContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: vinvrLabel
                                target: vinVr
                                text:  "<b>LDO CP Input Voltage<br>(VIN_VR)</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.centerIn: parent

                                SGInfoBox {
                                    id: vinVr
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    width: 100 * ratioCalc
                                    unit: "<b>V</b>"
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    text: platformInterface.telemetry.vin_vr
                                }
                            }
                        }

                        Rectangle {
                            id: inputCurrentContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: inputCurrentLabel
                                target: inputCurrent
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                text: "<b>Input Current<br>(IIN)</b>"
                                anchors.centerIn: parent

                                SGInfoBox {
                                    id: inputCurrent
                                    width: 100* ratioCalc
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unit: "<b>mA</b>"
                                    text: platformInterface.telemetry.iin
                                }

                            }
                        }
                    }

                    RowLayout {
                        id: telemetryBottom
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            id:vcpContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: vcpLabel
                                target: vcp
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                text: "<b>Charge Pump Output Voltage<br>(VCP)</b>"
                                anchors.verticalCenter: parent.verticalCenter

                                SGInfoBox {
                                    id: vcp
                                    width: (vcpContainer.width)/2
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vcp
                                }
                            }
                        }

                        Rectangle {
                            id: voutVrContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: voutVrLabel
                                target: voutVr
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                text: "<b>LDO CP Output Voltage<br>(VOUT_VR)</b>"
                                anchors.centerIn: parent

                                SGInfoBox {
                                    id: voutVr
                                    width: 100* ratioCalc
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vout
                                }
                            }
                        }

                        Rectangle{
                            id: outputCurrentContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: outputCurrentLabel
                                target: outputCurrent
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                text: "<b>Output Current<br>(IOUT)</b>"
                                anchors.centerIn: parent

                                SGInfoBox {
                                    id: outputCurrent
                                    width: 100*  ratioCalc
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unit: "<b>mA</b>"
                                    text: platformInterface.telemetry.iout
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height/9
                        Text {
                            id: ledsetting
                            text: "Status Indicators"
                            font.bold: true
                            font.pixelSize: ratioCalc * 20
                            color: "#696969"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            id: line5
                            height: 1.5
                            width: parent.width
                            border.color: "lightgray"
                            radius: 2
                            anchors.top: ledsetting.bottom
                            anchors.topMargin: 5
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: -5

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id:vinGoodLabel
                                target: vinGoodLight
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc
                                text: "Buck Regulator\nInput Voltage Valid"
                                font.bold: true

                                SGStatusLight {
                                    id: vinGoodLight
                                    property var vin_good: platformInterface.int_status.vin_good
                                    onVin_goodChanged: {
                                        vinGoodLight.status = (vin_good === true) ? SGStatusLight.Green  : SGStatusLight.Off
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id:vinVrGoodLabel
                                target: vinVrGoodLight
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                text: "LDO Input\nUnder Voltage"
                                font.bold: true

                                SGStatusLight {
                                    id: vinVrGoodLight
                                    property var vin_vr_good: platformInterface.int_status.vin_vr_good
                                    onVin_vr_goodChanged: {
                                        vinVrGoodLight.status = (vin_vr_good === false) ? SGStatusLight.Red  : SGStatusLight.Off
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: ldoCurrentLimitContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id:ldoCurrentLimitLabel
                                target: ldoCurrentLimitLight
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                text: "LDO Current\nLimit or TSD"
                                font.bold: true

                                SGStatusLight {
                                    id: ldoCurrentLimitLight
                                    property var ldo_clim: platformInterface.int_status.ldo_clim
                                    onLdo_climChanged: {
                                        ldoCurrentLimitLight.status = (ldo_clim === true) ? SGStatusLight.Red  : SGStatusLight.Off
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: ldoTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id:ldoTempLabel
                                target: ldoTempLight
                                alignment: SGAlignedLabel.SideTopCenter
                                //height: parent.height - contentHeight
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                text: "LDO \n Temperature Alert "
                                font.bold: true

                                SGStatusLight {
                                    id: ldoTempLight
                                    property var ldo_temp_alert: platformInterface.ldo_temp_alert.value
                                    onLdo_temp_alertChanged: {
                                        ldoTempLight.status = (ldo_temp_alert === true) ? SGStatusLight.Red  : SGStatusLight.Off
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
        id: bottomRowContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"

        RowLayout {
            id: bottomRow
            anchors {
                fill: parent
                topMargin: 5
                leftMargin: 20
                rightMargin: 20
                bottomMargin: 20
            }

            Rectangle {
                id: interruptsContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                    columns: 2
                    anchors {
                        top: line3.bottom
                        topMargin: 10
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
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
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>Buck Regulator Power Good</b>"

                            SGStatusLight {
                                id: powerGoodLight
                                property bool powerGoodNoti: platformInterface.int_status.int_vin_vr_pg
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
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>Charge Pump On</b>"

                            SGStatusLight {
                                id: chargePumpOnLight
                                property bool chargePumpOnNoti: platformInterface.int_status.int_cp_on
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
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>Reset Output</b>"

                            SGStatusLight {
                                id: roMcuLight
                                property bool roMcuNoti: platformInterface.int_status.int_ro_mcu
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
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideBottomCenter
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "<b>OS#/ALERT#</b>"

                            SGStatusLight {
                                id: osAlertLight
                                property bool osAlertNoti: platformInterface.int_status.int_os_alert
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
                    }

                    Rectangle {
                        id: tempgaugeContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        SGAlignedLabel {
                            id: tempLabel
                            target: tempGauge
                            text: "Board \n Temperature"
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideBottomCenter
                            margin: -15
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true

                            SGCircularGauge {
                                id: tempGauge
                                height: tempgaugeContainer.height - boardTempText.contentHeight - line4.height - parent.margin
                                width: tempgaugeContainer.width
                                minimumValue: 0
                                maximumValue: 150
                                tickmarkStepSize: 10
                                gaugeFillColor1: "blue"
                                gaugeFillColor2: "red"
                                unitText: "°C"
                                unitTextFontSizeMultiplier: ratioCalc * 1.2
                                property var temp_change: platformInterface.telemetry.temperature
                                onTemp_changeChanged: {
                                    value = temp_change
                                }
                                valueDecimalPlaces: 1

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
                            text: "LDO \n Power Loss"
                            margin: -15
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideBottomCenter
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true

                            SGCircularGauge {
                                id: powerLoss
                                height: powerLossContainer.height - boardTempText.contentHeight - line4.height - parent.margin
                                width: powerLossContainer.width
                                minimumValue: 0
                                maximumValue: 5.0
                                tickmarkStepSize: 0.5
                                gaugeFillColor1: "blue"
                                gaugeFillColor2: "red"
                                unitText: "W"
                                unitTextFontSizeMultiplier: ratioCalc * 1.2
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
