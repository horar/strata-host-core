import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    property string voltageType: "Boost"

    RowLayout {
        width: parent.width - 10
        height: parent.height/1.5
        anchors.centerIn: parent
        Rectangle {
            Layout.fillHeight: true
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
                                    //Check on the firmware
                                    //model: ["Boost", "Buck", "Bypass"]
                                    //                                    onCurrentIndexChanged: {
                                    //                                        if(currentIndex === 0) {
                                    //                                            voltageType = "Boost"
                                    //                                            voltageSet.to = 12
                                    //                                            voltageSet.from = 5.5
                                    //                                            voltageSet.toText.text = "12V"
                                    //                                            voltageSet.fromText.text = "5.5V"
                                    //                                        }
                                    //                                        else if (currentIndex === 1) {
                                    //                                            voltageType = "Buck"
                                    //                                            voltageSet.to = 18
                                    //                                            voltageSet.from = 2
                                    //                                            voltageSet.toText.text = "18V"
                                    //                                            voltageSet.fromText.text = "2V"
                                    //                                        }
                                    //                                        else if (currentIndex === 2) {
                                    //                                            voltageSet.enabled = false
                                    //                                            voltageSet.opacity = 0.5
                                    //                                        }
                                    //                                    }

                                    property var power_vled_type_caption: platformInterface.power_vled_type_caption.caption
                                    onPower_vled_type_captionChanged: {
                                        vedInputVoltageTypeLabel.text = power_vled_type_caption
                                    }

                                    property var power_vled_type_state: platformInterface.power_vled_type_state.state
                                    onPower_vled_type_stateChanged: {
                                        if(power_vled_type_state === "enabled") {
                                            vedInputVoltageType.opacity = 1.0
                                            vedInputVoltageType.enabled = true
                                        }
                                        else if (power_vled_type_state === "disabled") {
                                            vedInputVoltageType.opacity = 1.0
                                            vedInputVoltageType.enabled = false
                                        }
                                        else  {
                                            vedInputVoltageType.opacity = 0.5
                                            vedInputVoltageType.enabled = false
                                        }
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

                                }
                                property var power_boost_ocp_caption: platformInterface.power_boost_ocp_caption.caption
                                onPower_boost_ocp_captionChanged: {
                                    boostOCPLabel.text = power_boost_ocp_caption
                                }

                                property var power_boost_ocp_state: platformInterface.power_boost_ocp_state.state
                                onPower_boost_ocp_stateChanged: {
                                    if(power_boost_ocp_state === "enabled") {
                                        boostOCP.opacity = 1.0
                                        boostOCP.enabled = true
                                    }
                                    else if (power_boost_ocp_state === "disabled") {
                                        boostOCP.opacity = 1.0
                                        boostOCP.enabled = false
                                    }
                                    else  {
                                        boostOCP.opacity = 0.5
                                        boostOCP.enabled = false
                                    }
                                }

                                property var power_boost_ocp_value: platformInterface.power_boost_ocp_value.value
                                onPower_boost_ocp_valueChanged:{
                                    if(power_boost_ocp_value === true)
                                        boostOCP.status = SGStatusLight.Red
                                    else boostOCP.status = SGStatusLight.Off
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
                            //                            to: 18
                            //                            from: 2
                            //                            stepSize: 1
                            //                            toText.text: "18V"
                            //                            fromText.text: "2V"
                            //                            value: 7
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

                        property var power_voltage_set_state: platformInterface.power_voltage_set_state.state
                        onPower_voltage_set_stateChanged: {
                            if(power_voltage_set_state === "enabled") {
                                voltageSet.opacity = 1.0
                                voltageSet.enabled = true
                            }
                            else if (power_voltage_set_state === "disabled") {
                                voltageSet.opacity = 1.0
                                voltageSet.enabled = false
                            }
                            else  {
                                voltageSet.opacity = 0.5
                                voltageSet.enabled = false
                            }
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
                        }

                        property var power_vs_select_caption: platformInterface.power_vs_select_caption.caption
                        onPower_vs_select_captionChanged: {
                            vsVoltageSelectLabel.text = power_vs_select_caption
                        }

                        property var power_vs_select_state: platformInterface.power_vs_select_state.state
                        onPower_vs_select_stateChanged: {
                            if(power_vs_select_state === "enabled") {
                                vsVoltageSelect.opacity = 1.0
                                vsVoltageSelect.enabled = true
                            }
                            else if (power_vs_select_state === "disabled") {
                                vsVoltageSelect.opacity = 1.0
                                vsVoltageSelect.enabled = false
                            }
                            else  {
                                vsVoltageSelect.opacity = 0.5
                                vsVoltageSelect.enabled = false
                            }
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
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width/1.5
            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.preferredHeight: parent.height/2
                    Layout.fillWidth: true
                    //color: "red"


                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            // color: "gray"

                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: vLEDLabel
                                        //text: "LED Voltage\n(VLED)"
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
                                            // unit: "<b>V</b>"
                                            // text: "12.5"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vled_caption: platformInterface.power_vled_caption.caption
                                        onPower_vled_captionChanged: {
                                            vLEDLabel.text = power_vled_caption
                                        }

                                        property var power_vled_state: platformInterface.power_vled_state.state
                                        onPower_vled_stateChanged: {
                                            if(power_vled_state === "enabled") {
                                                vLED.opacity = 1.0
                                                vLED.enabled = true
                                            }
                                            else if (power_vled_state === "disabled") {
                                                vLED.opacity = 1.0
                                                vLED.enabled = false
                                            }
                                            else  {
                                                vLED.opacity = 0.5
                                                vLED.enabled = false
                                            }
                                        }

                                        property var power_vled_value: platformInterface.power_vled_value.value
                                        onPower_vled_valueChanged:{
                                            vLED.text = power_vled_value
                                            vLED.unit = "<b>V</b>"
                                        }




                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: supplyVoltageLabel
                                        //text: "Supply Voltage\n(VS)"
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
                                            // text: "5"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vs_caption: platformInterface.power_vs_caption.caption
                                        onPower_vs_captionChanged: {
                                            supplyVoltageLabel.text = power_vs_caption
                                        }

                                        property var power_vs_state: platformInterface.power_vs_state.state
                                        onPower_vs_stateChanged: {
                                            if(power_vs_state === "enabled") {
                                                supplyVoltage.opacity = 1.0
                                                supplyVoltage.enabled = true
                                            }
                                            else if (power_vs_state === "disabled") {
                                                supplyVoltage.opacity = 1.0
                                                supplyVoltage.enabled = false
                                            }
                                            else  {
                                                supplyVoltage.opacity = 0.5
                                                supplyVoltage.enabled = false
                                            }
                                        }

                                        property var power_vs_value: platformInterface.power_vs_value.value
                                        onPower_vs_valueChanged:{
                                            supplyVoltage.text = power_vs_value
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: digitalVoltageLabel
                                        //text: "Digital Voltage\n(VDD)"
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
                                            unit: "<b> mA</b>"

                                            // text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }
                                        property var power_vdd_caption: platformInterface.power_vdd_caption.caption
                                        onPower_vdd_captionChanged: {
                                            digitalVoltageLabel.text = power_vdd_caption
                                        }

                                        property var power_vdd_state: platformInterface.power_vdd_state.state
                                        onPower_vdd_stateChanged: {
                                            if(power_vdd_state === "enabled") {
                                                digitalVoltage.opacity = 1.0
                                                digitalVoltage.enabled = true
                                            }
                                            else if (power_vdd_state === "disabled") {
                                                digitalVoltage.opacity = 1.0
                                                digitalVoltage.enabled = false
                                            }
                                            else  {
                                                digitalVoltage.opacity = 0.5
                                                digitalVoltage.enabled = false
                                            }
                                        }

                                        property var power_vdd_value: platformInterface.power_vdd_value.value
                                        onPower_vdd_valueChanged:{
                                            digitalVoltage.text = power_vdd_value
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: batteryVoltageLabel
                                        // text: "Battery Voltage\n(VBAT)"
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

                                        property var power_vbat_caption: platformInterface.power_vbat_caption.caption
                                        onPower_vbat_captionChanged: {
                                            batteryVoltageLabel.text = power_vbat_caption
                                        }

                                        property var power_vbat_state: platformInterface.power_vbat_state.state
                                        onPower_vbat_stateChanged: {
                                            if(power_vbat_state === "enabled") {
                                                batteryVoltage.opacity = 1.0
                                                batteryVoltage.enabled = true
                                            }
                                            else if (power_vbat_state === "disabled") {
                                                batteryVoltage.opacity = 1.0
                                                batteryVoltage.enabled = false
                                            }
                                            else  {
                                                batteryVoltage.opacity = 0.5
                                                batteryVoltage.enabled = false
                                            }
                                        }

                                        property var power_vbat_value: platformInterface.power_vbat_value.value
                                        onPower_vbat_valueChanged:{
                                            batteryVoltage.text = power_vbat_value
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

                                        property var power_iled_caption: platformInterface.power_iled_caption.caption
                                        onPower_iled_captionChanged: {
                                            ledCurrentLabel.text = power_iled_caption
                                        }

                                        property var power_iled_state: platformInterface.power_iled_state.state
                                        onPower_iled_stateChanged: {
                                            if(power_iled_state === "enabled") {
                                                ledCurrent.opacity = 1.0
                                                ledCurrent.enabled = true
                                            }
                                            else if (power_iled_state === "disabled") {
                                                ledCurrent.opacity = 1.0
                                                ledCurrent.enabled = false
                                            }
                                            else  {
                                                ledCurrent.opacity = 0.5
                                                ledCurrent.enabled = false
                                            }
                                        }

                                        property var power_iled_value: platformInterface.power_iled_value.value
                                        onPower_iled_valueChanged:{
                                            ledCurrent.text = power_iled_value
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


                                        property var power_is_caption: platformInterface.power_is_caption.caption
                                        onPower_is_captionChanged: {
                                            supplyCurrentLabel.text = power_is_caption
                                        }

                                        property var power_is_state: platformInterface.power_is_state.state
                                        onPower_is_stateChanged: {
                                            if(power_is_state === "enabled") {
                                                supplyCurrent.opacity = 1.0
                                                supplyCurrent.enabled = true
                                            }
                                            else if (power_is_state === "disabled") {
                                                supplyCurrent.opacity = 1.0
                                                supplyCurrent.enabled = false
                                            }
                                            else  {
                                                supplyCurrent.opacity = 0.5
                                                supplyCurrent.enabled = false
                                            }
                                        }

                                        property var power_is_value: platformInterface.power_is_value.value
                                        onPower_is_valueChanged:{
                                            supplyCurrent.text = power_is_value
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: digitalCurrentLabel
                                        // text: "Digital Current\n(IDD)"
                                        target: digitalCurrent
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        SGInfoBox {
                                            id: digitalCurrent
                                            height:  35 * ratioCalc
                                            width: 160 * ratioCalc
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            unit: "<b>mA</b>"
                                            //text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_idd_caption: platformInterface.power_idd_caption.caption
                                        onPower_idd_captionChanged: {
                                            digitalCurrentLabel.text = power_idd_caption
                                        }

                                        property var power_idd_state: platformInterface.power_idd_state.state
                                        onPower_idd_stateChanged: {
                                            if(power_idd_state === "enabled") {
                                                digitalCurrent.opacity = 1.0
                                                digitalCurrent.enabled = true
                                            }
                                            else if (power_idd_state === "disabled") {
                                                digitalCurrent.opacity = 1.0
                                                digitalCurrent.enabled = false
                                            }
                                            else  {
                                                digitalCurrent.opacity = 0.5
                                                digitalCurrent.enabled = false
                                            }
                                        }

                                        property var power_idd_value: platformInterface.power_idd_value.value
                                        onPower_idd_valueChanged:{
                                            digitalCurrent.text = power_idd_value
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: voltageLabel
                                        // text: "Voltage\n(VCC)"
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
                                            unit: "<b>mA</b>"
                                            // text: "500"
                                            boxFont.family: Fonts.digitalseven
                                        }

                                        property var power_vcc_caption: platformInterface.power_vcc_caption.caption
                                        onPower_vcc_captionChanged: {
                                            voltageLabel.text = power_vcc_caption
                                        }

                                        property var power_vcc_state: platformInterface.power_vcc_state.state
                                        onPower_vcc_stateChanged: {
                                            if(power_vcc_state === "enabled") {
                                                voltage.opacity = 1.0
                                                voltage.enabled = true
                                            }
                                            else if (power_vcc_state === "disabled") {
                                                voltage.opacity = 1.0
                                                voltage.enabled = false
                                            }
                                            else  {
                                                voltage.opacity = 0.5
                                                voltage.enabled = false
                                            }
                                        }

                                        property var power_vcc_value: platformInterface.power_vcc_value.value
                                        onPower_vcc_valueChanged:{
                                            voltage.text = power_vcc_value
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
                                    // valueDecimalPlaces: 0
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

                                property var power_led_driver_temp_top_caption: platformInterface.power_led_driver_temp_top_caption.caption
                                onPower_led_driver_temp_top_captionChanged: {
                                    ledDriverTempTopLabel.text = power_led_driver_temp_top_caption
                                }

                                property var power_led_driver_temp_top_state: platformInterface.power_led_driver_temp_top_state.state
                                onPower_led_driver_temp_top_stateChanged: {
                                    if(power_led_driver_temp_top_state === "enabled") {
                                        ledDriverTempTop.opacity = 1.0
                                        ledDriverTempTop.enabled = true
                                    }
                                    else if (power_led_driver_temp_top_state === "disabled") {
                                        ledDriverTempTop.opacity = 1.0
                                        ledDriverTempTop.enabled = false
                                    }
                                    else  {
                                        ledDriverTempTop.opacity = 0.5
                                        ledDriverTempTop.enabled = false
                                    }
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

                                property var power_led_driver_temp_bottom_caption: platformInterface.power_led_driver_temp_bottom_caption.caption
                                onPower_led_driver_temp_bottom_captionChanged: {
                                    ledDriverTempBottomLabel.text = power_led_driver_temp_bottom_caption
                                }

                                property var power_led_driver_temp_bottom_state: platformInterface.power_led_driver_temp_bottom_state.state
                                onPower_led_driver_temp_bottom_stateChanged: {
                                    if(power_led_driver_temp_bottom_state === "enabled") {
                                        ledDriverTempBottom.opacity = 1.0
                                        ledDriverTempBottom.enabled = true
                                    }
                                    else if (power_led_driver_temp_bottom_state === "disabled") {
                                        ledDriverTempBottom.opacity = 1.0
                                        ledDriverTempBottom.enabled = false
                                    }
                                    else  {
                                        ledDriverTempBottom.opacity = 0.5
                                        ledDriverTempBottom.enabled = false
                                    }
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

                                    property var power_led_temp_caption: platformInterface.power_led_temp_caption.caption
                                    onPower_led_temp_captionChanged: {
                                        tempGaugeLabel.text = power_led_temp_caption
                                    }

                                    property var power_led_temp_state: platformInterface.power_led_temp_state.state
                                    onPower_led_temp_stateChanged: {
                                        if(power_led_temp_state === "enabled") {
                                            tempGauge.opacity = 1.0
                                            tempGauge.enabled = true
                                        }
                                        else if (power_led_temp_state === "disabled") {
                                            tempGauge.opacity = 1.0
                                            tempGauge.enabled = false
                                        }
                                        else  {
                                            tempGauge.opacity = 0.5
                                            tempGauge.enabled = false
                                        }
                                    }

                                    property var power_led_temp_scales: platformInterface.power_led_temp_scales.scales
                                    onPower_led_temp_scalesChanged: {
                                        tempGauge.maximumValue = power_led_temp_scales[0]
                                        tempGauge.minimumValue = power_led_temp_scales[1]
                                        tempGauge.tickmarkStepSize = power_led_temp_scales[2]


                                    }

                                    property var power_led_temp_value: platformInterface.power_led_temp_value.value
                                    onPower_led_temp_valueChanged: {
                                        tempGauge.value = power_led_driver_temp_top_value
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

                                    property var power_total_power_loss_caption: platformInterface.power_total_power_loss_caption.caption
                                    onPower_total_power_loss_captionChanged: {
                                        powerLossGaugeLabel.text = power_total_power_loss_caption
                                    }

                                    property var power_total_power_loss_state: platformInterface.power_total_power_loss_state.state
                                    onPower_total_power_loss_stateChanged: {
                                        if(power_total_power_loss_state === "enabled") {
                                            powerLoss.opacity = 1.0
                                            powerLoss.enabled = true
                                        }
                                        else if (power_total_power_loss_state === "disabled") {
                                            powerLoss.opacity = 1.0
                                            powerLoss.enabled = false
                                        }
                                        else  {
                                            powerLoss.opacity = 0.5
                                            powerLoss.enabled = false
                                        }
                                    }

                                    property var power_total_power_loss_scales: platformInterface.power_total_power_loss_scales.scales
                                    onPower_total_power_loss_scalesChanged: {
                                        powerLoss.maximumValue = power_total_power_loss_scales[0]
                                        powerLoss.minimumValue = power_total_power_loss_scales[1]
                                        powerLoss.tickmarkStepSize = power_total_power_loss_scales[2]


                                    }

                                    property var power_total_power_loss_value: platformInterface.power_total_power_loss_value.value
                                    onPower_total_power_loss_valueChanged: {
                                        powerLoss.value = power_total_power_loss_value
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

