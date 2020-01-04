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
    property real initialAspectRatio: 1200/820
    Rectangle {
        id: proximityContainer
        width: parent.width/2
        height: parent.height/2
        color: "transparent"
        radius: 10
        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }


        RowLayout {
            anchors.fill: parent
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                SGAlignedLabel {
                    id: boardTempLabel
                    target: lightGauge
                    text: "<b>" + qsTr("Light Intensity (2 bytes)") + "</b>"
                    fontSizeMultiplier: ratioCalc * 1.2
                    alignment: SGAlignedLabel.SideBottomCenter
                    Layout.alignment: Qt.AlignCenter
                    anchors.centerIn: parent

                    SGCircularGauge{
                        id:lightGauge
                        height: 200 * ratioCalc
                        width: 200 * ratioCalc
                        //unitText: "Lux \n (lx)"
                        unitTextFontSizeMultiplier: ratioCalc * 1.2
                        //                        minimumValue: 0
                        //                        maximumValue: 65000
                        tickmarkStepSize: 5000
                        //                        property var lux_value: platformInterface.light_value.value
                        //                        onLux_valueChanged:  {
                        //                            value = lux_value
                        //                        }

                        property var light_changed: platformInterface.light
                        onLight_changedChanged: {
                            lightGauge.unitText = light_changed.caption
                            lightGauge.value = light_changed.value

                            if(light_changed.state === "enabled")
                                lightGauge.enabled = true
                            else if (light_changed.state === "disabled")
                                lightGauge.enabled = false
                            else {
                                lightGauge.enabled = false
                                lightGauge.opacity = 0.5
                            }



                            lightGauge.maximumValue = parseInt(light_changed.scales[0])
                            lightGauge.minimumValue = parseInt(light_changed.scales[1])

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
                            //text: "Sensitivity"
                            font.bold: true
                            //alignment: SGAlignedLabel.SideTopCenter
                            fontSizeMultiplier: ratioCalc * 1.2
                            anchors.verticalCenter: parent.verticalCenter


                            SGSlider{
                                id: sensitivitySlider
                                width: sensitivitySliderContainer.width
                                //                                from: 66.7
                                //                                to: 150
                                //                                fromText.text: "66.7%"
                                //                                toText.text: "150%"
                                stepSize: 0.1
                                live: false
                                fontSizeMultiplier: ratioCalc * 1.2
                                //inputBoxWidth: sensitivitySliderContainer.width/8
                                inputBox.validator: DoubleValidator {
                                    top: sensitivitySlider.to
                                    bottom: sensitivitySlider.from

                                }

                                onUserSet: {
                                    platformInterface.set_light_sensitivity.update(value)
                                }

                            }

                            property var light_sensitivity: platformInterface.light_sensitivity
                            onLight_sensitivityChanged: {
                                sensitivitySliderLabel.text = light_sensitivity.caption
                                sensitivitySlider.value = parseInt(light_sensitivity.value).toFixed(2)

                                if(light_sensitivity.state === "enabled"){
                                    sensitivitySliderContainer.enabled = true
                                    sensitivitySliderContainer.opacity = 1.0
                                }
                                else if(light_sensitivity.state === "disabled"){
                                    sensitivitySliderContainer.enabled = false
                                    sensitivitySliderContainer.opacity = 1.0
                                }
                                else {
                                    sensitivitySliderContainer.enabled = false
                                    sensitivitySliderContainer.opacity = 0.5
                                }

                                sensitivitySlider.to = parseInt(light_sensitivity.scales[0])
                                sensitivitySlider.toText.text = light_sensitivity.scales[0] + "%"
                                sensitivitySlider.from = parseInt(light_sensitivity.scales[1])
                                sensitivitySlider.fromText.text = light_sensitivity.scales[1] + "%"



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
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.verticalCenter: parent.verticalCenter
                                    SGComboBox {
                                        id:gainbox
                                        //model: ["0.25", "1", "2", "8"]
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        onActivated: {
                                            platformInterface.set_light_gain.update(parseFloat(currentText))
                                        }
                                    }

                                    property var light_gain: platformInterface.light_gain
                                    onLight_gainChanged: {
                                        gainboxLabel.text = light_gain.caption
                                        gainbox.model = light_gain.values

                                        for(var i = 0; i < gainbox.model.length; ++i) {
                                            if(light_gain.value === gainbox.model[i].toString()){
                                                gainbox.currentIndex = i
                                            }
                                        }

                                        if(light_gain.state === "enabled"){
                                            gainboxContainer.enabled = true
                                            gainboxContainer.opacity = 1.0
                                        }
                                        else if(light_gain.state === "disabled"){
                                            gainboxContainer.enabled = false
                                            gainboxContainer.opacity = 1.0
                                        }
                                        else {
                                            gainboxContainer.enabled = false
                                            gainboxContainer.opacity = 0.5
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
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        onActivated: {
                                            platformInterface.set_light_integ_time.update(currentText)
                                        }
                                    }

                                    property var light_integ_time: platformInterface.light_integ_time
                                    onLight_integ_timeChanged: {
                                        timeboxLabel.text = light_integ_time.caption
                                        timebox.model = light_integ_time.values

                                        for(var i = 0; i < timebox.model.length; ++i) {
                                            if(light_integ_time.value === timebox.model[i].toString()){
                                                timebox.currentIndex = i
                                            }
                                        }

                                        if(light_integ_time.state === "enabled"){
                                            timeboxConatiner.enabled = true
                                            timeboxConatiner.opacity = 1.0
                                        }
                                        else if(light_integ_time.state === "disabled"){
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
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                SGAlignedLabel {
                                    id: activeswLabel
                                    target: activesw
                                    //text: "<b>" + qsTr("Status") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.verticalCenter: parent.verticalCenter
                                    SGSwitch {
                                        id:activesw
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        onClicked: {
                                            if(checked) {
                                                platformInterface.set_light_status.update(true)
                                            }
                                            else {
                                                platformInterface.set_light_status.update(false)
                                            }
                                        }

                                        property var light_status: platformInterface.light_status
                                        onLight_statusChanged: {
                                            activeswLabel.text = light_status.caption
                                            if(light_status.value === "Sleep")
                                                activesw.checked = false
                                            else activesw.checked = true

                                            if(light_status.state === "enabled")
                                                activesw.enabled = true
                                            else if (light_status.state === "disabled")
                                                activesw.enabled = false
                                            else {
                                                activesw.enabled = false
                                                activesw.opacity = 0.5
                                            }

                                            activesw.checkedLabel = light_status.values[0]
                                            activesw.uncheckedLabel = light_status.values[1]
                                        }
                                    }
                                }
                            }

                            Rectangle {
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
                                        fontSizeMultiplier: ratioCalc * 1.2

                                        onClicked: {
                                            platformInterface.set_light_manual_integ.update(checked)
                                        }

                                        property var light_manual_integ: platformInterface.light_manual_integ
                                        onLight_manual_integChanged: {
                                            startswLabel.text = light_manual_integ.caption
                                            if(light_manual_integ.value === "Stop")
                                                startsw.checked = false
                                            else startsw.checked = true

                                            if(light_manual_integ.state === "enabled")
                                                startswLabel.enabled = true
                                            else if (light_manual_integ.state === "disabled")
                                                startswLabel.enabled = false
                                            else {
                                                startswLabel.enabled = false
                                                startswLabel.opacity = 0.5
                                            }

                                            startsw.checkedLabel = light_manual_integ.values[0]
                                            startsw.uncheckedLabel = light_manual_integ.values[1]

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
