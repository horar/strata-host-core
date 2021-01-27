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
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1225/648
    anchors.centerIn: parent
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.height

    Component.onCompleted: {
        platformInterface.get_status_command.update()
        Help.registerTarget(enableSwitchLabel, "This switch will enable the buck converter by setting the SS/SD# pin high.", 0, "100VcontrolHelp")
        Help.registerTarget(setSwitchFreqLabel, "This switch allows the user to switch between the standard 100kHz switching frequency or a manually set frequency using potentiometer R33.", 1, "100VcontrolHelp")
        Help.registerTarget(softStartLabel, "This dropdown selection allows the user to change the approximate soft start time for the buck converter.", 2, "100VcontrolHelp")
        Help.registerTarget(outputVolLabel, "The slider and the text box both allow the user to set the output voltage between 5V and 24V.",3, "100VcontrolHelp")
        Help.registerTarget(setoutputVoltAdjustmentLabel, "This switch will turn on/off the ability for the user to adjust the output voltage. The default fixed voltage if this feature is disabled is 17V. Disabling the output voltage adjustment feature allows for adjusting the output voltage of the board to voltages outside the recommended range by manually replacing the output voltage feedback divider resistors. See the User Guide for more details.",4, "100VcontrolHelp")
        Help.registerTarget(enableVCCLDOLabel, "This switch turns on/off the LDO that provides power to the VCC rail of the NCP1034 controller by default. When enabled, VCC power is drawn from the input voltage supply. If this is disabled, the user would need to apply VCC power externally through the VCC_EXT header provided on the board. See the User Guide for more details.",5, "100VcontrolHelp")
        Help.registerTarget(filterHelpContainer, "All measured voltages and currents on the board are shown here. Input/output voltages and currents are measured at the input and output to the evaluation board.",6, "100VcontrolHelp")
        Help.registerTarget(logFault, "This status list contains all the error messages, and will store them in the order received with the most recent error messages displayed on top.",7, "100VcontrolHelp")
        Help.registerTarget(filterHelp2Container, "These gauges show the input and output power to the evaluation board. They are calculated from the measured voltages and currents at input and output. The current readings max out at 1.1A and 2.2A for input and output current, respectively, so if more current than that is being drawn, the numbers here will be inaccurate as the input/output current sense amps will be saturated.",8, "100VcontrolHelp")
        Help.registerTarget(effGaugeLabel, "The buck converter efficiency is calculated by taking the buck regulator's measured output power divided by the buck regulator's measured input power. This reading does not include the power loss in the VCC LDO when enabled.",9, "100VcontrolHelp")
        Help.registerTarget(ldoTempLabel, "The temperature from the sensor closest to the LDO supplying the VCC rail is measured here. The LDO may have significant power loss at high input voltages. The temperature alert limit is set to 100˚C. The LDO will automatically be disabled during a temperature alert event and cannot be enabled again until the temperature reading decreases below 95˚C.",10, "100VcontrolHelp")
        Help.registerTarget(boardTempLabel, "The temperature from the sensor closest to the inductor of the buck converter is measured here to estimate the overall board temperature. The temperature alert limit is set to 80˚C. The buck regulator will automatically be disabled during a temperature alert event and cannot be enabled again until the temperature reading decreases below 75˚C.", 11, "100VcontrolHelp")
        Help.registerTarget(sgstatusHelpContainer, "Green or black indicates that the parameter is within specification and operating normally. Red indicates there is a problem. Check the Status list for more information on errors. ", 12, "100VcontrolHelp")
    }


    Item {
        id: filterHelpContainer
        property point topLeft
        property point bottomRight
        width:  telemetryContainer1.width + telemetryContainer2.width
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = telemetryContainer1.mapToItem(root, 0,  0)
            bottomRight = telemetryContainer2.mapToItem(root, telemetryContainer2.width, telemetryContainer2.height)
        }
    }

    Item {
        id: filterHelp2Container
        property point topLeft
        property point bottomRight
        width:  inputpowerGaugeLabel.width + inputpowerGaugeLabel.width
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = inputpowerGaugeLabel.mapToItem(root, 0,  0)
            bottomRight = buckOutputPowerGaugeLabel.mapToItem(root, buckOutputPowerGaugeLabel.width, buckOutputPowerGaugeLabel.height)
        }
    }

    Connections {
        target: Help.utility
        onTour_runningChanged:{
            filterHelpContainer.update()
            filterHelp2Container.update()
        }
    }

    onWidthChanged: {
        filterHelpContainer.update()
        filterHelp2Container.update()
    }
    onHeightChanged: {
        filterHelpContainer.update()
        filterHelp2Container.update()
    }

    property var error_msg: platformInterface.error_msg.value
    onError_msgChanged: {
        if(error_msg !== "")
            pushMessagesToLog(error_msg)
    }

    function pushMessagesToLog (messageIs) {
        // Change text color to black of the entire existing list of faults
        for(var j = 0; j < logFault.model.count; j++){
            logFault.model.get(j).color = "black"
        }

        logFault.insert(messageIs, 0, "red")

    }

    property var control_states: platformInterface.control_states
    onControl_statesChanged: {
        enableSwitch.checked = control_states.buck_enabled
        enableVCCLDO.checked = control_states.ldo_enabled
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
                                                id: enableSwitchLabel
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
                                        text: "Switching Frequency \nControl"
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
                                        id: softStartLabel
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
                                            onActivated: {
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
                                Item {
                                    id: outputVoltAdjustmentContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: setoutputVoltAdjustmentLabel
                                        target: outputVoltAdjustment
                                        text: "Output Voltage \nAdjustment"
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
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: enableVCCLDOLabel
                                        target: enableVCCLDO
                                        text: "Enable VCC \nLDO"
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true

                                        SGSwitch {
                                            id: enableVCCLDO
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
                                                    id:telemetryContainer1
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
                                                    id:telemetryContainer2
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
                                                                    unit: " mA"
                                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                                    width: 115 * ratioCalc
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
                                                text: "Output \n Power"
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
                                                        effGauge.value = periodic_telemetry_eff.toFixed(1)
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
                                                text: "Approximate \n LDO Temperature"
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
                                                        ldoTemp.value = periodic_telemetry_ldo_temp.toFixed(1)
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
                                                text: "Approximate Board \n Temperature"
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
                                                        boardTemp.value = periodic_telemetry_board_temp.toFixed(1)
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
                            Item {
                                id: sgstatusHelpContainer
                                width:  statusLed.width - 50
                                height: statusLed.height/2.2
                                anchors.top: parent.top
                                anchors.topMargin: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: 15
                            }


                            ColumnLayout{
                                id: statusLed
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
                                            id: vinLedcontainer
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
                                            id: tempAlertContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: tempAlertLabel
                                                target: tempAlertLed
                                                alignment: SGAlignedLabel.SideLeftCenter
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "Temperature\nAlert "
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
