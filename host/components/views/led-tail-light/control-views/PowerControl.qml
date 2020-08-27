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
                            SGAlignedLabel {
                                id: vsVoltageSelectLabel
                                target: vsVoltageSelect
                                //text: "VS Voltage Select"
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
                                    //checkedLabel: "VLED"
                                    //uncheckedLabel: "5V"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    checked: false

                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_power_vs_select.update("5V_USB")
                                        else
                                            platformInterface.set_power_vs_select.update("VLED")

                                    }
                                }

                                property var power_vs_select: platformInterface.power_vs_select
                                onPower_vs_selectChanged: {
                                    vsVoltageSelectLabel.text = power_vs_select.caption
                                    setStatesForControls(vsVoltageSelect,power_vs_select.states[0])


                                    vsVoltageSelect.checkedLabel = power_vs_select.values[0]
                                    vsVoltageSelect.uncheckedLabel = power_vs_select.values[1]

                                    if(power_vs_select.value === power_vs_select.values[0])
                                        vsVoltageSelect.checked = true
                                    else  vsVoltageSelect.checked = false
                                }

                                property var power_vs_select_caption: platformInterface.power_vs_select_caption.caption
                                onPower_vs_select_captionChanged: {
                                    vsVoltageSelectLabel.text = power_vs_select_caption
                                }

                                property var power_vs_select_state: platformInterface.power_vs_select_states.states
                                onPower_vs_select_stateChanged: {
                                    setStatesForControls(vsVoltageSelect,power_vs_select_state[0])
                                }

                                property var power_vs_select_values: platformInterface.power_vs_select_values.values
                                onPower_vs_select_valuesChanged: {
                                    vsVoltageSelect.checkedLabel = power_vs_select_values[0]
                                    vsVoltageSelect.uncheckedLabel = power_vs_select_values[1]
                                }

                                property var power_vs_select_value: platformInterface.power_vs_select_value.value
                                onPower_vs_select_valueChanged: {
                                    var valuesOfswitch =  platformInterface.power_vs_select_values.values
                                    console.log(valuesOfswitch,power_vs_select_value)
                                    if(power_vs_select_value === valuesOfswitch[0])
                                        vsVoltageSelect.checked = true
                                    else  vsVoltageSelect.checked = false
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
                                    top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                //text: "Boost\nOCP"
                                font.bold: true

                                SGStatusLight {
                                    id: boostOCP
                                    width : 40

                                }

                                property var power_fault_vled: platformInterface.power_fault_vled
                                onPower_fault_vledChanged: {
                                    console.log(power_fault_vled.caption)
                                    boostOCPLabel.text = power_fault_vled.caption
                                    console.log(boostOCPLabel.text)
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
                                        boostOCP.status = SGStatusLight.Off
                                    }
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id:vsPowerFaultLabel
                                target: vsPowerFault
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors {
                                    top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }

                                SGStatusLight {
                                    id: vsPowerFault
                                    width : 40

                                    property var power_fault_vs: platformInterface.power_fault_vs
                                    onPower_fault_vsChanged: {
                                        vsPowerFaultLabel.text = power_fault_vs.caption
                                        setStatesForControls(vsPowerFault,power_fault_vs.states[0])
                                        if(power_fault_vs.value === true)
                                            vsPowerFault.status = SGStatusLight.Red
                                        else vsPowerFault.status = SGStatusLight.Off
                                    }

                                    property var power_fault_vs_caption: platformInterface.power_fault_vs_caption.caption
                                    onPower_fault_vs_captionChanged: {
                                        vsPowerFaultLabel.text = power_fault_vs_caption
                                    }

                                    property var power_fault_vs_states: platformInterface.power_fault_vs_states.states
                                    onPower_fault_vs_statesChanged: {
                                        setStatesForControls(vsPowerFault,power_fault_vs_states[0])
                                    }

                                    property var power_fault_vs_value: platformInterface.power_fault_vs_value.value
                                    onPower_fault_vs_valueChanged:{
                                        if(power_fault_vs_value === true) {
                                            if(!powerControl.visible) {
                                                alertViewBadge.opacity = 1.0
                                            }
                                            vsPowerFault.status = SGStatusLight.Red
                                        }
                                        else {
                                            vsPowerFault.status = SGStatusLight.Off
                                        }
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
                                    top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
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
                                            vddPowerFault.status = SGStatusLight.Off
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
                                        //text: "LED Current\n(ILED)"
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
                                            //text: "500"
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
                                        //text: "Supply Current\n(IS)"
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
                                            //text: "500"
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
                                            // text: "500"
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
                                            console.log("testing", voltage.text, power_vcc_value, platformInterface.power_vcc_value.value)
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
                            id: ledDriverTempTopContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: ledDriverTempTopLabel
                                target: ledDriverTempTop
                                //text: "LED Driver Temp Top \n (°C)"
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: ledDriverTempTop
                                    width: ledDriverTempTopContainer.width
                                    height: ledDriverTempTopContainer.height - ledDriverTempTopLabel.contentHeight
                                    //tickmarkStepSize: 10
                                    //  minimumValue: 0
                                    //  maximumValue: 150
                                    gaugeFillColor1: "blue"
                                    gaugeFillColor2: "red"
                                    unitText: "°C"
                                    unitTextFontSizeMultiplier: ratioCalc * 2.5
                                    //valueDecimalPlaces: 2
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

                                property var power_led_driver_temp_top: platformInterface.power_led_driver_temp_top
                                onPower_led_driver_temp_topChanged: {
                                    ledDriverTempTopLabel.text = power_led_driver_temp_top.caption
                                    setStatesForControls(ledDriverTempTop,power_led_driver_temp_top.states[0])

                                    ledDriverTempTop.maximumValue = power_led_driver_temp_top.scales[0]
                                    ledDriverTempTop.minimumValue = power_led_driver_temp_top.scales[1]
                                    ledDriverTempTop.tickmarkStepSize = power_led_driver_temp_top.scales[2]

                                    ledDriverTempTop.value = power_led_driver_temp_top.value

                                }

                                property var power_led_driver_temp_top_caption: platformInterface.power_led_driver_temp_top_caption.caption
                                onPower_led_driver_temp_top_captionChanged: {
                                    ledDriverTempTopLabel.text = power_led_driver_temp_top_caption
                                }

                                property var power_led_driver_temp_top_state: platformInterface.power_led_driver_temp_top_states.states
                                onPower_led_driver_temp_top_stateChanged: {
                                    setStatesForControls(ledDriverTempTop,power_led_driver_temp_top_state[0])
                                }

                                property var power_led_driver_temp_top_scales: platformInterface.power_led_driver_temp_top_scales.scales
                                onPower_led_driver_temp_top_scalesChanged: {
                                    ledDriverTempTop.maximumValue = power_led_driver_temp_top_scales[0]
                                    ledDriverTempTop.minimumValue = power_led_driver_temp_top_scales[1]
                                    ledDriverTempTop.tickmarkStepSize = power_led_driver_temp_top_scales[2]

                                }

                                property var power_led_driver_temp_top_value: platformInterface.power_led_driver_temp_top_value.value
                                onPower_led_driver_temp_top_valueChanged: {
                                    ledDriverTempTop.value = power_led_driver_temp_top_value
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
                                //text: "LED Driver Temp Bottom \n (°C)"
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

                                property var power_led_driver_temp_top_value: platformInterface.power_led_driver_temp_top_value.value
                                onPower_led_driver_temp_top_valueChanged: {
                                    ledDriverTempBottom.value = power_led_driver_temp_top_value
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
                                    //tickmarkStepSize: 10

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
                                        //                                        if(power_led_temp.state === "enabled") {
                                        //                                            tempGauge.opacity = 1.0
                                        //                                            tempGauge.enabled = true
                                        //                                        }
                                        //                                        else if (power_led_temp.state === "disabled") {
                                        //                                            tempGauge.opacity = 1.0
                                        //                                            tempGauge.enabled = false
                                        //                                        }
                                        //                                        else  {
                                        //                                            tempGauge.opacity = 0.5
                                        //                                            tempGauge.enabled = false
                                        //                                        }

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
                                //text: "Total Power Loss \n (W)"
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideBottomCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGCircularGauge {
                                    id: powerLoss
                                    width: powerLossContainer.width
                                    height: powerLossContainer.height - powerLossGaugeLabel.contentHeight
                                    //tickmarkStepSize: 0.5
                                    //                                    minimumValue: 0
                                    //                                    maximumValue: 5
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
                                        //                                        if(power_total_power.state === "enabled") {
                                        //                                            powerLoss.opacity = 1.0
                                        //                                            powerLoss.enabled = true
                                        //                                        }
                                        //                                        else if (power_total_power.state === "disabled") {
                                        //                                            powerLoss.opacity = 1.0
                                        //                                            powerLoss.enabled = false
                                        //                                        }
                                        //                                        else  {
                                        //                                            powerLoss.opacity = 0.5
                                        //                                            powerLoss.enabled = false
                                        //                                        }
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

