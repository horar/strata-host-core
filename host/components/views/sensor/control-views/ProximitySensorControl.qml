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

    function setSensorsValue() {
        for(var i = 1600; i >= 100; i-=100){

            if(i == 100) {
                sensorArray.push(i + "Max")
            }
            else if(i == 1600) {
                sensorArray.push(i + "Min")
            }
            else {
                sensorArray.push(i)
            }
        }
        sensorList.model = sensorArray
    }
    function setAllSensorsValue(){

        for(var i=1 ; i <= 16; i++){
            if(i == 16) {
                eachSensor.push(i + "Max")
            }
            else if(i == 1) {
                eachSensor.push(i + "Min")
            }
            else {
                eachSensor.push(i)
            }
        }
        sensorListA.model = eachSensor
        sensorListB.model = eachSensor
        sensorListC.model = eachSensor
        sensorListD.model = eachSensor

    }


    Component.onCompleted: {
        setSensorsValue()
        setAllSensorsValue()
    }

    Rectangle {
        width:parent.width/1.5
        height: parent.height/1.5
        anchors.centerIn: parent

        RowLayout{
            anchors.fill: parent
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Rectangle {
                    id: proximitySensorContainer2
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGAlignedLabel {
                        id: sensorListLabel
                        target: sensorList
                        text: "Sensors 1-8 \n 1st Gain"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideTopCenter
                        anchors.centerIn: parent
                        font.bold: true
                        SGComboBox {
                            id: sensorList
                            fontSizeMultiplier: ratioCalc * 1.2
                            onActivated: {
                                if(currentIndex === 0 || currentIndex === 15)
                                    platformInterface.touch_first_gain8_15.update(currentText.slice(0,-3))
                                else  platformInterface.touch_first_gain8_15.update(currentText)
                            }

                        }
                    }
                }

                Rectangle {
                    id: resetContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"


                    SGButton{
                        id: reset
                        width: parent.width/2
                        height: parent.height/4
                        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                        roundedLeft: true
                        roundedRight: true
                        text: qsTr("Reset")
                        anchors.centerIn: parent
                        onClicked: {
                            platformInterface.touch_reset.update()
                        }

                    }
                }
            }

            Rectangle {
                id:errSetting
                Layout.preferredHeight: parent.height/2
                Layout.fillWidth: true
                ColumnLayout {
                    anchors.fill:parent
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        SGAlignedLabel {
                            id: calerrLabel
                            target: calerr
                            text: "<b>" + qsTr("CALERR") + "</b>"
                            fontSizeMultiplier: ratioCalc * 1.2
                            alignment:  SGAlignedLabel.SideLeftCenter
                            Layout.alignment: Qt.AlignCenter
                            anchors.centerIn: parent
                            SGStatusLight{
                                id: calerr
                                height: 40 * ratioCalc
                                width: 40 * ratioCalc
                                status: SGStatusLight.Off
                                property var touch_calerr: platformInterface.touch_calerr.value
                                onTouch_calerrChanged: {
                                    if(touch_calerr === 0)
                                        calerr.status = SGStatusLight.Off
                                    else calerr.status = SGStatusLight.Red
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        SGAlignedLabel {
                            id: syserrLabel
                            target: syserr
                            text: "<b>" + qsTr("SYSERR") + "</b>"
                            fontSizeMultiplier: ratioCalc * 1.2
                            alignment:  SGAlignedLabel.SideLeftCenter
                            Layout.alignment: Qt.AlignCenter
                            anchors.centerIn: parent
                            SGStatusLight{
                                id: syserr
                                height: 40 * ratioCalc
                                width: 40 * ratioCalc
                                status: SGStatusLight.Off
                                property var touch_syserr: platformInterface.touch_syserr.value
                                onTouch_syserrChanged: {
                                    if(touch_syserr === 0)
                                        syserr.status = SGStatusLight.Off
                                    else syserr.status = SGStatusLight.Red
                                }


                            }
                        }
                    }
                }
            }

            Rectangle {
                id: proximitySensorSetting
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width/1.5

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
                                text: "<b>" + qsTr("Sensor A") + "</b>"
                                fontSizeMultiplier: ratioCalc * 1.2
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
                                    if(currentIndex === 0 || currentIndex === 15)
                                        platformInterface.touch_second_gain.update(12,currentText.slice(0,-3))
                                    else  platformInterface.touch_second_gain.update(12,currentText)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGInfoBox {
                                id: sensordataA
                                fontSizeMultiplier: ratioCalc * 1.2
                                width:parent.width/1.5
                                height:parent.height/2
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
                                text: "<b>" + qsTr("Sensor B") + "</b>"
                                fontSizeMultiplier: ratioCalc * 1.2
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
                                        platformInterface.touch_second_gain.update(13,currentText.slice(0,-3))
                                    else  platformInterface.touch_second_gain.update(13,currentText)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGInfoBox {
                                id: sensordataB
                                fontSizeMultiplier: ratioCalc * 1.2
                                width:parent.width/1.5
                                height:parent.height/2
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
                                text: "<b>" + qsTr("Sensor C") + "</b>"
                                fontSizeMultiplier: ratioCalc * 1.2
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
                                        platformInterface.touch_second_gain.update(14,currentText.slice(0,-3))
                                    else  platformInterface.touch_second_gain.update(14,currentText)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGInfoBox {
                                id: sensordataC
                                fontSizeMultiplier: ratioCalc * 1.2
                                width:parent.width/1.5
                                height:parent.height/2
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
                                text: "<b>" + qsTr("Sensor D") + "</b>"
                                fontSizeMultiplier: ratioCalc * 1.2
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
                                        platformInterface.touch_second_gain.update(15,currentText.slice(0,-3))
                                    else  platformInterface.touch_second_gain.update(15,currentText)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGInfoBox {
                                id: sensordataD
                                fontSizeMultiplier: ratioCalc * 1.2
                                width:parent.width/1.5
                                height:parent.height/2
                                anchors.centerIn: parent
                            }
                        }
                    }
                }
            }
        }
    }
}





