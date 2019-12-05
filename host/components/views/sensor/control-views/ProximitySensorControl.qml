import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root

    property bool debugLayout: false
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    property var sensorArray: []
    property var eachSensor: []
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    property var proximity_sensor_notification: platformInterface.lc717a10ar_cin_act_proximity.cin
    onProximity_sensor_notificationChanged: {
        if(proximity_sensor_notification[0] === 0){
            sensor13.status = "off"
        }
        else {
            sensor13.status = "green"
        }

        if(proximity_sensor_notification[1] === 0){
            sensor14.status = "off"
        }
        else {
            sensor14.status = "green"
        }

        if(proximity_sensor_notification[2] === 0){
            sensor15.status = "off"
        }
        else {
            sensor15.status = "green"
        }
        if(proximity_sensor_notification[3] === 0){
            sensor16.status = "off"
        }
        else {
            sensor16.status = "green"
        }
    }

    function setSensorsValue() {
        for(var i = 1600; i >= 100; i -= 100){
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
            if(i== 16) {
                eachSensor.push(i + "Max")
            }
            else if(i == 1) {
                eachSensor.push(i + "Min")
            }
            else {
                eachSensor.push(i)
            }
        }
        sensorList13.model = eachSensor
        sensorList14.model = eachSensor
        sensorList15.model = eachSensor
        sensorList16.model = eachSensor
    }

    Component.onCompleted: {
        setSensorsValue()
        setAllSensorsValue()
    }


    Rectangle {
        id: proximityContainer
        width: 800 * ratioCalc
        height: ratioCalc * 470
        color: "transparent"
        border.color: "gray"
        border.width: 2
        radius: 10
        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        SGComboBox {
            id: sensorList
            anchors{
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }

            label: "Sensors 1-8 \n 1st Gain"
            fontSize: 30 * ratioCalc
            comboBoxWidth:ratioCalc * 100
            comboBoxHeight: ratioCalc * 30

        }

        Button{
            id: reset
            width: 150 * ratioCalc
            height: 50 * ratioCalc
            text: qsTr("Reset")
            anchors{
                horizontalCenter: sensorList.horizontalCenter
                top: sensorList.bottom
                topMargin: 30
            }
            onClicked: {
                controlContainer.currentIndex = 0
                navTabs.currentIndex = 0
                platformInterface.reset_touch_mode.update()
            }
        }

        ColumnLayout {
            anchors {
                left: sensorList.right
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
            width: parent.width/2
            height: parent.height/1.5
            spacing: 6
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                color: "transparent"
            }

            RowLayout {
                spacing: 20
                Layout.fillHeight: true
                Layout.fillWidth: true
                Rectangle{
                    Layout.preferredWidth:ratioCalc * 150
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
                        anchors.bottom: parent.bottom
                        font.pixelSize: ratioCalc * 20
                    }
                }
            }
            RowLayout{
                spacing: 2
                Layout.fillHeight: true
                Layout.fillWidth: true

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight{
                        id: sensor13
                        label: "Sensor 13"
                        fontSize: ratioCalc * 30
                        anchors.centerIn: parent
                        lightSize: ratioCalc * 30
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGComboBox {
                        id: sensorList13
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
                    }
                }

            }


            RowLayout{
                spacing: 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight{
                        id: sensor14
                        label: "Sensor 14"
                        fontSize: ratioCalc * 30
                        anchors.centerIn: parent
                        lightSize: ratioCalc * 30
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGComboBox {
                        id: sensorList14
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30

                    }
                }
            }


            RowLayout{
                spacing: 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight{
                        id: sensor15
                        label: "Sensor 15"
                        fontSize: ratioCalc * 30
                        anchors.centerIn: parent
                        lightSize: ratioCalc * 30

                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGComboBox {
                        id: sensorList15
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30
                    }
                }
            }

            RowLayout{
                spacing: 2
                Layout.fillHeight: true
                Layout.fillWidth: true

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight{
                        id: sensor16
                        label: "Sensor 16"
                        fontSize: ratioCalc * 30
                        anchors.centerIn: parent
                        lightSize: ratioCalc * 30
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGComboBox {
                        id: sensorList16
                        anchors.centerIn: parent
                        comboBoxWidth:ratioCalc * 100
                        comboBoxHeight: ratioCalc * 30

                    }
                }
            }
        }
    }
}
