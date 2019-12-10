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
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    property var sensorArray: []
    property var eachSensor: []

    property var touch_sensor_notification: platformInterface.lc717a10ar_cin_act_touch.cin
    onTouch_sensor_notificationChanged: {
        if(touch_sensor_notification[0] === 0){
            sensor1.status = SGStatusLight.Off
        }
        else {
            sensor1.status =SGStatusLight.Green
        }

        if(touch_sensor_notification[1] === 0){
            sensor2.status = SGStatusLight.Off
        }
        else {
            sensor2.status = SGStatusLight.Green
        }

        if(touch_sensor_notification[2] === 0){
            sensor3.status = SGStatusLight.Off
        }
        else {
            sensor3.status = SGStatusLight.Green
        }
        if(touch_sensor_notification[3] === 0){
            sensor4.status = SGStatusLight.Off
        }
        else {
            sensor4.status = SGStatusLight.Green
        }
        if(touch_sensor_notification[4] === 0){
            sensor5.status = SGStatusLight.Off
        }
        else {
            sensor5.status = SGStatusLight.Green
        }
        if(touch_sensor_notification[5] === 0){
            sensor6.status = SGStatusLight.Off
        }
        else {
            sensor6.status = SGStatusLight.Green
        }
        if(touch_sensor_notification[6] === 0){
            sensor7.status = SGStatusLight.Off
        }
        else {
            sensor7.status = SGStatusLight.Green
        }
        if(touch_sensor_notification[7] === 0){
            sensor8.status = SGStatusLight.Off
        }
        else {
            sensor8.status = SGStatusLight.Green
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

        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            //leftMargin: 10
        }

        SGAlignedLabel {
            id: sensorListLabel
            target: sensorList
            text: "<b>" + qsTr("Sensors 1-8 1st Gain") + "</b>"
            fontSizeMultiplier: ratioCalc * 1.2
            alignment:  SGAlignedLabel.SideTopCenter
            anchors.centerIn: parent
            SGComboBox {
                id: sensorList
                fontSizeMultiplier: ratioCalc * 1.2

            }
        }

    }

    Rectangle {
        id: resetContainer
        width: 220 * ratioCalc
        height: 100 * ratioCalc
        anchors{
            top: touchSensorContainer1.bottom
            topMargin: 40
            horizontalCenter: touchSensorContainer1.horizontalCenter
        }

        SGButton{
            id: reset
            width: 150 * ratioCalc
            height: 50 * ratioCalc
            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
            roundedLeft: true
            roundedRight: true
            text: qsTr("Reset")
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

        }
    }

    Rectangle {
        id:errSetting
        width: parent.width/6
        height: parent.height/4
        anchors{
            left: touchSensorContainer1.right
            verticalCenter: parent.verticalCenter
        }
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

                    }
                }
            }
        }
    }

    Rectangle {
        id: touchSensorContainer2
        width: parent.width/2
        height: parent.height/1.5
        color: "transparent"
        //        border.color: "gray"
        //        border.width: 2
        //        radius: 10
        anchors{
            left: errSetting.right
            leftMargin: 10
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
                        font.pixelSize: ratioCalc * 20
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
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
                    SGAlignedLabel {
                        id: sensor1Label
                        target: sensor1
                        text: "<b>" + qsTr("Sensor 1") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        Layout.alignment: Qt.AlignCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor1
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
                        id: sensorList1
                        fontSizeMultiplier: ratioCalc * 1.2
                        anchors.centerIn: parent

                    }


                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGAlignedLabel {
                        id: sensor2Label
                        target: sensor2
                        text: "<b>" + qsTr("Sensor 2") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor2
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
                        id: sensorList2
                        fontSizeMultiplier: ratioCalc * 1.2
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
                        id: sensor3Label
                        target: sensor3
                        text: "<b>" + qsTr("Sensor 3") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor3
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
                        id: sensorList3
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                    }

                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: sensor4Label
                        target: sensor4
                        text: "<b>" + qsTr("Sensor 4") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor4
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
                        id: sensorList4
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
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
                        id: sensor5Label
                        target: sensor5
                        text: "<b>" + qsTr("Sensor 5") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor5
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
                        id: sensorList5
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                    }

                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"

                    SGAlignedLabel {
                        id: sensor6Label
                        target: sensor6
                        text: "<b>" + qsTr("Sensor 6") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor6
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
                        id: sensorList6
                        fontSizeMultiplier: ratioCalc * 1.2
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
                        id: sensor7Label
                        target: sensor7
                        text: "<b>" + qsTr("Sensor 7") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor7
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
                        id: sensorList7
                        fontSizeMultiplier: ratioCalc * 1.2
                        anchors.centerIn: parent
                    }

                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    SGAlignedLabel {
                        id: sensor8Label
                        target: sensor8
                        text: "<b>" + qsTr("Sensor 8") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        alignment:  SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        SGStatusLight{
                            id: sensor8
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
                        id: sensorList8
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                    }
                }
            }
        }
    }
}




