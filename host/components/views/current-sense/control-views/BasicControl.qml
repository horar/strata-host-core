import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    MouseArea {
        id: containMouseArea
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
        }
    }

    Item {
        id: filterHelpContainer
        property point topLeft
        property point bottomRight
        width:  label1Container.width+ enable1.width + enable1.width + reading1Setting.width + 50//enable.width + inputCurrentContainer.width - 80
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = label1Container.mapToItem(root, 0,  0)
            bottomRight = enable5.mapToItem(root, enable5.width, enable5.height)
        }
    }

    Component.onCompleted:  {
        Help.registerTarget(filterHelpContainer, "These 5 switches enable/disable the 5 current sense circuits supplied on the board. Only 1 circuit may be enabled at a time. The current rating given is the range for accurate readings from each of the circuits throughout the entire range of input voltages from 0 - 26V. The exception is the NCS333A circuit which operates from 0 - 5V. Safety features will prevent the user from turning the NCS333A circuit on if the input voltage is too high. Do not exceed 26V on the input to the board.", 0, "currentSenseHelp")
        Help.registerTarget(currentSenseMaxLabel, "This LED will let the user know if the current range through the enabled circuit has been exceeded and therefore the measurements are no longer accurate.", 1, "currentSenseHelp")
        Help.registerTarget(vinReading, "Input voltage to the 5 parallel circuits are measured here. This measurement is taken after the input current sense circuit.", 2, "currentSenseHelp")
        Help.registerTarget(recalibrateContainer, "This will recalibrate all 5 circuits to set the new offset reading. It is recommended to recalibrate before measurements or anytime the input voltage is changed. Measurements may be negative if this is used under load.", 4, "currentSenseHelp")
        Help.registerTarget(activeDischargeLabel, "This switch enables/disables the active discharge on the output of the board. When this switch is enabled the output will actively discharge the output capacitance.", 3,"currentSenseHelp")
        Help.registerTarget(reset, "This will reset the board by turning all circuitry off. If an interrupt occurred, the parameters that caused the interrupt will need to be fixed in order for the board to reset itself.", 5, "currentSenseHelp")
        Help.registerTarget(onBoardColumn, "These are the controls for the programmable load included on the board. The load is split into 3 circuits each with independent controls. Only 1 load circuit may be on at a time. The ranges for each load circuit are given by the labels below the sliders, and the sliders can be adjusted to draw the desired load. The switches enable and disable the circuit.", 6, "currentSenseHelp")
        Help.registerTarget(voltageStatusLabel,"This LED indicates that the input voltage is higher than the set point for the input voltage interrupt. While in Auto mode, this set point is a constant 26V for all current sense amplifiers except the NCS333A, where it is set to 5.1V. While in Manual mode, this set point is determined by the user using the "  + "\"" + "Set Max Input Voltage" + "\"" + " slider in the Manual Mode Set section." , 7 , "currentSenseHelp" )
        Help.registerTarget(currentStatusLabel,"This LED indicates that the current going through the On-Board Programmable Load is too high. The set point value is calculated by measuring the input voltage and determining the maximum amount of current that can travel through the load. The maximum current through the load regardless of the total power being drawn is 10A.",  8 , "currentSenseHelp" )
        Help.registerTarget(loadCurrentStatusLabel,"This LED indicates the input current to the board is too high. When in Auto mode, this threshold is set automatically depending on which current sense amplifier circuit is enabled. When in Manual Mode, the user may set this value lower than the automatically set value but not higher.", 9 , "currentSenseHelp" )
        Help.registerTarget(loadFaultLabel ,"This LED indicates that one of the previous three interrupts occurred and the board is placed in a protected state where none of the loads or current sense amplifiers can be enabled. The Reset button must be used to use the board again, and the cause of the interrupt must be resolved by the user in order to reset the board.",10 , "currentSenseHelp" )
        Help.registerTarget(interruptBox,"These readings will let the user know where the interrupt thresholds are. They will change depending on which circuit is enabled as well as what the input voltage/current through the board is. If these thresholds are exceeded an interrupt will occur.", 11, "currentSenseHelp")
        Help.registerTarget(powerGaugeContainer,"This gauge lets the user know how much power is being drawn by the high current on-board load circuit in relation to its maximum power capability. If maximum power is exceeded, an interrupt will trigger. Refer to "+ "\""+ "Max Input Voltage" + "\"" + " and " + "\"" +"Max On-Board Load Current" + "\"" + " above to know what the load circuits' capabilities are.", 12, "currentSenseHelp")
        Help.registerTarget(statusListContainer, "This will contain any interrupt messages or warnings for the user to diagnose any problems.", 13, "currentSenseHelp")
        Help.registerTarget(manualModeSection, "This section is for if the user would like to set customizable input voltage and current limits. While in " + "\"" + "Auto" + "\""  +" mode, the limits are determined by the max capabilities of whatever circuit is enabled. While in " + "\"" + "Manual" + "\"" + " mode the limits are determined by the user, but will still be limited by the max capabilities of whatever circuit is enabled.", 14, "currentSenseHelp")
    }

    onWidthChanged: {
        filterHelpContainer.update()
    }
    onHeightChanged: {
        filterHelpContainer.update()
    }

    Connections {
        target: Help.utility
        onTour_runningChanged:{
            filterHelpContainer.update()
        }
    }

    property var switch_status_notification_current: platformInterface.current_sense_interrupt.switch_status
    onSwitch_status_notification_currentChanged: {
        if(switch_status_notification_current !== "") {
            if(switch_status_notification_current === "freeze") {
                enable1.enabled = false
                enable2.enabled = false
                enable3.enabled = false
                enable4.enabled = false
                enable5.enabled = false
                lowLoadEnable.enabled = false
                midCurrentEnable.enabled = false
                highCurrentEnable.enabled = false
            }
            else {
                enable1.enabled = true
                enable2.enabled = true
                enable3.enabled = true
                enable4.enabled = true
                enable5.enabled = true
            }
        }
    }

    property var switch_status_notification_voltage: platformInterface.voltage_sense_interrupt.switch_status
    onSwitch_status_notification_voltageChanged: {
        if(switch_status_notification_voltage !== "") {
            if(switch_status_notification_voltage === "freeze") {
                enable1.enabled = false
                enable2.enabled = false
                enable3.enabled = false
                enable4.enabled = false
                enable5.enabled = false
                lowLoadEnable.enabled = false
                midCurrentEnable.enabled = false
                highCurrentEnable.enabled = false
            }
            else {
                enable1.enabled = true
                enable2.enabled = true
                enable3.enabled = true
                enable4.enabled = true
                enable5.enabled = true
            }
        }
    }

    property var switch_enable_status_state: platformInterface.switch_enable_status.load_switch_status
    onSwitch_enable_status_stateChanged: {
        if(switch_enable_status_state !== "") {
            if(switch_enable_status_state === "freeze") {
                lowLoadEnable.enabled = false
                midCurrentEnable.enabled = false
                highCurrentEnable.enabled = false
            }
            else {
                lowLoadEnable.enabled = true
                midCurrentEnable.enabled = true
                highCurrentEnable.enabled = true
            }
        }
    }

    property var switch_status_notification_i_in: platformInterface.i_in_interrupt.switch_status
    onSwitch_status_notification_i_inChanged: {
        if(switch_status_notification_i_in !== "") {
            if(switch_status_notification_i_in === "freeze") {
                enable1.enabled = false
                enable2.enabled = false
                enable3.enabled = false
                enable4.enabled = false
                enable5.enabled = false
                lowLoadEnable.enabled = false
                midCurrentEnable.enabled = false
                highCurrentEnable.enabled = false
            }
            else {
                enable1.enabled = true
                enable2.enabled = true
                enable3.enabled = true
                enable4.enabled = true
                enable5.enabled = true
            }
        }
    }

    property var initial_status: platformInterface.initial_status
    onInitial_statusChanged: {
        if(initial_status.en_210 === "on") {
            enable3.checked = true
        }
        else enable3.checked = false

        if (initial_status.en_211 === "on") {
            enable4.checked = true
        }
        else  enable4.checked = false

        if(initial_status.en_213 === "on") {
            enable1.checked = true
        }
        else enable1.checked = false

        if(initial_status.en_214 === "on") {
            enable2.checked = true
        }
        else enable2.checked = false

        if(initial_status.en_333 === "on") {
            enable5.checked = true
        }
        else enable5.checked = false

        if(initial_status.manual_mode === "Manual") {
            enableModeSet.checked = true
            maxInputCurrentContainer.enabled = true
            maxInputCurrentContainer.opacity = 1.0
            maxInputVoltageContainer.enabled = true
            maxInputVoltageContainer.opacity = 1.0
        }
        else {
            enableModeSet.checked = false
            maxInputCurrentContainer.enabled = false
            maxInputCurrentContainer.opacity = 0.5
            maxInputVoltageContainer.enabled = false
            maxInputVoltageContainer.opacity = 0.5
        }

        maxInputCurrent.value = initial_status.max_input_current
        maxInputVoltage.value = initial_status.max_input_voltage

        if(initial_status.low_load_en === "on")
            lowLoadEnable.checked = true
        else lowLoadEnable.checked = false

        if(initial_status.mid_load_en === "on")
            midCurrentEnable.checked = true
        else midCurrentEnable.checked = false

        if(initial_status.high_load_en === "on")
            highCurrentEnable.checked = true
        else highCurrentEnable.checked = false

        if(initial_status.active_discharge === "on")
            activeDischarge.checked = true
        else activeDischarge.checked = false

        if(initial_status.load_switch_status !== "") {
            if(initial_status.load_switch_status === "freeze") {
                lowLoadEnable.enabled = false
                midCurrentEnable.enabled = false
                highCurrentEnable.enabled = false
            }
            else {
                lowLoadEnable.enabled = true
                midCurrentEnable.enabled = true
                highCurrentEnable.enabled = true
            }
        }
    }

    property var ad_status: platformInterface.ad_status.status
    onAd_statusChanged: {
        if(ad_status === "on"){
            activeDischarge.checked = true
        }
        else activeDischarge.checked = false
    }

    property var reset_status: platformInterface.reset_status
    onReset_statusChanged: {
        if(reset_status.switch_en_state === "on"){
            enable1.checked = true
            enable2.checked = true
            enable3.checked = true
            enable4.checked = true
            enable5.checked = true
        }
        else {
            enable1.checked = false
            enable2.checked = false
            enable3.checked = false
            enable4.checked = false
            enable5.checked = false
        }

        if(reset_status.switch_load_state === "on"){
            lowLoadEnable.checked = true
            midCurrentEnable.checked = true
            midCurrentEnable.checked = true
        }
        else {
            lowLoadEnable.checked = false
            midCurrentEnable.checked = false
            midCurrentEnable.checked = false
        }

        if (reset_status.load_fault === "on")
            loadFault.status = SGStatusLight.Red
        else  loadFault.status = SGStatusLight.Off

        if(reset_status.switch_status !== "") {
            if(reset_status.switch_status === "freeze") {
                enable1.enabled = false
                enable2.enabled = false
                enable3.enabled = false
                enable4.enabled = false
                enable5.enabled = false
                lowLoadEnable.enabled = false
                midCurrentEnable.enabled = false
                highCurrentEnable.enabled = false
            }
            else {
                enable1.enabled = true
                enable2.enabled = true
                enable3.enabled = true
                enable4.enabled = true
                enable5.enabled = true
            }
        }
        if(reset_status.load_switch_status !== ""){
            if(reset_status.load_switch_status === "freeze"){
                lowLoadEnable.enabled = false
                midCurrentEnable.enabled = false
                highCurrentEnable.enabled = false
            }
            else {
                lowLoadEnable.enabled = true
                midCurrentEnable.enabled = true
                highCurrentEnable.enabled = true
            }
        }
    }

    property  var switch_enable_status_en_210: platformInterface.switch_enable_status.en_210
    onSwitch_enable_status_en_210Changed: {
        if(switch_enable_status_en_210 === "on") {
            enable3.checked = true
        }
        else enable3.checked = false
    }

    property  var switch_enable_status_en_211: platformInterface.switch_enable_status.en_211
    onSwitch_enable_status_en_211Changed: {
        if(switch_enable_status_en_211 === "on") {
            enable4.checked = true
        }
        else enable4.checked = false
    }

    property  var switch_enable_status_en_214: platformInterface.switch_enable_status.en_214
    onSwitch_enable_status_en_214Changed: {
        console.log(switch_enable_status_en_214)
        if(switch_enable_status_en_214 === "on") {
            enable2.checked = true
        }
        else enable2.checked = false
    }

    property  var switch_enable_status_en_213: platformInterface.switch_enable_status.en_213
    onSwitch_enable_status_en_213Changed: {

        if(switch_enable_status_en_213 === "on") {
            enable1.checked = true
        }
        else enable1.checked = false
    }


    property  var switch_enable_status_en_333: platformInterface.switch_enable_status.en_333
    onSwitch_enable_status_en_333Changed: {
        if(switch_enable_status_en_333 === "on") {
            enable5.checked = true
        }
        else enable5.checked = false
    }

    property var error_notification: platformInterface.error_notification.message
    onError_notificationChanged: {
        if(error_notification !== "")
            pushMessagesToLog(error_notification)
    }

    function pushMessagesToLog (messageIs) {
        // Change text color to black of the entire existing list of faults
        for(var j = 0; j < logFault.model.count; j++){
            logFault.model.get(j).color = "black"
        }

        logFault.insert(messageIs, 0, "red")

    }

    property var current_sense_interrupt_message: platformInterface.current_sense_interrupt.error_msg
    onCurrent_sense_interrupt_messageChanged: {
        if(current_sense_interrupt_message !== "")
            pushMessagesToLog(current_sense_interrupt_message)
    }

    property var voltage_sense_interrupt_message: platformInterface.voltage_sense_interrupt.error_msg
    onVoltage_sense_interrupt_messageChanged: {
        if(voltage_sense_interrupt_message !== "")
            pushMessagesToLog(voltage_sense_interrupt_message)
    }

    property var i_in_interrupt_message: platformInterface.i_in_interrupt.error_msg
    onI_in_interrupt_messageChanged: {
        if(i_in_interrupt_message !== "")
            pushMessagesToLog(i_in_interrupt_message)
    }

    property var led_status_CSA_warning: platformInterface.led_status.CSA_warning
    onLed_status_CSA_warningChanged: {
        if(led_status_CSA_warning !== "" && led_status_CSA_warning !== "N/A") {
            pushMessagesToLog(led_status_CSA_warning)
        }
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        property var periodic_status: platformInterface.periodic_status
        onPeriodic_statusChanged: {
            setting1Reading.text = periodic_status.ADC_213
            setting2Reading.text = periodic_status.ADC_214
            setting3Reading.text = periodic_status.ADC_210
            setting4Reading.text = periodic_status.ADC_211
            setting5Reading.text = periodic_status.ADC_333
            vinReading.text = periodic_status.ADC_VIN
        }

        property var led_status: platformInterface.led_status
        onLed_statusChanged: {
            if(led_status.interrupts.vs_int === "on") {
                voltageStatusLight.status = SGStatusLight.Red
            }
            else voltageStatusLight.status = SGStatusLight.Off

            if(led_status.interrupts.cs_int === "on") {
                currentStatusLight.status = SGStatusLight.Red
            }
            else currentStatusLight.status = SGStatusLight.Off

            if(led_status.interrupts.i_in_int === "on") {
                loadCurrent.status = SGStatusLight.Red
            }
            else loadCurrent.status = SGStatusLight.Off
        }

        property var current_sense_interrupt: platformInterface.current_sense_interrupt
        onCurrent_sense_interruptChanged:  {
            if(current_sense_interrupt.value === "yes") {
                currentStatusLight.status = SGStatusLight.Red
            }
            else currentStatusLight.status = SGStatusLight.Off

            if(current_sense_interrupt.load_fault === "on")
                loadFault.status = SGStatusLight.Red

            else loadFault.status = SGStatusLight.Off
        }

        property var voltage_sense_interrupt: platformInterface.voltage_sense_interrupt
        onVoltage_sense_interruptChanged: {
            if(voltage_sense_interrupt.value === "yes") {
                voltageStatusLight.status = SGStatusLight.Red
            }
            else voltageStatusLight.status = SGStatusLight.Off

            if(voltage_sense_interrupt.load_fault === "on")
                loadFault.status = SGStatusLight.Red

            else loadFault.status = SGStatusLight.Off

        }

        property var i_in_interrupt: platformInterface.i_in_interrupt
        onI_in_interruptChanged: {
            if(i_in_interrupt.value === "yes") loadCurrent.status = SGStatusLight.Red
            else loadCurrent.status = SGStatusLight.Off

            if(i_in_interrupt.load_fault === "on") loadFault.status = SGStatusLight.Red
            else loadFault.status = SGStatusLight.Off

        }

        Text {
            id: platformName
            Layout.alignment: Qt.AlignHCenter
            text: "Current Sense"
            font.bold: true
            font.pixelSize: ratioCalc * 25
            topPadding: 7
        }


        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - platformName.contentHeight - 40
            Layout.alignment: Qt.AlignCenter

            RowLayout {
                anchors.fill:parent
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    ColumnLayout {
                        anchors.fill: parent

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Text {
                                id: settings
                                text: "Settings"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    top: parent.top
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
                                    topMargin: 7
                                }
                            }

                            ColumnLayout{
                                anchors {
                                    top: line1.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                id: label1Container
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "NCS213R"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                    }
                                                }

                                                Rectangle {

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter

                                                        text: "30A Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable1
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                //fontSizeMultiplier: ratioCalc
                                                anchors.centerIn: parent



                                                onToggled: {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("213_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }

                                            }


                                        }

                                        Rectangle{
                                            id: reading1Setting
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting1Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 140 * ratioCalc
                                                unit: " A"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "NCS214R"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "1A Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }
                                                }

                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable2

                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                //fontSizeMultiplier: ratioCalc

                                                anchors.centerIn: parent


                                                onToggled: {

                                                    if(checked)
                                                        platformInterface.switch_enables.update("214_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }


                                            }

                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting2Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 140 * ratioCalc
                                                unit: " A"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "NCS210R"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "100mA Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }
                                                }

                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable3
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                anchors.centerIn: parent
                                                onToggled:  {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("210_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }

                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting3Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 155 * ratioCalc
                                                unit: " mA"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            ColumnLayout {
                                                anchors.fill: parent

                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "NCS211R"
                                                        font.bold: true
                                                        fontSizeMultiplier:ratioCalc * 1.2
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "2mA Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }
                                                }
                                            }

                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable4
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                anchors.centerIn: parent
                                                onToggled:  {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("211_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }

                                            }

                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting4Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 155 * ratioCalc
                                                unit: " mA"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        ColumnLayout {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            Rectangle{
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                SGText {
                                                    anchors.bottom: parent.bottom
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "NCS333A"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    font.bold: true
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                SGText {
                                                    anchors.top:parent.top
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "100µA & 5V Max"
                                                    font.bold: true
                                                    fontSizeMultiplier: ratioCalc
                                                    color: "red"

                                                }
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable5
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                anchors.centerIn: parent
                                                onToggled:  {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("333_on")
                                                    else platformInterface.switch_enables.update("off")

                                                }
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting5Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 152 * ratioCalc
                                                unit: " µA"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter

                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "transparent"

                                    RowLayout {
                                        anchors.fill: parent

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"

                                            SGAlignedLabel {
                                                id: currentSenseMaxLabel
                                                target: currentSenseMaxReading
                                                alignment: SGAlignedLabel.SideLeftCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Current Sense \n Max Reading "
                                                font.bold: true

                                                SGStatusLight {
                                                    id: currentSenseMaxReading
                                                    width: 30
                                                }

                                                property var periodic_status_CSA_max_reading: platformInterface.led_status.CSA_max_reading
                                                onPeriodic_status_CSA_max_readingChanged:  {
                                                    if(periodic_status_CSA_max_reading === "on")
                                                        currentSenseMaxReading.status = SGStatusLight.Red
                                                    else currentSenseMaxReading.status = SGStatusLight.Off
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"


                                            SGText {
                                                id: vinText
                                                text : "VIN"
                                                fontSizeMultiplier:ratioCalc * 1.2
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"


                                            SGInfoBox {
                                                id: vinReading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 143 * ratioCalc
                                                unit: " V"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }


                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "transparent"
                                    RowLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:  activeDischargeLabel
                                                target: activeDischarge
                                                text: "Active \n Discharge"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideLeftCenter
                                                anchors.centerIn: parent
                                                horizontalAlignment: Text.AlignHCenter
                                                SGSwitch {
                                                    id: activeDischarge
                                                    checkedLabel: "On"
                                                    uncheckedLabel: "Off"
                                                    // fontSizeMultiplier: ratioCalc
                                                    onToggled: {
                                                        if(checked)
                                                            platformInterface.set_active_discharge.update("on")
                                                        else
                                                            platformInterface.set_active_discharge.update("off")
                                                    }
                                                }
                                            }

                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"

                                            SGButton {
                                                id: recalibrateContainer
                                                text: "Recalibrate"
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc
                                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                                hoverEnabled: true
                                                height: parent.height/2
                                                width: parent.width/2
                                                onClicked: platformInterface.set_recalibrate.send()
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"

                                            SGButton {
                                                id: reset
                                                text: "Reset"
                                                fontSizeMultiplier: ratioCalc
                                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                                hoverEnabled: true
                                                height: parent.height/2
                                                width: parent.width/2
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                onClicked: {
                                                    platformInterface.reset_board.send()
                                                    logFault.clear()
                                                    enable1.checked = false
                                                    enable2.checked = false
                                                    enable3.checked = false
                                                    enable4.checked = false
                                                    enable5.checked = false
                                                    lowLoadEnable.checked = false
                                                    midCurrentEnable.checked = false
                                                    highCurrentEnable.checked = false


                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: parent.height/3
                            Layout.fillWidth: true

                            Text {
                                id: modeSet
                                text: "Manual Mode Set"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    top: parent.top
                                }
                            }

                            Rectangle {
                                id: line4
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: modeSet.bottom
                                    topMargin: 7
                                }
                            }

                            RowLayout {
                                id: manualModeSection
                                anchors {
                                    top: line4.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width/4

                                    SGAlignedLabel {
                                        id:  enableModeSetLabel
                                        target: enableModeSet
                                        text: "Mode"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        SGSwitch {
                                            id: enableModeSet
                                            checkedLabel: "Manual"
                                            uncheckedLabel: "Auto"
                                            onToggled: {
                                                if(checked) {
                                                    maxInputCurrentContainer.enabled = true
                                                    maxInputCurrentContainer.opacity = 1.0
                                                    maxInputVoltageContainer.enabled = true
                                                    maxInputVoltageContainer.opacity = 1.0
                                                    platformInterface.set_mode.update("Manual")
                                                }
                                                else {
                                                    maxInputCurrentContainer.enabled = false
                                                    maxInputCurrentContainer.opacity = 0.5
                                                    maxInputVoltageContainer.enabled = false
                                                    maxInputVoltageContainer.opacity = 0.5
                                                    platformInterface.set_mode.update("Auto")
                                                }
                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    ColumnLayout{
                                        anchors.fill: parent
                                        Rectangle {
                                            id: maxInputCurrentContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGAlignedLabel {
                                                id:  maxInputCurrentLabel
                                                target: maxInputCurrent
                                                text: "Set Max Input Current"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent

                                                SGSlider {
                                                    id: maxInputCurrent
                                                    width: maxInputCurrentContainer.width
                                                    live: false
                                                    from: 0.0
                                                    to: 30.5
                                                    stepSize: 0.1
                                                    fromText.text: "0A"
                                                    toText.text: "30.5A"
                                                    inputBoxWidth: maxInputCurrentContainer.width/5
                                                    fontSizeMultiplier: ratioCalc
                                                    inputBox.validator: DoubleValidator { }
                                                    inputBox.text: maxInputCurrent.value.toFixed(1)
                                                    inputBox.unit: " A"
                                                    inputBox.unitFont.bold: true
                                                    inputBox.unitOverrideWidth: 30 * ratioCalc

                                                    onUserSet: {
                                                        var valueSet = parseInt(value)
                                                        if (valueSet > maxInputCurrent.to) {
                                                            value = maxInputCurrent.to
                                                        }
                                                        if (valueSet < maxInputCurrent.from) {
                                                            value = maxInputCurrent.from
                                                        }
                                                        inputBox.text = value.toFixed(1)

                                                        platformInterface.set_i_in_dac.update(value.toFixed(1))
                                                    }
                                                    onValueChanged: {
                                                        inputBox.text = value
                                                    }

                                                    property var switch_enable_status_iin_max: platformInterface.switch_enable_status.i_in_max
                                                    onSwitch_enable_status_iin_maxChanged: {
                                                        maxInputCurrent.to = parseFloat(switch_enable_status_iin_max)
                                                        maxInputCurrent.toText.text = switch_enable_status_iin_max + "A"

                                                    }

                                                    property var enable_status_in_set: platformInterface.switch_enable_status.i_in_set
                                                    onEnable_status_in_setChanged:  {
                                                        maxInputCurrent.stepSize = 0.1
                                                        maxInputCurrent.value = parseFloat(enable_status_in_set)
                                                        console.log("b", maxInputCurrent.value)

                                                    }

                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: maxInputVoltageContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:  maxInputVoltageLabel
                                                target: maxInputVoltage
                                                text: "Set Max Input Voltage"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent

                                                SGSlider {
                                                    id: maxInputVoltage
                                                    width: maxInputVoltageContainer.width
                                                    live: false
                                                    from: 0
                                                    to: 26.5
                                                    stepSize: 0.1
                                                    fromText.text: "0V"
                                                    toText.text: "26.5V"
                                                    inputBoxWidth: maxInputVoltageContainer.width/5
                                                    inputBox.unit: " V"
                                                    inputBox.unitFont.bold: true
                                                    fontSizeMultiplier: ratioCalc
                                                    inputBox.unitOverrideWidth: 30 * ratioCalc
                                                    inputBox.validator: DoubleValidator { top: 26.5; bottom: 0}

                                                    onUserSet:{
                                                        var valueSet = parseInt(value)
                                                        if (valueSet > maxInputVoltage.to) {
                                                            value = maxInputVoltage.to
                                                        }
                                                        if (valueSet < maxInputVoltage.from) {
                                                            value = maxInputVoltage.from

                                                        }
                                                        inputBox.text = value.toFixed(1)

                                                        platformInterface.set_v_set.update(parseFloat(value.toFixed(1)))

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
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent

                        Rectangle {
                            Layout.preferredHeight: parent.height/2.5
                            Layout.fillWidth: true


                            Text {
                                id: onboardLoadControl
                                text: "On-Board Load Controls"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line3
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: onboardLoadControl.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout{
                                anchors {
                                    top: line3.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                ColumnLayout {
                                    id: onBoardColumn
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        RowLayout {
                                            anchors.fill: parent
                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width/6
                                                SGAlignedLabel {
                                                    id: lowCurrentLabel
                                                    target: lowLoadEnable
                                                    text: "<b>" + qsTr("Low Current") + "</b>"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    anchors.centerIn: parent
                                                    SGSwitch {
                                                        id: lowLoadEnable
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        onToggled:  {
                                                            if(checked) {
                                                                platformInterface.load_enables.update("low_load_on")
                                                                platformInterface.set_load_dac_load.update(lowloadSetting.value)
                                                            }
                                                            else  {
                                                                platformInterface.load_enables.update("off")
                                                            }
                                                        }

                                                        property var load_enable_status_low_load: platformInterface.load_enable_status.low_load_en
                                                        onLoad_enable_status_low_loadChanged: {
                                                            if(load_enable_status_low_load === "on") {
                                                                lowLoadEnable.checked = true
                                                            }
                                                            else {
                                                                lowLoadEnable.checked = false
                                                            }
                                                        }

                                                        property var switch_enable_status_low_load: platformInterface.switch_enable_status.low_load_en
                                                        onSwitch_enable_status_low_loadChanged: {
                                                            if(switch_enable_status_low_load === "on")
                                                                lowLoadEnable.checked = true
                                                            else lowLoadEnable.checked = false

                                                        }

                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: lowLoadSettingContainer
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true

                                                SGSlider {
                                                    id: lowloadSetting
                                                    width: lowLoadSettingContainer.width
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.verticalCenterOffset: 10
                                                    live: false
                                                    from: 1
                                                    to:  100
                                                    stepSize: 1
                                                    fromText.text: "1µA"
                                                    toText.text: "100µA"
                                                    value: 0
                                                    inputBoxWidth: lowLoadSettingContainer.width/5
                                                    inputBox.enabled: true
                                                    inputBox.unit: "µA"
                                                    inputBox.unitFont.bold: true
                                                    fontSizeMultiplier: ratioCalc * 1.1
                                                    inputBox.validator: IntValidator { top: 100; bottom: 1 }
                                                    inputBox.unitOverrideWidth: 30 * ratioCalc
                                                    onUserSet: {
                                                        if(lowLoadEnable.checked)
                                                            platformInterface.set_load_dac_load.update(lowloadSetting.value)
                                                    }
                                                }

                                            }

                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        RowLayout{
                                            anchors.fill: parent
                                            Rectangle {

                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width/6
                                                SGAlignedLabel {
                                                    id: midCurrentLabel
                                                    target: midCurrentEnable
                                                    text: "<b>" + qsTr("Mid Current") + "</b>"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    anchors.centerIn: parent
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    SGSwitch {
                                                        id: midCurrentEnable

                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        //fontSizeMultiplier: ratioCalc

                                                        onToggled:  {
                                                            if(checked) {
                                                                platformInterface.load_enables.update("mid_load_on")
                                                                platformInterface.set_load_dac_load.update(midloadSetting.value.toFixed(2))
                                                            }
                                                            else {
                                                                platformInterface.load_enables.update("off")

                                                            }
                                                        }

                                                        property var load_enable_status_mid_load: platformInterface.load_enable_status.mid_load_en
                                                        onLoad_enable_status_mid_loadChanged: {
                                                            if(load_enable_status_mid_load === "on") {
                                                                midCurrentEnable.checked = true
                                                                //platformInterface.set_load_dac_load.update(midloadSetting.value.toFixed(2))
                                                            }
                                                            else {
                                                                midCurrentEnable.checked = false

                                                            }
                                                        }

                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: midLoadSettingContainer
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true

                                                SGSlider {
                                                    id: midloadSetting
                                                    width: midLoadSettingContainer.width
                                                    live: false
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.verticalCenterOffset: 10
                                                    from: 0.1
                                                    to:  100
                                                    stepSize: 0.1
                                                    fromText.text: "0.1mA"
                                                    toText.text: "100mA"
                                                    value: 0
                                                    inputBoxWidth: midLoadSettingContainer.width/5
                                                    fontSizeMultiplier: ratioCalc * 1.1
                                                    inputBox.unit: "mA"
                                                    inputBox.unitFont.bold: true
                                                    inputBox.enabled: true
                                                    inputBox.unitOverrideWidth: 30 * ratioCalc
                                                    inputBox.validator: DoubleValidator { top: 100; bottom: 0.1}
                                                    onUserSet: {
                                                        if(midCurrentEnable.checked)
                                                            platformInterface.set_load_dac_load.update(midloadSetting.value.toFixed(2))
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
                                                Layout.preferredWidth: parent.width/6
                                                Layout.fillHeight: true
                                                SGAlignedLabel {
                                                    id: highCurrentLabel
                                                    target: highCurrentEnable
                                                    text: "<b>" + qsTr("High Current") + "</b>"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    anchors.centerIn: parent
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    SGSwitch {
                                                        id: highCurrentEnable
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"

                                                        onToggled:  {
                                                            if(checked) {
                                                                platformInterface.load_enables.update("high_load_on")
                                                                platformInterface.set_load_dac_load.update(highloadSetting.value.toFixed(2))
                                                            }
                                                            else {
                                                                platformInterface.load_enables.update("off")
                                                            }
                                                        }

                                                        property var load_enable_status_high_load: platformInterface.load_enable_status.high_load_en
                                                        onLoad_enable_status_high_loadChanged: {
                                                            if(load_enable_status_high_load === "on") {
                                                                highCurrentEnable.checked = true
                                                            }
                                                            else {
                                                                highCurrentEnable.checked = false
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: highLoadSettingContainer
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true

                                                SGSlider {
                                                    id: highloadSetting
                                                    width: highLoadSettingContainer.width
                                                    live: false
                                                    from: 0.01
                                                    to:  10
                                                    stepSize: 0.01
                                                    fromText.text: "0.01A"
                                                    toText.text: "10A"
                                                    value: 0
                                                    inputBox.unit: "A"
                                                    inputBox.unitFont.bold: true
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.verticalCenterOffset: 10
                                                    inputBoxWidth: highLoadSettingContainer.width/5
                                                    inputBox.enabled: true
                                                    inputBox.unitOverrideWidth: 30 * ratioCalc

                                                    fontSizeMultiplier: ratioCalc * 1.1
                                                    inputBox.validator: DoubleValidator { top: 10;  bottom: 0.01 }
                                                    onUserSet: {
                                                        if(highCurrentEnable.checked)
                                                            platformInterface.set_load_dac_load.update(highloadSetting.value.toFixed(2))
                                                    }
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


                            Text {
                                id: interrupt
                                text: "Status and Information"
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
                                    top: interrupt.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout{
                                anchors {
                                    top: line2.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                Rectangle {
                                    Layout.preferredHeight: parent.height/5
                                    Layout.fillWidth: true
                                    RowLayout{
                                        id: ledSection
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:voltageStatusLabel
                                                target: voltageStatusLight
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Input Voltage\n Status"
                                                font.bold: true

                                                SGStatusLight {
                                                    id: voltageStatusLight
                                                    width: 30
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: currentStatusLabel
                                                target: currentStatusLight
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "On-Board Load\n Current Status"
                                                font.bold: true
                                                SGStatusLight {
                                                    id: currentStatusLight
                                                    width: 30
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:loadCurrentStatusLabel
                                                target: loadCurrent
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Input Current\n Status"
                                                font.bold: true

                                                SGStatusLight {
                                                    id: loadCurrent
                                                    width: 30
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: loadFaultLabel
                                                target: loadFault
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                anchors.verticalCenterOffset: 10
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Fault "
                                                font.bold: true

                                                SGStatusLight {
                                                    id: loadFault
                                                    width: 30
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: interruptBox
                                    Layout.preferredHeight: parent.height/4
                                    Layout.fillWidth: true

                                    RowLayout {
                                        anchors.fill: parent


                                        Rectangle{
                                            id: maxIVoltageContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: maxInputVolatgeLabel
                                                target: maxInputVolage
                                                font.bold: true
                                                alignment: SGAlignedLabel.SideTopCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Max Input \n Voltage"
                                                anchors.centerIn: parent

                                                SGInfoBox {
                                                    id: maxInputVolage
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    height:  35 * ratioCalc
                                                    width: 125 * ratioCalc
                                                    unit: "<b>V</b>"
                                                    // anchors.centerIn: parent

                                                    property var periodic_status_input_voltage: platformInterface.periodic_status.max_input_voltage
                                                    onPeriodic_status_input_voltageChanged:  {
                                                        maxInputVolage.text = periodic_status_input_voltage
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle{
                                            id: maxLoadContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGAlignedLabel {
                                                id: maxLoadLabel
                                                target: maxLoadCurrent
                                                font.bold: true
                                                alignment: SGAlignedLabel.SideTopCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Max On-Board \n Load Current"
                                                anchors.centerIn: parent

                                                SGInfoBox {
                                                    id: maxLoadCurrent
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    height:  35 * ratioCalc
                                                    width: 125 * ratioCalc
                                                    unit: "A"
                                                    unitFont.bold: true
                                                    property var max_OBL_current: platformInterface.periodic_status.max_OBL_current
                                                    onMax_OBL_currentChanged:  {
                                                        maxLoadCurrent.text = max_OBL_current
                                                    }
                                                }
                                            }

                                        }

                                        Rectangle{
                                            id: maxICurrentContainter
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGAlignedLabel {
                                                id: maxICurrentLabel
                                                target: maxICurrent
                                                font.bold: true
                                                alignment: SGAlignedLabel.SideTopCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Max Input \n Current"
                                                anchors.centerIn: parent

                                                SGInfoBox {
                                                    id: maxICurrent
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    height:  35 * ratioCalc
                                                    width: 125 * ratioCalc
                                                    unit: "A"
                                                    unitFont.bold: true
                                                    property var periodic_max_input_current: platformInterface.periodic_status.max_input_current
                                                    onPeriodic_max_input_currentChanged:  {
                                                        maxICurrent.text = periodic_max_input_current
                                                    }
                                                }
                                            }
                                        }

                                    }

                                }

                                Rectangle {

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true


                                    RowLayout {
                                        anchors.fill: parent

                                        Rectangle {
                                            id: powerGaugeContainer
                                            Layout.preferredWidth: parent.width/3
                                            Layout.fillHeight: true


                                            SGAlignedLabel {
                                                id: powerGaugeLabel
                                                target: powerGauge
                                                text: "Programmable \n Load Power Usage"
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
                                                    id: powerGauge

                                                    height: powerGaugeContainer.height - powerGaugeLabel.contentHeight
                                                    tickmarkStepSize: 10
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    gaugeFillColor1: "blue"
                                                    gaugeFillColor2: "red"
                                                    unitText: "%"
                                                    unitTextFontSizeMultiplier: ratioCalc * 1.5
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
                                                    property var power_margin: platformInterface.periodic_status.power_margin
                                                    onPower_marginChanged: {
                                                        value = power_margin
                                                    }
                                                }
                                            }

                                        }
                                        Rectangle {
                                            id: statusListContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGStatusLogBox{
                                                id: logFault
                                                //anchors.fill: parent
                                                width: parent.width - 20
                                                height: parent.height - 50
                                                title: "Status List"
                                                anchors.centerIn: parent

                                                listElementTemplate : {
                                                    "message": "",
                                                    "id": 0,
                                                    "color": "black"
                                                }
                                                scrollToEnd: false
                                                delegate: Rectangle {
                                                    id: delegatecontainer
                                                    height: delegateText.height
                                                    width: ListView.view.width

                                                    SGText {
                                                        id: delegateText
                                                        text: { return (
                                                                    logFault.showMessageIds ?
                                                                        model.id + ": " + model.message :
                                                                        model.message
                                                                    )}

                                                        fontSizeMultiplier: logFault.fontSizeMultiplier
                                                        color: model.color
                                                        wrapMode: Text.Wrap
                                                        width: parent.width
                                                    }
                                                }

                                                function append(message,color) {
                                                    listElementTemplate.message = message
                                                    listElementTemplate.color = color
                                                    model.append( listElementTemplate )
                                                    return (listElementTemplate.id++)
                                                }
                                                function insert(message,index,color){
                                                    listElementTemplate.message = message
                                                    listElementTemplate.color = color
                                                    model.insert(index, listElementTemplate )
                                                    return (listElementTemplate.id++)
                                                }
                                            }

                                        }

                                    }

                                }

                            }

                        }
                    }
                }
            } // end of RowLayout
        }
    }
}
