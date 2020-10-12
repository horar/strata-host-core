import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1400/900
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    property string voltageType: "Boost"

    Component.onCompleted: {
        Help.registerTarget(vedInputVoltageType, "Sets the VLED input voltage source for the LED driver. The power supply can be restarted if there is a Power Fault by clicking Reset VLED button or re-selecting the power supply type from this drop down. If there is no fault and the LEDs are not illuminated ensure:\n1) an external supply is provided for Buck and Bypass supplies\n2) the Boost supply is not overloaded\n3) the LED driver is configured to illuminate the LEDs on the LED Driver tab.\n\nBoost = Use onboard NCV5173 boost supply that is adjustable from 5.5 to 14V. The boost input voltage is supplied from the USB cable and a load switch prevents input currents higher than 400mA. The VLED Power Fault indicator will indicate an over current event. The maximum ILED current will be less than 400mA and depends on the set boost output voltage and efficiency of the boost regulator. Use Buck or Bypass power sources with external power supply for higher current applications. This is the default voltage source on boot.\n\nBuck = Use onboard NCV885301 buck supply that is adjustable from 2-18V. External voltage source that is greater than the user’s Buck Voltage Set value is required.\n\nBypass = Bypass both buck and boost input supplies to directly use externally supplied voltage source.", 0, "powerControlHelp")
        Help.registerTarget(resetButton, "Resets the VLED input supply specified in the VLED Input Voltage Type drop down.",1, "powerControlHelp")
        Help.registerTarget(voltageSet, "Sets the output voltage for the Buck or Boost power supply configured in the VLED Input Voltage Type control. Bypass option will disable this control.",2, "powerControlHelp")
        Help.registerTarget(boostOCP, "Indicates the VLED input voltage source has faulted.\n\nBoost = the boost converter may have reached its maximum input current of 400mA - this is a limitation of the current provided from the USB cable. The maximum ILED current will be less than 400mA and depends on the set boost output voltage and efficiency of the boost regulator. Use Buck or Bypass VLED Input Voltage Type with external power supply for higher current applications\n\nBuck = the buck converter may have reached its 1A current limit. Remove the load and the buck converter will restart automatically\n\nBypass = the bypass load switch may have reached its 1A current limit. Remove the load and the bypass load switch will restart automatically.", 3, "powerControlHelp")
        Help.registerTarget(vddPowerFault, "Indicates a power fault on the VDD load switch's FLAGB pin. This is likely due to an over current event on VDD. Remove the load and the load switch will restart automatically. Using the user interface with a VDD Power Fault will cause unknown behavior.",4, "powerControlHelp")
        Help.registerTarget(twPowerFault,"Thermal warning that is set when junction temperature is above the Tjwar_on threshold (140°C typical) and reset on register read and when temperature is below Tjwar_on minus Tjsd_hys threshold (127.5°C typical).",5,"powerControlHelp")
        Help.registerTarget(tsdPowerFault,"Thermal shutdown set when junction temperature is above the TSD threshold (170°C typical) and reset on register read and when temperature is below TSD minus Tjsd_hys threshold (157.5°C typical).",6,"powerControlHelp")
        Help.registerTarget(filterHelpContainer1, "Indicates the board temperature near the center of the onboard LEDs and underneath the LED driver on the bottom of the PCB. The LED driver temperature gauge does not reflect the junction temperature of the LED driver and does not correlate directly to TW and TSD temperature trip thresholds.", 7, "powerControlHelp")
        Help.registerTarget(powerLossContainer, "Indicates the total power consumption by the LED driver, LEDs, and other power sinks connected to the VLED input supply.", 8, "powerControlHelp")

    }

    Item {
        id: filterHelpContainer1
        property point topLeft
        property point bottomRight
        width:  (ledDriverTempBottomContainer.width) * 2
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = ledDriverTempBottomContainer.mapToItem(root, 0,  0)
            bottomRight = tempGaugeContainer.mapToItem(root, tempGaugeContainer.width, tempGaugeContainer.height)
        }
    }

    onWidthChanged: {
        filterHelpContainer1.update()
    }
    onHeightChanged: {
        filterHelpContainer1.update()
    }

    Connections {
        target: Help.utility
        onTour_runningChanged:{
            filterHelpContainer1.update()
        }
        onInternal_tour_indexChanged: {
            if(Help.current_tour_targets[index]["target"] === vedInputVoltageType) {
                Help.current_tour_targets[index]["helpObject"].toolTipPopup.contentItem.width = 800
                Help.current_tour_targets[index]["helpObject"].toolTipPopup.onHeightChanged.connect(function () {
                    Help.refreshView(index)
                })

            }
        }
    }

    function setStatesForControls (theId, index){
        if(index !== null && index !== undefined)  {
            if(index === 0) {
                theId.enabled = true
                theId.opacity = 1.0
            }
            else if(index === 1) {
                theId.enabled = false
                theId.opacity = 1.0
            }
            else {
                theId.enabled = false
                theId.opacity = 0.5
            }
        }
    }
    RowLayout {
        width: parent.width - 20
        height: parent.height/1.3
        anchors.centerIn: parent
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent

                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/9
                    color: "transparent"

                    Text {
                        id: powerControlHeading
                        text: "Power Control"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line1
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: powerControlHeading.bottom
                            topMargin: 7
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout {
                        anchors.fill: parent

                        Rectangle {
                            id: vedInputVoltageTypeContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: vedInputVoltageTypeLabel
                                target: vedInputVoltageType
                                //text: "VED Input Voltage \nType"
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
                                    onActivated: {
                                        platformInterface.set_power_vled_type.update(currentText)
                                    }

                                    property var power_vled_type: platformInterface.power_vled_type
                                    onPower_vled_typeChanged: {
                                        vedInputVoltageTypeLabel.text = power_vled_type.caption
                                        setStatesForControls(vedInputVoltageType,power_vled_type.states[0])


                                        vedInputVoltageType.model = power_vled_type.values

                                        for(var a = 0; a < vedInputVoltageType.model.length; ++a) {
                                            if(power_vled_type.value === vedInputVoltageType.model[a].toString()){
                                                vedInputVoltageType.currentIndex = a

                                            }
                                        }
                                    }


                                    property var power_vled_type_caption: platformInterface.power_vled_type_caption.caption
                                    onPower_vled_type_captionChanged: {
                                        vedInputVoltageTypeLabel.text = power_vled_type_caption
                                    }

                                    property var power_vled_type_state: platformInterface.power_vled_type_states.states
                                    onPower_vled_type_stateChanged: {
                                        setStatesForControls(vedInputVoltageType,power_vled_type_state[0])
                                    }

                                    property var power_vled_type_values: platformInterface.power_vled_type_values.values
                                    onPower_vled_type_valuesChanged:{
                                        vedInputVoltageType.model = power_vled_type_values
                                    }

                                    property var power_vled_type_value: platformInterface.power_vled_type_value.value
                                    onPower_vled_type_valueChanged: {
                                        for(var a = 0; a < vedInputVoltageType.model.length; ++a) {
                                            if(power_vled_type_value === vedInputVoltageType.model[a].toString()){
                                                vedInputVoltageType.currentIndex = a

                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGButton {
                                id:  resetButton
                                text: qsTr("Reset VLED")
                                anchors {
                                    top:parent.top
                                    topMargin: 20
                                    left: parent.left
                                    leftMargin: 20
                                }
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                height: parent.height/2.5
                                width: parent.width/2.2
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        platformInterface.set_power_vled_type.update(vedInputVoltageType.currentText)
                                    }
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
                        //text: voltageType + " Voltage Set"
                        SGSlider {
                            id: voltageSet
                            width: voltageSetContainer.width/1.2
                            live: false
                            fontSizeMultiplier: ratioCalc * 1.2
                            onUserSet: {
                                platformInterface.set_power_voltage_set.update(parseFloat(value.toFixed(1)))
                            }
                        }

                        property var power_voltage_set: platformInterface.power_voltage_set
                        onPower_voltage_setChanged: {
                            voltageSetLabel.text = power_voltage_set.caption
                            voltageSet.to = power_voltage_set.scales[0]
                            voltageSet.from =  power_voltage_set.scales[1]
                            voltageSet.toText.text = power_voltage_set.scales[0] + "V"
                            voltageSet.fromText.text = power_voltage_set.scales[1] + "V"
                            voltageSet.stepSize = power_voltage_set.scales[2]
                            setStatesForControls(voltageSet,power_voltage_set.states[0])
                            voltageSet.value =  power_voltage_set.value

                        }

                        property var power_voltage_set_caption: platformInterface.power_voltage_set_caption.caption
                        onPower_voltage_set_captionChanged: {
                            voltageSetLabel.text = power_voltage_set_caption
                        }

                        property var power_voltage_set_scales: platformInterface.power_voltage_set_scales.scales
                        onPower_voltage_set_scalesChanged: {
                            voltageSet.to = power_voltage_set_scales[0]
                            voltageSet.from =  power_voltage_set_scales[1]
                            voltageSet.toText.text = power_voltage_set_scales[0] + "V"
                            voltageSet.fromText.text = power_voltage_set_scales[1] + "V"
                            voltageSet.stepSize = power_voltage_set_scales[2]
                        }

                        property var power_voltage_set_state: platformInterface.power_voltage_set_states.states
                        onPower_voltage_set_stateChanged: {
                            setStatesForControls(voltageSet,power_voltage_set_state[0])
                        }
                        property var power_voltage_set_value: platformInterface.power_voltage_set_value.value
                        onPower_voltage_set_valueChanged: {
                            voltageSet.value =  power_voltage_set_value
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
                                id:boostOCPLabel
                                target: boostOCP
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors {
                                    centerIn: parent
                                    horizontalCenter: parent.horizontalCenter
                                    horizontalCenterOffset: -20
                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold: true
                                SGStatusLight {
                                    id: boostOCP
                                    width : 40

                                }

                                property var power_fault_vled: platformInterface.power_fault_vled
                                onPower_fault_vledChanged: {
                                    boostOCPLabel.text = power_fault_vled.caption
                                    setStatesForControls(boostOCP,power_fault_vled.states[0])
                                    if(power_fault_vled.value === true)
                                        boostOCP.status = SGStatusLight.Red
                                    else boostOCP.status = SGStatusLight.Off
                                }

                                property var power_fault_vled_caption: platformInterface.power_fault_vled_caption.caption
                                onPower_fault_vled_captionChanged: {
                                    boostOCPLabel.text = power_fault_vled_caption
                                }

                                property var power_fault_vled_states: platformInterface.power_fault_vled_states.states
                                onPower_fault_vled_statesChanged: {
                                    setStatesForControls(boostOCP,power_fault_vled_states[0])
                                }

                                property var power_fault_vled_value: platformInterface.power_fault_vled_value.value
                                onPower_fault_vled_valueChanged:{
                                    if(power_fault_vled_value === true) {
                                        if(!powerControl.visible) {
                                            alertViewBadge.opacity = 1.0
                                        }
                                        boostOCP.status = SGStatusLight.Red
                                    }
                                    else {
                                        if(!powerControl.visible) {
                                            alertViewBadge.opacity = 0.0
                                        }
                                        boostOCP.status = SGStatusLight.Off
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id:vddPowerFaultLabel
                                target: vddPowerFault
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors {
                                    centerIn: parent
                                    horizontalCenter: parent.horizontalCenter
                                    horizontalCenterOffset: -20
                                }

                                SGStatusLight {
                                    id: vddPowerFault
                                    width : 40
                                    property var power_fault_vdd: platformInterface.power_fault_vdd
                                    onPower_fault_vddChanged: {
                                        vddPowerFaultLabel.text = power_fault_vdd.caption
                                        setStatesForControls(vddPowerFault,power_fault_vdd.states[0])
                                        if(power_fault_vdd.value === true)
                                            vddPowerFault.status = SGStatusLight.Red
                                        else vddPowerFault.status = SGStatusLight.Off
                                    }

                                    property var power_fault_vdd_caption: platformInterface.power_fault_vdd_caption.caption
                                    onPower_fault_vdd_captionChanged: {
                                        vddPowerFaultLabel.text = power_fault_vdd_caption
                                    }

                                    property var power_fault_vdd_states: platformInterface.power_fault_vdd_states.states
                                    onPower_fault_vdd_statesChanged: {
                                        setStatesForControls(vddPowerFault,power_fault_vdd_states[0])
                                    }

                                    property var power_fault_vdd_value: platformInterface.power_fault_vdd_value.value
                                    onPower_fault_vdd_valueChanged:{
                                        if(power_fault_vdd_value === true) {
                                            if(!powerControl.visible) {
                                                alertViewBadge.opacity = 1.0
                                            }
                                            vddPowerFault.status = SGStatusLight.Red
                                        }
                                        else {
                                            if(!powerControl.visible) {
                                                alertViewBadge.opacity = 0.0
                                            }
                                            vddPowerFault.status = SGStatusLight.Off
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
                    RowLayout{
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"

                            SGAlignedLabel {
                                id:twPowerFaultLabel
                                target: twPowerFault
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors {
                                    centerIn: parent
                                    horizontalCenter: parent.horizontalCenter
                                    horizontalCenterOffset: -20
                                }

                                SGStatusLight {
                                    id: twPowerFault
                                    width : 40

                                    property var power_tw: platformInterface.power_tw
                                    onPower_twChanged: {
                                        twPowerFaultLabel.text = power_tw.caption
                                        setStatesForControls(twPowerFault,power_tw.states[0])
                                        if(power_tw.value === true)
                                            twPowerFault.status = SGStatusLight.Red
                                        else twPowerFault.status = SGStatusLight.Off
                                    }

                                    property var power_tw_caption: platformInterface.power_tw_caption.caption
                                    onPower_tw_captionChanged: {
                                        twPowerFaultLabel.text = power_tw_caption
                                    }

                                    property var power_tw_states: platformInterface.power_tw_states.states
                                    onPower_tw_statesChanged: {
                                        setStatesForControls(twPowerFault,power_tw_states[0])
                                    }

                                    property var power_tw_value: platformInterface.power_tw_value.value
                                    onPower_tw_valueChanged:{
                                        if(power_tw_value === true) {
                                            twPowerFault.status = SGStatusLight.Red
                                        }
                                        else {
                                            twPowerFault.status = SGStatusLight.Off
                                        }
                                    }

                                }
                            }
                        }

                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"

                            SGAlignedLabel {
                                id:tsdPowerFaultLabel
                                target: tsdPowerFault
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors {
                                    centerIn: parent
                                    horizontalCenter: parent.horizontalCenter
                                    horizontalCenterOffset: -20
                                }

                                SGStatusLight {
                                    id: tsdPowerFault
                                    width : 40

                                    property var power_tsd: platformInterface.power_tsd
                                    onPower_tsdChanged: {
                                        tsdPowerFaultLabel.text = power_tsd.caption
                                        setStatesForControls(tsdPowerFault,power_tsd.states[0])
                                        if(power_tsd.value === true)
                                            tsdPowerFault.status = SGStatusLight.Red
                                        else tsdPowerFault.status = SGStatusLight.Off
                                    }

                                    property var power_tsd_caption: platformInterface.power_tsd_caption.caption
                                    onPower_tsd_captionChanged: {
                                        tsdPowerFaultLabel.text = power_tsd_caption
                                    }

                                    property var power_tsd_states: platformInterface.power_tsd_states.states
                                    onPower_tsd_statesChanged: {
                                        setStatesForControls(tsdPowerFault,power_tsd_states[0])
                                    }

                                    property var power_tsd_value: platformInterface.power_tsd_value.value
                                    onPower_tsd_valueChanged:{
                                        if(power_tsd_value === true) {
                                            tsdPowerFault.status = SGStatusLight.Red
                                        }
                                        else {
                                            tsdPowerFault.status = SGStatusLight.Off
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
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width/1.5
            ColumnLayout {
                anchors.fill: parent

                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/9
                    color: "transparent"

                    Text {
                        id: telemetryHeading
                        text: "Telemetry"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line2
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: telemetryHeading.bottom
                            topMargin: 7
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: parent.height/2
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
                                        id: vLEDLabel
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
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vled: platformInterface.power_vled
                                        onPower_vledChanged: {
                                            vLEDLabel.text = power_vled.caption
                                            setStatesForControls(vLED,power_vled.states[0])
                                            vLED.text = (power_vled.value).toFixed(2)
                                            vLED.unit = "<b>V</b>"
                                        }

                                        property var power_vled_caption: platformInterface.power_vled_caption.caption
                                        onPower_vled_captionChanged: {
                                            vLEDLabel.text = power_vled_caption
                                        }

                                        property var power_vled_state: platformInterface.power_vled_states.states
                                        onPower_vled_stateChanged: {
                                            setStatesForControls(vLED,power_vled_state[0])
                                        }

                                        property var power_vled_value: platformInterface.power_vled_value.value
                                        onPower_vled_valueChanged:{
                                            vLED.text = power_vled_value.toFixed(2)
                                            vLED.unit = "<b>V</b>"
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: supplyVoltageLabel
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
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vs: platformInterface.power_vs
                                        onPower_vsChanged: {
                                            supplyVoltageLabel.text = power_vs.caption
                                            setStatesForControls(supplyVoltage,power_vs.states[0])
                                            supplyVoltage.text = power_vs.value
                                        }

                                        property var power_vs_caption: platformInterface.power_vs_caption.caption
                                        onPower_vs_captionChanged: {
                                            supplyVoltageLabel.text = power_vs_caption
                                        }

                                        property var power_vs_state: platformInterface.power_vs_states.states
                                        onPower_vs_stateChanged: {
                                            setStatesForControls(supplyVoltage,power_vs_state[0])
                                        }

                                        property var power_vs_value: platformInterface.power_vs_value.value
                                        onPower_vs_valueChanged:{
                                            supplyVoltage.text = power_vs_value.toFixed(2)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: digitalVoltageLabel
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
                                            unit: "<b> V </b>"

                                            // text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vdd: platformInterface.power_vdd
                                        onPower_vddChanged: {
                                            digitalVoltageLabel.text = power_vdd.caption
                                            setStatesForControls(digitalVoltage,power_vdd.states[0])
                                            digitalVoltage.text = (power_vdd.value).toFixed(2)

                                        }

                                        property var power_vdd_caption: platformInterface.power_vdd_caption.caption
                                        onPower_vdd_captionChanged: {
                                            digitalVoltageLabel.text = power_vdd_caption
                                        }

                                        property var power_vdd_state: platformInterface.power_vdd_states.states
                                        onPower_vdd_stateChanged: {
                                            setStatesForControls(digitalVoltage,power_vdd_state[0])
                                        }

                                        property var power_vdd_value: platformInterface.power_vdd_value.value
                                        onPower_vdd_valueChanged:{
                                            digitalVoltage.text = power_vdd_value.toFixed(2)
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: batteryVoltageLabel
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
                                            //text: "14.4"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vconn: platformInterface.power_vconn
                                        onPower_vconnChanged: {
                                            batteryVoltageLabel.text = power_vconn.caption
                                            setStatesForControls(batteryVoltage,power_vconn.states[0])
                                            batteryVoltage.text = (power_vconn.value).toFixed(2)
                                        }

                                        property var power_vconn_caption: platformInterface.power_vconn_caption.caption
                                        onPower_vconn_captionChanged: {
                                            batteryVoltageLabel.text = power_vconn_caption
                                        }

                                        property var power_vconn_state: platformInterface.power_vconn_states.states
                                        onPower_vconn_stateChanged: {
                                            setStatesForControls(batteryVoltage,power_vconn_state[0])
                                        }

                                        property var power_vconn_value: platformInterface.power_vconn_value.value
                                        onPower_vconn_valueChanged:{
                                            batteryVoltage.text = power_vconn_value.toFixed(2)
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
                                        target: ledCurrent
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: ledCurrent
                                            height:  35 * ratioCalc
                                            width: 160 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_iled: platformInterface.power_iled
                                        onPower_iledChanged: {
                                            ledCurrentLabel.text = power_iled.caption
                                            setStatesForControls(ledCurrent,power_iled.states[0])
                                            ledCurrent.text = (power_iled.value).toFixed(1)

                                        }

                                        property var power_iled_caption: platformInterface.power_iled_caption.caption
                                        onPower_iled_captionChanged: {
                                            ledCurrentLabel.text = power_iled_caption
                                        }

                                        property var power_iled_state: platformInterface.power_iled_states.states
                                        onPower_iled_stateChanged: {
                                            setStatesForControls(ledCurrent,power_iled_state[0])
                                        }

                                        property var power_iled_value: platformInterface.power_iled_value.value
                                        onPower_iled_valueChanged:{
                                            ledCurrent.text = power_iled_value.toFixed(1)
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: supplyCurrentLabel
                                        target: supplyCurrent
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: supplyCurrent
                                            height:  35 * ratioCalc
                                            width: 160 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_is: platformInterface.power_is
                                        onPower_isChanged: {
                                            supplyCurrentLabel.text = power_is.caption
                                            setStatesForControls(supplyCurrent,power_is.states[0])
                                            supplyCurrent.text = (power_is.value).toFixed(1)
                                        }

                                        property var power_is_caption: platformInterface.power_is_caption.caption
                                        onPower_is_captionChanged: {
                                            supplyCurrentLabel.text = power_is_caption
                                        }

                                        property var power_is_state: platformInterface.power_is_states.states
                                        onPower_is_stateChanged: {
                                            setStatesForControls(supplyCurrent,power_is_state[0])
                                        }

                                        property var power_is_value: platformInterface.power_is_value.value
                                        onPower_is_valueChanged:{
                                            supplyCurrent.text = power_is_value.toFixed(1)
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: voltageLabel
                                        target: voltage
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: voltage
                                            height:  35 * ratioCalc
                                            width: 160 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>V</b>"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vcc: platformInterface.power_vcc
                                        onPower_vccChanged: {
                                            voltageLabel.text = power_vcc.caption
                                            setStatesForControls(voltage,power_vcc.states[0])
                                            voltage.text = power_vcc.value.toFixed(2)

                                        }

                                        property var power_vcc_caption: platformInterface.power_vcc_caption.caption
                                        onPower_vcc_captionChanged: {
                                            voltageLabel.text = power_vcc_caption
                                        }

                                        property var power_vcc_state: platformInterface.power_vcc_states.states
                                        onPower_vcc_stateChanged: {
                                            setStatesForControls(voltage,power_vcc_state[0])
                                        }
                                        property var power_vcc_value: platformInterface.power_vcc_value.value
                                        onPower_vcc_valueChanged:{
                                            voltage.text = power_vcc_value.toFixed(2)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
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
                            id: ledDriverTempBottomContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: ledDriverTempBottomLabel
                                target: ledDriverTempBottom
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: ledDriverTempBottom
                                    width: ledDriverTempBottomContainer.width
                                    height: ledDriverTempBottomContainer.height - ledDriverTempBottomLabel.contentHeight
                                    //tickmarkStepSize: 10
                                    // minimumValue: 0
                                    // maximumValue: 150
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

                                property var power_led_driver_temp_bottom: platformInterface.power_led_driver_temp_bottom
                                onPower_led_driver_temp_bottomChanged: {
                                    ledDriverTempBottomLabel.text = power_led_driver_temp_bottom.caption
                                    setStatesForControls(ledDriverTempBottom,power_led_driver_temp_bottom.states[0])
                                    ledDriverTempBottom.maximumValue = power_led_driver_temp_bottom.scales[0]
                                    ledDriverTempBottom.minimumValue = power_led_driver_temp_bottom.scales[1]
                                    ledDriverTempBottom.tickmarkStepSize = power_led_driver_temp_bottom.scales[2]
                                    ledDriverTempBottom.value = power_led_driver_temp_bottom.value

                                }

                                property var power_led_driver_temp_bottom_caption: platformInterface.power_led_driver_temp_bottom_caption.caption
                                onPower_led_driver_temp_bottom_captionChanged: {
                                    ledDriverTempBottomLabel.text = power_led_driver_temp_bottom_caption
                                }

                                property var power_led_driver_temp_bottom_state: platformInterface.power_led_driver_temp_bottom_states.states
                                onPower_led_driver_temp_bottom_stateChanged: {
                                    setStatesForControls(ledDriverTempBottom,power_led_driver_temp_bottom_state[0])
                                }

                                property var power_led_driver_temp_bottom_scales: platformInterface.power_led_driver_temp_bottom_scales.scales
                                onPower_led_driver_temp_bottom_scalesChanged: {
                                    ledDriverTempBottom.maximumValue = power_led_driver_temp_bottom_scales[0]
                                    ledDriverTempBottom.minimumValue = power_led_driver_temp_bottom_scales[1]
                                    ledDriverTempBottom.tickmarkStepSize = power_led_driver_temp_bottom_scales[2]


                                }

                                property var power_led_driver_temp_bottom_value: platformInterface.power_led_driver_temp_bottom_value.value
                                onPower_led_driver_temp_bottom_valueChanged: {
                                    ledDriverTempBottom.value = power_led_driver_temp_bottom_value
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
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: tempGauge
                                    width: tempGaugeContainer.width
                                    height: tempGaugeContainer.height - tempGaugeLabel.contentHeight
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

                                    property var power_led_temp: platformInterface.power_led_temp
                                    onPower_led_tempChanged: {
                                        tempGaugeLabel.text = power_led_temp.caption
                                        setStatesForControls(tempGauge,power_led_temp.states[0])

                                        tempGauge.maximumValue = power_led_temp.scales[0]
                                        tempGauge.minimumValue = power_led_temp.scales[1]
                                        tempGauge.tickmarkStepSize = power_led_temp.scales[2]
                                        tempGauge.value = power_led_temp.value

                                    }
                                    property var power_led_temp_caption: platformInterface.power_led_temp_caption.caption
                                    onPower_led_temp_captionChanged: {
                                        tempGaugeLabel.text = power_led_temp_caption
                                    }

                                    property var power_led_temp_state: platformInterface.power_led_temp_states.states
                                    onPower_led_temp_stateChanged: {
                                        setStatesForControls(tempGauge,power_led_temp_state[0])
                                    }

                                    property var power_led_temp_scales: platformInterface.power_led_temp_scales.scales
                                    onPower_led_temp_scalesChanged: {
                                        tempGauge.maximumValue = power_led_temp_scales[0]
                                        tempGauge.minimumValue = power_led_temp_scales[1]
                                        tempGauge.tickmarkStepSize = power_led_temp_scales[2]


                                    }

                                    property var power_led_temp_value: platformInterface.power_led_temp_value.value
                                    onPower_led_temp_valueChanged: {
                                        tempGauge.value = power_led_temp_value
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
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: powerLoss
                                    width: powerLossContainer.width
                                    height: powerLossContainer.height - powerLossGaugeLabel.contentHeight
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "W"
                                    unitTextFontSizeMultiplier: ratioCalc * 2.5
                                    valueDecimalPlaces: 2

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

                                    property var power_total_power: platformInterface.power_total_power
                                    onPower_total_powerChanged: {
                                        powerLossGaugeLabel.text = power_total_power.caption
                                        setStatesForControls(powerLoss,power_total_power.states[0])
                                        powerLoss.maximumValue = power_total_power.scales[0]
                                        powerLoss.minimumValue = power_total_power.scales[1]
                                        powerLoss.tickmarkStepSize = power_total_power.scales[2]
                                        powerLoss.value = power_total_power.value

                                    }

                                    property var power_total_power_caption: platformInterface.power_total_power_caption.caption
                                    onPower_total_power_captionChanged: {
                                        powerLossGaugeLabel.text = power_total_power_caption
                                    }

                                    property var power_total_power_state: platformInterface.power_total_power_states.states
                                    onPower_total_power_stateChanged: {
                                        setStatesForControls(powerLoss,power_total_power_state[0])
                                    }

                                    property var power_total_power_scales: platformInterface.power_total_power_scales.scales
                                    onPower_total_power_scalesChanged: {
                                        powerLoss.maximumValue = power_total_power_scales[0]
                                        powerLoss.minimumValue = power_total_power_scales[1]
                                        powerLoss.tickmarkStepSize = power_total_power_scales[2]
                                    }

                                    property var power_total_power_value: platformInterface.power_total_power_value.value
                                    onPower_total_power_valueChanged: {
                                        powerLoss.value = power_total_power_value
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

