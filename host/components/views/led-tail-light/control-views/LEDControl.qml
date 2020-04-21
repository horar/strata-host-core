import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    //   anchors.centerIn: parent
    //    height: parent.height
    //    width: parent.width/parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

    property var led_OL_value: platformInterface.led_OL_value.value
    onLed_OL_valueChanged: {
        if(led_OL_value === true)
            ol.status = SGStatusLight.Red
        else ol.status = SGStatusLight.Off
    }

    property var led_DIAGERR_value: platformInterface.led_DIAGERR_value.value
    onLed_DIAGERR_valueChanged: {
        if(led_DIAGERR_value === true)
            diagree.status = SGStatusLight.Red
        else diagree.status = SGStatusLight.Off
    }

    property var led_TSD_value: platformInterface.led_TSD_value.value
    onLed_TSD_valueChanged: {
        if(led_TSD_value === true)
            tsd.status = SGStatusLight.Red
        else tsd.status = SGStatusLight.Off
    }

    property var led_TW_value: platformInterface.led_TW_value.value
    onLed_TW_valueChanged: {
        if(led_TW_value === true)
            tw.status = SGStatusLight.Red
        else tw.status = SGStatusLight.Off
    }

    property var led_diagRange_value: platformInterface.led_diagRange_value.value
    onLed_diagRange_valueChanged: {
        if(led_diagRange_value === true)
            diagRange.status = SGStatusLight.Red
        else diagRange.status = SGStatusLight.Off
    }

    property var led_UV_value: platformInterface.led_UV_value.value
    onLed_UV_valueChanged: {
        if(led_UV_value === true)
            uv.status = SGStatusLight.Red
        else uv.status = SGStatusLight.Off
    }

    property var led_I2Cerr_value: platformInterface.led_I2Cerr_value.value
    onLed_I2Cerr_valueChanged: {
        if(led_I2Cerr_value === true)
            i2Cerr.status = SGStatusLight.Red
        else i2Cerr.status = SGStatusLight.Off
    }

    property var led_SC_Iset_value: platformInterface.led_SC_Iset_value.value
    onLed_SC_Iset_valueChanged: {
        if(led_SC_Iset_value === true)
            scIset.status = SGStatusLight.Red
        else scIset.status = SGStatusLight.Off
    }

    property var led_ch_enable_read_values: platformInterface.led_ch_enable_read_values.values
    onLed_ch_enable_read_valuesChanged: {
        if(led_ch_enable_read_values[0] === true)
            scIset.status = SGStatusLight.Red




    }

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    id: leftSetting
                    Layout.fillHeight: true
                    Layout.preferredWidth: root.width/3
                    // color: "red"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //color: "red"
                            SGAlignedLabel {
                                id: enableOutputLabel
                                target: enableOutput
                                text: "Output Enable (OEN)"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60

                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: enableOutput
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: lockPWMDutyLabel
                                target: lockPWMDuty
                                text: "Lock PWM Duty Together"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60

                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: lockPWMDuty
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: lockPWMDutyENLabel
                                target: lockPWMDutyEN
                                text: "Lock PWM EN Together"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60

                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGSwitch {
                                    id: lockPWMDutyEN
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: pwmLinearLogLabel
                                target: pwmLinearLog
                                text: "PWM Linear/Log"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60

                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                //horizontalAlignment: Text.AlignHCenter

                                SGSwitch {
                                    id: pwmLinearLog
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //color: "red"

                            SGAlignedLabel {
                                id: autoFaultRecoveryLabel
                                target: autoFaultRecovery
                                text: "Auto Fault Recovery"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60

                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: autoFaultRecovery
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: label
                                target: labelSwitch
                                text: "?"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60

                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: labelSwitch
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: pwmFrequencyLabel
                                target: pwmFrequency
                                text: "PWM Frequency (Hz)"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60

                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGComboBox {
                                    id: pwmFrequency
                                    fontSizeMultiplier: ratioCalc
                                    model: ["150", "250", "300"]
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: openLoadLabel
                                target: openLoadDiagnostic
                                text: "I2C Open Load\nDiagnostic"
                                alignment: SGAlignedLabel.SideLeftCenter

                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 60
                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGComboBox {
                                    id: openLoadDiagnostic
                                    fontSizeMultiplier: ratioCalc
                                    model: ["No Diagnostic", "Auto Retry", "Detect Only", "No Regulations\nChange"]
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: rightSetting
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent
                        anchors.right: parent.right
                        anchors.rightMargin: 15


                        Rectangle {
                            Layout.preferredHeight: parent.height/1.2
                            Layout.fillWidth: true
                            //color: "red"
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    //color: "grey"
                                    RowLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width/12
                                            //color: "blue"
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT EN") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter

                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGText {
                                                        text: "Internal \n External LED"
                                                        horizontalAlignment: Text.AlignHCenter
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter

                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGText {
                                                        text: "<b>" + qsTr("PWM Enable") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter

                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGText {
                                                        text: "<b>" + qsTr("Fault Status") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter

                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    // color: "red"
                                                    SGText {
                                                        text: "<b>" + qsTr("PWM Duty (%)") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            //color: "blue"

                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    //color: "red"
                                                    SGText {
                                                        id: text1
                                                        text: "<b>" + qsTr("OUT0") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    // color: "blue"


                                                    SGSwitch {
                                                        id: out0ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out0interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true


                                                    SGSwitch {
                                                        id: out0pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }


                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out0faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.1666


                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10

                                                    SGText {
                                                        text: "<b>" + qsTr("OUT1") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out1ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true


                                                    SGSwitch {
                                                        id: out1interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out1pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out1faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.1666


                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    //color: "red"
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT2") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out2ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out2interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out2pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out2faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    // color: "red"

                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        // slider_start_color: 0.1666


                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    //color: "red"
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT3") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true


                                                    SGSwitch {
                                                        id: out3ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out3interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out3pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out3faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        //slider_start_color: 0.1666


                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT4") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter

                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out4ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out4interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out4pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out4faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.0
                                                        slider_start_color2: 0

                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    //color: "red"
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT5") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out5ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out5interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out5pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out5faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }

                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.0
                                                        slider_start_color2: 0

                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT6") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true


                                                    SGSwitch {
                                                        id: out6ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out6interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out6pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out6faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.0
                                                        slider_start_color2: 0

                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    //color: "red"
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT7") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out7ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out7interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out7pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out7faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.0
                                                        slider_start_color2: 0

                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT8") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out8ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out8interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out8pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out8faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent

                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    //color: "red"
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT9") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out9ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out9interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out9pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out9faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent

                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT10") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out10ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out10interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out10pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out10faultStatusLED
                                                        width: 30
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: 5
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.1666

                                                    }
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/10
                                                    //color: "red"
                                                    SGText {
                                                        text: "<b>" + qsTr("OUT11") + "</b>"
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out11ENLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out11interExterLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGSwitch {
                                                        id: out11pwmEnableLED
                                                        labelsInside: true
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        textColor: "black"              // Default: "black"
                                                        handleColor: "white"            // Default: "white"
                                                        grooveColor: "#ccc"             // Default: "#ccc"
                                                        grooveFillColor: "#0cf"         // Default: "#0cf"
                                                        fontSizeMultiplier: ratioCalc
                                                        checked: false
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    SGStatusLight {
                                                        id: out11faultStatusLED
                                                        width: 30
                                                        anchors.centerIn: parent
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: parent.height/3
                                                    CustomizeRGBSlider {
                                                        width: 30
                                                        height: parent.height
                                                        orientation: Qt.Vertical
                                                        value: 50
                                                        anchors.centerIn: parent
                                                        slider_start_color: 0.1666
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: gobalCurrentSetContainer
                                    Layout.preferredHeight: parent.height/10
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: gobalCurrentSetLabel
                                        target: gobalCurrentSetSlider
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        alignment: SGAlignedLabel.SideLeftCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        text: "Gobal Current Set (ISET)"
                                        SGSlider {
                                            id: gobalCurrentSetSlider
                                            width: gobalCurrentSetContainer.width/1.5
                                            live: false
                                            fontSizeMultiplier: ratioCalc * 1.2
                                            to: 60
                                            from: 0
                                            stepSize: 1
                                            toText.text: "60mA"
                                            fromText.text: "0mA"
                                        }

                                    }
                                }
                            }
                        }


                        Rectangle {
                            id: i2cStatusSettingContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //  color: "red"

                            SGText{
                                id: i2cStatusLable
                                fontSizeMultiplier: ratioCalc * 1.2
                                text: "I2C Status Registers"
                                font.bold: true
                                anchors.top: parent. top
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                            }

                            Rectangle {
                                id: i2cLEDS
                                anchors.top: i2cStatusLable.bottom
                                anchors.centerIn: parent
                                width: parent.width - 100
                                height: parent.height - i2cStatusLable.contentHeight
                                color: "transparent"

                                RowLayout{
                                    anchors.fill: parent

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"

                                        SGAlignedLabel {
                                            id: scIsetLabel
                                            target: scIset
                                            text:  "SC_Iset"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: scIset
                                                width: 30
                                            }
                                        }

                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        SGAlignedLabel {
                                            id: i2CerrLabel
                                            target: i2Cerr
                                            text:  "I2Cerr"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: i2Cerr
                                                width: 30
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        SGAlignedLabel {
                                            id: uvLabel
                                            target: uv
                                            text:  "UV"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: uv
                                                width: 30
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"

                                        SGAlignedLabel {
                                            id: diagRangeLabel
                                            target: diagRange
                                            text:  "diagRange"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: diagRange
                                                width: 30
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        SGAlignedLabel {
                                            id: twLabel
                                            target: tw
                                            text:  "TW"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: tw
                                                width: 30
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        SGAlignedLabel {
                                            id: tsdLabel
                                            target: tsd
                                            text:  "TSD"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: tsd
                                                width: 30
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        SGAlignedLabel {
                                            id: diagreeLabel
                                            target: diagree
                                            text:  "DIAGERR"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: diagree
                                                width: 30
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        SGAlignedLabel {
                                            id: olLabel
                                            target: ol
                                            text:  "OL"
                                            font.bold: true
                                            alignment: SGAlignedLabel.SideTopCenter
                                            fontSizeMultiplier: ratioCalc
                                            anchors.centerIn: parent

                                            SGStatusLight {
                                                id: ol
                                                width: 30
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width/8
                                        SGButton {
                                            id:  exportButton
                                            text: qsTr("Export Registers")
                                            anchors.verticalCenter: parent.verticalCenter
                                            fontSizeMultiplier: ratioCalc
                                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                            hoverEnabled: true
                                            MouseArea {
                                                hoverEnabled: true
                                                anchors.fill: parent
                                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

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



