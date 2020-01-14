import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item  {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    property var sensorArray: []
    property var eachSensor: []

    Component.onCompleted:  {
        //setAllSensorsValue()
    }


    property var touch_hw_reset_value: platformInterface.touch_hw_reset_value
    onTouch_hw_reset_valueChanged: {
        if(touch_hw_reset_value.value === "1") {
            warningPopup.close()
        }
    }

    function setAllSensorsValue(){
        for(var i=1 ; i <= 16; i++){
            eachSensor.push(i)
        }
        sensorList0.model = eachSensor
        sensorList1.model = eachSensor
        sensorList2.model = eachSensor
        sensorList3.model = eachSensor
        sensorList4.model = eachSensor
        sensorList5.model = eachSensor
        sensorList6.model = eachSensor
        sensorList7.model = eachSensor
        sensorListTouch.model = eachSensor
        sensorListProximity.model = eachSensor
        sensorListLight.model = eachSensor
        sensorListTemp.model = eachSensor
        sensorListA.model = eachSensor
        sensorListB.model = eachSensor
        sensorListC.model = eachSensor
        sensorListD.model = eachSensor

    }



    property var touch_second_gain_states: platformInterface.touch_second_gain_state
    onTouch_second_gain_statesChanged: {
        setAllSensorsValue()
        if(touch_second_gain_states.state === "enabled"){
            sensorList0.enabled = true
            sensorList0.opacity = 1.0
            sensorList1.enabled = true
            sensorList1.opacity = 1.0
            sensorList2.enabled = true
            sensorList2.opacity = 1.0
            sensorList3.enabled = true
            sensorList3.opacity = 1.0
            sensorList4.enabled = true
            sensorList4.opacity = 1.0
            sensorList5.enabled = true
            sensorList5.opacity = 1.0
            sensorList6.enabled = true
            sensorList6.opacity = 1.0
            sensorList7.enabled = true
            sensorList7.opacity = 1.0
            sensorListTouch.enabled = true
            sensorListTouch.opacity = 1.0
            sensorListProximity.enabled = true
            sensorListProximity.opacity = 1.0
            sensorListLight.enabled = true
            sensorListLight.opacity = 1.0
            sensorListTemp.enabled = true
            sensorListTemp.opacity = 1.0
            sensorListA.enabled = true
            sensorListA.opacity = 1.0
            sensorListB.enabled = true
            sensorListB.opacity = 1.0
            sensorListC.enabled = true
            sensorListC.opacity = 1.0
            sensorListD.enabled = true
            sensorListD.opacity = 1.0
        }
        else if(touch_second_gain_states.state === "disabled"){
            sensorList0.enabled = false
            sensorList0.opacity = 1.0
            sensorList1.enabled = false
            sensorList1.opacity = 1.0
            sensorList2.enabled = false
            sensorList2.opacity = 1.0
            sensorList3.enabled = false
            sensorList3.opacity = 1.0
            sensorList4.enabled = false
            sensorList4.opacity = 1.0
            sensorList5.enabled = false
            sensorList5.opacity = 1.0
            sensorList6.enabled = false
            sensorList6.opacity = 1.0
            sensorList7.enabled = false
            sensorList7.opacity = 1.0
            sensorListTouch.enabled = false
            sensorListTouch.opacity = 1.0
            sensorListProximity.enabled = false
            sensorListProximity.opacity = 1.0
            sensorListLight.enabled = false
            sensorListLight.opacity = 1.0
            sensorListTemp.enabled = false
            sensorListTemp.opacity = 1.0
            sensorListA.enabled = false
            sensorListA.opacity = 1.0
            sensorListB.enabled = false
            sensorListB.opacity = 1.0
            sensorListC.enabled = false
            sensorListC.opacity = 1.0
            sensorListD.enabled = false
            sensorListD.opacity = 1.0
        }
        else {
            sensorList0.enabled = false
            sensorList0.opacity = 0.5
            sensorList1.enabled = false
            sensorList1.opacity = 0.5
            sensorList2.enabled = false
            sensorList2.opacity = 0.5
            sensorList3.enabled = false
            sensorList3.opacity = 0.5
            sensorList4.enabled = false
            sensorList4.opacity = 0.5
            sensorList5.enabled = false
            sensorList5.opacity = 0.5
            sensorList6.enabled = false
            sensorList6.opacity = 0.5
            sensorList7.enabled = false
            sensorList7.opacity = 0.5
            sensorListTouch.enabled = false
            sensorListTouch.opacity = 0.5
            sensorListProximity.enabled = false
            sensorListProximity.opacity = 0.5
            sensorListLight.enabled = false
            sensorListLight.opacity = 0.5
            sensorListTemp.enabled = false
            sensorListTemp.opacity = 0.5
            sensorListA.enabled = false
            sensorListA.opacity = 0.5
            sensorListB.enabled = false
            sensorListB.opacity = 0.5
            sensorListC.enabled = false
            sensorListC.opacity = 0.5
            sensorListD.enabled = false
            sensorListD.opacity = 0.5
        }

    }
    property var touch_second_gain_values: platformInterface.touch_second_gain_values
    onTouch_second_gain_valuesChanged: {

        for(var a = 0; a < sensorList0.model.length; ++a) {

            if(touch_second_gain_values.values[0] === sensorList0.model[a].toString()){
                console.log(a)
                sensorList0.currentIndex = a
                console.log(sensorList0.currentIndex)
            }
            if(touch_second_gain_values.values[1] === sensorList1.model[a].toString()){
                sensorList1.currentIndex = a
            }
            if(touch_second_gain_values.values[2] === sensorList2.model[a].toString()){
                sensorList2.currentIndex = a
            }
            if(touch_second_gain_values.values[2] === sensorList3.model[a].toString()){
                sensorList3.currentIndex = a
            }

            if(touch_second_gain_values.values[4] === sensorList4.model[a].toString()){
                sensorList4.currentIndex = a
            }

            if(touch_second_gain_values.values[5] === sensorList5.model[a].toString()){
                sensorList5.currentIndex = a
            }

            if(touch_second_gain_values.values[6] === sensorList6.model[a].toString()){
                sensorList6.currentIndex = a
            }
            if(touch_second_gain_values.values[7] === sensorList7.model[a].toString()){
                sensorList7.currentIndex = a
            }
            if(touch_second_gain_values.values[8] === sensorListTouch.model[a].toString()){
                sensorListTouch.currentIndex = a
            }
            if(touch_second_gain_values.values[9] === sensorListProximity.model[a].toString()){
                sensorListProximity.currentIndex = a
            }
            if(touch_second_gain_values.values[10] === sensorListLight.model[a].toString()){
                sensorListLight.currentIndex = a
            }
            if(touch_second_gain_values.values[11] === sensorListTemp.model[a].toString()){
                sensorListTemp.currentIndex = a
            }

            if(touch_second_gain_values.values[12] === sensorListA.model[a].toString()){
                sensorListA.currentIndex = a
            }
            if(touch_second_gain_values.values[13] === sensorListB.model[a].toString()){
                sensorListB.currentIndex = a
            }
            if(touch_second_gain_values.values[14] === sensorListC.model[a].toString()){
                sensorListC.currentIndex = a
            }
            if(touch_second_gain_values.values[15] === sensorListD.model[a].toString()){
                sensorListD.currentIndex = a
            }
        }
    }

    property var touch_cin_thres_values: platformInterface.touch_cin_thres_values
    onTouch_cin_thres_valuesChanged: {
        threshold0.text = touch_cin_thres_values.values[0]
        threshold1.text = touch_cin_thres_values.values[1]
        threshold2.text = touch_cin_thres_values.values[2]
        threshold3.text = touch_cin_thres_values.values[3]
        threshold4.text = touch_cin_thres_values.values[4]
        threshold5.text = touch_cin_thres_values.values[5]
        threshold6.text = touch_cin_thres_values.values[6]
        threshold7.text = touch_cin_thres_values.values[7]
        thresholdTouch.text = touch_cin_thres_values.values[8]
        thresholdProximity.text = touch_cin_thres_values.values[9]
        thresholdLight.text = touch_cin_thres_values.values[10]
        thresholdTemp.text = touch_cin_thres_values.values[11]
        thresholdA.text = touch_cin_thres_values.values[12]
        thresholdB.text = touch_cin_thres_values.values[13]
        thresholdC.text = touch_cin_thres_values.values[14]
        thresholdD.text = touch_cin_thres_values.values[15]
    }


    property var touch_cin_thres_state: platformInterface.touch_cin_thres_state
    onTouch_cin_thres_stateChanged: {
        if(touch_cin_thres_state.state === "enabled" ) {
            threshold0Container.enabled = true
            threshold0Container.opacity = 1.0
            threshold1Container.enabled = true
            threshold1Container.opacity = 1.0
            threshold2Container.enabled = true
            threshold2Container.opacity = 1.0
            threshold3Container.enabled = true
            threshold3Container.opacity = 1.0
            threshold4Container.enabled = true
            threshold4Container.opacity = 1.0
            threshold5Container.enabled = true
            threshold5Container.opacity = 1.0
            threshold6Container.enabled = true
            threshold6Container.opacity = 1.0
            threshold7Container.enabled = true
            threshold7Container.opacity = 1.0
            thresholTouch3Container.enabled = true
            thresholProximityContainer.opacity = 1.0
            thresholLightContainer.enabled = true
            thresholLightContainer.opacity  = 1.0
            thresholLightContainer.enabled = true
            thresholLightContainer.opacity = 1.0
            thresholdAContainer.enabled = true
            thresholdAContainer.opacity  = 1.0
            thresholdBContainer.enabled = true
            thresholdBContainer.opacity  = 1.0
            thresholdCContainer.enabled = true
            thresholdCContainer.opacity  = 1.0
            thresholdDContainer.enabled = true
            thresholdDContainer.opacity  = 1.0
        }
        else if (touch_cin_thres_state.state === "disabled") {
            threshold0Container.enabled = false
            threshold0Container.opacity = 1.0
            threshold1Container.enabled = false
            threshold1Container.opacity = 1.0
            threshold2Container.enabled = false
            threshold2Container.opacity = 1.0
            threshold3Container.enabled = false
            threshold3Container.opacity = 1.0
            threshold4Container.enabled = false
            threshold4Container.opacity = 1.0
            threshold5Container.enabled = false
            threshold5Container.opacity = 1.0
            threshold6Container.enabled = false
            threshold6Container.opacity = 1.0
            threshold7Container.enabled = false
            threshold7Container.opacity = 1.0
            thresholTouch3Container.enabled = false
            thresholProximityContainer.opacity = 1.0
            thresholLightContainer.enabled = false
            thresholLightContainer.opacity  = 1.0
            thresholLightContainer.enabled = false
            thresholLightContainer.opacity = 1.0
            thresholdAContainer.enabled = false
            thresholdAContainer.opacity  = 1.0
            thresholdBContainer.enabled = false
            thresholdBContainer.opacity  = 1.0
            thresholdCContainer.enabled = false
            thresholdCContainer.opacity  = 1.0
            thresholdDContainer.enabled = false
            thresholdDContainer.opacity  = 1.0
        }
        else {
            threshold0Container.enabled = false
            threshold0Container.opacity = 0.5
            threshold1Container.enabled = false
            threshold1Container.opacity = 0.5
            threshold2Container.enabled = false
            threshold2Container.opacity = 0.5
            threshold3Container.enabled = false
            threshold3Container.opacity = 0.5
            threshold4Container.enabled = false
            threshold4Container.opacity = 0.5
            threshold5Container.enabled = false
            threshold5Container.opacity = 0.5
            threshold6Container.enabled = false
            threshold6Container.opacity = 0.5
            threshold7Container.enabled = false
            threshold7Container.opacity = 0.5
            thresholTouch3Container.enabled = false
            thresholProximityContainer.opacity = 0.5
            thresholLightContainer.enabled = false
            thresholLightContainer.opacity  = 0.5
            thresholLightContainer.enabled = false
            thresholLightContainer.opacity = 0.5
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

    property var touch_cin_en_values: platformInterface.touch_cin_en_values
    onTouch_cin_en_valuesChanged: {
        touch_cin_en_values.values[0] === "0" ? enable0Switch.checked = false : enable0Switch.checked = true
        touch_cin_en_values.values[1] === "0" ? enable1Switch.checked = false : enable1Switch.checked = true
        touch_cin_en_values.values[2] === "0" ? enable2Switch.checked = false : enable2Switch.checked = true
        touch_cin_en_values.values[3] === "0" ? enable3Switch.checked = false : enable3Switch.checked = true
        touch_cin_en_values.values[4] === "0" ? enable4Switch.checked = false : enable4Switch.checked = true
        touch_cin_en_values.values[5] === "0" ? enable5Switch.checked = false : enable5Switch.checked = true
        touch_cin_en_values.values[6] === "0" ? enable6Switch.checked = false : enable6Switch.checked = true
        touch_cin_en_values.values[7] === "0" ? enable7Switch.checked = false : enable7Switch.checked = true
        touch_cin_en_values.values[8] === "0" ? enableTouchSwitch.checked = false : enableTouchSwitch.checked = true
        touch_cin_en_values.values[9] === "0" ? enableProximitySwitch.checked = false : enableProximitySwitch.checked = true
        touch_cin_en_values.values[10] === "0" ? enableLightSwitch.checked = false : enableLightSwitch.checked = true
        touch_cin_en_values.values[11] === "0" ? enableTemptSwitch.checked = false : enableTemptSwitch.checked = true
        touch_cin_en_values.values[12] === "0" ? enableASwitch.checked = false : enableASwitch.checked = true
        touch_cin_en_values.values[13] === "0" ? enableBSwitch.checked = false : enableBSwitch.checked = true
        touch_cin_en_values.values[14] === "0" ? enableCSwitch.checked = false : enableCSwitch.checked = true
        touch_cin_en_values.values[15] === "0" ? enableDSwitch.checked = false : enableDSwitch.checked = true
    }


    property var touch_register_cin_notification: platformInterface.touch_register_cin
    onTouch_register_cin_notificationChanged: {
        sensordata0.text = touch_register_cin_notification.data[0]
        if(touch_register_cin_notification.act[0] === 0 && touch_register_cin_notification.err[0] === 0)
            ldoTempLight.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[0] === 1) {
            if (touch_register_cin_notification.err[0] === 1)
                ldoTempLight.status =SGStatusLight.Red
            else ldoTempLight.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[0] === 1)
            ldoTempLight.status =SGStatusLight.Red

        sensordata1.text = touch_register_cin_notification.data[1]
        if(touch_register_cin_notification.act[1] === 0 && touch_register_cin_notification.err[1] === 0)
            ldoTempLight1.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[1] === 1) {
            if (touch_register_cin_notification.err[1] === 1)
                ldoTempLight1.status =SGStatusLight.Red
            else ldoTempLight1.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[1] === 1)
            ldoTempLight1.status =SGStatusLight.Red

        sensordata2.text = touch_register_cin_notification.data[2]
        if(touch_register_cin_notification.act[2] === 0 && touch_register_cin_notification.err[2] === 0)
            ldoTempLight2.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[2] === 1) {
            if (touch_register_cin_notification.err[2] === 1)
                ldoTempLight2.status =SGStatusLight.Red
            else ldoTempLight2.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[2] === 1)
            ldoTempLight2.status =SGStatusLight.Red

        sensordata3.text = touch_register_cin_notification.data[3]
        if(touch_register_cin_notification.act[3] === 0 && touch_register_cin_notification.err[3] === 0)
            ldoTempLight3.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[3] === 1) {
            if (touch_register_cin_notification.err[3] === 1)
                ldoTempLight3.status =SGStatusLight.Red
            else ldoTempLight3.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[3] === 1)
            ldoTempLight3.status =SGStatusLight.Red

        sensordata4.text = touch_register_cin_notification.data[4]
        if(touch_register_cin_notification.act[4] === 0 && touch_register_cin_notification.err[4] === 0)
            ldoTempLight4.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[4] === 1) {
            if (touch_register_cin_notification.err[4] === 1)
                ldoTempLight4.status =SGStatusLight.Red
            else ldoTempLight4.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[4] === 1)
            ldoTempLight4.status =SGStatusLight.Red

        sensordata5.text = touch_register_cin_notification.data[5]
        if(touch_register_cin_notification.act[5] === 0 && touch_register_cin_notification.err[5] === 0)
            ldoTempLight5.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[5] === 1) {
            if (touch_register_cin_notification.err[5] === 1)
                ldoTempLight5.status =SGStatusLight.Red
            else ldoTempLight5.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[5] === 1)
            ldoTempLight5.status =SGStatusLight.Red


        sensordata6.text = touch_register_cin_notification.data[6]
        if(touch_register_cin_notification.act[6] === 0 && touch_register_cin_notification.err[6] === 0)
            ldoTempLight6.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[6] === 1) {
            if (touch_register_cin_notification.err[6] === 1)
                ldoTempLight6.status =SGStatusLight.Red
            else ldoTempLight6.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[6] === 1)
            ldoTempLight6.status =SGStatusLight.Red

        sensordata7.text = touch_register_cin_notification.data[7]
        if(touch_register_cin_notification.act[7] === 0 && touch_register_cin_notification.err[7] === 0)
            ldoTempLight7.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[7] === 1) {
            if (touch_register_cin_notification.err[7] === 1)
                ldoTempLight7.status =SGStatusLight.Red
            else ldoTempLight7.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[7] === 1)
            ldoTempLight7.status =SGStatusLight.Red

        sensordataTouch.text = touch_register_cin_notification.data[8]
        if(touch_register_cin_notification.act[8] === 0 && touch_register_cin_notification.err[8] === 0)
            ldoTempLightTouch.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[8] === 1) {
            if (touch_register_cin_notification.err[8] === 1)
                ldoTempLightTouch.status =SGStatusLight.Red
            else ldoTempLightTouch.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[8] === 1)
            ldoTempLightTouch.status =SGStatusLight.Red

        sensordataProximity.text = touch_register_cin_notification.data[9]
        if(touch_register_cin_notification.act[9] === 0 && touch_register_cin_notification.err[9] === 0)
            ldoTempLightProximity.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[9] === 1) {
            if (touch_register_cin_notification.err[9] === 1)
                ldoTempLightProximity.status =SGStatusLight.Red
            else ldoTempLightProximity.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[9] === 1)
            ldoTempLightProximity.status =SGStatusLight.Red

        sensordataLight.text = touch_register_cin_notification.data[10]
        if(touch_register_cin_notification.act[10] === 0 && touch_register_cin_notification.err[10] === 0)
            ldoTempLightLed.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[10] === 1) {
            if (touch_register_cin_notification.err[10] === 1)
                ldoTempLightLed.status =SGStatusLight.Red
            else ldoTempLightLed.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[10] === 1)
            ldoTempLightLed.status =SGStatusLight.Red

        sensordataTemp.text = touch_register_cin_notification.data[11]
        if(touch_register_cin_notification.act[11] === 0 && touch_register_cin_notification.err[11] === 0)
            ldoTempLed.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[11] === 1) {
            if (touch_register_cin_notification.err[11] === 1)
                ldoTempLed.status =SGStatusLight.Red
            else ldoTempLed.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[11] === 1)
            ldoTempLed.status =SGStatusLight.Red


        sensordataA.text = touch_register_cin_notification.data[12]
        if(touch_register_cin_notification.act[12] === 0 && touch_register_cin_notification.err[12] === 0)
            ldoALed.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[12] === 1) {
            if (touch_register_cin_notification.err[12] === 1)
                ldoALed.status =SGStatusLight.Red
            else ldoALed.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[12] === 1)
            ldoALed.status =SGStatusLight.Red

        sensordataB.text = touch_register_cin_notification.data[13]
        if(touch_register_cin_notification.act[13] === 0 && touch_register_cin_notification.err[13] === 0)
            ldoBLed.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[13] === 1) {
            if (touch_register_cin_notification.err[13] === 1)
                ldoBLed.status =SGStatusLight.Red
            else ldoBLed.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[13] === 1)
            ldoBLed.status =SGStatusLight.Red

        sensordataC.text = touch_register_cin_notification.data[14]
        if(touch_register_cin_notification.act[14] === 0 && touch_register_cin_notification.err[14] === 0)
            ldoCLed.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[14] === 1) {
            if (touch_register_cin_notification.err[14] === 1)
                ldoCLed.status =SGStatusLight.Red
            else ldoCLed.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[14] === 1)
            ldoCLed.status =SGStatusLight.Red


        sensordataD.text = touch_register_cin_notification.data[15]
        if(touch_register_cin_notification.act[15] === 0 && touch_register_cin_notification.err[15] === 0)
            ldoDLed.status = SGStatusLight.Off
        else if(touch_register_cin_notification.act[15] === 1) {
            if (touch_register_cin_notification.err[15] === 1)
                ldoDLed.status =SGStatusLight.Red
            else ldoDLed.status =SGStatusLight.Green
        }
        else if(touch_register_cin_notification.err[15] === 1)
            ldoDLed.status =SGStatusLight.Red

    }


    RowLayout {
        anchors.fill: parent


        anchors {
            fill: parent
            top:parent.top
            left:parent.Left
            leftMargin: 9
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 15
        }

        Rectangle {
            Layout.preferredWidth: parent.width/2.9
            Layout.fillHeight: true


            ColumnLayout {
                anchors.fill:parent
                spacing: 15
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text {
                        id: leftHeading
                        text: "Enable, Gain, & Threshold Settings"
                        font.bold: true
                        font.pixelSize: ratioCalc * 15
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
                            top: leftHeading.bottom
                            topMargin: 7
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            Layout.preferredWidth: parent.width/3.5
                            Layout.fillHeight: true

                             SGText {
                                 anchors.centerIn: parent
                                 fontSizeMultiplier: ratioCalc * 0.9
                                 font.bold : true
                                 text: "Activation"
                             }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "Enable"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "2nd Gain"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGText {
                                anchors.centerIn: parent

                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "Data"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "Threshold"
                            }
                        }

                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("0") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGText {
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN0"
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter


                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLight
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }
                        Rectangle {
                            id:enable0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSwitch {
                                id: enable0Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(0,1)
                                    else  platformInterface.touch_cin_en_value.update(0,0)
                                }


                            }

                        }

                        Rectangle {
                            id: sensorList0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorList0
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                //width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(0,currentText)
                                }

                            }


                        }

                        Rectangle {
                            id: sensordata0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordata0
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                height: sensordata0Container.height
                                width: sensordata0Container.width/1.5
                            }

                        }

                        Rectangle {
                            id: threshold0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: threshold0
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                width: threshold0Container.width/1.5
                                infoBoxHeight: threshold0Container.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(0,text)
                                }

                            }
                        }

                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("1") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN1"

                                    }
                                }

                            }

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true
                            SGStatusLight {
                                id: ldoTempLight1
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }


                        }
                        Rectangle {
                            id:enable1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable1Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(1,1)
                                    else  platformInterface.touch_cin_en_value.update(1,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorList1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList1
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                //width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(1,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordata1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordata1
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: threshold1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: threshold1
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(1,text)
                                }
                            }
                        }


                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("2") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN2"

                                    }
                                }
                            }

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLight2
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }


                        }
                        Rectangle {
                            id:enable2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable2Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(2,1)
                                    else  platformInterface.touch_cin_en_value.update(2,0)
                                }
                            }
                        }

                        Rectangle {
                            id: sensorList2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList2
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                // width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(2,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordata2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata2
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: threshold2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSubmitInfoBox {
                                id: threshold2
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(2,text)
                                }
                            }
                        }

                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout{
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("3") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN3"
                                    }
                                }

                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true


                            SGStatusLight {
                                id: ldoTempLight3
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }



                        }
                        Rectangle {
                            id:enable3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable3Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(3,1)
                                    else  platformInterface.touch_cin_en_value.update(3,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorList3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList3
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                //width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(3,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordata3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata3
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: threshold3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: threshold3
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(3,text)
                                }
                            }
                        }

                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("4") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN4"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true


                            SGStatusLight {
                                id: ldoTempLight4
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }

                        }
                        Rectangle {
                            id:enable4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSwitch {
                                id: enable4Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(4,1)
                                    else  platformInterface.touch_cin_en_value.update(4,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorList4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList4
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                //width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(4,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordata4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata4
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: threshold4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSubmitInfoBox {
                                id: threshold4
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(4,text)
                                }
                            }
                        }


                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("5") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN5"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLight5
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }

                        }
                        Rectangle {
                            id:enable5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable5Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(5,1)
                                    else  platformInterface.touch_cin_en_value.update(5,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorList5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorList5
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                // width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(5,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordata5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordata5
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: threshold5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: threshold5
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(5,text)
                                }
                            }
                        }


                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("6") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN6"
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter


                                    }
                                }
                            }

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLight6
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }
                        Rectangle {
                            id:enable6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable6Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(6,1)
                                    else  platformInterface.touch_cin_en_value.update(6,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorList6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList6
                                anchors.centerIn: parent
                                //width: parent.width/1.5
                                height: parent.height
                                fontSizeMultiplier: ratioCalc * 0.9
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(6,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordata6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordata6
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: threshold6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: threshold6
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(6,text)
                                }
                            }
                        }

                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("7") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN7"
                                    }
                                }
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLight7
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Rectangle {
                            id:enable7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSwitch {
                                id: enable7Switch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(7,1)
                                    else  platformInterface.touch_cin_en_value.update(7,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorList7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList7
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                //width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(7,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordata7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata7
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: threshold7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSubmitInfoBox {
                                id: threshold7
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(7,text)
                                }
                            }
                        }

                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("Touch") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN8"
                                    }
                                }
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLightTouch
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: 30

                            }


                        }
                        Rectangle {
                            id:enableTouchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true



                            SGSwitch {
                                id: enableTouchSwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(8,1)
                                    else  platformInterface.touch_cin_en_value.update(8,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorListTouchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListTouch
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                //width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(8,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataTouchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordataTouch
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholTouch3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSubmitInfoBox {
                                id: thresholdTouch
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(8,text)
                                }
                            }
                        }


                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGText {
                                        text: "<b>" + qsTr("Proximity") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN9"
                                    }
                                }
                            }

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLightProximity
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }

                        }
                        Rectangle {
                            id:enableProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableProximitySwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(9,1)
                                    else  platformInterface.touch_cin_en_value.update(9,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorListProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListProximity
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                //width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(9,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataProximity
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: thresholdProximity
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(9,text)
                                }
                            }
                        }

                    }


                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("Light") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN10"
                                    }
                                }
                            }
                        }
                        Rectangle {
                            id: ldoLightContainer
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLightLed
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }

                        }
                        Rectangle {
                            id:enableLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSwitch {
                                id: enableLightSwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(10,1)
                                    else  platformInterface.touch_cin_en_value.update(1,0)
                                }

                            }

                        }

                        Rectangle {
                            id: sensorListLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListLight
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                // width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(10,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordataLight
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSubmitInfoBox {
                                id: thresholdLight
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(10,text)
                                }
                            }
                        }

                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("Temperature") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN11"
                                    }
                                }
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoTempLed
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }


                        }
                        Rectangle {
                            id:enableTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableTemptSwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(11,1)
                                    else  platformInterface.touch_cin_en_value.update(11,0)
                                }
                            }
                        }

                        Rectangle {
                            id: sensorListTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListTemp
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                // width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(11,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataTemp
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholdTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: thresholdTemp
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(11,text)
                                }
                            }
                        }


                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("A") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN12"
                                    }
                                }
                            }

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoALed
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                            }

                        }
                        Rectangle {
                            id:enableAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableASwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(12,1)
                                    else  platformInterface.touch_cin_en_value.update(12,0)
                                }
                            }
                        }

                        Rectangle {
                            id: sensorListAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListA
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                // width: parent.width/1.5
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(12,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataA
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholdAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: thresholdA
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(12,text)
                                }
                            }
                        }

                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("B") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN13"
                                    }
                                }
                            }

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoBLed
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }
                        Rectangle {
                            id:enableBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableBSwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(13,1)
                                    else  platformInterface.touch_cin_en_value.update(13,0)
                                }
                            }
                        }

                        Rectangle {
                            id: sensorListBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListB
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9

                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(13,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataB
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholdBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: thresholdB
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(13,text)
                                }
                            }
                        }

                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("C") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN14"
                                    }
                                }
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoCLed
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }
                        Rectangle {
                            id:enableCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableCSwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(14,1)
                                    else  platformInterface.touch_cin_en_value.update(14,0)
                                }
                            }
                        }

                        Rectangle {
                            id: sensorListCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListC
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                height: parent.height
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(14,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataC
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholdCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: thresholdC
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(14,text)
                                }
                            }
                        }


                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        text: "<b>" + qsTr("D") + "</b>"
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGText {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc * 0.9
                                        font.bold : true
                                        text: "CIN15"
                                    }
                                }
                            }

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/9
                            Layout.fillHeight: true

                            SGStatusLight {
                                id: ldoDLed
                                width: 30
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }
                        Rectangle {
                            id:enableDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableDSwitch
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
                                onToggled: {
                                    if(checked)
                                        platformInterface.touch_cin_en_value.update(15,1)
                                    else  platformInterface.touch_cin_en_value.update(15,0)
                                }
                            }
                        }

                        Rectangle {
                            id: sensorListDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListD
                                anchors.centerIn: parent
                                height: parent.height
                                fontSizeMultiplier: ratioCalc * 0.9
                                onActivated: {
                                    platformInterface.touch_second_gain_value.update(15,currentText)
                                }
                            }
                        }

                        Rectangle {
                            id: sensordataDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataD
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: thresholdDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSubmitInfoBox {
                                id: thresholdD
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/1.5
                                infoBoxHeight: parent.height
                                onAccepted: {
                                    platformInterface.touch_cin_thres_value.update(15,text)
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
            AdvanceViewSettings { }

        }
    }
}


