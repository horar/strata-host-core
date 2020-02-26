import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: root
    property real ratioCalc: root.width/1200
    property real initialAspectRatio: 1225/648
    property var sensorArray: []
    property var eachSensor: []
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
        Help.registerTarget(calerrLabel, "Indicates a calibration error has occurred. Can be indicative of a noisy environment or invalid register configuration. Change the configuration and perform a Static Offset Calibration to remove calibration error.", 0, "proximityHelp")
        Help.registerTarget(syserrLabel, "Indicates a system error has occurred. A software or power-on (hardware) reset must be performed to remove the system error.", 1, "proximityHelp")
        Help.registerTarget(hardwareButton, "Performs a hardware reset of the LC717A10AR sensor and returns all UI controls back to default values.", 2, "proximityHelp")
        Help.registerTarget(staticOffsetCalibrationButton, "Performs a static offset calibration that adjusts the capacitance of the ADC for parasitism capacitance of each CIN to decide the most suitable plus/minus offset capacitance.", 3, "proximityHelp")
        Help.registerTarget(sensorALabel, "Indicates activation of each proximity sensor when the threshold register value is exceeded. Default threshold for all Proximity sensors is 5. ", 4, "proximityHelp")
        Help.registerTarget(sensorListA,"Adjusts the second amplifier’s gain of each individual CIN from unity minimum to 16 maximum. It is recommended to perform a Static Offset Calibration after modifying this register.", 5, "proximityHelp")
        Help.registerTarget(thresholdA, "Adjusts the threshold value of each proximity sensor from 0 to 127. Exceeding the threshold value indicates sensor activation.", 6, "proximityHelp")
        Help.registerTarget(sensordataA,"Indicates the data measurement value of each individual CIN from -127 to 127. Positive values indicate increase in capacitance and negative value indicate decrease in capacitance since the last calibration.", 7, "proximityHelp")
    }


    property var sensor_status_value:  platformInterface.sensor_status_value.value
    onSensor_status_valueChanged: {
        if(sensor_status_value === "defaults") {
            if(proximity.visible) {
                set_default_prox_value()
            }
        }
    }

    property var sensor_defaults_value: platformInterface.sensor_defaults_value.value
    onSensor_defaults_valueChanged: {
        if(sensor_defaults_value === "1") {
            set_default_prox_value()
        }
    }

    property var proximity_sensor_notification: platformInterface.proximity_cin
    onProximity_sensor_notificationChanged: {
        sensordataA.text = proximity_sensor_notification.data[0]
        if(proximity_sensor_notification.act[0] === 0 && proximity_sensor_notification.err[0] === 0)
            sensorA.status = SGStatusLight.Off
        else if(proximity_sensor_notification.act[0] === 1) {
            if (proximity_sensor_notification.err[0] === 1)
                sensorA.status =SGStatusLight.Red
            else sensorA.status =SGStatusLight.Green
        }
        else if(proximity_sensor_notification.err[0] === 1)
            sensorA.status =SGStatusLight.Red

        sensordataB.text = proximity_sensor_notification.data[1]
        if(proximity_sensor_notification.act[1] === 0 && proximity_sensor_notification.err[1] === 0)
            sensorB.status = SGStatusLight.Off
        else if(proximity_sensor_notification.act[1] === 1) {
            if (proximity_sensor_notification.err[1] === 1)
                sensorB.status = SGStatusLight.Red
            else sensorB.status = SGStatusLight.Green
        }
        else if(proximity_sensor_notification.err[1] === 1)
            sensorB.status =SGStatusLight.Red

        sensordataC.text = proximity_sensor_notification.data[2]
        if(proximity_sensor_notification.act[2] === 0 && proximity_sensor_notification.err[2] === 0)
            sensorC.status = SGStatusLight.Off
        else if(proximity_sensor_notification.act[2] === 1) {
            if (proximity_sensor_notification.err[2] === 1)
                sensorC.status = SGStatusLight.Red
            else sensorC.status = SGStatusLight.Green
        }
        else if(proximity_sensor_notification.err[2] === 1)
            sensorC.status =SGStatusLight.Red

        sensordataD.text = proximity_sensor_notification.data[3]
        if(proximity_sensor_notification.act[3] === 0 && proximity_sensor_notification.err[3] === 0)
            sensorD.status = SGStatusLight.Off
        else if(proximity_sensor_notification.act[3] === 1) {
            if (proximity_sensor_notification.err[3] === 1)
                sensorD.status = SGStatusLight.Red
            else sensorD.status = SGStatusLight.Green
        }
        else if(proximity_sensor_notification.err[3] === 1)
            sensorD.status =SGStatusLight.Red

    }

    property var touch_cin_thres_values: platformInterface.touch_cin_thres_values.values
    onTouch_cin_thres_valuesChanged: {
        thresholdA.text = touch_cin_thres_values[12]
        thresholdB.text = touch_cin_thres_values[13]
        thresholdC.text = touch_cin_thres_values[14]
        thresholdD.text = touch_cin_thres_values[15]
    }


    property var touch_cin_thres_state: platformInterface.touch_cin_thres_state.state
    onTouch_cin_thres_stateChanged: {
        if(touch_cin_thres_state === "enabled" ) {
            thresholdAContainer.enabled = true
            thresholdAContainer.opacity  = 1.0
            thresholdBContainer.enabled = true
            thresholdBContainer.opacity  = 1.0
            thresholdCContainer.enabled = true
            thresholdCContainer.opacity  = 1.0
            thresholdDContainer.enabled = true
            thresholdDContainer.opacity  = 1.0
        }
        else if (touch_cin_thres_state === "disabled") {
            thresholdAContainer.opacity  = 1.0
            thresholdBContainer.enabled = false
            thresholdBContainer.opacity  = 1.0
            thresholdCContainer.enabled = false
            thresholdCContainer.opacity  = 1.0
            thresholdDContainer.enabled = false
            thresholdDContainer.opacity  = 1.0
        }
        else {
            thresholdAContainer.enabled = false
            thresholdAContainer.opacity  = 0.5
            thresholdBContainer.enabled = false
            thresholdBContainer.opacity  = 0.5
            thresholdCContainer.enabled = false
            thresholdCContainer.opacity  = 0.5
            thresholdDContainer.enabled = false
            thresholdDContainer.opacity  = 0.5
        }
    }

    function setAllSensorsValue() {
        for(var i=1 ; i <= 16; i++){
            eachSensor.push(i)
        }
        sensorListA.model = eachSensor
        sensorListB.model = eachSensor
        sensorListC.model = eachSensor
        sensorListD.model = eachSensor
    }


    property var touch_second_gain_values: platformInterface.touch_second_gain_values.values
    onTouch_second_gain_valuesChanged: {
        setAllSensorsValue()
        for(var a = 0; a < sensorListA.model.length; ++a) {
            if(touch_second_gain_values[12] === sensorListA.model[a].toString()){
                sensorListA.currentIndex = a
            }
            if(touch_second_gain_values[13] === sensorListB.model[a].toString()){
                sensorListB.currentIndex = a
            }
            if(touch_second_gain_values[14] === sensorListC.model[a].toString()){
                sensorListC.currentIndex = a
            }
            if(touch_second_gain_values[15] === sensorListD.model[a].toString()){
                sensorListD.currentIndex = a
            }
        }
    }

    property var touch_calerr_caption: platformInterface.touch_calerr_caption
    onTouch_calerr_captionChanged:  {
        calerrLabel.text = touch_calerr_caption.caption
    }

    property var touch_calerr_value: platformInterface.touch_calerr_value.value
    onTouch_calerr_valueChanged: {
        if(touch_calerr_value === "0")
            calerr.status = SGStatusLight.Off
        else calerr.status = SGStatusLight.Red
    }

    function set_default_prox_value() {
        var default_touch_calerr = platformInterface.default_touch_calerr.value

        if(default_touch_calerr === "0")
            calerr.status = SGStatusLight.Off
        else calerr.status = SGStatusLight.Red

        var touch_syserr_value = platformInterface.default_touch_syserr.value
        if(touch_syserr_value === "0")
            syserr.status = SGStatusLight.Off
        else syserr.status = SGStatusLight.Red
        platformInterface.proximity_cin = platformInterface.default_proximity_cin
        touch_cin_thres_values = platformInterface.default_touch_cin_thres.values
        touch_second_gain_values = platformInterface.default_touch_second_gain.values
        touch_cin_thres_state = platformInterface.default_touch_cin_thres.state
        eachSensor = []
    }

    property var touch_calerr_state: platformInterface.touch_calerr_state.state
    onTouch_calerr_stateChanged: {
        if(touch_calerr_state === "enabled") {
            calerrLabel.enabled = true
            calerrLabel.opacity = 1.0
        }
        else if (touch_calerr_state === "disabled") {
            calerrLabel.enabled = false
            calerrLabel.opacity = 1.0
        }
        else {
            calerrLabel.enabled = false
            calerrLabel.opacity = 0.5
        }
    }

    property var touch_syserr_caption: platformInterface.touch_syserr_caption
    onTouch_syserr_captionChanged: {
        syserrLabel.text = touch_syserr_caption.caption
    }

    property var touch_syserr_value: platformInterface.touch_syserr_value.value
    onTouch_syserr_valueChanged: {
        console.log(touch_syserr_value)
        if(touch_syserr_value === "0")
            syserr.status = SGStatusLight.Off
        else syserr.status = SGStatusLight.Red
    }

    property var touch_syserr_state: platformInterface.touch_syserr_state.state
    onTouch_syserr_stateChanged: {
        if(touch_syserr_state === "enabled") {
            syserrLabel.enabled = true
            syserrLabel.opacity = 1.0
        }
        else if (touch_syserr_state === "disabled") {
            syserrLabel.enabled = false
            syserrLabel.opacity = 1.0
        }
        else {
            syserrLabel.enabled = false
            syserrLabel.opacity = 0.5
        }
    }

    Rectangle {
        width:parent.width/1.2
        height: parent.height/1.5
        anchors.centerIn: parent
        ColumnLayout{
            anchors.fill:parent

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height/4
                Text {
                    id: firstDebugLabel
                    text: "First Gain, Error & Reset"
                    font.bold: true
                    font.pixelSize: ratioCalc * 17
                    color: "#696969"
                    anchors {
                        top: parent.top
                        topMargin: 5
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
                        top: firstDebugLabel.bottom
                        topMargin: 7
                    }
                }

                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    anchors {
                        top: line1.bottom
                        topMargin: 10
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    RowLayout {
                        anchors.fill: parent
                        Rectangle{
                            id: calerrContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            SGAlignedLabel {
                                id: calerrLabel
                                target: calerr
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 1.2
                                alignment:  SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight{
                                    id: calerr
                                    height: 40 * ratioCalc
                                    width: 40 * ratioCalc
                                    status: SGStatusLight.Off

                                }
                            }
                        }
                        Rectangle{
                            id: syserrContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: syserrLabel
                                target: syserr
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 1.2
                                alignment:  SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight{
                                    id: syserr
                                    height: 40 * ratioCalc
                                    width: 40 * ratioCalc
                                    status: SGStatusLight.Off

                                }
                            }
                        }
                        Rectangle {
                            id: resetContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGButton {
                                id:  hardwareButton
                                text: qsTr("Hardware Reset")
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                height: parent.height/1.5
                                width: parent.width/1.5
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        warningPopup.open()
                                        popupMessage = "Performing Hardware Reset"
                                        platformInterface.touch_reset.update()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: staticOffsetContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGButton {
                                id:  staticOffsetCalibrationButton
                                text: qsTr("Static Offset \n Calibration")
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                height: parent.height/1.5
                                width: parent.width/1.5
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        warningPopup.open()
                                        platformInterface.set_touch_static_offset_cal.update()
                                        popupMessage = "Performing Static Offset Calibration"

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

                Text {
                    id: secondDebugLabel
                    text: "Second Gain, Data, Threshold & Activation Status"
                    font.bold: true
                    font.pixelSize: ratioCalc * 17
                    color: "#696969"
                    anchors {
                        top: parent.top
                        topMargin: 5
                    }
                }

                Rectangle {
                    id: line2
                    height: 2
                    Layout.alignment: Qt.AlignCenter
                    width: parent.width
                    border.color: "lightgray"
                    radius: 2
                    anchors {
                        top: secondDebugLabel.bottom
                        topMargin: 7
                    }
                }


                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    anchors {
                        top: line2.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            spacing: 20
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                Text {
                                    id: activationLabel1
                                    text: qsTr("Activation")
                                    font.bold: true
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pixelSize: ratioCalc * 20
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                Text {
                                    id: gainLabel
                                    text: qsTr("2nd Gain")
                                    font.bold: true
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pixelSize: ratioCalc * 20
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                Text {
                                    id: label2
                                    text: qsTr("Threshold")
                                    font.bold: true
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pixelSize: ratioCalc * 20
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                Text {
                                    id: data1
                                    text: qsTr("Data")
                                    font.bold: true
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pixelSize: ratioCalc * 20
                                }
                            }
                        }
                        RowLayout {
                            spacing: 20
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle {
                                id:cinA
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: sensorALabel
                                    target: sensorA
                                    text: "<b>" + qsTr("A") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    alignment:  SGAlignedLabel.SideLeftCenter
                                    Layout.alignment: Qt.AlignCenter
                                    anchors.centerIn: parent

                                    SGStatusLight{
                                        id: sensorA
                                        height: 40 * ratioCalc
                                        width: 40 * ratioCalc
                                        status: SGStatusLight.Off
                                    }
                                }
                            }

                            Rectangle {
                                id: cin2gain
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGComboBox {
                                    id: sensorListA
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent

                                    Keys.onBacktabPressed: {
                                        thresholdD.forceActiveFocus()
                                        thresholdD.selectAll()
                                        textField.deselect()
                                    }

                                    Keys.onTabPressed: {
                                        thresholdA.forceActiveFocus()
                                        thresholdA.selectAll()
                                        textField.deselect()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            textField.deselect()
                                    }

                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(12,currentText)
                                    }
                                }
                            }

                            Rectangle {
                                id: thresholdAContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGSubmitInfoBox {
                                    id: thresholdA
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.4
                                    validator: IntValidator { }
                                    placeholderText: "1-127"

                                    Keys.onBacktabPressed: {
                                        sensorListA.forceActiveFocus()
                                        sensorListA.textField.selectAll()

                                    }
                                    Keys.onTabPressed: {
                                        sensorListB.forceActiveFocus()
                                        sensorListB.textField.selectAll()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            deselect()
                                    }

                                    onEditingFinished: {
                                        var value = parseInt(text)
                                        if(value > 127)
                                            thresholdA.text = 127
                                        if (value < 1)
                                            thresholdA.text = 1

                                        platformInterface.touch_cin_thres_value.update(12,parseInt(thresholdA.text))
                                    }
                                }
                            }

                            Rectangle {
                                id:cin0data
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGInfoBox {
                                    id: sensordataA
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.5
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        RowLayout {
                            spacing: 20
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: sensorBLabel
                                    target: sensorB
                                    text: "<b>" + qsTr("B") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    alignment:  SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent

                                    SGStatusLight{
                                        id: sensorB
                                        height: 40 * ratioCalc
                                        width: 40 * ratioCalc
                                        status: SGStatusLight.Off
                                    }
                                }
                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGComboBox {
                                    id: sensorListB
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.2

                                    Keys.onBacktabPressed: {
                                        thresholdA.forceActiveFocus()
                                        thresholdA.selectAll()
                                        textField.deselect()
                                    }

                                    Keys.onTabPressed: {
                                        thresholdB.forceActiveFocus()
                                        thresholdB.selectAll()
                                        textField.deselect()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            textField.deselect()
                                    }

                                    onActivated: {
                                        if(currentIndex === 0 || currentIndex === 15)
                                            platformInterface.touch_second_gain_value.update(13,currentText.slice(0,-3))
                                        else  platformInterface.touch_second_gain_value.update(13,currentText)
                                    }
                                }
                            }

                            Rectangle {
                                id: thresholdBContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGSubmitInfoBox {
                                    id: thresholdB
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.4
                                    validator: IntValidator { }
                                    placeholderText: "1-127"

                                    Keys.onBacktabPressed: {
                                        sensorListB.forceActiveFocus()
                                        sensorListB.selectAll()
                                    }

                                    Keys.onTabPressed: {
                                        sensorListC.forceActiveFocus()
                                        sensorListC.textField.selectAll()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            deselect()
                                    }

                                    onEditingFinished: {
                                        var value = parseInt(text)
                                        if(value > 127)
                                            thresholdB.text = 127
                                        if (value < 1)
                                            thresholdB.text = 1
                                        platformInterface.touch_cin_thres_value.update(13,parseInt(thresholdB.text))

                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordataB
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.5
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        RowLayout {
                            spacing: 20
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: sensorCLabel
                                    target: sensorC
                                    text: "<b>" + qsTr("C") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    alignment:  SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent

                                    SGStatusLight{
                                        id: sensorC
                                        height: 40 * ratioCalc
                                        width: 40 * ratioCalc
                                        status: SGStatusLight.Off
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGComboBox {
                                    id: sensorListC
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.2

                                    Keys.onBacktabPressed: {
                                        thresholdB.forceActiveFocus()
                                        thresholdB.selectAll()
                                        textField.deselect()
                                    }

                                    Keys.onTabPressed: {
                                        thresholdC.forceActiveFocus()
                                        thresholdC.selectAll()
                                        textField.deselect()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            textField.deselect()
                                    }

                                    onActivated: {
                                        if(currentIndex === 0 || currentIndex === 15)
                                            platformInterface.touch_second_gain_value.update(14,currentText.slice(0,-3))
                                        else  platformInterface.touch_second_gain_value.update(14,currentText)
                                    }
                                }
                            }

                            Rectangle {
                                id: thresholdCContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGSubmitInfoBox {
                                    id: thresholdC
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.4
                                    validator: IntValidator {
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }

                                    Keys.onBacktabPressed: {
                                        sensorListC.forceActiveFocus()
                                        sensorListC.selectAll()

                                    }
                                    Keys.onTabPressed: {
                                        sensorListD.forceActiveFocus()
                                        sensorListD.textField.selectAll()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            deselect()
                                    }
                                    placeholderText: "1-127"

                                    onEditingFinished: {
                                        var value = parseInt(text)
                                        if(value > 127)
                                            thresholdC.text = 127
                                        if (value < 1)
                                            thresholdC.text = 1
                                        platformInterface.touch_cin_thres_value.update(14,parseInt(thresholdC.text))
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordataC
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.5
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        RowLayout {
                            spacing: 20
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: sensorDLabel
                                    target: sensorD
                                    text: "<b>" + qsTr("D") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    alignment:  SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent

                                    SGStatusLight{
                                        id: sensorD
                                        height: 40 * ratioCalc
                                        width: 40 * ratioCalc
                                        status: SGStatusLight.Off
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGComboBox {
                                    id: sensorListD
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent

                                    Keys.onBacktabPressed: {
                                        thresholdC.forceActiveFocus()
                                        thresholdC.selectAll()
                                        textField.deselect()
                                    }

                                    Keys.onTabPressed: {
                                        thresholdD.forceActiveFocus()
                                        thresholdD.selectAll()
                                        textField.deselect()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            textField.deselect()
                                    }

                                    onActivated: {
                                        if(currentIndex === 0 || currentIndex === 15)
                                            platformInterface.touch_second_gain_value.update(15,currentText.slice(0,-3))
                                        else  platformInterface.touch_second_gain_value.update(15,currentText)
                                    }
                                }
                            }

                            Rectangle {
                                id: thresholdDContainer
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SGSubmitInfoBox {
                                    id: thresholdD
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.4
                                    validator: IntValidator {  }
                                    placeholderText: "1-127"

                                    Keys.onBacktabPressed: {
                                        sensorListD.forceActiveFocus()
                                        sensorListD.textField.selectAll()
                                    }

                                    Keys.onTabPressed: {
                                        sensorListA.forceActiveFocus()
                                        sensorListA.textField.selectAll()
                                    }

                                    onFocusChanged:  {
                                        if(!focus)
                                            deselect()
                                    }

                                    onEditingFinished: {
                                        var value = parseInt(text)
                                        if(value > 127)
                                            thresholdD.text = 127
                                        if (value < 1)
                                            thresholdD.text = 1
                                        platformInterface.touch_cin_thres_value.update(15,parseInt(thresholdD.text))
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordataD
                                    fontSizeMultiplier: ratioCalc * 1.4
                                    width:parent.width/2.5
                                    height:parent.height/1.5
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}



