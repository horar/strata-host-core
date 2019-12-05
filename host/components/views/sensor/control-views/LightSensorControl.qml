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
                        unitText: "Lux \n (lx)"
                        unitTextFontSizeMultiplier: ratioCalc * 1.2
                        minimumValue: 0
                        maximumValue: 65000
                        tickmarkStepSize: 5000
                        property var lux_value: platformInterface.light.value
                        onLux_valueChanged:  {
                            value = lux_value
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
                            text: "Sensitivity:"
                            font.bold: true
                            alignment: SGAlignedLabel.SideTopCenter
                            fontSizeMultiplier: ratioCalc * 1.2
                            anchors.centerIn: parent

                            SGSlider{
                                id: sensitivitySlider
                                width: sensitivitySliderContainer.width
                                from: 66.7
                                to: 150
                                fromText.text: "66.7%"
                                toText.text: "150%"
                                stepSize: 0.1
                                live: false
                                fontSizeMultiplier: ratioCalc * 1.2
                                //inputBoxWidth: sensitivitySliderContainer.width/8
                                inputBox.validator: DoubleValidator {
                                    top: sensitivitySlider.to
                                    bottom: sensitivitySlider.from
                                }

                                onUserSet: {
                                    platformInterface.light_sensitivity.update(value)
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
                                    id: gainboxLabel
                                    target: gainbox
                                    text: "<b>" + qsTr("Gain") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.verticalCenter: parent.verticalCenter
                                    SGComboBox {
                                        id:gainbox
                                        model: ["0.25", "1", "2", "8"]
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        onActivated: {
                                            platformInterface.light_gain.update(parseFloat(currentText))
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                SGAlignedLabel {
                                    id: timeboxLabel
                                    target: timebox
                                    text: "<b>" + qsTr("Integration Time") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    SGComboBox {
                                        id:timebox
                                        model: ["12.5ms", "100ms", "200ms", "Manual"]
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        onActivated: {
                                            platformInterface.light_integ_time.update(currentText)
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
                                    text: "<b>" + qsTr("Status") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.verticalCenter: parent.verticalCenter
                                    SGSwitch {
                                        id:activesw
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        checkedLabel: qsTr("Active")
                                        uncheckedLabel: qsTr("Sleep")
                                        onClicked: {
                                            if(checked) {
                                                platformInterface.light_status.update(true)
                                            }
                                            else {
                                                platformInterface.light_status.update(false)
                                            }
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
                                    text: "<b>" + qsTr("Manual Integration") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    SGSwitch {
                                        id:startsw
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        checkedLabel: qsTr("Start")
                                        uncheckedLabel: qsTr("Stop")
                                        onClicked: {
                                            platformInterface.light_manual_integ.update(checked)
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
            }

        }




        //            RowLayout {
        //                id: settingContainer
        //                width: parent.width/1.5
        //                height: parent.height
        //                anchors{
        //                    left: gaugeContainer.right
        //                    leftMargin: 20
        //                    verticalCenter: proximityContainer.verticalCenter

        //                }




        //                Rectangle {
        //                    Layout.fillHeight: true
        //                    Layout.fillWidth: true
        //                    color: "yellow"
        //                }
        //                    SGSlider{
        //                        id: sensitivitySlider
        //                        anchors{
        //                            verticalCenter: parent.verticalCenter
        //                            left: parent.left
        //                            leftMargin: 20

        //                        }
        //                        width: ratioCalc * 200
        //                        label: "<b> Sensitivity: </b>"
        //                        from: 66.7
        //                        to: 150
        //                        fontSize: 20 * ratioCalc

        //                    }


        //                    SGSubmitInfoBox {
        //                        id: setSpeed
        //                        infoBoxColor: "white"
        //                        buttonVisible: false
        //                        anchors {
        //                            verticalCenter: sensitivitySlider.verticalCenter
        //                            left: sensitivitySlider.right
        //                            leftMargin: 10
        //                        }

        //                        input: sensitivitySlider.value.toFixed(3)
        //                        infoBoxWidth: ratioCalc * 100
        //                        infoBoxHeight: ratioCalc * 30

        //                    }


        //            ColumnLayout {
        //                width: ratioCalc * 200
        //                height: ratioCalc * 200
        //                spacing: 30
        //                Layout.alignment: Qt.AlignVCenter

        //                SGSwitch{
        //                    id: mode
        //                    label: "Sleep/Active"
        //                    checkedLabel: "On"
        //                    uncheckedLabel: "Off"
        //                    switchWidth: ratioCalc * 55     // Default: 52 (change for long custom checkedLabels when labelsInside)
        //                    switchHeight: ratioCalc * 20               // Default: 26
        //                    textColor: "black"              // Default: "black"
        //                    handleColor: "white"            // Default: "white"
        //                    grooveColor: "#ccc"             // Default: "#ccc"
        //                    grooveFillColor: "#0cf"         // Default: "#0cf"
        //                    fontSize: ratioCalc * 20
        //                    Layout.alignment: Qt.AlignCenter
        //                    onToggled: {
        //                        if(checked){
        //                            if(manual.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                        }
        //                        else {
        //                            if(manual.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                        }
        //                    }
        //                }

        //                SGSwitch{
        //                    id: manual
        //                    label: "Start/Stop"
        //                    checkedLabel: "On"
        //                    uncheckedLabel: "Off"
        //                    switchWidth: ratioCalc * 55          // Default: 52 (change for long custom checkedLabels when labelsInside)
        //                    switchHeight: ratioCalc * 20               // Default: 26
        //                    textColor: "black"              // Default: "black"
        //                    handleColor: "white"            // Default: "white"
        //                    grooveColor: "#ccc"             // Default: "#ccc"
        //                    grooveFillColor: "#0cf"         // Default: "#0cf"
        //                    fontSize: ratioCalc * 20
        //                    Layout.alignment: Qt.AlignCenter
        //                    onToggled: {
        //                        if(checked){
        //                            if(mode.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                        }
        //                        else {
        //                            if(mode.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //            ColumnLayout {
        //                width: ratioCalc * 200
        //                height: ratioCalc * 200
        //                spacing: 30
        //                Layout.alignment: Qt.AlignVCenter
        //                SGComboBox {
        //                    id: integrationTime
        //                    Layout.alignment: Qt.AlignCenter
        //                    comboBoxWidth:ratioCalc * 100
        //                    comboBoxHeight: ratioCalc * 30
        //                    model: ["12.5ms", "12.5ms", "100ms", "200ms", "Manual"]
        //                    label: "Integration Time"
        //                    fontSize: 20 * ratioCalc
        //                    onActivated: {
        //                        if(manual.checked){
        //                            if(mode.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                        }
        //                        else {
        //                            if(mode.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                        }
        //                    }

        //                }
        //                SGComboBox {
        //                    id: gain
        //                    Layout.alignment: Qt.AlignCenter
        //                    comboBoxWidth:ratioCalc * 100
        //                    comboBoxHeight: ratioCalc * 30
        //                    model: ["0.25","0.25", "1", "2", "8"]
        //                    label: "Gain"
        //                    fontSize: 20 * ratioCalc
        //                    onActivated: {
        //                        if(manual.checked){
        //                            if(mode.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"start")
        //                            }
        //                        }
        //                        else {
        //                            if(mode.checked){
        //                                platformInterface.lv0104cs_setup_measurement.update("active",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                            else {
        //                                platformInterface.lv0104cs_setup_measurement.update("sleep",integrationTime.currentText, gain.currentText,"stop")
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        // } // end of rowLayout


    }
}
