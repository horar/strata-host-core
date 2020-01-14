import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    property var sensorArray: []
    property var eachSensor: []


    property var proximity_sensor_notification: platformInterface.proximity_cin
    onProximity_sensor_notificationChanged: {
        //Sensor 1
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


        //sensor 2
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

    property var touch_cin_thres_values: platformInterface.touch_cin_thres_values
    onTouch_cin_thres_valuesChanged: {
        thresholdA.text = touch_cin_thres_values.values[12]
        thresholdB.text = touch_cin_thres_values.values[13]
        thresholdC.text = touch_cin_thres_values.values[14]
        thresholdD.text = touch_cin_thres_values.values[15]
    }


    property var touch_cin_thres_state: platformInterface.touch_cin_thres_state
    onTouch_cin_thres_stateChanged: {
        if(touch_cin_thres_state.state === "enabled" ) {

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

    function setAllSensorsValue(){

        for(var i=1 ; i <= 16; i++){
            eachSensor.push(i)
        }
        sensorListA.model = eachSensor
        sensorListB.model = eachSensor
        sensorListC.model = eachSensor
        sensorListD.model = eachSensor

    }


    property var touch_first_gain8_15_values: platformInterface.touch_first_gain8_15_values
    onTouch_first_gain8_15_valuesChanged: {
        sensorList.model = touch_first_gain8_15_values.values
    }

    property var touch_first_gain8_15_value: platformInterface.touch_first_gain8_15_value
    onTouch_first_gain8_15_valueChanged: {
        for(var i = 0; i < sensorList.model.length; ++i) {
            if(i === 0 || i === 15) {
                if(touch_first_gain8_15_value.value === sensorList.model[i].slice(0,-3).toString()){
                    sensorList.currentIndex = i
                }
            }
            else {
                if(touch_first_gain8_15_value.value === sensorList.model[i].toString()){
                    sensorList.currentIndex = i
                }
            }
        }
    }

    property var touch_first_gain8_15_state: platformInterface.touch_first_gain8_15_state
    onTouch_first_gain8_15_stateChanged: {

        if(touch_first_gain8_15_state.state === "enabled"){
            proximitySensorContainer2.enabled = true
        }
        else if(touch_first_gain8_15_state.state === "disabled"){
            proximitySensorContainer2.enabled = false
        }
        else {
            proximitySensorContainer2.enabled = false
            proximitySensorContainer2.opacity = 0.5
        }
    }

    property var touch_second_gain_values: platformInterface.touch_second_gain_values
    onTouch_second_gain_valuesChanged: {

        setAllSensorsValue()
        for(var a = 0; a < sensorListA.model.length; ++a) {
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

    property var touch_hw_reset_value: platformInterface.touch_hw_reset_value
    onTouch_hw_reset_valueChanged: {
        if(touch_hw_reset_value.value === "1") {
            warningPopup.close()
        }
    }

    property var touch_calerr_caption: platformInterface.touch_calerr_caption
    onTouch_calerr_captionChanged:  {
        calerrLabel.text = touch_calerr_caption.caption
    }

    property var touch_calerr_value: platformInterface.touch_calerr_value
    onTouch_calerr_valueChanged: {
        if(touch_calerr_value.value === "0")
            calerr.status = SGStatusLight.Off
        else calerr.status = SGStatusLight.Red
    }

    property var touch_calerr_state: platformInterface.touch_calerr_state
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

    property var touch_syserr_value: platformInterface.touch_syserr_value
    onTouch_syserr_valueChanged: {
        if(touch_syserr_value.value === "0")
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
        width:parent.width/1.5
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

                        Rectangle {
                            id: proximitySensorContainer2
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"

                            SGAlignedLabel {
                                id: sensorListLabel
                                target: sensorList
                                text: "Sensors 8-15 \n 1st Gain (fF)"
                                fontSizeMultiplier: ratioCalc * 1.2
                                alignment:  SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                font.bold: true
                                SGComboBox {
                                    id: sensorList
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onActivated: {
                                        if(currentIndex === 0 || currentIndex === 15)
                                            platformInterface.set_touch_first_gain8_15_value.update(currentText.slice(0,-3))
                                        else  platformInterface.set_touch_first_gain8_15_value.update(currentText)
                                    }

                                }
                            }

                        }

                        Rectangle{
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
                                        platformInterface.touch_reset.update()
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
                        //topMargin: 5
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
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                Text {
                                    id: label1
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
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGComboBox {
                                    id: sensorListA
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
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
                                    onAccepted: {
                                        platformInterface.touch_cin_thres_value.update(12,text)
                                    }

                                }
                            }

                            Rectangle {
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
                                    onAccepted: {
                                        platformInterface.touch_cin_thres_value.update(13,text)
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
                                    onAccepted: {
                                        platformInterface.touch_cin_thres_value.update(14,text)
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
                                    onAccepted: {
                                        platformInterface.touch_cin_thres_value.update(15,text)
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



