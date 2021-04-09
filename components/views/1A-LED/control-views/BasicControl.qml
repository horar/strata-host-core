import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9 as SG0_9
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help
import "../components"

ColumnLayout {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    spacing: 15

    anchors {
        fill: parent
        bottom: parent.bottom
        bottomMargin: 40
    }

    Component.onCompleted: {
        platformInterface.get_all_states.send()
        Help.registerTarget(enableSwitchLabel, "This switch enables the LED driver.", 0, "1A-LEDHelp")
        Help.registerTarget(dutySliderLabel, "This slider allows you to set the duty cycle of the DIM#/EN PWM signal. The duty cycle can be adjusted for an approximately linear increase/decrease in average LED current from the nominal value of approximately 714 mA at 100% duty cycle.", 1, "1A-LEDHelp")
        Help.registerTarget(freqSliderLabel, "This slider allows you to set the frequency of the DIM#/EN PWM signal.", 2, "1A-LEDHelp")
        Help.registerTarget(extLedCheckboxLabel, "Click this checkbox to indicate that external LEDs are connected to the board.", 3, "1A-LEDHelp")
        Help.registerTarget(ledConfigLabel, "This combo box allows you to choose the operating configuration of the LEDs. See the Platform Content page for more info on using the different LED configurations. Caution: Do not connect external LEDs when onboard LEDs are enabled.", 4, "1A-LEDHelp")
        Help.registerTarget(vinConnLabel, "This info box shows the input voltage to the board.", 5, "1A-LEDHelp")
        Help.registerTarget(vinLabel, "This info box shows the input voltage to the onboard LEDs at the anode of the 1st onboard LED. This value may not be accurate for high DIM#/EN frequencies and low DIM#/EN duty cycle settings. See the Platform Content page for more information.", 6, "1A-LEDHelp")
        Help.registerTarget(inputCurrentLabel, "This info box shows the input current to the board.", 7, "1A-LEDHelp")
        Help.registerTarget(vledLabel, "This info box shows the approximate voltage across the LEDs. This value may not be accurate for high DIM#/EN frequencies and low DIM#/EN duty cycle settings. See the Platform Content page for more information.", 8, "1A-LEDHelp")
        Help.registerTarget(voutLEDLabel, "This info box shows the output voltage of the LEDs. This value may not be accurate for high DIM#/EN frequencies and low DIM#/EN duty cycle settings. See the Platform Content page for more information.", 9, "1A-LEDHelp")
        Help.registerTarget(csCurrentLabel, "This info box shows the approximate average value of the current through the CS resistor. This value may vary greatly at low DIM#/EN frequencies.", 10, "1A-LEDHelp")
        Help.registerTarget(osAlertThresholdLabel, "This input box can be used to set the threshold at which the onboard temperature sensor's over-temperature warning signal (OS#/ALERT#) will trigger. The default setting is 110°C (max value) which corresponds to an LED temperature of approximately 125°C.", 11, "1A-LEDHelp")
        Help.registerTarget(osAlertLabel, "This indicator will turn red when the onboard temperature sensor detects a board temperature near the 3rd onboard LED higher than the temperature threshold set in the input box above.", 12, "1A-LEDHelp")
        Help.registerTarget(tempGaugeLabel, "This gauge shows the board temperature near the ground pad of the 3rd onboard LED.", 13, "1A-LEDHelp")
    }

    Text {
        id: platformName
        Layout.alignment: Qt.AlignHCenter
        text: "NCL30160 1A LED Driver"
        font.bold: true
        font.pixelSize: ratioCalc * 40
        topPadding: 20
    }

    ListModel {
        id: ledConfigModel
        ListElement {text: "1 LED"; enabled: true; grayedOut: false}
        ListElement {text: "2 LEDs"; enabled: true; grayedOut: false}
        ListElement {text: "3 LEDs"; enabled: true; grayedOut: false}
        ListElement {text: "External LEDs"; enabled: true; grayedOut: false}
        ListElement {text: "Shorted"; enabled: true; grayedOut: false}
    }

    property var ics_change:  platformInterface.telemetry.ics
    onIcs_changeChanged: {
        csCurrent.text = ics_change
    }

    property var iin_change:  platformInterface.telemetry.iin
    onIin_changeChanged: {
        inputCurrent.text = iin_change
    }

    property var vin_change:  platformInterface.telemetry.vin
    onVin_changeChanged: {
        vin.text = vin_change
    }

    property var vout_change:  platformInterface.telemetry.vout
    onVout_changeChanged: {
        voutLED.text =  vout_change
    }

    //control properties
    property var control_states_enable: platformInterface.control_states.enable
    onControl_states_enableChanged: {
        if(control_states_enable === "on")
            enableSwitch.checked = true
        else enableSwitch.checked = false
    }

    property var control_states_dim_en_duty: platformInterface.control_states.dim_en_duty

    onControl_states_dim_en_dutyChanged: {
        dutySlider.value = control_states_dim_en_duty
    }

    property var control_states_dim_en_freq: platformInterface.control_states.dim_en_freq

    onControl_states_dim_en_freqChanged: {
        freqSlider.value = control_states_dim_en_freq
    }

    property var control_states_led_config: platformInterface.control_states.led_config

    onControl_states_led_configChanged: {
        if(control_states_led_config !== "") {
            for(var i = 0; i < ledConfigCombo.model.count; ++i){
                if(control_states_led_config === ledConfigCombo.model.get(i)["text"]){
                    if((i === 3) || (i === 4)) {
                        osAlertContainer.opacity = 0.5
                        osAlertSettingsContainer.opacity = 0.5
                        osAlertSettingsContainer.enabled = false
                    }
                    ledConfigCombo.currentIndex = i
                    return
                }
            }
        }
    }

    property var control_states_ext_led_state: platformInterface.control_states.ext_led_state

    onControl_states_ext_led_stateChanged: {
        if (control_states_ext_led_state === "connected") {
            extLedCheckbox.checked = true
            if (ledConfigCombo.currentIndex !== 3) {
                if (ledConfigCombo.currentIndex === 4) {
                    platformInterface.set_led.update("short")
                } else{
                    platformInterface.set_led.update("external")
                }
            }
            for(var i = 0; i < ledConfigCombo.model.count; ++i){
                if((i === 3) || (i === 4)){
                    ledConfigCombo.model.get(i)["enabled"] = true
                    ledConfigCombo.model.get(i)["grayedOut"] = false
                } else {
                    ledConfigCombo.model.get(i)["enabled"] = false
                    ledConfigCombo.model.get(i)["grayedOut"] = true
                }
            }
        } else {

            extLedCheckbox.checked = false
            for(var j = 0; j < ledConfigCombo.model.count; ++j){
                if (j === 3) {
                    ledConfigCombo.model.get(j)["enabled"] = false
                    ledConfigCombo.model.get(j)["grayedOut"] = true
                } else {
                    ledConfigCombo.model.get(j)["enabled"] = true
                    ledConfigCombo.model.get(j)["grayedOut"] = false
                }
            }
        }
    }

    Popup{
        id: warningPopupOsAlert
        width: root.width/1.7
        height: root.height/3
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy:Popup.NoAutoClose
        background: Rectangle{
            id: warningContainerForOsAlert
            width: warningPopupOsAlert.width
            height: warningPopupOsAlert.height
            color: "white"
            border.color: "black"
            border.width: 4
            radius: 10
        }

        Rectangle {
            id: warningBoxForOsAlert
            color: "transparent"
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: warningContainerForOsAlert.width - 50
            height: warningContainerForOsAlert.height - 50

            Rectangle {
                id:warningLabelForOsAlert
                width: warningBoxForOsAlert.width - 100
                height: parent.height/5
                color:"red"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top:parent.top
                }

                Text {
                    id: warningLabelTextForOsAlert
                    anchors.centerIn: warningLabelForOsAlert
                    text: "<b>WARNING</b>"
                    font.pixelSize: ratioCalc * 15
                    color: "white"
                }

                Text {
                    id: warningIconLeft
                    anchors {
                        right: warningLabelTextForOsAlert.left
                        verticalCenter: warningLabelTextForOsAlert.verticalCenter
                        rightMargin: 10
                    }
                    text: "\ue80e"
                    font.family: Fonts.sgicons
                    font.pixelSize: (parent.width + parent.height)/25
                    color: "white"
                }

                Text {
                    id: warningIconRight
                    anchors {
                        left: warningLabelTextForOsAlert.right
                        verticalCenter: warningLabelTextForOsAlert.verticalCenter
                        leftMargin: 10
                    }
                    text: "\ue80e"
                    font.family: Fonts.sgicons
                    font.pixelSize: (parent.width + parent.height)/25
                    color: "white"
                }

            }

            Rectangle {
                id: messageContainerForOsAlert
                anchors {
                    top: warningLabelForOsAlert.bottom
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - warningLabelForOsAlert.height - selectionContainerForOsAlert.height
                Text {
                    id: warningTextForForOsAlert
                    anchors.fill:parent
                    text:  "The temperature of the onboard LEDs has exceeded the specified temperature threshold. The duty cycle of the DIM#/EN signal is now being reduced automatically to bring the LED temperature to a safe operating region. The duty cycle cannot be adjusted during this time period unless the device is disabled."
                    verticalAlignment:  Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.bold: true
                    font.pixelSize: ratioCalc * 15
                }
            }

            Rectangle {
                id: selectionContainerForOsAlert
                width: parent.width
                height: parent.height/4.5
                anchors{
                    top: messageContainerForOsAlert.bottom
                }
                color: "transparent"

                Rectangle {
                    id: okButtonForOsAlert
                    width: parent.width/2
                    height:parent.height
                    anchors.centerIn: parent
                    color: "transparent"

                    SGButton {
                        anchors.centerIn: parent
                        text: "OK"
                        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                        roundedLeft: true
                        roundedRight: true
                        onClicked: {
                            warningPopupOsAlert.close()
                        }
                    }
                }
            }
        }
    }


    RowLayout {
        id: mainSetting
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height/1.3
        Layout.alignment: Qt.AlignCenter

        Rectangle{
            id: mainSettingContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color:"transparent"

            ColumnLayout{
                anchors {
                    margins: 15
                    fill: parent
                }

                Rectangle {
                    id: enableSwitchContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    SGAlignedLabel {
                        id: enableSwitchLabel
                        target: enableSwitch
                        text: "Enable"
                        font.bold: true
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.3
                        CustomSGSwitch{
                            id: enableSwitch
                            height: 35 * ratioCalc
                            width: 95 * ratioCalc
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel:   "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            checked: true
                            fontSizeMultiplier: ratioCalc * 1.3
                            onToggled: {
                                checked ? platformInterface.set_enable.update("on") : platformInterface.set_enable.update("off")
                            }
                        }

                    }
                }

                Rectangle {
                    id: dutySliderContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    SGAlignedLabel {
                        id: dutySliderLabel
                        target: dutySlider
                        text: "DIM#/EN Positive Duty Cycle"
                        font.bold: true
                        alignment: SGAlignedLabel.SideTopCenter
                        fontSizeMultiplier: ratioCalc * 1.3
                        anchors.centerIn: parent

                        SGSlider{
                            id: dutySlider
                            width: dutySliderContainer.width/1.3
                            from: 0
                            to: 100
                            fromText.text: "0%"
                            toText.text: "100%"
                            stepSize: 0.1
                            live: false
                            fontSizeMultiplier: ratioCalc * 1.3
                            inputBoxWidth: dutySliderContainer.width/7
                            inputBox.validator: DoubleValidator {
                                top: dutySlider.to
                                bottom: dutySlider.from
                            }
                            onUserSet: platformInterface.set_dim_en_duty.update(value)
                        }
                    }
                }

                Rectangle {
                    id: freqSliderContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: freqSliderLabel
                        target: freqSlider
                        text: "DIM#/EN Frequency"
                        alignment: SGAlignedLabel.SideTopCenter
                        fontSizeMultiplier: ratioCalc * 1.3
                        anchors.centerIn: parent
                        font.bold: true
                        SGSlider{
                            id: freqSlider
                            width: freqSliderContainer.width/1.3
                            from: 0.1
                            to: 20
                            stepSize: 0.001
                            value: 1
                            fromText.text: "0.1kHz"
                            toText.text: "20kHz"
                            live: false
                            fontSizeMultiplier: ratioCalc * 1.2
                            inputBoxWidth: dutySliderContainer.width/7
                            inputBox.validator: DoubleValidator {
                                top: freqSlider.to
                                bottom: freqSlider.from
                            }
                            onUserSet: platformInterface.set_dim_en_freq.update(value)

                        }
                    }
                }

                Rectangle {
                    id: ledConfigSettingsContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent

                        Rectangle {
                            id:extLedCheckboxContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            SGAlignedLabel {
                                id: extLedCheckboxLabel
                                target: extLedCheckbox
                                text: "External LEDs \n connected?"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                font.italic: true
                                alignment: SGAlignedLabel.SideTopCenter
                                //anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.3
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter


                                Rectangle {
                                    color: "transparent"
                                    anchors { fill: extLedCheckboxLabel }
                                    MouseArea {
                                        id: hoverArea
                                        anchors { fill: parent }
                                        hoverEnabled: true
                                    }
                                }

                                CheckBox {
                                    id: extLedCheckbox
                                    checked: false

                                    onClicked: {
                                        if(checked) {
                                            platformInterface.set_ext_led_state.update("connected")
                                        } else {
                                            platformInterface.set_ext_led_state.update("disconnected")
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id:ledConfigContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"

                            SGAlignedLabel {
                                id: ledConfigLabel
                                target: ledConfigCombo
                                text: "LED Configuration"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors{ left:parent.left
                                    leftMargin: 15
                                    verticalCenter: parent.verticalCenter
                                }
                                fontSizeMultiplier: ratioCalc * 1.3

                                CustomSGComboBox {
                                    id: ledConfigCombo
                                    textRole: "text"
                                    model: ledConfigModel
                                    borderColor: "black"
                                    textColor: "black"          // Default: "black"
                                    indicatorColor: "black"
                                    fontSizeMultiplier:  ratioCalc * 1.2
                                    onActivated: {
                                        if(currentIndex == 0) {
                                            platformInterface.set_led.update("1_led")
                                            osAlertContainer.opacity = 1.0
                                            osAlertSettingsContainer.opacity = 1.0
                                            osAlertSettingsContainer.enabled = true
                                        }
                                        else if(currentIndex == 1) {
                                            platformInterface.set_led.update("2_leds")
                                            osAlertContainer.opacity = 1.0
                                            osAlertSettingsContainer.opacity = 1.0
                                            osAlertSettingsContainer.enabled = true
                                        }
                                        else if (currentIndex == 2) {
                                            platformInterface.set_led.update("3_leds")
                                            osAlertContainer.opacity = 1.0
                                            osAlertSettingsContainer.opacity = 1.0
                                            osAlertSettingsContainer.enabled = true
                                        }
                                        else if(currentIndex == 3) {
                                            platformInterface.set_led.update("external")
                                            osAlertContainer.opacity = 0.5
                                            osAlertSettingsContainer.opacity = 0.5
                                            osAlertSettingsContainer.enabled = false

                                        }
                                        else {
                                            platformInterface.set_led.update("short")
                                            osAlertContainer.opacity = 0.5
                                            osAlertSettingsContainer.opacity = 0.5
                                            osAlertSettingsContainer.enabled = false

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

            ColumnLayout {
                anchors{
                    fill: parent
                    margins: 15
                }

                Rectangle {
                    id: infoBoxRow1Container
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    RowLayout {
                        anchors {
                            margins: 10
                            fill: parent
                        }
                        Rectangle {
                            id: vinConnContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"transparent"
                            SGAlignedLabel {
                                id: vinConnLabel
                                text: "<b>Input Voltage<br>(VIN_CONN)</b>"
                                target: vin_conn
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.3
                                font.bold : true
                                SGInfoBox {
                                    id: vin_conn
                                    height:  35 * ratioCalc
                                    width: 140 * ratioCalc
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vin_conn
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true
                                }
                            }
                        }
                        Rectangle {
                            id: vinContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            SGAlignedLabel {
                                id: vinLabel
                                text: "<b>LED Input Voltage<br>(VIN_LED)</b>"
                                target: vin
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.3
                                font.bold : true
                                SGInfoBox {
                                    id: vin
                                    height:  35 * ratioCalc
                                    width: 140 * ratioCalc
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vin
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true
                                }
                            }
                        }
                        Rectangle {
                            id: inputCurrentContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            SGAlignedLabel {
                                id: inputCurrentLabel
                                text: "<b>Input Current<br>(IIN)</b>"
                                target: inputCurrent
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.3
                                font.bold : true
                                SGInfoBox {
                                    id: inputCurrent
                                    height:  35 * ratioCalc
                                    width: 140 * ratioCalc
                                    unit: "<b>mA</b>"
                                    text: platformInterface.telemetry.iin
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: infoBoxRow2Container
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent
                        Rectangle {
                            id:  vledContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"transparent"
                            SGAlignedLabel {
                                id: vledLabel
                                text: "<b>Approximate LED<br>Voltage</b>"
                                target: vled
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.3
                                font.bold : true
                                SGInfoBox {
                                    id: vled
                                    height: 35 * ratioCalc
                                    width: 140 * ratioCalc
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vled
                                    boxFont.family: Fonts.digitalseven
                                }
                            }
                        }

                        Rectangle {
                            id:  voutLEDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"transparent"
                            SGAlignedLabel {
                                id: voutLEDLabel
                                text: "<b>LED Output Voltage<br>(VOUT_LED)</b>"
                                target: voutLED
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.3
                                font.bold : true
                                SGInfoBox {
                                    id: voutLED
                                    height:  35 * ratioCalc
                                    width: 140 * ratioCalc
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                    unit: "<b>V</b>"
                                    text: platformInterface.telemetry.vout
                                    boxFont.family: Fonts.digitalseven
                                }
                            }
                        }

                        Rectangle {
                            id:  csCurrentContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"transparent"
                            SGAlignedLabel {
                                id: csCurrentLabel
                                text: "<b>Average CS Current<br>(ICS)</b>"
                                target: csCurrent
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.3
                                font.bold : true
                                SGInfoBox {
                                    id: csCurrent
                                    height:  35 * ratioCalc
                                    width: 140 * ratioCalc
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                    unit: "<b>mA</b>"
                                    text:  platformInterface.telemetry.ics
                                    boxFont.family: Fonts.digitalseven
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: temperatureContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/2.5
                    color: "transparent"


                    RowLayout {
                        anchors.fill: parent
                        Rectangle {
                            id: osAlertSettingsContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle {
                                    id:  osAlertThresholdContainer
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: parent.height/1.5
                                    color:"white"
                                    SGAlignedLabel {
                                        id:osAlertThresholdLabel
                                        text: "<b>Set OS#/ALERT# </b><br><b>Temperature Threshold</b>"
                                        target: osAlertThreshold
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.3
                                        font.bold : true
                                        CustomSGSubmitInfoBox {
                                            id: osAlertThreshold
                                            infoBoxWidth: 140 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                            unit: "<b>°C</b>"
                                            validator: IntValidator {
                                                top: 110
                                                bottom: -55
                                            }
                                            buttonText: "Apply"
                                            placeholderText: platformInterface.control_states.os_alert_threshold
                                            onAccepted: {
                                                platformInterface.set_os_alert.update(value)
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: osAlertContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: osAlertLabel
                                        target: osAlert
                                        text:  "OS#/ALERT#"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors {
                                            top: parent.top
                                            topMargin: 10
                                            centerIn: parent
                                        }
                                        fontSizeMultiplier: ratioCalc * 1.3
                                        font.bold : true

                                        property bool osAlertNoti: platformInterface.int_os_alert.value
                                        onOsAlertNotiChanged: {
                                            if(osAlertNoti == true) {
                                                osAlert.status =  SGStatusLight.Red
                                            }
                                            else osAlert.status = SGStatusLight.Off
                                        }

                                        property var foldback_status_value: platformInterface.foldback_status.value
                                        onFoldback_status_valueChanged: {
                                            console.log("foldback_status_value",foldback_status_value)
                                            if(foldback_status_value === "on") {
                                                if (!warningPopupOsAlert.opened) {
                                                    warningPopupOsAlert.open()
                                                }
                                                dutySliderContainer.enabled = false
                                                dutySliderContainer.opacity = 0.5
                                            }
                                            else  {
                                                dutySliderContainer.enabled = true
                                                dutySliderContainer.opacity = 1.0
                                            }
                                        }

                                        SGStatusLight {
                                            id: osAlert
                                        }

                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: tempGaugeContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.topMargin: 5
                            color:"transparent"
                            SGAlignedLabel {
                                id: tempGaugeLabel
                                target: tempGauge
                                text: "Board \n Temperature"
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.3
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: tempGauge
                                    property var temp_change: platformInterface.telemetry.temperature
                                    onTemp_changeChanged: {
                                        value = temp_change
                                    }
                                    height: tempGaugeContainer.height - tempGaugeLabel.contentHeight
                                    tickmarkStepSize: 10
                                    minimumValue: 0
                                    maximumValue: 120
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "°C"
                                    unitTextFontSizeMultiplier: ratioCalc * 1.7
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
                    }
                }
            }
        }
    }
}



