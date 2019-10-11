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

//            Rectangle{
//                anchors.top:parent.top
//                anchors.topMargin: container2.motorColumnTopMargin/2
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.bottom:parent.bottom
//                width: parent.width*.75
//                color:motorControllerBrown
//                opacity:.9
//            }

            LinearGradient{
                id:column1background
                anchors.top:parent.top
                anchors.topMargin: container2.motorColumnTopMargin/2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom:parent.bottom
                width: parent.width
                start: Qt.point(0, 0)
                end: Qt.point(0, height)
                opacity:1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: motorControllerGrey }
                    GradientStop { position: .1; color: motorControllerBrown }

                }
            }



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
                    value: platformInterface.step_start_notification.Voltage
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
                    value: platformInterface.step_start_notification.Current
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
                        checked: (platformInterface.step_direction_notification.direction == "counterclockwise") ? true : false
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

                        //when changing the value
                        onActivated: {
                            //console.log("Max Power Output: setting max power to ",parseInt(maxPowerOutput.comboBox.currentText));
                            //platformInterface.set_usb_pd_maximum_power.update(portNumber,parseInt(maxPowerOutput.comboBox.currentText))
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

                    }
                    Column{
                        ButtonGroup{
                            id:speedUnitsGroup
                        }

                        RadioButton{
                            id:stepsRadioButton
                            //text:"steps/second"
                            checked:true
                            ButtonGroup.group: speedUnitsGroup

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
                                   stepMotorSpeedSlider.to = 500
                                }

                        }
                        RadioButton{
                            id:rpmRadioButton
                            ButtonGroup.group: speedUnitsGroup

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
                                   stepMotorSpeedSlider.to = 1000
                                }
                        }
                    }

               }

                SGSlider{
                    id:runForSlider
                    anchors.left:parent.left
                    width:parent.width

                    from: 0
                    to: 100
                    label: "Run for:"
                    grooveFillColor: motorControllerTeal
                    textColor:"white"

                }

                Row{
                    spacing: 10
                    id:stepButtonRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    SGButton{
                        id:motor1startButton
                        text:"start"
                        contentItem: Text {
                                text: motor1startButton.text
                                font.pixelSize: 32
                                color:"black"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                opacity: enabled ? 1 : 0.3
                                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                                color:motor1startButton.down ? "dimgrey" : "lightgrey"
                                border.width: 1
                                radius: 10
                            }


                    }
                    SGButton{
                        id:motor1stopButton
                        text:"stop"
                        contentItem: Text {
                                text: motor1stopButton.text
                                font.pixelSize: 32
                                color:"black"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                opacity: enabled ? 1 : 0.3
                                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                                color:motor1stopButton.down ? "dimgrey" : "lightgrey"
                                border.width: 1
                                radius: 10
                            }
                    }
                    SGButton{
                        id:motor1standbyButton
                        text:"standby"
                        contentItem: Text {
                                text: motor1standbyButton.text
                                font.pixelSize: 32
                                color:"black"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                opacity: enabled ? 1 : 0.3
                                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                                color:motor1standbyButton.down ? "dimgrey" : "lightgrey"
                                border.width: 1
                                radius: 10
                            }
                    }

                }
            }
        }
    }
}



