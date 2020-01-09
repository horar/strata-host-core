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




    property var touch_sensor_notification: platformInterface.touch_cin
    onTouch_sensor_notificationChanged: {
        //Sensor 1
        sensordata0.text = touch_sensor_notification.data[0]
        if(touch_sensor_notification.act[0] === 0 && touch_sensor_notification.err[0] === 0)
            sensor0.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[0] === 1) {
            if (touch_sensor_notification.err[0] === 1)
                sensor0.status =SGStatusLight.Red
            else sensor0.status =SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[0] === 1)
            sensor0.status =SGStatusLight.Red


        //sensor 2
        sensordata1.text = touch_sensor_notification.data[1]
        if(touch_sensor_notification.act[1] === 0 && touch_sensor_notification.err[1] === 0)
            sensor1.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[1] === 1) {
            if (touch_sensor_notification.err[1] === 1)
                sensor1.status = SGStatusLight.Red
            else sensor1.status = SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[1] === 1)
            sensor1.status =SGStatusLight.Red

        sensordata2.text = touch_sensor_notification.data[2]
        if(touch_sensor_notification.act[2] === 0 && touch_sensor_notification.err[2] === 0)
            sensor2.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[2] === 1) {
            if (touch_sensor_notification.err[2] === 1)
                sensor2.status = SGStatusLight.Red
            else sensor2.status = SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[2] === 1)
            sensor2.status =SGStatusLight.Red


        sensordata3.text = touch_sensor_notification.data[3]
        if(touch_sensor_notification.act[3] === 0 && touch_sensor_notification.err[3] === 0)
            sensor3.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[3] === 1) {
            if (touch_sensor_notification.err[3] === 1)
                sensor3.status = SGStatusLight.Red
            else sensor3.status = SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[3] === 1)
            sensor3.status =SGStatusLight.Red

        sensordata4.text = touch_sensor_notification.data[4]
        if(touch_sensor_notification.act[4] === 0 && touch_sensor_notification.err[4] === 0)
            sensor4.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[4] === 1) {
            if (touch_sensor_notification.err[4] === 1)
                sensor4.status = SGStatusLight.Red
            else sensor4.status = SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[4] === 1)
            sensor4.status =SGStatusLight.Red

        sensordata5.text = touch_sensor_notification.data[5]
        if(touch_sensor_notification.act[5] === 0 && touch_sensor_notification.err[5] === 0)
            sensor5.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[5] === 1) {
            if (touch_sensor_notification.err[5] === 1)
                sensor5.status = SGStatusLight.Red
            else sensor5.status = SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[5] === 1)
            sensor5.status =SGStatusLight.Red

        sensordata6.text = touch_sensor_notification.data[6]
        if(touch_sensor_notification.act[6] === 0 && touch_sensor_notification.err[6] === 0)
            sensor6.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[6] === 1) {
            if (touch_sensor_notification.err[6] === 1)
                sensor6.status = SGStatusLight.Red
            else sensor6.status = SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[6] === 1)
            sensor6.status =SGStatusLight.Red

        sensordata7.text = touch_sensor_notification.data[7]
        if(touch_sensor_notification.act[7] === 0 && touch_sensor_notification.err[7] === 0)
            sensor7.status = SGStatusLight.Off
        else if(touch_sensor_notification.act[7] === 1) {
            if (touch_sensor_notification.err[7] === 1)
                sensor7.status = SGStatusLight.Red
            else sensor7.status = SGStatusLight.Green
        }
        else if(touch_sensor_notification.err[7] === 1)
            sensor7.status =SGStatusLight.Red

    }

    property var touch_hw_reset_value: platformInterface.touch_hw_reset_value
    onTouch_hw_reset_valueChanged: {
        if(touch_hw_reset_value.value === "1") {
            //warningPopup.close()
        }
    }

    //    Popup{
    //        id: warningPopup
    //        width: root.width/3
    //        height: root.height/5
    //        anchors.centerIn: root
    //        modal: true
    //        focus: true
    //        closePolicy:Popup.NoAutoClose
    //        background: Rectangle{
    //            anchors.fill:parent
    //            color: "black"
    //            anchors.centerIn: parent

    //        }

    //        Rectangle {
    //            id: warningBox
    //            color: "red"
    //            anchors {
    //                top: parent.top
    //                topMargin: 20
    //            }
    //            anchors.horizontalCenter: parent.horizontalCenter
    //            width: (parent.width) - 10
    //            height: parent.height/3
    //            Text {
    //                id: warningText
    //                anchors.centerIn: parent
    //                text: "<b>Hardware is getting reset. </b>"
    //                font.pixelSize: (parent.width + parent.height)/ 32
    //                color: "white"
    //            }

    //            Text {
    //                id: warningIcon3
    //                anchors {
    //                    right: warningText.left
    //                    verticalCenter: warningText.verticalCenter
    //                    rightMargin: 10
    //                }
    //                text: "\ue80e"
    //                font.family: Fonts.sgicons
    //                font.pixelSize: (parent.width + parent.height)/ 15
    //                color: "white"
    //            }

    //            Text {
    //                id: warningIcon4
    //                anchors {
    //                    left: warningText.right
    //                    verticalCenter: warningText.verticalCenter
    //                    leftMargin: 10
    //                }
    //                text: "\ue80e"
    //                font.family: Fonts.sgicons
    //                font.pixelSize: (parent.width + parent.height)/ 15
    //                color: "white"
    //            }
    //        }
    //    }



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
    }

    property var touch_first_gain0_7_caption: platformInterface.touch_first_gain0_7_caption
    onTouch_first_gain0_7_captionChanged:{
        sensorListLabel.text = touch_first_gain0_7_caption.caption
    }

    property var touch_first_gain0_7_values: platformInterface.touch_first_gain0_7_values
    onTouch_first_gain0_7_valuesChanged: {
        sensorList.model = touch_first_gain0_7_values.values
    }

    property var touch_first_gain0_7_value: platformInterface.touch_first_gain0_7_value
    onTouch_first_gain0_7_valueChanged:{
        for(var i = 0; i < sensorList.model.length; ++i) {
            if(i === 0 || i === 15) {
                if(touch_first_gain0_7_value.value === sensorList.model[i].slice(0,-3).toString()){
                    sensorList.currentIndex = i
                }
            }
            else {
                if(touch_first_gain0_7_value.value === sensorList.model[i].toString()){
                    sensorList.currentIndex = i
                }
            }
        }
    }

    property var touch_first_gain0_7_state: platformInterface.touch_first_gain0_7_state
    onTouch_first_gain0_7_stateChanged: {

        if(touch_first_gain0_7_state.state === "enabled"){
            touchSensorContainer1.enabled = true
        }
        else if(touch_first_gain0_7_state.state === "disabled"){
            touchSensorContainer1.enabled = false
        }
        else {
            touchSensorContainer1.enabled = false
            touchSensorContainer1.opacity = 0.5
        }
    }

    property var touch_second_gain_values: platformInterface.touch_second_gain_values
    onTouch_second_gain_valuesChanged: {

        setAllSensorsValue()
        for(var a = 0; a < sensorList0.model.length; ++a) {
            if(touch_second_gain_values.values[0] === sensorList0.model[a].toString()){
                sensorList0.currentIndex = a
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
                    text: "First Gain, Error, & Reset"
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

                Rectangle {
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
                            id: touchSensorContainer1
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: sensorListLabel
                                target: sensorList
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 1.2
                                alignment:  SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                SGComboBox {
                                    id: sensorList
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onActivated: {
                                        if(currentIndex === 0 || currentIndex === 15)
                                            platformInterface.set_touch_first_gain0_7_value.update(currentText.slice(0,-3))
                                        else  platformInterface.set_touch_first_gain0_7_value.update(currentText)
                                    }

                                }
                            }

                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
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

                                    property var touch_syserr_state: platformInterface.touch_syserr_state
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
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        //warningPopup.open()
                                        platformInterface.touch_reset.update()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    id: secondDebugLabel
                    text: "Second Gain, Data, & Activation Status"
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
                                    id: data1
                                    text: qsTr("Data")
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
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pixelSize: ratioCalc * 20
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                Text {
                                    id: data2
                                    text: qsTr("Data")
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
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
                                    id: sensor0Label
                                    target: sensor0
                                    text: "<b>" + qsTr("0") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    alignment:  SGAlignedLabel.SideLeftCenter
                                    Layout.alignment: Qt.AlignCenter
                                    anchors.centerIn: parent
                                    SGStatusLight{
                                        id: sensor0
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
                                    id: sensorList0
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(0,currentText)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordata0
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    width:parent.width/1.5
                                    height:parent.height/2
                                    anchors.centerIn: parent
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: sensor1Label
                                    target: sensor1
                                    text: "<b>" + qsTr("1") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    alignment:  SGAlignedLabel.SideLeftCenter
                                    anchors.centerIn: parent
                                    SGStatusLight{
                                        id: sensor1
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
                                    id: sensorList1
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(1,currentText)
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGInfoBox {
                                    id: sensordata1
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
                                    id: sensor2Label
                                    target: sensor2
                                    text: "<b>" + qsTr("2") + "</b>"
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
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(2,currentText)
                                    }
                                }

                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordata2
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    width:parent.width/1.5
                                    height:parent.height/2
                                    anchors.centerIn: parent
                                }
                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: sensor3Label
                                    target: sensor3
                                    text: "<b>" + qsTr("3") + "</b>"
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
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(3,currentText)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordata3
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
                                    id: sensor4Label
                                    target: sensor4
                                    text: "<b>" + qsTr("4") + "</b>"
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

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGComboBox {
                                    id: sensorList4
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(4,currentText)
                                    }
                                }

                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordata4
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    width:parent.width/1.5
                                    height:parent.height/2
                                    anchors.centerIn: parent
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: sensor5Label
                                    target: sensor5
                                    text: "<b>" + qsTr("5") + "</b>"
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

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGComboBox {
                                    id: sensorList5
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(4,currentText)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordata5
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
                                    id: sensor6Label
                                    target: sensor6
                                    text: "<b>" + qsTr("6") + "</b>"
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

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGComboBox {
                                    id: sensorList6
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(6,currentText)
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordata6
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    width:parent.width/1.5
                                    height:parent.height/2
                                    anchors.centerIn: parent
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: sensor7Label
                                    target: sensor7
                                    text: "<b>" + qsTr("7") + "</b>"
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
                                    anchors.centerIn: parent
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onActivated: {
                                        platformInterface.touch_second_gain_value.update(7,currentText)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGInfoBox {
                                    id: sensordata7
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

        //        RowLayout{
        //            anchors.fill:parent

        //            ColumnLayout {
        //                Layout.fillHeight: true
        //                Layout.fillWidth: true
        //                Rectangle{
        //                    id: touchSensorContainer1
        //                    Layout.fillHeight: true
        //                    Layout.fillWidth: true
        //                    color: "transparent"

        //                    SGAlignedLabel {
        //                        id: sensorListLabel
        //                        target: sensorList
        //                        // text: "Sensors 1-8 \n 1st Gain"
        //                        font.bold: true
        //                        fontSizeMultiplier: ratioCalc * 1.2
        //                        alignment:  SGAlignedLabel.SideTopCenter
        //                        anchors.centerIn: parent
        //                        SGComboBox {
        //                            id: sensorList
        //                            fontSizeMultiplier: ratioCalc * 1.2
        //                            onActivated: {
        //                                if(currentIndex === 0 || currentIndex === 15)
        //                                    platformInterface.set_touch_first_gain0_7_value.update(currentText.slice(0,-3))
        //                                else  platformInterface.set_touch_first_gain0_7_value.update(currentText)
        //                            }

        //                        }
        //                    }

        //                }

        //                Rectangle {
        //                    id: resetContainer
        //                    Layout.fillHeight: true
        //                    Layout.fillWidth: true
        //                    SGButton {
        //                        id:  hardwareButton
        //                        text: qsTr("Hardware Reset")
        //                        anchors.verticalCenter: parent.verticalCenter
        //                        fontSizeMultiplier: ratioCalc
        //                        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
        //                        hoverEnabled: true
        //                        MouseArea {
        //                            hoverEnabled: true
        //                            anchors.fill: parent
        //                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        //                            onClicked: {
        //                                //warningPopup.open()
        //                                platformInterface.touch_reset.update()
        //                            }
        //                        }
        //                    }
        //                }
        //            }

        //            Rectangle {
        //                id:errSetting
        //                Layout.preferredHeight: parent.height/2
        //                Layout.fillWidth: true
        //                ColumnLayout {
        //                    anchors.fill:parent
        //                    Rectangle {
        //                        Layout.fillHeight: true
        //                        Layout.fillWidth: true
        //                        color: "transparent"
        //                        SGAlignedLabel {
        //                            id: calerrLabel
        //                            target: calerr
        //                            font.bold: true
        //                            fontSizeMultiplier: ratioCalc * 1.2
        //                            alignment:  SGAlignedLabel.SideLeftCenter
        //                            anchors.centerIn: parent
        //                            SGStatusLight{
        //                                id: calerr
        //                                height: 40 * ratioCalc
        //                                width: 40 * ratioCalc
        //                                status: SGStatusLight.Off
        //                                property var touch_calerr_caption: platformInterface.touch_calerr_caption
        //                                onTouch_calerr_captionChanged:  {
        //                                    calerrLabel.text = touch_calerr_caption.caption
        //                                }

        //                                property var touch_calerr_value: platformInterface.touch_calerr_value
        //                                onTouch_calerr_valueChanged: {
        //                                    if(touch_calerr_value.value === "0")
        //                                        calerr.status = SGStatusLight.Off
        //                                    else calerr.status = SGStatusLight.Red
        //                                }

        //                                property var touch_calerr_state: platformInterface.touch_calerr_state
        //                                onTouch_calerr_stateChanged: {
        //                                    if(touch_calerr_state === "enabled") {

        //                                        calerrLabel.enabled = true
        //                                        calerrLabel.opacity = 1.0
        //                                    }
        //                                    else if (touch_calerr_state === "disabled") {
        //                                        calerrLabel.enabled = false
        //                                        calerrLabel.opacity = 1.0
        //                                    }
        //                                    else {
        //                                        calerrLabel.enabled = false
        //                                        calerrLabel.opacity = 0.5
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }

        //                    Rectangle {
        //                        Layout.fillHeight: true
        //                        Layout.fillWidth: true
        //                        color: "transparent"
        //                        SGAlignedLabel {
        //                            id: syserrLabel
        //                            target: syserr
        //                            font.bold: true
        //                            fontSizeMultiplier: ratioCalc * 1.2
        //                            alignment:  SGAlignedLabel.SideLeftCenter
        //                            anchors.centerIn: parent
        //                            SGStatusLight{
        //                                id: syserr
        //                                height: 40 * ratioCalc
        //                                width: 40 * ratioCalc
        //                                status: SGStatusLight.Off

        //                                property var touch_syserr_caption: platformInterface.touch_syserr_caption
        //                                onTouch_syserr_captionChanged: {
        //                                    syserrLabel.text = touch_syserr_caption.caption
        //                                }

        //                                property var touch_syserr_value: platformInterface.touch_syserr_value
        //                                onTouch_syserr_valueChanged: {
        //                                    if(touch_syserr_value.value === "0")
        //                                        syserr.status = SGStatusLight.Off
        //                                    else syserr.status = SGStatusLight.Red
        //                                }

        //                                property var touch_syserr_state: platformInterface.touch_syserr_state
        //                                onTouch_syserr_stateChanged: {
        //                                    if(touch_syserr_state === "enabled") {
        //                                        syserrLabel.enabled = true
        //                                        syserrLabel.opacity = 1.0
        //                                    }
        //                                    else if (touch_syserr_state === "disabled") {
        //                                        syserrLabel.enabled = false
        //                                        syserrLabel.opacity = 1.0
        //                                    }
        //                                    else {
        //                                        syserrLabel.enabled = false
        //                                        syserrLabel.opacity = 0.5
        //                                    }
        //                                }




        //                            }
        //                        }
        //                    }
        //                }
        //            }

        //            Rectangle {
        //                id: touchSensorContainer2
        //                Layout.fillHeight: true
        //                Layout.preferredWidth: parent.width/1.3
        //                color: "transparent"
        //                ColumnLayout {
        //                    anchors.fill: parent
        //                    spacing: 10
        //                    RowLayout {
        //                        spacing: 20
        //                        Layout.fillHeight: true
        //                        Layout.fillWidth: true
        //                        Rectangle{
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            Text {
        //                                id: label1
        //                                text: qsTr("2nd Gain")
        //                                font.bold: true
        //                                anchors.bottom: parent.bottom
        //                                anchors.horizontalCenter: parent.horizontalCenter
        //                                font.pixelSize: ratioCalc * 20
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            Text {
        //                                id: data1
        //                                text: qsTr("Data")
        //                                font.bold: true
        //                                anchors.bottom: parent.bottom
        //                                anchors.horizontalCenter: parent.horizontalCenter
        //                                font.pixelSize: ratioCalc * 20
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            Text {
        //                                id: label2
        //                                text: qsTr("2nd Gain")
        //                                font.bold: true
        //                                anchors.bottom: parent.bottom
        //                                anchors.horizontalCenter: parent.horizontalCenter
        //                                font.pixelSize: ratioCalc * 20
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            Text {
        //                                id: data2
        //                                text: qsTr("Data")
        //                                font.bold: true
        //                                anchors.horizontalCenter: parent.horizontalCenter
        //                                anchors.bottom: parent.bottom
        //                                font.pixelSize: ratioCalc * 20
        //                            }
        //                        }

        //                    }
        //                    RowLayout {
        //                        spacing: 20
        //                        Layout.fillHeight: true
        //                        Layout.fillWidth: true

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGAlignedLabel {
        //                                id: sensor0Label
        //                                target: sensor0
        //                                text: "<b>" + qsTr("Sensor 0") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                Layout.alignment: Qt.AlignCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor0
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off

        //                                }
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGComboBox {
        //                                id: sensorList0
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                anchors.centerIn: parent
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(0,currentText.slice(0,-3))
        //                                    else  platformInterface.touch_second_gain_value.update(0,currentText)
        //                                }
        //                            }
        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGInfoBox {
        //                                id: sensordata0
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGAlignedLabel {
        //                                id: sensor1Label
        //                                target: sensor1
        //                                text: "<b>" + qsTr("Sensor 1") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor1
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off
        //                                }
        //                            }
        //                        }

        //                        Rectangle{
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGComboBox {
        //                                id: sensorList1
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                anchors.centerIn: parent
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(1,currentText.slice(0,-3))
        //                                    else  platformInterface.touch_second_gain_value.update(1,currentText)
        //                                }
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGInfoBox {
        //                                id: sensordata1
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }
        //                    }

        //                    RowLayout {
        //                        spacing: 20
        //                        Layout.fillHeight: true
        //                        Layout.fillWidth: true

        //                        Rectangle{
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGAlignedLabel {
        //                                id: sensor2Label
        //                                target: sensor2
        //                                text: "<b>" + qsTr("Sensor 2") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor2
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off
        //                                }
        //                            }
        //                        }

        //                        Rectangle{
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGComboBox {
        //                                id: sensorList2
        //                                anchors.centerIn: parent
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(2,currentText.slice(0,-3))
        //                                    else  platformInterface.touch_second_gain_value.update(2,currentText)
        //                                }
        //                            }

        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGInfoBox {
        //                                id: sensordata2
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }

        //                        Rectangle{
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGAlignedLabel {
        //                                id: sensor3Label
        //                                target: sensor3
        //                                text: "<b>" + qsTr("Sensor 3") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor3
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off
        //                                }
        //                            }
        //                        }

        //                        Rectangle{
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGComboBox {
        //                                id: sensorList3
        //                                anchors.centerIn: parent
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(3,currentText.slice(0,-3))
        //                                    else  platformInterface.touch_second_gain_value.update(3,currentText)
        //                                }
        //                            }
        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGInfoBox {
        //                                id: sensordata3
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }
        //                    }

        //                    RowLayout {
        //                        spacing: 20
        //                        Layout.fillHeight: true
        //                        Layout.fillWidth: true

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGAlignedLabel {
        //                                id: sensor4Label
        //                                target: sensor4
        //                                text: "<b>" + qsTr("Sensor 4") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor4
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off
        //                                }
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGComboBox {
        //                                id: sensorList4
        //                                anchors.centerIn: parent
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(4,currentText.slice(0,-3))
        //                                    else  platformInterface.touch_second_gain_value.update(4,currentText)
        //                                }
        //                            }

        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGInfoBox {
        //                                id: sensordata4
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGAlignedLabel {
        //                                id: sensor5Label
        //                                target: sensor5
        //                                text: "<b>" + qsTr("Sensor 5") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor5
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off
        //                                }
        //                            }

        //                        }

        //                        Rectangle{
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGComboBox {
        //                                id: sensorList5
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                anchors.centerIn: parent
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(4,currentText.slice(0,-3))
        //                                    else platformInterface.touch_second_gain_value.update(4,currentText)
        //                                }
        //                            }
        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGInfoBox {
        //                                id: sensordata5
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }
        //                    }

        //                    RowLayout {
        //                        spacing: 20
        //                        Layout.fillHeight: true
        //                        Layout.fillWidth: true

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGAlignedLabel {
        //                                id: sensor6Label
        //                                target: sensor6
        //                                text: "<b>" + qsTr("Sensor 6") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor6
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off
        //                                }
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGComboBox {
        //                                id: sensorList6
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                anchors.centerIn: parent
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(6,currentText.slice(0,-3))
        //                                    else platformInterface.touch_second_gain_value.update(6,currentText)
        //                                }
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGInfoBox {
        //                                id: sensordata6
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"
        //                            SGAlignedLabel {
        //                                id: sensor7Label
        //                                target: sensor7
        //                                text: "<b>" + qsTr("Sensor 7") + "</b>"
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                alignment:  SGAlignedLabel.SideLeftCenter
        //                                anchors.centerIn: parent
        //                                SGStatusLight{
        //                                    id: sensor7
        //                                    height: 40 * ratioCalc
        //                                    width: 40 * ratioCalc
        //                                    status: SGStatusLight.Off
        //                                }
        //                            }
        //                        }

        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGComboBox {
        //                                id: sensorList7
        //                                anchors.centerIn: parent
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                onActivated: {
        //                                    if(currentIndex === 0 || currentIndex === 15)
        //                                        platformInterface.touch_second_gain_value.update(7,currentText.slice(0,-3))
        //                                    else platformInterface.touch_second_gain_value.update(7,currentText)
        //                                }
        //                            }
        //                        }
        //                        Rectangle {
        //                            Layout.fillHeight: true
        //                            Layout.fillWidth: true
        //                            color: "transparent"

        //                            SGInfoBox {
        //                                id: sensordata7
        //                                fontSizeMultiplier: ratioCalc * 1.2
        //                                width:parent.width/1.5
        //                                height:parent.height/2
        //                                anchors.centerIn: parent
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        } // end of RowLayout
    }
}




