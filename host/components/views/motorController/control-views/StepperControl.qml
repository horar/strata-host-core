import QtQuick 2.9
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.3

import tech.strata.sgwidgets 0.9 as Widget09

import "qrc:/js/help_layout_manager.js" as Help

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 600
    minimumWidth: 1000

    Rectangle {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }


        Rectangle {
            id: container2
            parent: root.contentItem
            anchors {
                fill: parent
            }
            color: motorControllerGrey

            property int leftMargin: 100
            property int statBoxHeight:100
            property int motorColumnTopMargin: 100

            Rectangle{
                anchors.top:parent.top
                anchors.topMargin: container2.motorColumnTopMargin/2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom:parent.bottom
                width: parent.width
                color:motorControllerGrey
                opacity:.9
            }


            Column{
                id:stepColumn

                anchors.top:parent.top
                anchors.topMargin: container2.motorColumnTopMargin *1.35
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom:parent.bottom
                width: parent.width/3
                spacing: 20




                RowLayout{
                    id:portInfoRow
                    height:container2.statBoxHeight
                    width:parent.width*2
                    anchors.left:parent.left
                    anchors.leftMargin: -parent.width/2

                    //spacing: 100

                    Rectangle{
                       Layout.fillWidth: true
                       Layout.fillHeight: true
                        color: "transparent"

                        PortStatBox{
                            id:motor1InputVoltage

                            height:container2.statBoxHeight
                            width:250
                            anchors.horizontalCenter: parent.horizontalCenter
                            label: "INPUT VOLTAGE"
                            labelSize:12
                            unit:"V"
                            unitColor: motorControllerDimGrey
                            color:"transparent"
                            valueSize: 64
                            unitSize: 20
                            textColor: "black"
                            portColor: "#2eb457"
                            labelColor:"black"
                            //underlineWidth: 0
                            imageHeightPercentage: .5
                            bottomMargin: 10
                            value: platformInterface.step_notification.voltage.toFixed(1)
                        }
                    }

                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        PortStatBox{
                            id:motor1InputCurrent
                            height:container2.statBoxHeight
                            width:250
                            anchors.horizontalCenter: parent.horizontalCenter
                            label: "HOLDING CURRENT"
                            labelSize:12
                            unit:"mA"
                            unitColor:motorControllerDimGrey
                            color:"transparent"
                            valueSize: 64
                            unitSize: 20
                            textColor: "black"
                            portColor: "#2eb457"
                            labelColor:"black"
                            //underlineWidth: 0
                            imageHeightPercentage: .5
                            bottomMargin: 10
                            value: platformInterface.step_notification.current.toFixed(0)
                        }
                    }
                }

                Row{
                    spacing: 10
                    id:excitationRow
                    anchors.left:parent.left
                    width: parent.width

                    Text{
                        id:excitationLabel
                        text: "Excitation:"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: excitationRow.verticalCenter
                        anchors.verticalCenterOffset: -10
                        width:50
                    }
                    Text{
                        id:halfStepLabel
                        color:motorControllerDimGrey
                        text: "1/2 step"
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: excitationRow.verticalCenter
                        anchors.verticalCenterOffset: -8
                        font.pixelSize: 15
                    }
                    SGSwitch{
                        id:excitationSwitch
                        anchors.bottom: excitationRow.bottom
                        anchors.bottomMargin: 10
                        width:50
                        textColor:"white"
                        grooveFillColor: motorControllerPurple
                        checked: (platformInterface.step_excitation_notification.excitation === "full_step") ? true : false
                        onToggled: {
                            if (checked){
                                platformInterface.step_excitation.update("full_step")
                            }
                            else{
                                platformInterface.step_excitation.update("half_step")
                            }
                        }
                    }

                    Text{
                        id:fullStepLabel
                        color:motorControllerDimGrey
                        text: "full step"
                        horizontalAlignment: Text.AlignLeft
                        anchors.verticalCenter: excitationRow.verticalCenter
                        anchors.verticalCenterOffset: -8
                        font.pixelSize: 15
                    }
                }


                Row{
                    spacing: 10
                    id:directionRow
                    anchors.left:parent.left
                    width: parent.width

                    Text{
                        id:directionLabel
                        text: "Direction:"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: directionRow.verticalCenter
                        anchors.verticalCenterOffset: -5
                        width:50
                    }

                    Image {
                        id: clockwiseicon
                        height:20
                        fillMode: Image.PreserveAspectFit
                        mipmap:true

                        source:"../images/icon-clockwise-darkGrey.svg"
                    }

                    SGSwitch{
                        id:stepDirectionSwitch
                        textColor:"white"
                        grooveFillColor: motorControllerPurple
                        width:50
                        anchors.bottom: directionRow.bottom
                        anchors.bottomMargin: 5
                        //checked value flipped as part of a kludge
                        //checked: (platformInterface.step_direction_notification.direction === "counterclockwise") ? true : false
                        checked: (platformInterface.step_direction_notification.direction === "counterclockwise") ? false : true

                        onToggled: {
                            if (checked){
                                //platformInterface.step_direction.update("counterclockwise")
                                //temporary kludge
                                platformInterface.step_direction.update("clockwise")
                            }
                            else{
                                //platformInterface.step_direction.update("clockwise")
                                //temporary kludge
                                platformInterface.step_direction.update("counterclockwise")
                            }
                        }
                    }
                    Image {
                        id: counterClockwiseicon
                        height:20
                        fillMode: Image.PreserveAspectFit
                        mipmap:true

                        source:"../images/icon-counterClockwise-darkGrey.svg"
                    }
                }

                Row{
                    spacing: 10
                    id:stepRow
                    anchors.left:parent.left
                    width: parent.width

                    Text{
                        id:stepComboLabel
                        text:"Step angle:"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignRight
                        width:50
                    }

                    SGComboBox {
                        id: stepCombo

                        property variant stepOptions: [".9", "1.8", "3.6", "3.75", "7.5", "15", "18"]

                        model: stepOptions
                        //textColor:"white"

                        boxColor:"white"
                        //comboBoxHeight: 25
                        //comboBoxWidth: 60
                        //overrideLabelWidth:50

                        property var currentValue: platformInterface.step_angle_notification.angle
                        onCurrentValueChanged: {
                            //console.log("Current step angle is ",currentValue);
                            var currentIndex = stepCombo.find(currentValue);
                            //console.log("Current step index is ",currentIndex);
                            //console.log("Current step text is ",stepCombo.currentText);
                            //console.log("Current item count is ",stepCombo.count);
                            stepCombo.currentIndex = currentIndex;
                        }

                        //when changing the value
                        onActivated: {
                            console.log("New step angle is ",stepCombo.currentText);
                            platformInterface.step_angle.update(stepCombo.currentText);
                        }

                    }

                    Text{
                        id: stepUnits
                        text: "degrees"
                        font.pixelSize: 15
                        color: motorControllerDimGrey
                        anchors.verticalCenter: stepCombo.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        width:50
                    }
                }

                Row{
                    spacing: 10
                    id:speedSliderRow
                    anchors.left:parent.left
                    width: parent.width

                    Text{
                        id:motorSpeedLabel
                        //color:"white"
                        text: "Motor speed:"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: speedSliderRow.verticalCenter
                        anchors.verticalCenterOffset: -10
                        width:50
                    }

                    MCSlider{
                        id:stepMotorSpeedSlider
                        width:parent.width -60

                        from: 0
                        to: 500
                        stepSize: 1
                        textColor:"black"
                        toolTipTextColor:"black"
                        grooveColor: "lightgrey"
                        fillColor: motorControllerPurple
                        live:false
                        //inputBox.validator.bottom: from
                        //inputBox.validator.top: to

                        property var speed: platformInterface.step_speed_notification.speed

                        onSpeedChanged: {
                            stepMotorSpeedSlider.value =speed;
                        }

                        onUserSet: {
                            //console.log("setting speed to",value);
                            var unit = "sps";
                            if(speedUnitsSelector.index == 1){
                                unit = "rpm"
                            }

                            platformInterface.step_speed.update(value,unit);
                        }

                    }
                    Widget09.SGSegmentedButtonStrip {
                        id: speedUnitsSelector
                        labelLeft: false
                        textColor: "#666"
                        activeTextColor: "white"
                        radius: 4
                        buttonHeight: 20
                        exclusive: true
                        buttonImplicitWidth: 50
                        hoverEnabled:false

                        property var stepUnit:  platformInterface.step_speed_notification.unit

                        onStepUnitChanged: {
                            if (stepUnit === "sps"){
                                index = 0;
                            }
                            else if (stepUnit === "rpm"){
                                index = 1;
                            }

                        }

                        segmentedButtons: GridLayout {
                            columnSpacing: 2
                            rowSpacing: 2

                            Widget09.SGSegmentedButton{
                                id:stepsPerSecondSegmentedButton
                                text: qsTr("steps/second")
                                activeColor: "dimgrey"
                                inactiveColor: "gainsboro"
                                textColor: motorControllerInactiveButtonText
                                textActiveColor: "white"
                                checked: true
                                onClicked: {
                                    stepMotorSpeedSlider.to = 1000;
                                    platformInterface.step_speed.update(stepMotorSpeedSlider.value, "sps");
                                }
                            }

                            Widget09.SGSegmentedButton{
                                id:rpmSegmentedButton
                                text: qsTr("rpm")
                                activeColor: "dimgrey"
                                inactiveColor: "gainsboro"
                                textColor: motorControllerInactiveButtonText
                                textActiveColor: "white"
                                onClicked: {
                                    platformInterface.step_speed.update(stepMotorSpeedSlider.value,"rpm");
                                    stepMotorSpeedSlider.to = 500
                                }
                            }

                        }
                    }




                }

                Row{
                    spacing: 10
                    id:transferTimeRow
                    anchors.left:parent.left
                    width: parent.width

                    Text{
                        id:runForLabel
                        text:"Transfer time:"
                        //color:"white"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: transferTimeRow.verticalCenter
                        anchors.verticalCenterOffset: -5
                        width:50
                    }

                    MCSlider{
                        id:runForSlider
                        width:60
                        slider.visible: false

                        from: 0
                        to: 99999
                        showLabels:false
                        grooveColor: "lightgrey"
                        fillColor: motorControllerTeal
                        textColor:"white"
                        live:false

                        property var duration: platformInterface.step_duration_notification.duration

                        onDurationChanged: {
                            runForSlider.value =duration
                        }

                        onUserSet: {
                            //console.log("setting duration to",value);
                            platformInterface.step_duration.update(value, platformInterface.step_duration_notification.unit);
                        }

                    }
                    Widget09.SGSegmentedButtonStrip {
                        id: runUnitsSelector
                        labelLeft: false
                        textColor: "#666"
                        activeTextColor: "white"
                        radius: 4
                        buttonHeight: 20
                        exclusive: true
                        buttonImplicitWidth: 50
                        hoverEnabled:false

                        property var stepUnit:  platformInterface.step_duration_notification.unit

                        onStepUnitChanged: {
                            console.log("received a new step duration notification. Units are",platformInterface.step_duration_notification.unit)
                            if (stepUnit === "seconds"){
                                index = 0;
                            }
                            else if (stepUnit === "steps"){
                                index = 1;
                            }
                            else if (stepUnit === "degrees"){
                                index = 2;
                            }
                        }

                        segmentedButtons: GridLayout {
                            columnSpacing: 2
                            rowSpacing: 2

                            Widget09.SGSegmentedButton{
                                id:secondsSegmentedButton
                                text: qsTr("seconds")
                                activeColor: "dimgrey"
                                inactiveColor: "gainsboro"
                                textColor: motorControllerInactiveButtonText
                                textActiveColor: "white"
                                checked: true
                                onClicked: platformInterface.step_duration.update(platformInterface.step_duration_notification.duration, "seconds")
                            }

                            Widget09.SGSegmentedButton{
                                id:stepsSegmentedButton
                                text: qsTr("steps")
                                activeColor: "dimgrey"
                                inactiveColor: "gainsboro"
                                textColor: motorControllerInactiveButtonText
                                textActiveColor: "white"
                                onClicked: platformInterface.step_duration.update(platformInterface.step_duration_notification.duration, "steps")
                            }
                            Widget09.SGSegmentedButton{
                                id:degreesSegmentedButton
                                text: qsTr("degrees")
                                activeColor: "dimgrey"
                                inactiveColor: "gainsboro"
                                textColor: motorControllerInactiveButtonText
                                textActiveColor: "white"
                                onClicked: platformInterface.step_duration.update(platformInterface.step_duration_notification.duration, "degrees")
                            }
                        }
                    }
                }


                Widget09.SGSegmentedButtonStrip {
                    id: stepButtonSelector
                    labelLeft: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    textColor: "#666"
                    activeTextColor: "white"
                    radius: 10
                    buttonHeight: 50
                    exclusive: true
                    buttonImplicitWidth: 100
                    hoverEnabled:false


                    property var stepRunMode : platformInterface.step_run_notification
                    onStepRunModeChanged:{
                        if (platformInterface.step_run_notification.mode === 1){
                            index = 0;
                        }
                        else if (platformInterface.step_run_notification.mode === 2){
                            index = 1;
                        }
                        else if (platformInterface.step_run_notification.mode === 3){
                            index = 2;
                        }
                    }

                    segmentedButtons: GridLayout {
                        columnSpacing: 2
                        rowSpacing: 2

                        MCSegmentedButton{
                            text: qsTr("start")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: motorControllerInactiveButtonText
                            textActiveColor: "white"
                            checked: false
                            textSize:24
                            onClicked: platformInterface.step_run.update(1);
                        }

                        MCSegmentedButton{
                            text: qsTr("hold")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: motorControllerInactiveButtonText
                            textActiveColor: "white"
                            textSize:24
                            onClicked: platformInterface.step_run.update(2);
                        }

                        MCSegmentedButton{
                            text: qsTr("free")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: motorControllerInactiveButtonText
                            textActiveColor: "white"
                            textSize:24
                            checked: true
                            onClicked: platformInterface.step_run.update(3);
                        }
                    }
                }


            }
        }
    }
}



