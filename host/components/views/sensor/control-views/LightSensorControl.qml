import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property bool debugLayout: false
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1225/648

    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

    MouseArea {
        id: containMouseArea
        anchors.fill:root
        onClicked: {
            forceActiveFocus()
        }
    }

    Component.onCompleted: {
        Help.registerTarget(sensitivitySliderContainer, "Adjust the light sensitivity in percentage from 66.7% to 150%. The sensitivity will be coerced to the nearest valid value according to the sensitivity calculation in the LV0140CS datasheet. The calculation imposes more resolution around 100%.", 0, "lightHelp")
        Help.registerTarget(gainboxLabel, "Adjusts the gain of the light sensor.", 1, "lightHelp")
        Help.registerTarget(timeboxLabel, "Adjusts the integration time of the light sensor. The Lux (lx) gauge will be refreshed with the value set in the Integration Time control. Setting the Integration Time time to Manual will enable the Manual Integration control to manually start and stop integration.", 2, "lightHelp")
        Help.registerTarget(activeswLabel, "Sets the Light sensor state to be Active or Sleep mode.", 3, "lightHelp")
        Help.registerTarget(startswLabel, "Manual integration toggle is enabled when Integration Time is set to Manual and Status is set to Active. Set Manual Integration to Start and then Stop to generate a manual integration time.", 4, "lightHelp")
        Help.registerTarget(luxGauge,"Indicates the 16-bit light measurement result.", 5, "lightHelp")
    }

    Rectangle {
        id: proximityContainer
        width: parent.width/1.7
        height: parent.height/1.7
        color: "transparent"
        radius: 10

        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        RowLayout {
            anchors.fill: parent

            Rectangle {
                id: luxGauge
                Layout.fillHeight: true
                Layout.fillWidth: true

                SGAlignedLabel {
                    id: boardTempLabel
                    target: lightGauge
                    font.bold: true
                    fontSizeMultiplier: ratioCalc * 1.2
                    alignment: SGAlignedLabel.SideBottomCenter
                    Layout.alignment: Qt.AlignCenter
                    anchors.fill:parent

                    SGCircularGauge{
                        id:lightGauge
                        anchors.centerIn: parent
                        width: 300 * ratioCalc
                        height: 300 * ratioCalc
                        unitTextFontSizeMultiplier: ratioCalc * 2.0
                        tickmarkStepSize: 5000
                        unitText : "Lux \n (lx)"

                        property var light_value: platformInterface.light_value.value
                        onLight_valueChanged:  lightGauge.value =light_value

                        property var light_state: platformInterface.light_state.state
                        onLight_stateChanged: {
                            if(light_state === "enabled")
                                lightGauge.enabled = true
                            else if (light_state === "disabled")
                                lightGauge.enabled = false
                            else {
                                lightGauge.enabled = false
                                lightGauge.opacity = 0.5
                            }
                        }

                        property var light_scales: platformInterface.light_scales.scales
                        onLight_scalesChanged: {
                            lightGauge.maximumValue = parseInt(light_scales[0])
                            lightGauge.minimumValue = parseInt(light_scales[1])
                        }
                    }
                }
            }

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "transparent"

                ColumnLayout {
                    anchors.fill:parent

                    Rectangle {
                        id:sensitivitySliderContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        SGAlignedLabel {
                            id: sensitivitySliderLabel
                            target: sensitivitySlider
                            font.bold: true
                            fontSizeMultiplier: ratioCalc * 1.2
                            anchors.verticalCenter: parent.verticalCenter


                            SGSlider{
                                id: sensitivitySlider
                                width: sensitivitySliderContainer.width
                                stepSize: 0.01
                                live: false
                                fontSizeMultiplier: ratioCalc * 1.2
                                inputBox.validator: DoubleValidator {
                                    top: sensitivitySlider.to
                                    bottom: sensitivitySlider.from
                                }

                                onUserSet: {
                                    platformInterface.set_light_sensitivity.update(value)
                                }
                            }

                            property var light_sensitivity_caption: platformInterface.light_sensitivity_caption.caption
                            onLight_sensitivity_captionChanged: {
                                sensitivitySliderLabel.text = light_sensitivity_caption

                            }

                            property var light_sensitivity_value: platformInterface.light_sensitivity_value.value
                            onLight_sensitivity_valueChanged: {
                                sensitivitySlider.value = parseFloat(light_sensitivity_value).toFixed(2)
                            }

                            property var light_sensitivity_states: platformInterface.light_sensitivity_state.state
                            onLight_sensitivity_statesChanged: {
                                if(light_sensitivity_states === "enabled"){
                                    sensitivitySliderContainer.enabled = true
                                    sensitivitySliderContainer.opacity = 1.0
                                }
                                else if(light_sensitivity_states === "disabled"){
                                    sensitivitySliderContainer.enabled = false
                                    sensitivitySliderContainer.opacity = 1.0
                                }
                                else {
                                    sensitivitySliderContainer.enabled = false
                                    sensitivitySliderContainer.opacity = 0.5
                                }
                            }

                            property var light_sensitivity_scales: platformInterface.light_sensitivity_scales.scales
                            onLight_sensitivity_scalesChanged: {
                                sensitivitySlider.to = parseInt(light_sensitivity_scales[0])
                                sensitivitySlider.toText.text = light_sensitivity_scales[0] + "%"
                                sensitivitySlider.from = parseInt(light_sensitivity_scales[1])
                                sensitivitySlider.fromText.text = light_sensitivity_scales[1] + "%"
                            }

                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout {
                            anchors.fill: parent

                            Rectangle {
                                id: gainboxContainer
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                SGAlignedLabel {
                                    id: gainboxLabel
                                    target: gainbox
                                    font.bold: true
                                    //text: "<b>" + qsTr("Gain") + "</b>"
                                    Component.onCompleted: {
                                        fontSizeMultiplier = Qt.binding(function(){ return ratioCalc * 1.2})
                                    }
                                    anchors.verticalCenter: parent.verticalCenter
                                    SGComboBox {
                                        id:gainbox
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        // KeyNavigation.tab: timebox
                                        Keys.onBacktabPressed: {
                                            timebox.forceActiveFocus()
                                            timebox.textField.selectAll()
                                            textField.deselect()

                                        }
                                        Keys.onTabPressed: {
                                            timebox.forceActiveFocus()
                                            timebox.textField.selectAll()
                                            textField.deselect()
                                        }

                                        onFocusChanged:  {
                                            if(!focus)
                                                textField.deselect()
                                        }
                                        onActivated: {
                                            platformInterface.set_light_gain.update(parseFloat(currentText))
                                        }
                                    }

                                    property var light_gain_caption: platformInterface.light_gain_caption
                                    onLight_gain_captionChanged: {
                                        gainboxLabel.text = light_gain_caption.caption
                                    }

                                    property var light_gain_values: platformInterface.light_gain_values
                                    onLight_gain_valuesChanged: {
                                        gainbox.model = light_gain_values.values
                                    }

                                    property var light_gain_states: platformInterface.light_gain_state
                                    onLight_gain_statesChanged: {
                                        if(light_gain_states.state === "enabled"){
                                            gainboxContainer.enabled = true
                                            gainboxContainer.opacity = 1.0
                                        }
                                        else if(light_gain_states.state === "disabled"){
                                            gainboxContainer.enabled = false
                                            gainboxContainer.opacity = 1.0
                                        }
                                        else {
                                            gainboxContainer.enabled = false
                                            gainboxContainer.opacity = 0.5
                                        }
                                    }

                                    property var light_gain_value: platformInterface.light_gain_value
                                    onLight_gain_valueChanged: {
                                        for(var i = 0; i < gainbox.model.length; ++i) {
                                            if(light_gain_value.value === gainbox.model[i].toString()){
                                                gainbox.currentIndex = i
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id:timeboxConatiner
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                SGAlignedLabel {
                                    id: timeboxLabel
                                    target: timebox
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    font.bold: true
                                    anchors.centerIn: parent
                                    SGComboBox {
                                        id:timebox
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        // KeyNavigation.tab: gainbox
                                        Keys.onBacktabPressed: {
                                            gainbox.forceActiveFocus()
                                            gainbox.textField.selectAll()
                                            textField.deselect()

                                        }
                                        Keys.onTabPressed: {
                                            gainbox.forceActiveFocus()
                                            gainbox.textField.selectAll()
                                            textField.deselect()
                                        }
                                        onFocusChanged:  {
                                            if(!focus)
                                                textField.deselect()
                                        }
                                        onActivated: {
                                            platformInterface.set_light_integ_time.update(currentText)
                                        }
                                    }

                                    property var light_integ_time_caption: platformInterface.light_integ_time_caption
                                    onLight_integ_time_captionChanged: {
                                        timeboxLabel.text = light_integ_time_caption.caption
                                    }

                                    property var light_integ_time_values: platformInterface.light_integ_time_values
                                    onLight_integ_time_valuesChanged: {
                                        timebox.model = light_integ_time_values.values
                                    }

                                    property var light_integ_time_value: platformInterface.light_integ_time_value
                                    onLight_integ_time_valueChanged: {
                                        for(var i = 0; i < timebox.model.length; ++i) {
                                            if(light_integ_time_value.value === timebox.model[i].toString()){
                                                timebox.currentIndex = i
                                            }

                                        }
                                    }

                                    property var light_integ_time_states: platformInterface.light_integ_time_state
                                    onLight_integ_time_statesChanged: {

                                        if(light_integ_time_states.state === "enabled"){
                                            timeboxConatiner.enabled = true
                                            timeboxConatiner.opacity = 1.0
                                        }
                                        else if(light_integ_time_states.state === "disabled"){
                                            timeboxConatiner.enabled = false
                                            timeboxConatiner.opacity = 1.0
                                        }
                                        else {
                                            timeboxConatiner.enabled = false
                                            timeboxConatiner.opacity = 0.5
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

                            Rectangle {
                                id: statusContainer
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                SGAlignedLabel {
                                    id: activeswLabel
                                    target: activesw
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.verticalCenter: parent.verticalCenter
                                    SGSwitch {
                                        id:activesw
                                        Component.onCompleted: {
                                            fontSizeMultiplier = Qt.binding(function(){ return ratioCalc * 1.2})
                                        }
                                        onClicked: {
                                            if(checked) {
                                                platformInterface.set_light_status.update("Active")
                                            }
                                            else {
                                                platformInterface.set_light_status.update("Sleep")
                                            }
                                        }

                                        property var light_status_caption: platformInterface.light_status_caption
                                        onLight_status_captionChanged: {
                                            activeswLabel.text = light_status_caption.caption
                                        }

                                        property var light_status_value: platformInterface.light_status_value
                                        onLight_status_valueChanged: {
                                            if(light_status_value.value === "Sleep")
                                                activesw.checked = false
                                            else activesw.checked = true
                                        }

                                        property var light_status_states: platformInterface.light_status_state
                                        onLight_status_statesChanged: {
                                            if(light_status_states.value === "Sleep")
                                                activesw.checked = false
                                            else activesw.checked = true

                                            if(light_status_states.state === "enabled") {
                                                activesw.enabled = true
                                                activesw.opacity = 1.0
                                            }
                                            else if (light_status.state === "disabled") {
                                                activesw.enabled = false
                                                activesw.opacity = 1.0
                                            }
                                            else {
                                                activesw.enabled = false
                                                activesw.opacity = 0.5
                                            }
                                        }

                                        property var light_status_values: platformInterface.light_status_values
                                        onLight_status_valuesChanged: {
                                            activesw.checkedLabel = light_status_values.values[0]
                                            activesw.uncheckedLabel = light_status_values.values[1]
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: manualIntegration
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGAlignedLabel {
                                    id: startswLabel
                                    target: startsw
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    SGSwitch {
                                        id:startsw
                                        Component.onCompleted: {
                                            fontSizeMultiplier = Qt.binding(function(){ return ratioCalc * 1.2})
                                        }

                                        onClicked: {
                                            if(checked)
                                                platformInterface.set_light_manual_integ.update("Start")
                                            else platformInterface.set_light_manual_integ.update("Stop")
                                        }

                                        property var light_manual_integ_caption: platformInterface.light_manual_integ_caption
                                        onLight_manual_integ_captionChanged: {
                                            startswLabel.text = light_manual_integ_caption.caption
                                        }

                                        property var light_manual_integ_value: platformInterface.light_manual_integ_value
                                        onLight_manual_integ_valueChanged: {
                                            if(light_manual_integ_value.value === "Stop")
                                                startsw.checked = false
                                            else startsw.checked = true
                                        }

                                        property var light_manual_integ_states: platformInterface.light_manual_integ_state
                                        onLight_manual_integ_statesChanged: {
                                            if(light_manual_integ_states.state === "enabled") {
                                                startswLabel.enabled = true
                                                startswLabel.opacity = 1.0
                                            }
                                            else if (light_manual_integ_states.state === "disabled") {
                                                startswLabel.enabled = false
                                                startswLabel.opacity = 1.0
                                            }
                                            else {
                                                startswLabel.enabled = false
                                                startswLabel.opacity = 0.5
                                            }
                                        }

                                        property var light_manual_integ_values: platformInterface.light_manual_integ_values
                                        onLight_manual_integ_valuesChanged: {
                                            startsw.checkedLabel = light_manual_integ_values.values[0]
                                            startsw.uncheckedLabel = light_manual_integ_values.values[1]
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
