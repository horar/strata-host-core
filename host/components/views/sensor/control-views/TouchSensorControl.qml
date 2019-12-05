import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help


Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    property var sensorArray: []
    property var eachSensor: []

    property var touch_sensor_notification: platformInterface.lc717a10ar_cin_act_touch.cin
    onTouch_sensor_notificationChanged: {
        if(touch_sensor_notification[0] === 0){
            sensor1.status = "off"
        }
        else {
            sensor1.status = "green"
        }

        if(touch_sensor_notification[1] === 0){
            sensor2.status = "off"
        }
        else {
            sensor2.status = "green"
        }

        if(touch_sensor_notification[2] === 0){
            sensor3.status = "off"
        }
        else {
            sensor3.status = "green"
        }
        if(touch_sensor_notification[3] === 0){
            sensor4.status = "off"
        }
        else {
            sensor4.status = "green"
        }
        if(touch_sensor_notification[4] === 0){
            sensor5.status = "off"
        }
        else {
            sensor5.status = "green"
        }
        if(touch_sensor_notification[5] === 0){
            sensor6.status = "off"
        }
        else {
            sensor6.status = "green"
        }
        if(touch_sensor_notification[6] === 0){
            sensor7.status = "off"
        }
        else {
            sensor7.status = "green"
        }
        if(touch_sensor_notification[7] === 0){
            sensor8.status = "off"
        }
        else {
            sensor8.status = "green"
        }


    }

    //   property var touch_reset_notification: platformInterface.lc717a10ar_reset


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
        sensorList1.model = eachSensor
        sensorList2.model = eachSensor
        sensorList3.model = eachSensor
        sensorList4.model = eachSensor
        sensorList5.model = eachSensor
        sensorList6.model = eachSensor
        sensorList7.model = eachSensor
        sensorList8.model = eachSensor


    }


    Component.onCompleted: {
        setSensorsValue()
        setAllSensorsValue()


    }

    Rectangle{
        id: touchSensorContainer1
        width: 310 * ratioCalc
        height: 100 * ratioCalc
        color: "transparent"
        border.color: "gray"
        border.width: 2
        radius: 10
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 20
        }
        SGComboBox {
            id: sensorList
            anchors.centerIn: parent
            label: "Sensors 1-8 \n 1st Gain"
            fontSize: 25 * ratioCalc

            comboBoxWidth:ratioCalc * 100
            comboBoxHeight: ratioCalc * 30
        }

    }

    Rectangle {
        id: resetContainer
        width: 220 * ratioCalc
        height: 100 * ratioCalc
        color: "transparent"
        border.color: "gray"
        border.width: 2
        radius: 10
        anchors{
            top: touchSensorContainer1.bottom
            topMargin: 40
            horizontalCenter: touchSensorContainer1.horizontalCenter
        }

        Button{
            id: reset
            width: 150 * ratioCalc
            height: 50 * ratioCalc
            text: qsTr("Reset")
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

        }
    }

    Rectangle {
        id: touchSensorContainer2
        width: parent.width/1.5
        height: parent.height/1.5
        color: "transparent"
        //        border.color: "gray"
        //        border.width: 2
        //        radius: 10
        anchors{
            left: touchSensorContainer1.right
            leftMargin: 20
            verticalCenter: parent.verticalCenter
        }


        ColumnLayout {
            anchors.fill: parent
            spacing: 6
            RowLayout {
                spacing: 20
                Layout.fillHeight: true
                Layout.fillWidth: true
                Rectangle{
                    Layout.preferredWidth:ratioCalc * 200
                    Layout.preferredHeight: ratioCalc * 50
                    color: "transparent"
                }
                Rectangle {
                    Layout.preferredWidth:ratioCalc * 100
                    Layout.preferredHeight: ratioCalc * 50
                    color: "transparent"
                    Text {
                        id: label1
                        text: qsTr("2nd Gain")
                        font.bold: true
                        anchors.bottom: parent.bottom
                        font.pixelSize: ratioCalc * 20
                    }
                }
                Rectangle {
                    Layout.preferredWidth:ratioCalc * 200
                    Layout.preferredHeight: ratioCalc * 50
                    color: "transparent"
                }
                Rectangle {
                    Layout.preferredWidth:ratioCalc * 100
                    Layout.preferredHeight: ratioCalc * 50
                    color: "transparent"
                    Text {
                        id: label2
                        text: qsTr("2nd Gain")
                        font.bold: true
                        anchors.bottom: parent.bottom
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
                    SGStatusLight{
                        id: sensor1
                        label: "Sensor 1"
                        fontSize: ratioCalc * 30
                        //Layout.alignment: Qt.AlignCenter
                        lightSize: ratioCalc * 40
                        //anchors.fill:parent
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGComboBox {
                        id: sensorList1
                        //Layout.alignment: Qt.AlignCenter
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
                        anchors.centerIn: parent

                    }

                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGStatusLight{
                        id: sensor2
                        label: "Sensor 2"
                        fontSize: ratioCalc * 30
                        //Layout.alignment: Qt.AlignCenter
                        lightSize: ratioCalc * 40
                        anchors.centerIn: parent
                    }
                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGComboBox {
                        id: sensorList2
                        //Layout.alignment: Qt.AlignCenter
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
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
                    SGStatusLight{
                        id: sensor3
                        label: "Sensor 3"
                        fontSize: ratioCalc * 30
                        anchors.centerIn: parent
                        lightSize: ratioCalc * 40

                    }
                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGComboBox {
                        id: sensorList3
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
                    }

                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGStatusLight{
                        id: sensor4
                        label: "Sensor 4"
                        fontSize: ratioCalc * 30
                        anchors.centerIn: parent
                        lightSize: ratioCalc * 40
                    }

                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGComboBox {
                        id: sensorList4
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
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
                    SGStatusLight{
                        id: sensor5
                        label: "Sensor 5"
                        fontSize: ratioCalc * 30
                        lightSize: ratioCalc * 40
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGComboBox {
                        id: sensorList5
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
                    }

                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGStatusLight{
                        id: sensor6
                        label: "Sensor 6"
                        fontSize: ratioCalc * 30
                        anchors.centerIn: parent
                        lightSize: ratioCalc * 40

                    }

                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGComboBox {
                        id: sensorList6
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
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

                    SGStatusLight{
                        id: sensor7
                        label: "Sensor 7"
                        anchors.centerIn: parent
                        fontSize: ratioCalc * 30
                        lightSize: ratioCalc * 40
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGComboBox {
                        id: sensorList7
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
                    }

                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGStatusLight{
                        id: sensor8
                        label: "Sensor 8"
                        anchors.centerIn: parent
                        fontSize: ratioCalc * 30
                        lightSize: ratioCalc * 40

                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGComboBox {
                        id: sensorList8
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
                    }
                }
            }
        }
    }
}




