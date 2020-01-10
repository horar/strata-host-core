import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0 as SGWidget10



Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    property var pwmArray: []



    //    property var change_remote_low_limit_state: platformInterface.nct72_remote_low_limit_state.state
    //    onChange_remote_low_limit_stateChanged: {
    //        if(change_remote_low_limit_state === "enabled"){
    //            lowlimitSlider.enabled = true
    //        }
    //        else if(change_remote_low_limit_state === "disabled"){
    //            lowlimitSlider.enabled = false
    //        }
    //        else {
    //            lowlimitSlider.enabled = false
    //            lowlimitSlider.opacity = 0.5
    //        }
    //    }

    //    property var remote_low_limit_scales: platformInterface.nct72_remote_low_limit.scales
    //    onRemote_low_limit_scalesChanged: {
    //        lowlimitSlider.endLabel = remote_low_limit_scales[0]
    //        lowlimitSlider.startLabel = remote_low_limit_scales[1]
    //        lowlimitSlider.from = remote_low_limit_scales[1]
    //        lowlimitSlider.to = remote_low_limit_scales[0]
    //        lowlimitSlider.stepSize  = remote_low_limit_scales[2]
    //        for(var i = 0; i < fractionComboBox1.model.length; ++i) {
    //            if(remote_low_limit_scales[2].toString() === fractionComboBox1.model[i]) {
    //                console.log("sakjd",parseInt(remote_low_limit_scales[2] ))
    //                fractionComboBox1.currentIndex = i
    //            }
    //        }

    //    }

    /*Notification:
      {"cmd":"nct72_range_value","payload":{"value":"0_127"}}
    */
    //Notification nct72_remote_high_limit_scales
    //    property var change_remote_high_limit_scales: platformInterface.nct72_remote_high_limit_scales.scales
    //    onChange_remote_high_limit_scalesChanged: {
    //        highlimitSlider.endLabel = change_remote_high_limit_scales[0]
    //        highlimitSlider.startLabel = change_remote_high_limit_scales[1]
    //        highlimitSlider.from = change_remote_high_limit_scales[1]
    //        highlimitSlider.to = change_remote_high_limit_scales[0]
    //        highlimitSlider.stepSize  = change_remote_high_limit_scales[2]
    //        for(var i = 0; i < fractionComboBox2.model.length; ++i) {
    //            if(change_remote_high_limit_scales[2].toString() === fractionComboBox2.model[i]) {
    //                fractionComboBox2.currentIndex = i
    //            }
    //        }

    //    }

    //    //Notification nct72_remote_low_limit_scales
    //    property var change_remote_low_limit_scales: platformInterface.nct72_remote_low_limit_scales.scales
    //    onChange_remote_low_limit_scalesChanged: {
    //        lowlimitSlider.endLabel = change_remote_low_limit_scales[0]
    //        lowlimitSlider.startLabel = change_remote_low_limit_scales[1]
    //        lowlimitSlider.from = change_remote_low_limit_scales[1]
    //        lowlimitSlider.to = change_remote_low_limit_scales[0]
    //        lowlimitSlider.stepSize = change_remote_low_limit_scales[2]
    //        for(var i = 0; i < fractionComboBox1.model.length; ++i) {
    //            if(change_remote_low_limit_scales[2].toString() === fractionComboBox1.model[i]) {
    //                fractionComboBox1.currentIndex = i

    //            }
    //        }
    //    }

    //Notification nct72_local_low_limit_scales
    property var change_local_low_limit_scales: platformInterface.nct72_local_low_limit_scales.scales
    onChange_local_low_limit_scalesChanged: {
        locallimitSlider.endLabel = change_local_low_limit_scales[0]
        locallimitSlider.startLabel = change_local_low_limit_scales[1]
        locallimitSlider.from = change_local_low_limit_scales[1]
        locallimitSlider.to = change_local_low_limit_scales[0]
        locallimitSlider.stepSize = change_local_low_limit_scales[2]
    }

    property var change_local_high_limit_scales: platformInterface.nct72_local_high_limit_scales.scales
    onChange_local_high_limit_scalesChanged: {
        localhighSlider.endLabel = change_local_high_limit_scales[0]
        localhighSlider.startLabel = change_local_high_limit_scales[1]
        localhighSlider.from = change_local_high_limit_scales[1]
        localhighSlider.to = change_local_high_limit_scales[0]
        localhighSlider.stepSize = change_local_high_limit_scales[2]
    }

    //control state alert therm2


    //    property var nct72_cons_alert_caption: platformInterface.nct72_cons_alert.caption
    //    onNct72_cons_alert_captionChanged: {
    //        consecutiveAlert.label = nct72_cons_alert_caption
    //    }

    //    property var change_nct72_cons_alert_caption: platformInterface.nct72_cons_alert_caption.caption
    //    onChange_nct72_cons_alert_captionChanged: {
    //        consecutiveAlert.label = change_nct72_cons_alert_caption
    //    }

    //    property var nct72_cons_alert_value: platformInterface.nct72_cons_alert.value
    //    onNct72_cons_alert_valueChanged: {
    //        for(var i = 0; i < consecutiveAlert.model.length; ++i) {
    //            if(nct72_cons_alert_value === consecutiveAlert.model[i]) {
    //                consecutiveAlert.currentIndex = i
    //            }
    //        }
    //    }

    //    property var change_nct72_cons_alert_value: platformInterface.nct72_cons_alert_value.value
    //    onChange_nct72_cons_alert_valueChanged: {
    //        for(var i = 0; i < consecutiveAlert.model.length; ++i) {
    //            if(change_nct72_cons_alert_value === consecutiveAlert.model[i]) {
    //                consecutiveAlert.currentIndex = i
    //            }
    //        }
    //    }

    //    property var nct72_cons_alert_state: platformInterface.nct72_cons_alert.state
    //    onNct72_cons_alert_stateChanged: {
    //        if(nct72_cons_alert_state === "enabled"){
    //            consecutiveAlert.enabled = true
    //        }
    //        else if(nct72_cons_alert_state === "disabled"){
    //            consecutiveAlert.enabled = false
    //        }
    //        else {
    //            consecutiveAlert.enabled = false
    //            consecutiveAlert.opacity = 0.5
    //        }
    //    }

    //    property var change_cons_alert_state: platformInterface.nct72_cons_alert_state.state
    //    onChange_cons_alert_stateChanged: {
    //        if(change_cons_alert_state === "enabled"){
    //            consecutiveAlert.enabled = true
    //        }
    //        else if(change_cons_alert_state === "disabled"){
    //            consecutiveAlert.enabled = false
    //        }
    //        else {
    //            consecutiveAlert.enabled = false
    //            consecutiveAlert.opacity = 0.5
    //        }
    //    }

    //    property var cons_alert_scales : platformInterface.nct72_cons_alert.values
    //    onCons_alert_scalesChanged: {
    //        consecutiveAlert.model = cons_alert_scales
    //    }

    //    property var change_cons_alert_scales: platformInterface.nct72_cons_alert_values.values
    //    onChange_cons_alert_scalesChanged: {
    //        consecutiveAlert.model = change_cons_alert_scales
    //    }

    Rectangle {
        id: temperatureContainer
        width: parent.width - 60
        height:  parent.height - 20
        color: "yellow"//"transparent"

        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }


        Rectangle {
            id: topContainer
            width: parent.width
            height: parent.height/2
            color: "transparent"
            anchors.top: parent.top

            ColumnLayout {
                id: leftContainer
                width: parent.width/4
                height:  parent.height - 50
                spacing: 20
                Rectangle {
                    id: gaugeContainer1
                    Layout.preferredHeight: parent.height/1.5
                    Layout.fillWidth: true
                    color: "transparent"
                    SGWidget10.SGAlignedLabel {
                        id: boardTempLabel
                        target: remotetempGauge
                        font.bold: true
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGWidget10.SGAlignedLabel.SideBottomCenter
                        Layout.alignment: Qt.AlignCenter

                        anchors.fill:parent
                        SGWidget10.SGCircularGauge{
                            id:remotetempGauge
                            height: 200 * ratioCalc
                            width: 200 * ratioCalc
                            unitTextFontSizeMultiplier: ratioCalc * 2.0
                            tickmarkStepSize: 20
                            unitText: "°c"
                            valueDecimalPlaces: 2
                            anchors.centerIn: parent


                            property var temp_remote_caption: platformInterface.temp_remote_caption.caption
                            onTemp_remote_captionChanged: {
                                boardTempLabel.text = temp_remote_caption
                            }

                            property var temp_remote_value: platformInterface.temp_remote_value.value
                            onTemp_remote_valueChanged: {
                                remotetempGauge.value = temp_remote_value
                            }


                            property var temp_remote_state: platformInterface.temp_remote_state.state
                            onTemp_remote_stateChanged: {
                                if(temp_remote_state === "enabled"){
                                    remotetempGauge.enabled = true
                                    remotetempGauge.opacity = 1.0
                                }
                                else if (temp_remote_state === "disabled"){
                                    remotetempGauge.enabled = false
                                    remotetempGauge.opacity = 1.0

                                }
                                else {
                                    remotetempGauge.opacity = 0.5
                                    remotetempGauge.enabled = false
                                }
                            }

                            property var temp_remote_scales: platformInterface.temp_remote_scales.scales
                            onTemp_remote_scalesChanged: {
                                remotetempGauge.maximumValue = parseInt(temp_remote_scales[0])
                                remotetempGauge.minimumValue = parseInt(temp_remote_scales[1])
                            }

                        }
                    }
                }
                Rectangle {
                    id: pwmDutyCycle1Container
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGWidget10.SGAlignedLabel {
                        id: pwmDutyCycle1Label
                        target: pwmDutyCycle1
                        alignment:  SGWidget10.SGAlignedLabel.SideTopLeft
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc
                        font.bold : true
                        SGWidget10.SGComboBox {
                            id: pwmDutyCycle1
                            fontSizeMultiplier: ratioCalc * 0.9
                            onActivated: {
                                platformInterface.set_temp_pwm_remote.update(currentText)

                            }

                            property var temp_pwm_remote_values: platformInterface.temp_pwm_remote_values.values
                            onTemp_pwm_remote_valuesChanged: {
                                pwmDutyCycle1.model = temp_pwm_remote_values
                            }
                            property var temp_pwm_remote_value: platformInterface.temp_pwm_remote_value.value
                            onTemp_pwm_remote_valueChanged: {
                                for(var i = 0; i < pwmDutyCycle1.model.length; ++i ){
                                    if( pwmDutyCycle1.model[i].toString() === temp_pwm_remote_value)
                                    {
                                        currentIndex = i
                                        return;
                                    }
                                }
                            }

                            property var temp_pwm_remote_caption: platformInterface.temp_pwm_remote_caption
                            onTemp_pwm_remote_captionChanged: {
                                pwmDutyCycle1Label.text = temp_pwm_remote_caption.caption
                            }

                            property var temp_pwm_remote_state: platformInterface.temp_pwm_remote_state.state
                            onTemp_pwm_remote_stateChanged: {
                                if(temp_pwm_remote_state === "enabled"){
                                    pwmDutyCycle1Container.enabled = true
                                    pwmDutyCycle1Container.opacity = 1.0
                                }
                                else if (temp_pwm_remote_state === "disabled"){
                                    pwmDutyCycle1Container.enabled = false
                                    pwmDutyCycle1Container.opacity = 1.0

                                }
                                else {
                                    pwmDutyCycle1Container.opacity = 0.5
                                    pwmDutyCycle1Container.enabled = false
                                }
                            }
                        }
                    }
                }
            }
            Rectangle{
                id: middleContainer
                width: parent.width/2
                height:  parent.height
                color: "transparent"
                anchors {
                    left: leftContainer.right
                }
                ColumnLayout {
                    id: middleSetting
                    anchors.fill: parent

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        RowLayout{
                            anchors.fill: parent
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGButton {
                                    id:  oneShot
                                    anchors.verticalCenter: parent.verticalCenter
                                    fontSizeMultiplier: ratioCalc
                                    color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                    hoverEnabled: true
                                    anchors.centerIn: parent
                                    MouseArea {
                                        hoverEnabled: true
                                        anchors.fill: parent
                                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            platformInterface.one_shot.update()
                                        }

                                    }
                                    property var temp_one_shot_caption: platformInterface.temp_one_shot_caption.caption
                                    onTemp_one_shot_captionChanged: {
                                        oneShot.text = temp_one_shot_caption
                                    }

                                    property var temp_one_shot_state: platformInterface.temp_one_shot_state.state
                                    onTemp_one_shot_stateChanged: {
                                        if(temp_one_shot_state === "enabled"){
                                            oneShot.enabled = true
                                            oneShot.opacity = 1.0
                                        }
                                        else if (temp_one_shot_state === "disabled"){
                                            oneShot.enabled = false
                                            oneShot.opacity = 1.0

                                        }
                                        else {
                                            oneShot.opacity = 0.5
                                            oneShot.enabled = false
                                        }
                                    }

                                }
                            }




                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel {
                                    id: busyLEDLabel
                                    target: busyLED
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc
                                    alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    SGWidget10.SGStatusLight{
                                        id: busyLED
                                        width: 30
                                    }
                                    property var nct72_busy_value: platformInterface.temp_busy_value.value
                                    onNct72_busy_valueChanged: {
                                        if(nct72_busy_value === "0")
                                            busyLED.status = SGWidget10.SGStatusLight.Off
                                        else busyLED.status = SGWidget10.SGStatusLight.Red
                                    }

                                    property var nct72_busy_caption: platformInterface.temp_busy_caption.caption
                                    onNct72_busy_captionChanged: {
                                        busyLEDLabel.text = nct72_busy_caption
                                    }

                                    property var nct72_busy_state: platformInterface.temp_busy_state.state
                                    onNct72_busy_stateChanged: {
                                        if(nct72_busy_state === "enabled"){
                                            busyLED.enabled = true
                                            busyLED.opacity = 1.0
                                        }
                                        else if (nct72_busy_state === "disabled"){
                                            busyLED.enabled = false
                                            busyLED.opacity = 1.0

                                        }
                                        else {
                                            busyLED.opacity = 0.5
                                            busyLED.enabled = false
                                        }
                                    }
                                }
                            }


                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel {
                                    id: thermLEDLabel
                                    target: thermLED
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc
                                    alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    SGWidget10.SGStatusLight{
                                        id: thermLED
                                        width: 30
                                    }

                                    property var nct72_therm_value: platformInterface.temp_therm_value.value
                                    onNct72_therm_valueChanged: {
                                        if(nct72_therm_value === "0")
                                            thermLED.status = SGWidget10.SGStatusLight.Off
                                        else thermLED.status = SGWidget10.SGStatusLight.Red
                                    }

                                    property var nct72_therm_caption: platformInterface.temp_therm_caption.caption
                                    onNct72_therm_captionChanged: {
                                        thermLEDLabel.text = "THERM"
                                    }

                                    property var nct72_therm_state: platformInterface.temp_therm_state.state
                                    onNct72_therm_stateChanged: {
                                        if(nct72_therm_state === "enabled"){
                                            thermLED.enabled = true
                                            thermLED.opacity = 1.0
                                        }
                                        else if (nct72_therm_state === "disabled"){
                                            thermLED.enabled = false
                                            thermLED.opacity = 1.0

                                        }
                                        else {
                                            thermLED.opacity = 0.5
                                            thermLED.enabled = false
                                        }
                                    }
                                }
                            }


                            Rectangle{
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel {
                                    id: alertAndThermLabel
                                    target: alertAndTherm
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc
                                    alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent

                                    SGWidget10.SGStatusLight{
                                        id: alertAndTherm
                                        width: 30
                                    }


                                    property var alert_therm2_caption: platformInterface.temp_alert_therm2_caption.caption
                                    onAlert_therm2_captionChanged: {
                                        alertAndThermLabel.text = alert_therm2_caption
                                    }

                                    property var alert_therm2_state: platformInterface.temp_alert_therm2_state.state
                                    onAlert_therm2_stateChanged: {
                                        if(alert_therm2_state === "enabled"){
                                            alertAndTherm.enabled = true
                                        }
                                        else if(alert_therm2_state === "disabled"){
                                            alertAndTherm.enabled = false
                                        }
                                        else {
                                            alertAndTherm.enabled = false
                                            alertAndTherm.opacity = 0.5
                                        }
                                    }
                                    property var nct72_alert_therm2_value: platformInterface.temp_alert_therm2_value.value
                                    onNct72_alert_therm2_valueChanged: {
                                        if(nct72_alert_therm2_value === 1)
                                            alertAndTherm.status = SGWidget10.SGStatusLight.Red

                                        alertAndTherm.status = SGWidget10.SGStatusLight.Off
                                    }



                                }
                            }

                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout{
                            anchors.fill:parent
                            Rectangle {
                                id: modeContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel{
                                    id: modeLabel
                                    target: modeRadioButtons
                                    anchors.centerIn: parent
                                    font.bold: true
                                    SGWidget10.SGRadioButtonContainer {
                                        id: modeRadioButtons
                                        columns: 1

                                        SGWidget10.SGRadioButton {
                                            id: run
                                            text: "Run"
                                            checked: true
                                            onCheckedChanged: {
                                                if(checked)
                                                    platformInterface.set_mode_value.update("Run")
                                                else
                                                    platformInterface.set_mode_value.update("Standby")

                                            }
                                        }

                                        SGWidget10. SGRadioButton {
                                            id: standby
                                            text: "Standby"
                                            onCheckedChanged: {
                                                !run.checked
                                            }

                                        }
                                    }
                                    property var temp_mode_caption: platformInterface.temp_mode_caption.caption
                                    onTemp_mode_captionChanged: {
                                        modeLabel.text = temp_mode_caption
                                    }

                                    property var temp_mode_value: platformInterface.temp_mode_value.value
                                    onTemp_mode_valueChanged: {
                                        if(temp_mode_value === "Run")
                                            run.checked = true
                                        else standby.checked = true
                                    }


                                    property var temp_mode_state: platformInterface.temp_mode_state.state
                                    onTemp_mode_stateChanged: {
                                        if(temp_mode_state === "enabled"){
                                            modeContainer.enabled = true
                                            modeContainer.opacity = 1.0
                                        }
                                        else if (temp_mode_state === "disabled"){
                                            modeContainer.enabled = false
                                            modeContainer.opacity = 1.0

                                        }
                                        else {
                                            modeContainer.opacity = 0.5
                                            modeContainer.enabled = false
                                        }
                                    }

                                }
                            }
                            Rectangle {
                                id:alertContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel{
                                    id: alertLabel
                                    target: alertRadioButtons
                                    font.bold: true
                                    anchors.centerIn: parent
                                    SGWidget10.SGRadioButtonContainer {
                                        id: alertRadioButtons
                                        columns: 1

                                        SGWidget10.SGRadioButton {
                                            id: alert1
                                            text: "Enabled"
                                            checked: true
                                            onCheckedChanged: {
                                                if(checked)
                                                    platformInterface.set_temp_alert.update("Enabled")
                                                else platformInterface.set_temp_alert.update("Masked")
                                            }
                                        }

                                        SGWidget10. SGRadioButton {
                                            id: alert2
                                            text: "Masked"
                                            onCheckedChanged: {
                                                !alert1.checked
                                            }

                                        }
                                    }
                                    property var temp_alert_caption: platformInterface.temp_alert_caption.caption
                                    onTemp_alert_captionChanged: {
                                        alertLabel.text = temp_alert_caption
                                    }

                                    property var temp_alert_state: platformInterface.temp_alert_state.state
                                    onTemp_alert_stateChanged: {
                                        if(temp_alert_state === "enabled"){
                                            alertContainer.enabled = true
                                            alertContainer.opacity = 1.0
                                        }
                                        else if (temp_alert_state === "disabled"){
                                            alertContainer.enabled = false
                                            alertContainer.opacity = 1.0
                                        }
                                        else {
                                            alertButton.opacity = 0.5
                                            alertButton.enabled = false
                                        }
                                    }


                                    property var temp_alert_value: platformInterface.temp_alert_value.value
                                    onTemp_alert_valueChanged: {
                                        if(temp_alert_value === "Enabled")
                                            alert1.checked = true
                                        else alert2.checked = true
                                    }
                                }

                            }

                            Rectangle {
                                id: pin6Container
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel{
                                    id: pinLabel
                                    target: pinButtons
                                    font.bold: true
                                    anchors.centerIn: parent
                                    SGWidget10.SGRadioButtonContainer {
                                        id: pinButtons
                                        columns: 1

                                        SGWidget10.SGRadioButton {
                                            id: pin1
                                            text: "ALERT#"
                                            checked: true
                                            onCheckedChanged: {
                                                if(checked)
                                                    platformInterface.set_alert_therm2_pin6.update("ALERT#")
                                                else platformInterface.set_alert_therm2_pin6.update("THERM2#")
                                            }
                                        }

                                        SGWidget10. SGRadioButton {
                                            id: pin2
                                            text: "THERM2"
                                            onCheckedChanged: {
                                                !alert1.checked
                                            }

                                        }
                                    }
                                    property var temp_pin6_caption: platformInterface.temp_pin6_caption.caption
                                    onTemp_pin6_captionChanged: {
                                        pinLabel.text = temp_pin6_caption
                                    }

                                    property var temp_pin6_state: platformInterface.temp_pin6_state.state
                                    onTemp_pin6_stateChanged: {
                                        if(temp_pin6_state === "enabled"){
                                            pin6Container.enabled = true
                                            pin6Container.opacity = 1.0
                                        }
                                        else if (temp_pin6_state === "disabled"){
                                            pin6Container.enabled = false
                                            pin6Container.opacity = 1.0

                                        }
                                        else {
                                            pin6Container.opacity = 0.5
                                            pin6Container.enabled = false
                                        }
                                    }

                                    property var temp_pin6_value: platformInterface.temp_pin6_value.value
                                    onTemp_pin6_valueChanged: {
                                        if(temp_pin6_value === "ALERT#")
                                            pin1.checked = true
                                        else pin2.checked = true
                                    }
                                }

                            }
                            Rectangle {
                                id: rangeContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel{
                                    id: rangeLabel
                                    target: rangeButtons
                                    font.bold: true
                                    anchors.centerIn: parent
                                    SGWidget10.SGRadioButtonContainer {
                                        id: rangeButtons
                                        columns: 1

                                        SGWidget10.SGRadioButton {
                                            id: range1
                                            text: "0 to 127˚c "
                                            checked: true
                                            onCheckedChanged: {
                                                if(checked)
                                                    platformInterface.set_range_value.update("0_127")
                                                else platformInterface.set_range_value.update("-64_191")
                                            }
                                        }

                                        SGWidget10. SGRadioButton {
                                            id: range2
                                            text: "-64 to 191˚c "
                                            onCheckedChanged: {
                                                !alert1.checked
                                            }

                                        }
                                    }
                                    property var temp_range_caption: platformInterface.temp_range_caption.caption

                                    onTemp_range_captionChanged: {
                                        rangeLabel.text = temp_range_caption
                                    }

                                    property var temp_range_value: platformInterface.temp_range_value.value
                                    onTemp_range_valueChanged: {
                                        if(temp_range_value === "0_127")
                                            range1.checked = true
                                        else range2.checked = true
                                    }

                                    property var temp_range_state: platformInterface.temp_range_state.state
                                    onTemp_range_stateChanged: {
                                        if(temp_range_state === "enabled"){
                                            rangeContainer.enabled = true
                                            rangeContainer.opacity = 1.0
                                        }
                                        else if (temp_range_state === "disabled"){
                                            rangeContainer.enabled = false
                                            rangeContainer.opacity = 1.0
                                        }
                                        else {
                                            rangeContainer.opacity = 0.5
                                            rangeContainer.enabled = false
                                        }
                                    }

                                }
                            }
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RowLayout{
                            anchors.fill: parent

                            Rectangle{
                                id: conAlertContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGWidget10.SGAlignedLabel {
                                    id: conAlertsLabel
                                    target: conAlerts
                                    alignment:  SGWidget10.SGAlignedLabel.SideTopLeft
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc
                                    font.bold : true
                                    SGWidget10.SGComboBox {
                                        id: conAlerts
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        onActivated: {
                                            platformInterface.set_temp_cons_alert.update(currentText)
                                        }
                                    }

                                    property var temp_cons_alert_state: platformInterface.temp_cons_alert_state.state
                                    onTemp_cons_alert_stateChanged: {
                                        if(temp_cons_alert_state === "enabled"){
                                            conAlertContainer.enabled = true
                                        }
                                        else if(temp_cons_alert_state === "disabled"){
                                            conAlertContainer.enabled = false
                                        }
                                        else {
                                            conAlertContainer.enabled = false
                                            conAlertContainer.opacity = 0.5
                                        }
                                    }

                                    property var temp_cons_alert_values : platformInterface.temp_cons_alert_values.values
                                    onTemp_cons_alert_valuesChanged: {
                                        conAlerts.model = temp_cons_alert_values
                                    }

                                    property var temp_cons_alert_value: platformInterface.temp_cons_alert_value.value
                                    onTemp_cons_alert_valueChanged: {
                                        for(var i = 0; i < conAlerts.model.length; ++i) {
                                            if(temp_cons_alert_value === conAlerts.model[i].toString()) {
                                                conAlerts.currentIndex = i
                                            }
                                        }
                                    }
                                    property var temp_cons_alert_caption: platformInterface.temp_cons_alert_caption.caption
                                    onTemp_cons_alert_captionChanged: {
                                        conAlertsLabel.text = temp_cons_alert_caption
                                    }
                                }
                            }
                            Rectangle {
                                id:conIntervalContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                SGWidget10.SGAlignedLabel {
                                    id: conIntervalsLabel
                                    target: conInterval
                                    alignment:  SGWidget10.SGAlignedLabel.SideTopLeft
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc
                                    font.bold : true
                                    SGWidget10.SGComboBox {
                                        id: conInterval
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        onActivated: {
                                            platformInterface.set_temp_conv_rate.update(currentText)
                                        }
                                    }
                                }
                                property var temp_cons_alert_state: platformInterface.temp_cons_alert_state.state
                                onTemp_cons_alert_stateChanged: {
                                    if(temp_cons_alert_state === "enabled"){
                                        conIntervalContainer.enabled = true
                                    }
                                    else if(temp_cons_alert_state === "disabled"){
                                        conIntervalContainer.enabled = false
                                    }
                                    else {
                                        conIntervalContainer.enabled = false
                                        conIntervalContainer.opacity = 0.5
                                    }
                                }

                                property var temp_conv_rate_values : platformInterface.temp_conv_rate_values.values
                                onTemp_conv_rate_valuesChanged: {
                                    conInterval.model = temp_conv_rate_values
                                }

                                property var temp_conv_rate_value: platformInterface.temp_conv_rate_value.value
                                onTemp_conv_rate_valueChanged: {
                                    for(var i = 0; i < conInterval.model.length; ++i) {
                                        if(temp_conv_rate_value === conInterval.model[i].toString()) {
                                            conInterval.currentIndex = i
                                        }
                                    }
                                }
                                property var temp_conv_rate_caption: platformInterface.temp_conv_rate_caption.caption
                                onTemp_conv_rate_captionChanged: {
                                    conIntervalsLabel.text = temp_conv_rate_caption
                                }

                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout {
                            anchors.fill:parent
                            Rectangle {
                                id: manufactorIdContainer
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGWidget10.SGAlignedLabel {
                                    id: manufactorIdLabel
                                    target: manufactorId
                                    font.bold: true
                                    alignment: SGWidget10.SGAlignedLabel.SideTopLeft
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.3
                                    SGWidget10.SGInfoBox {
                                        id: manufactorId
                                        height:  35 * ratioCalc
                                        width: 140 * ratioCalc
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.3
                                        boxFont.family: Fonts.digitalseven
                                        unitFont.bold: true
                                    }
                                    property var temp_man_id_caption: platformInterface.temp_man_id_caption.caption
                                    onTemp_man_id_captionChanged: {
                                        manufactorIdLabel.text = temp_man_id_caption
                                    }
                                    property var temp_man_id_value: platformInterface.temp_man_id_value.value
                                    onTemp_man_id_valueChanged: {
                                        manufactorId.text = temp_man_id_value
                                    }
                                    property var temp_man_id_state: platformInterface.temp_man_id_state.state
                                    onTemp_man_id_stateChanged: {
                                        if(temp_man_id_state === "enabled"){
                                            manufactorIdContainer.enabled = true
                                            manufactorIdContainer.opacity = 1.0
                                        }
                                        else if (temp_man_id_state === "disabled"){
                                            manufactorIdContainer.enabled = false
                                            manufactorIdContainer.opacity = 1.0

                                        }
                                        else {
                                            manufactorIdContainer.opacity = 0.5
                                            manufactorIdContainer.enabled = false
                                        }
                                    }
                                }

                            }

                            Rectangle {
                                id: thermHysContainer
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                SGWidget10.SGAlignedLabel {
                                    id: thermHysLabel
                                    target: thermHys
                                    fontSizeMultiplier: ratioCalc
                                    font.bold : true
                                    alignment: SGWidget10.SGAlignedLabel.SideTopLeft
                                    anchors.centerIn: parent

                                    SGWidget10.SGSlider {
                                        id: thermHys
                                        width: thermHysContainer.width - 10
                                        live: false
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        inputBox.validator: DoubleValidator {
                                            top: thermHys.to
                                            bottom: thermHys.from
                                        }
                                        onUserSet: {
                                            platformInterface.set_therm_hyst_value.update(value)
                                        }
                                    }
                                }
                                property var temp_therm_hyst_caption: platformInterface.temp_therm_hyst_caption.caption
                                onTemp_therm_hyst_captionChanged: {
                                    thermHysLabel.text = temp_therm_hyst_caption
                                }
                                property var temp_therm_hyst_value: platformInterface.temp_therm_hyst_value.value
                                onTemp_therm_hyst_valueChanged: {
                                    thermHys.value = temp_therm_hyst_value
                                }
                                property var temp_therm_hyst_scales: platformInterface.temp_therm_hyst_scales.scales
                                onTemp_therm_hyst_scalesChanged: {
                                    thermHys.to.toText = temp_therm_hyst_scales[0] + "˚c"
                                    thermHys.from.fromText = temp_therm_hyst_scales[1] + "˚c"
                                    thermHys.from = temp_therm_hyst_scales[1]
                                    thermHys.to = temp_therm_hyst_scales[0]
                                    thermHys.stepSize = temp_therm_hyst_scales[2]
                                }


                                property var temp_therm_hyst_state: platformInterface.temp_therm_hyst_state.state
                                onTemp_therm_hyst_stateChanged: {
                                    if(temp_therm_hyst_state === "enabled"){
                                        thermHysContainer.enabled = true
                                        thermHysContainer.opacity = 1.0
                                    }
                                    else if (temp_therm_hyst_state === "disabled"){
                                        thermHysContainer.enabled = false
                                        thermHysContainer.opacity = 1.0

                                    }
                                    else {
                                        thermHysContainer.opacity = 0.5
                                        thermHysContainer.enabled = false
                                    }
                                }

                            }

                        }
                    }
                } // end of cloumn
            }

            ColumnLayout {
                id: rightContainer
                width: parent.width/4
                height:  parent.height - 50
                spacing: 20
                anchors.left: middleContainer.right

                Rectangle {
                    id: gauageContainer2
                    Layout.preferredHeight: parent.height/1.5
                    Layout.fillWidth: true

                    SGWidget10.SGAlignedLabel {
                        id: localTempLabel
                        target: localTempGauge
                        font.bold: true
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGWidget10.SGAlignedLabel.SideBottomCenter
                        Layout.alignment: Qt.AlignCenter

                        anchors.fill:parent
                        SGWidget10.SGCircularGauge{
                            id: localTempGauge
                            height: 200 * ratioCalc
                            width: 200 * ratioCalc
                            unitTextFontSizeMultiplier: ratioCalc * 2.0
                            tickmarkStepSize: 20
                            unitText: "°c"
                            valueDecimalPlaces: 0
                            anchors.centerIn: parent

                            property var temp_local_value: platformInterface.temp_local_value.value
                            onTemp_local_valueChanged: {
                                localTempGauge.value = temp_local_value
                            }

                            property var temp_local_caption: platformInterface.temp_local_caption.caption
                            onTemp_local_captionChanged: {
                                localTempLabel.text = temp_local_caption
                            }



                            property var temp_local_state: platformInterface.temp_local_state.state
                            onTemp_local_stateChanged: {
                                if(temp_local_state === "enabled"){
                                    gauageContainer2.enabled = true
                                    gauageContainer2.opacity = 1.0
                                }
                                else if (temp_local_state === "disabled"){
                                    gauageContainer2.enabled = false
                                    gauageContainer2.opacity = 1.0

                                }
                                else {
                                    gauageContainer2.opacity = 0.5
                                    gauageContainer2.enabled = false
                                }
                            }

                            property var temp_local_scales: platformInterface.temp_local_scales.scales
                            onTemp_local_scalesChanged: {
                                localTempGauge.maximumValue = temp_local_scales[0]
                                localTempGauge.minimumValue = temp_local_scales[1]
                            }
                        }

                    }
                }
                Rectangle {
                    id: pwmDutyCycle2Container
                    Layout.fillHeight: true
                    Layout.fillWidth: true


                    SGWidget10.SGAlignedLabel {
                        id: pwmDutyCycle2Label
                        target: pwmDutyCycle2
                        alignment:  SGWidget10.SGAlignedLabel.SideTopLeft
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc
                        font.bold : true
                        SGWidget10.SGComboBox {
                            id: pwmDutyCycle2
                            fontSizeMultiplier: ratioCalc * 0.9
                            onActivated: {
                                platformInterface.set_pwm_temp_local_value.update(currentText)

                            }

                            property var temp_pwm_local_values: platformInterface.temp_pwm_local_values.values
                            onTemp_pwm_local_valuesChanged: {
                                pwmDutyCycle2.model = temp_pwm_local_values
                            }
                            property var temp_pwm_local_value: platformInterface.temp_pwm_local_value.value
                            onTemp_pwm_local_valueChanged: {
                                for(var i = 0; i < pwmDutyCycle2.model.length; ++i ){
                                    if( pwmDutyCycle2.model[i].toString() === temp_pwm_local_value)
                                    {
                                        currentIndex = i
                                        return;
                                    }
                                }
                            }

                            property var temp_pwm_local_caption: platformInterface.temp_pwm_local_caption
                            onTemp_pwm_local_captionChanged: {
                                pwmDutyCycle2Label.text = temp_pwm_local_caption.caption
                            }

                            property var temp_pwm_local_state: platformInterface.temp_pwm_local_state.state
                            onTemp_pwm_local_stateChanged: {
                                if(temp_pwm_local_state === "enabled"){
                                    pwmDutyCycle2Container.enabled = true
                                    pwmDutyCycle2Container.opacity = 1.0
                                }
                                else if (temp_pwm_local_state === "disabled"){
                                    pwmDutyCycle2Container.enabled = false
                                    pwmDutyCycle2Container.opacity = 1.0

                                }
                                else {
                                    pwmDutyCycle2Container.opacity = 0.5
                                    pwmDutyCycle2Container.enabled = false
                                }
                            }
                        }
                    }
                }
            }
        } //top setting

        Rectangle {
            id: remoteSetting
            width: parent.width/2.5
            height: parent.height - topContainer.height
            color: "transparent"
            anchors {
                left: parent.left
                top: topContainer.bottom
                leftMargin: 10
            }
            ColumnLayout {
                id: setting
                anchors.fill: parent
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    RowLayout{
                        anchors.fill: parent


                        Rectangle {
                            id: rthrmContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGWidget10.SGAlignedLabel {
                                id: rthrmLabel
                                target: rthrm
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGWidget10.SGStatusLight{
                                    id: rthrm
                                    width: 30
                                }
                                property var temp_rthrm_caption: platformInterface.temp_rthrm_caption.caption
                                onTemp_rthrm_captionChanged: {
                                    rthrmLabel.text = temp_rthrm_caption
                                }

                                property var temp_rthrm_value: platformInterface.temp_rthrm_value.value
                                onTemp_rthrm_valueChanged: {
                                    if(temp_rthrm_value === "0") {
                                        rthrm.status = SGWidget10.SGStatusLight.Red
                                    }
                                    else  rthrm.status = SGWidget10.SGStatusLight.Green
                                }

                                property var temp_rthrml_state: platformInterface.temp_rthrml_state.state
                                onTemp_rthrml_stateChanged: {
                                    if(temp_rthrml_state === "enabled"){
                                        rthrmContainer.enabled = true
                                        rthrmContainer.opacity = 1.0
                                    }
                                    else if (temp_rthrml_state === "disabled"){
                                        rthrmContainer.enabled = false
                                        rthrmContainer.opacity = 1.0

                                    }
                                    else {
                                        rthrmContainer.opacity = 0.5
                                        rthrm.enabled = false
                                    }
                                }
                            }
                        }




                        Rectangle {
                            id: rlowContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGWidget10.SGAlignedLabel {
                                id: rlowLabel
                                target: rlow
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGWidget10.SGStatusLight{
                                    id: rlow
                                    width: 30
                                }
                            }
                            property var temp_rlow_caption: platformInterface.temp_rlow_caption.caption
                            onTemp_rlow_captionChanged: {
                                rlowLabel.text = temp_rlow_caption
                            }

                            property var temp_rlow_value: platformInterface.temp_rlow_value.value
                            onTemp_rlow_valueChanged: {
                                if(temp_rlow_value ==="0") {
                                    rlow.status = SGWidget10.SGStatusLight.Red
                                }
                                else  rlow.status = SGWidget10.SGStatusLight.Green
                            }

                            property var temp_rlow_state: platformInterface.temp_rlow_state.state
                            onTemp_rlow_stateChanged: {
                                if(temp_rlow_state === "enabled"){
                                    rlowContainer.enabled = true
                                    rlowContainer.opacity = 1.0
                                }
                                else if (temp_rlow_state === "disabled"){
                                    rlowContainer.enabled = false
                                    rlowContainer.opacity = 1.0
                                }
                                else {
                                    rlowContainer.opacity = 0.5
                                    rlowContainer.enabled = false
                                }
                            }
                        }




                        Rectangle {
                            id: rhighContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGWidget10.SGAlignedLabel {
                                id: rhighLabel
                                target: rhigh
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGWidget10.SGStatusLight{
                                    id: rhigh
                                    width: 30
                                }
                            }
                            property var temp_rhigh_caption: platformInterface.temp_rhigh_caption.caption
                            onTemp_rhigh_captionChanged: {
                                rhighLabel.text = temp_rhigh_caption
                            }

                            property var temp_rhigh_value: platformInterface.temp_rhigh_value.value
                            onTemp_rhigh_valueChanged: {
                                if(temp_rhigh_value === "0") {
                                    rhigh.status = SGWidget10.SGStatusLight.Red
                                }
                                else  rhigh.status = SGWidget10.SGStatusLight.Green
                            }

                            property var temp_rhigh_state: platformInterface.temp_rhigh_state.state
                            onTemp_rhigh_stateChanged: {
                                if(temp_rhigh_state === "enabled"){
                                    rhighContainer.enabled = true
                                    rhighContainer.opacity = 1.0
                                }
                                else if (temp_rhigh_state === "disabled"){
                                    rhighContainer.enabled = false
                                    rhighContainer.opacity = 1.0
                                }
                                else {
                                    rhighContainer.opacity = 0.5
                                    rhighContainer.enabled = false
                                }
                            }
                        }







                        Rectangle {
                            id: openContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGWidget10.SGAlignedLabel {
                                id: openLabel
                                target: open
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGWidget10.SGStatusLight{
                                    id: open
                                    width: 30
                                }
                                property var temp_open_caption: platformInterface.temp_open_caption.caption
                                onTemp_open_captionChanged: {
                                    openLabel.text = temp_open_caption
                                }

                                property var temp_open_value: platformInterface.temp_open_value.value
                                onTemp_open_valueChanged: {
                                    if(temp_open_value === "0") {
                                        open.status = SGWidget10.SGStatusLight.Red
                                    }
                                    else  open.status = SGWidget10.SGStatusLight.Green
                                }

                                property var temp_open_state: platformInterface.temp_open_state.state
                                onTemp_open_stateChanged: {
                                    if(temp_open_state === "enabled"){
                                        openContainer.enabled = true
                                        openContainer.opacity = 1.0
                                    }
                                    else if (temp_open_state === "disabled"){
                                        openContainer.enabled = false
                                        openContainer.opacity = 1.0
                                    }
                                    else {
                                        openContainer.opacity = 0.5
                                        openContainer.enabled = false
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    RowLayout{
                        anchors.fill: parent

                        Rectangle {
                            id:lowlimitContainer
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/1.4

                            SGWidget10.SGAlignedLabel {
                                id: lowlimitLabel
                                target: lowlimit
                                fontSizeMultiplier: ratioCalc
                                font.bold : true
                                alignment: SGWidget10.SGAlignedLabel.SideTopLeft
                                anchors.centerIn: parent


                                SGWidget10.SGSlider {
                                    id: lowlimit
                                    width: lowlimitContainer.width - 10
                                    live: false
                                    fontSizeMultiplier: ratioCalc * 0.8
                                    showInputBox: true
                                    showToolTip:true
                                    inputBox.validator: DoubleValidator {
                                        top: lowlimit.to
                                        bottom: lowlimit.from
                                    }
                                    onUserSet: {
                                        platformInterface.set_temp_remote_low_lim.update(value)
                                    }
                                }
                            }
                            property var temp_remote_low_lim_caption: platformInterface.temp_remote_low_lim_caption.caption
                            onTemp_remote_low_lim_captionChanged: {
                                lowlimitLabel.text = temp_remote_low_lim_caption
                            }

                            property var temp_remote_low_lim_value: platformInterface.temp_remote_low_lim_value.value
                            onTemp_remote_low_lim_valueChanged: {
                                lowlimit.value = temp_remote_low_lim_value
                            }

                            property var temp_remote_low_lim_state: platformInterface.temp_remote_low_lim_state.state
                            onTemp_remote_low_lim_stateChanged: {
                                if(temp_remote_low_lim_state === "enabled"){
                                    lowlimitContainer.enabled = true
                                }
                                else if(temp_remote_low_lim_state === "disabled"){
                                    lowlimitContainer.enabled = false
                                }
                                else {
                                    lowlimitContainer.enabled = false
                                    lowlimitContainer.opacity = 0.5
                                }
                            }

                            property var temp_remote_low_lim_scales: platformInterface.temp_remote_low_lim_scales.scales
                            onTemp_remote_low_lim_scalesChanged: {
                                lowlimit.toText.text = temp_remote_low_lim_scales[0] + "˚c"
                                lowlimit.fromText.text = temp_remote_low_lim_scales[1] + "˚c"
                                lowlimit.from = temp_remote_low_lim_scales[1]
                                lowlimit.to = temp_remote_low_lim_scales[0]
                                lowlimit.stepSize = temp_remote_low_lim_scales[2]
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true


                            SGWidget10.SGComboBox {
                                id: fractionComboBox1
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9

                                onActivated: {
                                    platformInterface.set_temp_remote_low_lim_frac.update(currentText)
                                }

                                property var temp_remote_low_lim_frac_values: platformInterface.temp_remote_low_lim_frac_values.values
                                onTemp_remote_low_lim_frac_valuesChanged: {
                                    fractionComboBox1.model = temp_remote_low_lim_frac_values
                                }

                                property var temp_remote_low_lim_frac_value: platformInterface.temp_remote_low_lim_frac_value.value
                                onTemp_remote_low_lim_frac_valueChanged: {
                                    for(var i = 0; i < fractionComboBox1.model.length; ++i ){
                                        if( fractionComboBox1.model[i] === temp_remote_low_lim_frac_value)
                                        {
                                            fractionComboBox1.currentIndex = i
                                            return;
                                        }
                                    }
                                }
                            }
                        }

                    }
                } // end

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    RowLayout{
                        anchors.fill: parent
                        Rectangle {
                            id:highlimitContainer
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/1.4
                            SGWidget10.SGAlignedLabel {
                                id: highlimitLabel
                                target: highlimit
                                fontSizeMultiplier: ratioCalc
                                font.bold : true
                                alignment: SGWidget10.SGAlignedLabel.SideTopLeft
                                anchors.centerIn: parent

                                SGWidget10.SGSlider {
                                    id: highlimit
                                    width: highlimitContainer.width - 10
                                    live: false
                                    fontSizeMultiplier: ratioCalc * 0.8
                                    showInputBox: true
                                    showToolTip:true
                                    inputBox.validator: DoubleValidator {
                                        top: highlimit.to
                                        bottom: highlimit.from
                                    }
                                    onUserSet: {
                                        platformInterface.set_temp_remote_high_lim.update(value)
                                    }

                                    property var temp_remote_high_lim_caption: platformInterface.temp_remote_high_lim_caption.caption
                                    onTemp_remote_high_lim_captionChanged: {
                                        highlimitLabel.text = temp_remote_high_lim_caption
                                    }

                                    property var temp_remote_high_lim_value: platformInterface.temp_remote_high_lim_value.value
                                    onTemp_remote_high_lim_valueChanged: {
                                        highlimit.value = temp_remote_high_lim_value
                                    }

                                    property var temp_remote_high_lim_state: platformInterface.temp_remote_high_lim_state.state
                                    onTemp_remote_high_lim_stateChanged: {
                                        if(temp_remote_high_lim_state === "enabled"){
                                            highlimitContainer.enabled = true
                                        }
                                        else if(temp_remote_high_lim_state === "disabled"){
                                            highlimitContainer.enabled = false
                                        }
                                        else {
                                            highlimitContainer.enabled = false
                                            highlimitContainer.opacity = 0.5
                                        }
                                    }

                                    property var temp_remote_high_lim_scales: platformInterface.temp_remote_high_lim_scales.scales
                                    onTemp_remote_high_lim_scalesChanged: {
                                        highlimit.toText.text = temp_remote_high_lim_scales[0] + "˚c"
                                        highlimit.fromText.text = temp_remote_high_lim_scales[1] + "˚c"
                                        highlimit.from = temp_remote_high_lim_scales[1]
                                        highlimit.to = temp_remote_high_lim_scales[0]
                                        highlimit.stepSize = temp_remote_high_lim_scales[2]
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: fractionComboBox2Container
                            Layout.fillHeight: true
                            Layout.fillWidth: true


                            SGWidget10.SGComboBox {
                                id: fractionComboBox2
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                onActivated:  {
                                    platformInterface.set_temp_remote_high_lim_frac.update(currentText)
                                }

                                property var temp_remote_high_lim_frac_values: platformInterface.temp_remote_high_lim_frac_values.values
                                onTemp_remote_high_lim_frac_valuesChanged: {
                                    fractionComboBox2.model = temp_remote_high_lim_frac_values
                                }

                                property var temp_remote_high_lim_frac_value: platformInterface.temp_remote_high_lim_frac_value.value
                                onTemp_remote_high_lim_frac_valueChanged: {
                                    for(var i = 0; i < fractionComboBox2.model.length; ++i ){
                                        if( fractionComboBox2.model[i].toString() === temp_remote_high_lim_frac_value)
                                        {
                                            fractionComboBox2.currentIndex = i
                                            return;
                                        }
                                    }
                                }

                                property var temp_remote_high_lim_frac_state: platformInterface.temp_remote_high_lim_frac_state.state
                                onTemp_remote_high_lim_frac_stateChanged: {
                                    if(temp_remote_high_lim_frac_state === "enabled"){
                                        fractionComboBox2Container.enabled = true
                                    }
                                    else if(temp_remote_high_lim_frac_state === "disabled"){
                                        fractionComboBox2Container.enabled = false
                                    }
                                    else {
                                        fractionComboBox2Container.enabled = false
                                        fractionComboBox2Container.opacity = 0.5
                                    }
                                }
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
                            id:remoteOffsetContainer
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/1.4
                            SGWidget10.SGAlignedLabel {
                                id: remoteOffsetLabel
                                target: remoteOffset
                                fontSizeMultiplier: ratioCalc
                                font.bold : true
                                alignment: SGWidget10.SGAlignedLabel.SideTopLeft
                                anchors.centerIn: parent

                                SGWidget10.SGSlider {
                                    id: remoteOffset
                                    width: remoteOffsetContainer.width - 10
                                    live: false
                                    fontSizeMultiplier: ratioCalc * 0.8
                                    showInputBox: true
                                    showToolTip:true
                                    inputBox.validator: DoubleValidator {
                                        top: remoteOffset.to
                                        bottom: remoteOffset.from
                                    }
                                    onUserSet: {
                                        platformInterface.set_temp_remote_offset.update(value)
                                    }

                                    property var temp_remote_offset_caption: platformInterface.temp_remote_offset_caption.caption
                                    onTemp_remote_offset_captionChanged: {
                                        remoteOffsetLabel.text = temp_remote_offset_caption
                                    }

                                    property var temp_remote_offset_value: platformInterface.temp_remote_offset_value.value
                                    onTemp_remote_offset_valueChanged: {
                                        remoteOffset.value = temp_remote_offset_value
                                    }

                                    property var temp_remote_offset_state: platformInterface.temp_remote_offset_state.state
                                    onTemp_remote_offset_stateChanged: {
                                        if(temp_remote_offset_state === "enabled"){
                                            remoteOffsetContainer.enabled = true
                                        }
                                        else if(temp_remote_offset_state === "disabled"){
                                            remoteOffsetContainer.enabled = false
                                        }
                                        else {
                                            remoteOffsetContainer.enabled = false
                                            remoteOffsetContainer.opacity = 0.5
                                        }
                                    }

                                    property var temp_remote_offset_scales: platformInterface.temp_remote_offset_scales.scales
                                    onTemp_remote_offset_scalesChanged: {
                                        remoteOffset.toText.text = temp_remote_offset_scales[0] + "˚c"
                                        remoteOffset.fromText.text = temp_remote_offset_scales[1] + "˚c"
                                        remoteOffset.from = temp_remote_offset_scales[1]
                                        remoteOffset.to = temp_remote_offset_scales[0]
                                        remoteOffset.stepSize = temp_remote_offset_scales[2]
                                    }

                                }
                            }
                        }

                        Rectangle {
                            id: fractionComboBox3Container
                            Layout.fillHeight: true
                            Layout.fillWidth: true


                            SGWidget10.SGComboBox {
                                id: fractionComboBox3
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                onActivated:  {
                                    platformInterface.set_temp_remote_offset_frac.update(currentText)
                                }

                                property var temp_remote_offset_frac_values: platformInterface.temp_remote_offset_frac_values.values
                                onTemp_remote_offset_frac_valuesChanged: {
                                    fractionComboBox3.model = temp_remote_offset_frac_values
                                }

                                property var temp_remote_offset_frac_value: platformInterface.temp_remote_offset_frac_value.value
                                onTemp_remote_offset_frac_valueChanged: {
                                    for(var i = 0; i < fractionComboBox3.model.length; ++i ){
                                        if( fractionComboBox3.model[i].toString() === temp_remote_offset_frac_value)
                                        {
                                            fractionComboBox3.currentIndex = i
                                            return;
                                        }
                                    }
                                }

                                property var temp_remote_offset_frac_state: platformInterface.temp_remote_offset_frac_state.state
                                onTemp_remote_offset_frac_stateChanged: {
                                    if(temp_remote_offset_frac_state === "enabled"){
                                        fractionComboBox3Container.enabled = true
                                    }
                                    else if(temp_remote_offset_frac_state === "disabled"){
                                        fractionComboBox3Container.enabled = false
                                    }
                                    else {
                                        fractionComboBox3Container.enabled = false
                                        fractionComboBox3Container.opacity = 0.5
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id:tempRemoteThermLimContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGWidget10.SGAlignedLabel {
                        id: tempRemoteThermLimLabel
                        target: tempRemoteThermLim
                        fontSizeMultiplier: ratioCalc
                        font.bold : true
                        alignment: SGWidget10.SGAlignedLabel.SideTopLeft
                        anchors.verticalCenter: parent.verticalCenter

                        SGWidget10.SGSlider {
                            id: tempRemoteThermLim
                            width: tempRemoteThermLimContainer.width/1.5
                            live: false
                            fontSizeMultiplier: ratioCalc * 0.8
                            showInputBox: true
                            showToolTip:true
                            inputBox.validator: DoubleValidator {
                                top: tempRemoteThermLim.to
                                bottom: tempRemoteThermLim.from
                            }

                            onUserSet: platformInterface.set_temp_remote_therm_lim.update()
                            property var temp_remote_therm_lim_caption: platformInterface.temp_remote_therm_lim_caption.caption
                            onTemp_remote_therm_lim_captionChanged: {
                                tempRemoteThermLimLabel.text = temp_remote_therm_lim_caption
                            }
                            property var temp_remote_therm_limt_value: platformInterface.temp_remote_therm_limt_value.value
                            onTemp_remote_therm_limt_valueChanged: {
                                tempRemoteThermLim.value = temp_remote_therm_limt_value
                            }
                            property var temp_remote_therm_lim_scales: platformInterface.temp_remote_therm_lim_scales.scales
                            onTemp_remote_therm_lim_scalesChanged: {
                                tempRemoteThermLim.toText.text = temp_remote_therm_lim_scales[0] + "˚c"
                                tempRemoteThermLim.fromText.text = temp_remote_therm_lim_scales[1] + "˚c"
                                tempRemoteThermLim.from = temp_remote_therm_lim_scales[1]
                                tempRemoteThermLim.to = temp_remote_therm_lim_scales[0]
                                tempRemoteThermLim.stepSize = temp_remote_therm_lim_scales[2]
                            }
                        }
                    }


                }
            }
        } // end of remote setting (left bottom)


        Rectangle {
            width: parent.width/2.5
            height: topContainer.height
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 10
                top: topContainer.bottom
                leftMargin: 10
            }

            ColumnLayout {
                id: rightSetting
                anchors.fill: parent

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    RowLayout{
                        anchors.fill: parent
                        Rectangle {
                            id: lthrmContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGWidget10.SGAlignedLabel {
                                id: lthrmLabel
                                target: lthrm
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGWidget10.SGStatusLight{
                                    id: lthrm
                                    width: 30
                                }

                                property var temp_lthrm_caption: platformInterface.temp_lthrm_caption.caption
                                onTemp_lthrm_captionChanged: {
                                    lthrmLabel.text = temp_lthrm_caption
                                }

                                property var temp_lthrm_value: platformInterface.temp_lthrm_value.value
                                onTemp_lthrm_valueChanged: {
                                    if(temp_lthrm_value === "0") {
                                        lthrm.status = SGWidget10.SGStatusLight.Red
                                    }
                                    else  lthrm.status = SGWidget10.SGStatusLight.Green
                                }

                                property var temp_lthrm_state: platformInterface.temp_lthrm_state.state
                                onTemp_lthrm_stateChanged: {
                                    if(temp_lthrm_state === "enabled"){
                                        lthrmContainer.enabled = true
                                        lthrmContainer.opacity = 1.0
                                    }
                                    else if (temp_lthrm_state === "disabled"){
                                        lthrmContainer.enabled = false
                                        lthrmContainer.opacity = 1.0
                                    }
                                    else {
                                        lthrmContainer.opacity = 0.5
                                        lthrmContainer.enabled = false
                                    }
                                }


                            }
                        }

                        Rectangle {
                            id: llowContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGWidget10.SGAlignedLabel {
                                id: llowLabel
                                target: llow
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGWidget10.SGStatusLight{
                                    id: llow
                                    width: 30
                                }

                                property var temp_llow_caption: platformInterface.temp_llow_caption.caption
                                onTemp_llow_captionChanged: {
                                    llowLabel.text = temp_llow_caption
                                }

                                property var temp_llow_value: platformInterface.temp_llow_value.value
                                onTemp_llow_valueChanged: {
                                    if(temp_llow_value === "0") {
                                        llow.status = SGWidget10.SGStatusLight.Red
                                    }
                                    else  llow.status = SGWidget10.SGStatusLight.Green
                                }

                                property var temp_llow_state: platformInterface.temp_llow_state.state
                                onTemp_llow_stateChanged: {
                                    if(temp_llow_state === "enabled"){
                                        llowContainer.enabled = true
                                        llowContainer.opacity = 1.0
                                    }
                                    else if (temp_llow_state === "disabled"){
                                        llowContainer.enabled = false
                                        llowContainer.opacity = 1.0
                                    }
                                    else {
                                        llowContainer.opacity = 0.5
                                        llowContainer.enabled = false
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: lhighContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGWidget10.SGAlignedLabel {
                                id: lhighLabel
                                target: lhigh
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGWidget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGWidget10.SGStatusLight{
                                    id: lhigh
                                    width: 30
                                }

                                property var temp_lhigh_caption: platformInterface.temp_lhigh.caption
                                onTemp_lhigh_captionChanged: {
                                    lhighLabel.text = temp_lhigh_caption
                                }

                                property var temp_lhigh_value: platformInterface.temp_lhigh_value.value
                                onTemp_lhigh_valueChanged: {
                                    if(temp_lhigh_value === "0") {
                                        lhigh.status = SGWidget10.SGStatusLight.Red
                                    }
                                    else  lhigh.status = SGWidget10.SGStatusLight.Green
                                }

                                property var temp_lhigh_state: platformInterface.temp_lhigh_state.state
                                onTemp_lhigh_stateChanged: {
                                    if(temp_lhigh_state === "enabled"){
                                        lhighContainer.enabled = true
                                        lhighContainer.opacity = 1.0
                                    }
                                    else if (temp_lhigh_state === "disabled"){
                                        lhighContainer.enabled = false
                                        lhighContainer.opacity = 1.0
                                    }
                                    else {
                                        lhighContainer.opacity = 0.5
                                        lhighContainer.enabled = false
                                    }
                                }


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

                    }


                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent

                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent

                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                }

            }

            //            Column {
            //                id: settingTwo
            //                anchors.fill: parent
            //                Rectangle {
            //                    width: parent.width
            //                    height: parent.height/6
            //                    color: "transparent"
            //                    RowLayout{
            //                        anchors.fill: parent
            //                        property var nct72_lthrm_caption: platformInterface.nct72_lthrm.caption
            //                        onNct72_lthrm_captionChanged: {
            //                            lthrm.label = nct72_lthrm_caption
            //                        }

            //                        property var nct72_lthrm_value: platformInterface.nct72_lthrm.value
            //                        onNct72_lthrm_valueChanged: {

            //                            if(nct72_lthrm_value === "0") {
            //                                console.log("tanya",nct72_lthrm_value)
            //                                lthrm.status = "red"
            //                            }
            //                            else  lthrm.status = "green"
            //                        }

            //                        property var nct72_lthrm_state: platformInterface.nct72_lthrm.state
            //                        onNct72_lthrm_stateChanged: {
            //                            if(nct72_lthrm_state === "enabled"){
            //                                lthrm.enabled = true
            //                                lthrm.opacity = 1.0
            //                            }
            //                            else if (nct72_lthrm_state === "disabled"){
            //                                lthrm.enabled = false
            //                                lthrm.opacity = 1.0

            //                            }
            //                            else {
            //                                lthrm.opacity = 0.5
            //                                lthrm.enabled = false
            //                            }
            //                        }

            //                        SGStatusLight{
            //                            id: lthrm
            //                            label: "LTHRM"
            //                            fontSize: ratioCalc * 20
            //                            Layout.alignment: Qt.AlignCenter
            //                            lightSize: ratioCalc * 30

            //                        }

            //                        property var nct72_llow_caption: platformInterface.nct72_llow.caption
            //                        onNct72_llow_captionChanged: {
            //                            llow.label = nct72_llow_caption
            //                        }

            //                        property var nct72_llow_value: platformInterface.nct72_llow.value
            //                        onNct72_llow_valueChanged: {
            //                            if(nct72_llow_value === "0") {
            //                                llow.status = "red"
            //                            }
            //                            else  llow.status = "green"
            //                        }

            //                        property var nct72_llow_state: platformInterface.nct72_llow.state
            //                        onNct72_llow_stateChanged: {
            //                            if(nct72_llow_state === "enabled"){
            //                                llow.enabled = true
            //                                llow.opacity = 1.0
            //                            }
            //                            else if (nct72_lhigh_state === "disabled"){
            //                                llow.enabled = false
            //                                llow.opacity = 1.0

            //                            }
            //                            else {
            //                                llow.opacity = 0.5
            //                                llow.enabled = false
            //                            }
            //                        }

            //                        SGStatusLight{
            //                            id: llow
            //                            label: "LLOW"
            //                            fontSize: ratioCalc * 20
            //                            Layout.alignment: Qt.AlignCenter
            //                            lightSize: ratioCalc * 30
            //                        }

            //                        property var nct72_lhigh_caption: platformInterface.nct72_lhigh.caption
            //                        onNct72_lhigh_captionChanged: {
            //                            lhigh.label = nct72_lhigh_caption
            //                        }

            //                        property var nct72_lhigh_value: platformInterface.nct72_lhigh.value
            //                        onNct72_lhigh_valueChanged: {
            //                            if(nct72_lhigh_value === "0") {
            //                                lhigh.status = "red"
            //                            }
            //                            else  lhigh.status = "green"
            //                        }

            //                        property var nct72_lhigh_state: platformInterface.nct72_lhigh.state
            //                        onNct72_lhigh_stateChanged: {
            //                            if(nct72_lhigh_state === "enabled"){
            //                                lhigh.enabled = true
            //                                lhigh.opacity = 1.0
            //                            }
            //                            else if (nct72_lhigh_state === "disabled"){
            //                                lhigh.enabled = false
            //                                lhigh.opacity = 1.0

            //                            }
            //                            else {
            //                                lhigh.opacity = 0.5
            //                                lhigh.enabled = false
            //                            }
            //                        }

            //                        SGStatusLight{
            //                            id: lhigh
            //                            label: "LHIGH"
            //                            fontSize: ratioCalc * 20
            //                            Layout.alignment: Qt.AlignCenter
            //                            lightSize: ratioCalc * 30
            //                        }
            //                    }
            //                }
            //                Rectangle {
            //                    width: parent.width
            //                    height: parent.height/6
            //                    color: "transparent"

            //                    SGSlider {
            //                        id: locallimitSlider
            //                        anchors.centerIn: parent
            //                        fontSize: ratioCalc * 20
            //                        //label: "<b> Local Low Limit:</b>"         // Default: "" (if not entered, label will not appear)
            //                        textColor: "black"           // Default: "black"
            //                        labelLeft: false             // Default: true
            //                        width:  parent.width/1.5                   // Default: 200
            //                        stepSize: 1.0                // Default: 1.0
            //                        //value: platformInterface.nct72_get_int_low_lim.value               // Default: average of from and to
            //                        endLabel: "127°c"            // Default: to
            //                        showToolTip: true            // Default: true
            //                        toolTipDecimalPlaces: 0      // Default: 0
            //                        grooveColor: "#ddd"          // Default: "#dddddd"
            //                        grooveFillColor: "lightgreen"// Default: "#888888"
            //                        live: false
            //                        onMoved: {
            //                            platformInterface.nct72_local_low_limit_value.update(value.toString())
            //                        }
            //                        property var nct72_local_low_limit_caption: platformInterface.nct72_local_low_limit.caption
            //                        onNct72_local_low_limit_captionChanged: {
            //                            locallimitSlider.label = nct72_local_low_limit_caption
            //                        }
            //                        property var nct72_local_low_limit_value: platformInterface.nct72_local_low_limit.value
            //                        onNct72_local_low_limit_valueChanged: {
            //                            locallimitSlider.value = nct72_local_low_limit_value
            //                        }
            //                        property var nct72_local_low_limit_scales: platformInterface.nct72_local_low_limit.scales
            //                        onNct72_local_low_limit_scalesChanged: {
            //                            locallimitSlider.endLabel = nct72_local_low_limit_scales[0]
            //                            locallimitSlider.startLabel = nct72_local_low_limit_scales[1]
            //                            locallimitSlider.from = nct72_local_low_limit_scales[1]
            //                            locallimitSlider.to = nct72_local_low_limit_scales[0]
            //                            locallimitSlider.stepSize = nct72_local_low_limit_scales[2]
            //                        }


            //                    }

            //                }
            //                Rectangle {
            //                    width: parent.width
            //                    height: parent.height/6
            //                    color: "transparent"

            //                    SGSlider {
            //                        id: localhighSlider
            //                        anchors.centerIn: parent
            //                        fontSize: ratioCalc * 20
            //                        //label: "<b> Local High Limit:</b>"         // Default: "" (if not entered, label will not appear)
            //                        textColor: "black"           // Default: "black"
            //                        labelLeft: false             // Default: true
            //                        width:  parent.width/1.5                  // Default: 200
            //                        stepSize: 1.0                // Default: 1.0
            //                        value: 10
            //                        endLabel: "127°c"            // Default: to
            //                        showToolTip: true            // Default: true
            //                        toolTipDecimalPlaces: 0      // Default: 0
            //                        grooveColor: "#ddd"          // Default: "#dddddd"
            //                        grooveFillColor: "lightgreen"// Default: "#888888"
            //                        live: false

            //                        onMoved: {
            //                            platformInterface.nct72_local_high_limit_value.update(value.toString())
            //                        }

            //                        property var nct72_local_high_limit_caption: platformInterface.nct72_local_high_limit.caption
            //                        onNct72_local_high_limit_captionChanged: {
            //                            localhighSlider.label = nct72_local_high_limit_caption
            //                        }
            //                        property var nct72_local_high_limit_value: platformInterface.nct72_local_high_limit.value
            //                        onNct72_local_high_limit_valueChanged: {
            //                            localhighSlider.value = nct72_local_high_limit_value
            //                        }
            //                        property var nct72_local_high_limit_scales: platformInterface.nct72_local_high_limit.scales
            //                        onNct72_local_high_limit_scalesChanged: {
            //                            localhighSlider.endLabel = nct72_local_high_limit_scales[0]
            //                            localhighSlider.startLabel = nct72_local_high_limit_scales[1]
            //                            localhighSlider.from = nct72_local_high_limit_scales[1]
            //                            localhighSlider.to = nct72_local_high_limit_scales[0]
            //                            localhighSlider.stepSize = nct72_local_high_limit_scales[2]
            //                        }


            //                    }
            //                }
            //                Rectangle {
            //                    width: parent.width
            //                    height: parent.height/6
            //                    color: "transparent"

            //                    SGSlider {
            //                        id: localthermSlider
            //                        anchors.centerIn: parent
            //                        fontSize: ratioCalc * 20
            //                        /*  label: "<b> Local THERM Limit:</b>"         */// Default: "" (if not entered, label will not appear)
            //                        textColor: "black"           // Default: "black"
            //                        labelLeft: false             // Default: true
            //                        width: parent.width/1.5                 // Default: 200
            //                        /*     stepSize: 1.0                // Default: 1.0
            //                        value: 20                 // Default: average of from and to
            //                        endLabel: "255°c"      */      // Default: to
            //                        showToolTip: true            // Default: true
            //                        toolTipDecimalPlaces: 0      // Default: 0
            //                        grooveColor: "#ddd"          // Default: "#dddddd"
            //                        grooveFillColor: "lightgreen"// Default: "#888888"
            //                        live: false
            //                        property var nct72_local_therm_limit_caption: platformInterface.nct72_local_therm_limit.caption
            //                        onNct72_local_therm_limit_captionChanged: {
            //                            localthermSlider.label = nct72_local_therm_limit_caption
            //                        }
            //                        property var nct72_local_therm_limit_value: platformInterface.nct72_local_therm_limit.value
            //                        onNct72_local_therm_limit_valueChanged: {
            //                            localthermSlider.value = nct72_local_therm_limit_value
            //                        }
            //                        property var nct72_local_therm_limit_scales: platformInterface.nct72_local_therm_limit.scales
            //                        onNct72_local_therm_limit_scalesChanged: {
            //                            localthermSlider.endLabel = nct72_local_therm_limit_scales[0]
            //                            localthermSlider.startLabel = nct72_local_therm_limit_scales[1]
            //                            localthermSlider.from = nct72_local_therm_limit_scales[1]
            //                            localthermSlider.to = nct72_local_therm_limit_scales[0]
            //                            localthermSlider.stepSize = nct72_local_therm_limit_scales[2]
            //                        }

            //                        onMoved:{
            //                            platformInterface.nct72_local_therm_limit_value.update(value.toString())
            //                        }

            //                    }
            //                }
            //            }
        }

    }
}
