import QtQuick 2.9
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.3

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 800
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
                width: parent.width*.75
                color:motorControllerBrown
                opacity:.9
            }

//            LinearGradient{
//                id:column1background
//                anchors.top:parent.top
//                anchors.topMargin: container2.motorColumnTopMargin/2
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.bottom:parent.bottom
//                width: parent.width
//                start: Qt.point(0, 0)
//                end: Qt.point(0, height)
//                opacity:1
//                gradient: Gradient {
//                    GradientStop { position: 0.0; color: motorControllerGrey }
//                    GradientStop { position: .1; color: motorControllerBrown }

//                }
//            }



            Column{
                id:stepColumn

                anchors.top:parent.top
                anchors.topMargin: container2.motorColumnTopMargin *1.5
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom:parent.bottom
                width: parent.width/3
                spacing: 20




                PortStatBox{
                    id:motor1InputVoltage

                    height:container2.statBoxHeight
                    width:parent.width/2
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "INPUT VOLTAGE"
                    unit:"V"
                    color:"transparent"
                    valueSize: 64
                    unitSize: 20
                    textColor: "white"
                    portColor: "#2eb457"
                    labelColor:"dimgrey"
                    //underlineWidth: 0
                    imageHeightPercentage: .5
                    bottomMargin: 10
                    value: platformInterface.step_notification.Voltage
                }
                PortStatBox{
                    id:motor1InputCurrent

                    height:container2.statBoxHeight
                    width:parent.width/2
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "INPUT CURRENT"
                    unit:"A"
                    color:"transparent"
                    valueSize: 64
                    unitSize: 20
                    textColor: "white"
                    portColor: "#2eb457"
                    labelColor:"dimgrey"
                    //underlineWidth: 0
                    imageHeightPercentage: .5
                    bottomMargin: 10
                    value: platformInterface.step_notification.Current
                }

                Row{
                    spacing: 10
                    id:excitationRow
                    anchors.left:parent.left
                    width: parent.width

                    Text{
                        id:excitationLabel
                        color:"white"
                        text: "Excitation:"
                        horizontalAlignment: Text.AlignRight
                        width:50
                    }
                    Text{
                        id:halfStepLabel
                        color:"grey"
                        text: "1/2 step"
                        horizontalAlignment: Text.AlignRight
                    }
                    SGSwitch{
                        id:excitationSwitch
                        anchors.bottom: excitationRow.bottom
                        anchors.bottomMargin: 5
                        label:""
                        textColor:"white"
                        grooveFillColor: motorControllerTeal
                        checked: (platformInterface.step_excitation_notification.excitation === "full-step") ? true : false
                        onToggled: {
                            if (checked){
                                platformInterface.step_excitation.update("full-step")
                            }
                            else{
                                platformInterface.step_excitation.update("half-step")
                            }
                        }
                    }

                    Text{
                        id:fullStepLabel
                        color:"grey"
                        text: "full step"
                        horizontalAlignment: Text.AlignLeft
                    }
                }


                Row{
                    spacing: 10
                    id:directionRow
                    anchors.left:parent.left
                    width: parent.width

                    Text{
                        id:directionLabel
                        color:"white"
                        text: "Direction:"
                        horizontalAlignment: Text.AlignRight
                        width:50
                    }

                    Image {
                        id: clockwiseicon
                        height:20
                        fillMode: Image.PreserveAspectFit
                        mipmap:true

                        source:"../images/icon-clockwise.svg"
                    }

                    SGSwitch{
                        id:stepDirectionSwitch
                        label:""
                        textColor:"white"
                        grooveFillColor: motorControllerTeal
                        anchors.bottom: directionRow.bottom
                        anchors.bottomMargin: 5
                        checked: (platformInterface.step_direction_notification.direction === "counterclockwise") ? true : false

                        onToggled: {
                            if (checked){
                                platformInterface.step_direction.update("counterclockwise")
                            }
                            else{
                                platformInterface.step_direction.update("clockwise")
                            }
                        }
                    }
                    Image {
                        id: counterClockwiseicon
                        height:20
                        fillMode: Image.PreserveAspectFit
                        mipmap:true

                        source:"../images/icon-counterClockwise.svg"
                    }
                }

                Row{
                    spacing: 10
                    id:stepRow
                    anchors.left:parent.left
                    width: parent.width

                    SGComboBox {
                        id: stepCombo

                        property variant stepOptions: [".9", "1.8", "3.6", "3.75", "7.5", "15", "18"]

                        label: "Step angle:"
                        model: stepOptions
                        textColor:"white"
                        boxColor:motorControllerBrown
                        comboBoxHeight: 25
                        comboBoxWidth: 60
                        overrideLabelWidth:50

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
                        color: "grey"
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
                        color:"white"
                        text: "Motor speed:"
                        horizontalAlignment: Text.AlignRight
                        width:50
                    }

                    SGSlider{
                        id:stepMotorSpeedSlider
                        width:parent.width -60

                        from: 0
                        to: 500
                        label: ""
                        textColor:"white"
                        grooveFillColor: motorControllerTeal

                        property var speed: platformInterface.step_speed_notification.speed

                        onSpeedChanged: {
                            stepMotorSpeedSlider.setValue(speed)
                        }

                        onUserSet: {
                            //console.log("setting speed to",value);
                            var unit = "rpm";
                            if(stepsRadioButton.checked){
                                unit = "sps"
                            }

                            platformInterface.step_speed.update(value,unit);
                        }

                    }
                    Column{
                        ButtonGroup{
                            id:speedUnitsGroup
                        }

                        RadioButton{
                            id:stepsRadioButton
                            //text:"steps/second"
                            ButtonGroup.group: speedUnitsGroup
                            checked: platformInterface.step_speed.notification.unit === "sps";

                            indicator: Rectangle {
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    x: stepsRadioButton.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 8
                                    border.color: "black"
                                    color:"white"

                                    Rectangle {
                                        width: 12
                                        height: 12
                                        x: 2
                                        y: 2
                                        radius: 6
                                        color: motorControllerTeal
                                        visible: stepsRadioButton.checked
                                    }
                                }

                            contentItem: Text {
                                   text: "steps/second"
                                   color: "white"
                                   leftPadding: stepsRadioButton.indicator.width + stepsRadioButton.spacing
                            }


                            onCheckedChanged:
                                if(checked){
                                   stepMotorSpeedSlider.to = 500;
                                   platformInterface.step_speed.update(stepMotorSpeedSlider.value, "sps");
                                }

                        }
                        RadioButton{
                            id:rpmRadioButton
                            ButtonGroup.group: speedUnitsGroup
                            checked: platformInterface.step_speed_notification.unit === "rpm";

                            indicator: Rectangle {
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    x: rpmRadioButton.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 8
                                    border.color: "black"
                                    color:"white"

                                    Rectangle {
                                        width: 12
                                        height: 12
                                        x: 2
                                        y: 2
                                        radius: 6
                                        color: motorControllerTeal
                                        visible: rpmRadioButton.checked
                                    }
                                }

                            contentItem: Text {
                                   text: "rpm"
                                   color: "white"
                                   leftPadding: rpmRadioButton.indicator.width + rpmRadioButton.spacing
                            }

                            onCheckedChanged:
                                if(checked){
                                   platformInterface.step_speed.update(stepMotorSpeedSlider.value,"rpm");
                                   stepMotorSpeedSlider.to = 1000
                                }
                        }
                    }

               }

                Row{
                    spacing: 10
                    id:motorSpeedRow
                    anchors.left:parent.left
                    width: parent.width


                    SGSlider{
                        id:runForSlider
                        width:parent.width

                        from: 0
                        to: 100
                        label: "Run for:"
                        grooveFillColor: motorControllerTeal
                        textColor:"white"

                        property var duration: platformInterface.step_duration_notification.duration

                        onDurationChanged: {
                            runForSlider.setValue(duration)
                        }

                        onUserSet: {
                            //console.log("setting duration to",value);
                            platformInterface.step_duration.update(value, platformInterface.step_duration_notification.unit);
                        }

                    }
                    SGSegmentedButtonStrip {
                        id: runUnitsSelector
                        labelLeft: false
                        textColor: "#666"
                        activeTextColor: "white"
                        radius: 4
                        buttonHeight: 20
                        exclusive: true
                        buttonImplicitWidth: 50

                        property var stepUnit:  platformInterface.step_duration_notification.unit

                        onStepUnitChanged: {
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

                        SGSegmentedButton{
                            id:secondsSegmentedButton
                            text: qsTr("seconds")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: "black"
                            textActiveColor: "white"
                            checked: true
                            onClicked: platformInterface.step_start.update(platformInterface.step_duration_notification.duration, "seconds")
                        }

                        SGSegmentedButton{
                            id:stepsSegmentedButton
                            text: qsTr("steps")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: "black"
                            textActiveColor: "white"
                            onClicked: platformInterface.step_start.update(platformInterface.step_duration_notification.duration, "steps")
                        }
                        SGSegmentedButton{
                            id:degreesSegmentedButton
                            text: qsTr("degrees")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: "black"
                            textActiveColor: "white"
                            onClicked: platformInterface.step_start.update(platformInterface.step_duration_notification.duration, "degrees")
                        }
                    }
                }
            }


                SGSegmentedButtonStrip {
                    id: stepButtonSelector
                    labelLeft: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    textColor: "#666"
                    activeTextColor: "white"
                    radius: 10
                    buttonHeight: 50
                    exclusive: true
                    buttonImplicitWidth: 100

                    segmentedButtons: GridLayout {
                        columnSpacing: 2
                        rowSpacing: 2

                        SGSegmentedButton{
                            text: qsTr("start")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: "black"
                            textActiveColor: "white"
                            checked: true
                            onClicked: platformInterface.step_start.update();
                        }

                        SGSegmentedButton{
                            text: qsTr("stop")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: "black"
                            textActiveColor: "white"
                            onClicked: platformInterface.step_hold.update();
                        }

                        SGSegmentedButton{
                            text: qsTr("standby")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: "black"
                            textActiveColor: "white"
                            onClicked: platformInterface.step_open.update();
                        }
                    }
                }

//                Row{
//                    spacing: 10
//                    id:stepButtonRow
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    SGButton{
//                        id:motor1startButton
//                        text:"start"
//                        contentItem: Text {
//                                text: motor1startButton.text
//                                font.pixelSize: 32
//                                color:"black"
//                                horizontalAlignment: Text.AlignHCenter
//                                verticalAlignment: Text.AlignVCenter
//                                elide: Text.ElideRight
//                            }

//                            background: Rectangle {
//                                implicitWidth: 100
//                                implicitHeight: 40
//                                opacity: enabled ? 1 : 0.3
//                                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
//                                color:motor1startButton.down ? "dimgrey" : "lightgrey"
//                                border.width: 1
//                                radius: 10
//                            }


//                    }
//                    SGButton{
//                        id:motor1stopButton
//                        text:"stop"
//                        contentItem: Text {
//                                text: motor1stopButton.text
//                                font.pixelSize: 32
//                                color:"black"
//                                horizontalAlignment: Text.AlignHCenter
//                                verticalAlignment: Text.AlignVCenter
//                                elide: Text.ElideRight
//                            }

//                            background: Rectangle {
//                                implicitWidth: 100
//                                implicitHeight: 40
//                                opacity: enabled ? 1 : 0.3
//                                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
//                                color:motor1stopButton.down ? "dimgrey" : "lightgrey"
//                                border.width: 1
//                                radius: 10
//                            }
//                    }
//                    SGButton{
//                        id:motor1standbyButton
//                        text:"standby"
//                        contentItem: Text {
//                                text: motor1standbyButton.text
//                                font.pixelSize: 32
//                                color:"black"
//                                horizontalAlignment: Text.AlignHCenter
//                                verticalAlignment: Text.AlignVCenter
//                                elide: Text.ElideRight
//                            }

//                            background: Rectangle {
//                                implicitWidth: 100
//                                implicitHeight: 40
//                                opacity: enabled ? 1 : 0.3
//                                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
//                                color:motor1standbyButton.down ? "dimgrey" : "lightgrey"
//                                border.width: 1
//                                radius: 10
//                            }
//                    }

//                }
            }
        }
    }
}



