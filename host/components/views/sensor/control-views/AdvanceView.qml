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

    property var touch_second_gain_states: platformInterface.touch_second_gain
    onTouch_second_gain_statesChanged: {
        setAllSensorsValue()
        if(touch_second_gain_states.state === "enabled"){
            sensorList0.enabled = true
            sensorList1.enabled = true
            sensorList2.enabled = true
            sensorList3.enabled = true
            sensorList4.enabled = true
            sensorList5.enabled = true
            sensorList6.enabled = true
            sensorList7.enabled = true
            sensorListTouch.enabled = true
            sensorListProximity.enabled = true
            sensorListLight.enabled = true
            sensorListTemp.enabled = true
            sensorListA.enabled = true
            sensorListB.enabled = true
            sensorListC.enabled = true
            sensorListD.enabled = true
        }
        else if(touch_second_gain_states.state === "disabled"){
            sensorList0.enabled = false
            sensorList1.enabled = false
            sensorList2.enabled = false
            sensorList3.enabled = false
            sensorList4.enabled = false
            sensorList5.enabled = false
            sensorList6.enabled = false
            sensorList7.enabled = false
            sensorListTouch.enabled = false
            sensorListProximity.enabled = false
            sensorListLight.enabled = false
            sensorListTemp.enabled = false
            sensorListA.enabled = false
            sensorListB.enabled = false
            sensorListC.enabled = false
            sensorListD.enabled = false
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

        for(var a = 0; a < sensorList0.model.length; ++a) {

            if(touch_second_gain_states.values[0] === sensorList0.model[a].toString()){
                console.log(a)
                sensorList0.currentIndex = a
                console.log(sensorList0.currentIndex)
            }
            if(touch_second_gain_states.values[1] === sensorList1.model[a].toString()){
                sensorList1.currentIndex = a
            }
            if(touch_second_gain_states.values[2] === sensorList2.model[a].toString()){
                sensorList2.currentIndex = a
            }
            if(touch_second_gain_states.values[2] === sensorList3.model[a].toString()){
                sensorList3.currentIndex = a
            }

            if(touch_second_gain_states.values[4] === sensorList4.model[a].toString()){
                sensorList4.currentIndex = a
            }

            if(touch_second_gain_states.values[5] === sensorList5.model[a].toString()){
                sensorList5.currentIndex = a
            }

            if(touch_second_gain_states.values[6] === sensorList6.model[a].toString()){
                sensorList6.currentIndex = a
            }
            if(touch_second_gain_states.values[7] === sensorList7.model[a].toString()){
                sensorList7.currentIndex = a
            }
            if(touch_second_gain_states.values[8] === sensorListTouch.model[a].toString()){
                sensorListTouch.currentIndex = a
            }
            if(touch_second_gain_states.values[9] === sensorListProximity.model[a].toString()){
                sensorListProximity.currentIndex = a
            }
            if(touch_second_gain_states.values[10] === sensorListLight.model[a].toString()){
                sensorListLight.currentIndex = a
            }
            if(touch_second_gain_states.values[11] === sensorListTemp.model[a].toString()){
                sensorListTemp.currentIndex = a
            }

            if(touch_second_gain_states.values[12] === sensorListA.model[a].toString()){
                sensorListA.currentIndex = a
            }
            if(touch_second_gain_states.values[13] === sensorListB.model[a].toString()){
                sensorListB.currentIndex = a
            }
            if(touch_second_gain_states.values[14] === sensorListC.model[a].toString()){
                sensorListC.currentIndex = a
            }
            if(touch_second_gain_states.values[15] === sensorListD.model[a].toString()){
                sensorListD.currentIndex = a
            }
        }
    }

    property var touch_cin_thres_states: platformInterface.touch_cin_thres
    onTouch_cin_thres_statesChanged: {
        threshold0.text = touch_cin_thres_states.values[0]
        threshold1.text = touch_cin_thres_states.values[1]
        threshold2.text = touch_cin_thres_states.values[2]
        threshold3.text = touch_cin_thres_states.values[3]
        threshold4.text = touch_cin_thres_states.values[4]
        threshold5.text = touch_cin_thres_states.values[5]
        threshold6.text = touch_cin_thres_states.values[6]
        threshold7.text = touch_cin_thres_states.values[7]
        thresholdTouch.text = touch_cin_thres_states.values[8]
        thresholdProximity.text = touch_cin_thres_states.values[9]
        thresholdLight.text = touch_cin_thres_states.values[10]
        thresholdTemp.text = touch_cin_thres_states.values[11]
        thresholdA.text = touch_cin_thres_states.values[12]
        thresholdB.text = touch_cin_thres_states.values[13]
        thresholdC.text = touch_cin_thres_states.values[14]
        thresholdD.text = touch_cin_thres_states.values[15]

    }

    property var touch_cin_en_states: platformInterface.touch_cin_en
    onTouch_cin_en_statesChanged: {
        touch_cin_en_states.values[0] === "0" ? enable0Switch.checked = true : enable0Switch.checked = false
        touch_cin_en_states.values[1] === "0" ? enable1Switch.checked = true : enable1Switch.checked = false
        touch_cin_en_states.values[2] === "0" ? enable2Switch.checked = true : enable2Switch.checked = false
        touch_cin_en_states.values[3] === "0" ? enable3Switch.checked = true : enable3Switch.checked = false
        touch_cin_en_states.values[4] === "0" ? enable4Switch.checked = true : enable4Switch.checked = false
        touch_cin_en_states.values[5] === "0" ? enable5Switch.checked = true : enable5Switch.checked = false
        touch_cin_en_states.values[6] === "0" ? enable6Switch.checked = true : enable6Switch.checked = false
        touch_cin_en_states.values[7] === "0" ? enable7Switch.checked = true : enable7Switch.checked = false
        touch_cin_en_states.values[8] === "0" ? enableTouchSwitch.checked = true : enableTouchSwitch.checked = false
        touch_cin_en_states.values[9] === "0" ? enableProximitySwitch.checked = true : enableProximitySwitch.checked = false
        touch_cin_en_states.values[10] === "0" ? enableLightSwitch.checked = true : enableLightSwitch.checked = false
        touch_cin_en_states.values[11] === "0" ? enableTemptSwitch.checked = true : enableTemptSwitch.checked = false
        touch_cin_en_states.values[12] === "0" ? enableASwitch.checked = true : enableASwitch.checked = false
        touch_cin_en_states.values[13] === "0" ? enableBSwitch.checked = true : enableBSwitch.checked = false
        touch_cin_en_states.values[14] === "0" ? enableCSwitch.checked = true : enableCSwitch.checked = false
        touch_cin_en_states.values[15] === "0" ? enableDSwitch.checked = true : enableDSwitch.checked = false




    }



    RowLayout{

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
            Layout.preferredWidth: parent.width/2.8
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
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width/8
                            Layout.fillHeight: true
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
                                        platformInterface.touch_cin_en_value.update(0,0)
                                    else  platformInterface.touch_cin_en_value.update(0,1)
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
                                height: sensordata0Container.height - 10
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
                                width: threshold0Container.width/2
                                height: threshold0Container.height - 10
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
                                        platformInterface.touch_cin_en_value.update(1,0)
                                    else  platformInterface.touch_cin_en_value.update(1,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(2,0)
                                    else  platformInterface.touch_cin_en_value.update(2,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(3,0)
                                    else  platformInterface.touch_cin_en_value.update(3,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(4,0)
                                    else  platformInterface.touch_cin_en_value.update(4,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(5,0)
                                    else  platformInterface.touch_cin_en_value.update(5,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(6,0)
                                    else  platformInterface.touch_cin_en_value.update(6,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(7,0)
                                    else  platformInterface.touch_cin_en_value.update(7,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(8,0)
                                    else  platformInterface.touch_cin_en_value.update(8,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(9,0)
                                    else  platformInterface.touch_cin_en_value.update(9,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(10,0)
                                    else  platformInterface.touch_cin_en_value.update(1,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(11,0)
                                    else  platformInterface.touch_cin_en_value.update(11,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(12,0)
                                    else  platformInterface.touch_cin_en_value.update(12,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(13,0)
                                    else  platformInterface.touch_cin_en_value.update(13,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(14,0)
                                    else  platformInterface.touch_cin_en_value.update(14,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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
                                        platformInterface.touch_cin_en_value.update(15,0)
                                    else  platformInterface.touch_cin_en_value.update(15,1)
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
                                height: parent.height - 10
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
                                width: parent.width/2
                                height: parent.height - 10
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


