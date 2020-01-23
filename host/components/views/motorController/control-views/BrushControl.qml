import QtQuick 2.9
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.12
import "qrc:/js/help_layout_manager.js" as Help

SGWidgets09.SGResponsiveScrollView {
    id: root

    minimumHeight: 600
    minimumWidth: 1000

    // Animates opacity change
    Behavior on opacity {
        NumberAnimation { duration: 0 }
    }

    Rectangle {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }
        color: motorControllerGrey

        property int leftMargin: width/12
        property int statBoxHeight:100
        property int motorColumnTopMargin: 50

        Text{
            id:pwmSliderLabel
            text: "PWM Fequency:"
            font.pixelSize:24
            anchors.right:pwmSlider.left
            anchors.rightMargin: 5
            anchors.verticalCenter: pwmSlider.verticalCenter
            anchors.verticalCenterOffset: -10
        }

        SGSlider{
            id:pwmSlider
            height:40
            //width:200
            anchors.top:parent.top
            anchors.topMargin: 50
            anchors.left:parent.left
            anchors.leftMargin:container.leftMargin*3
            anchors.right:parent.right
            anchors.rightMargin: container.leftMargin * 2
            from: 500
            to: 10000
            stepSize:100
            grooveColor: "lightgrey"
            fillColor: motorControllerPurple
            enabled: !motor1IsRunning && !motor2IsRunning
            live:false

            property var frequency: platformInterface.pwm_frequency_notification.frequency
            onFrequencyChanged: {
                pwmSlider.slider.value = frequency
            }

            property bool motor1IsRunning: false
            property var motor1Running: platformInterface.motor_run_1_notification
            onMotor1RunningChanged: {
                if (platformInterface.motor_run_1_notification.mode === 1)
                    motor1IsRunning = true;
                else
                    motor1IsRunning = false;
            }

            property bool motor2IsRunning: false
            property var motor2Running: platformInterface.motor_run_2_notification
            onMotor2RunningChanged: {
                if (platformInterface.motor_run_2_notification.mode === 1)
                    motor2IsRunning = true;
                else
                    motor2IsRunning = false;
            }

            onUserSet: {
                //console.log("setting frequency to",value);
                platformInterface.set_pwm_frequency.update(value);
            }

        }
        Text{
            id:pwmUnitText
            anchors.verticalCenter: pwmSlider.verticalCenter
            anchors.verticalCenterOffset: -10
            anchors.left:pwmSlider.right
            anchors.leftMargin: 5
            text:"Hz"
            font.pixelSize: 18
            color:motorControllerDimGrey
        }



        Row{
            id:portInfoRow
            height:container.statBoxHeight
            width: parent.width
            anchors.left:parent.left
            anchors.leftMargin: parent.width*.2
            anchors.top: pwmSliderLabel.bottom
            anchors.topMargin: 75

            spacing: parent.width*.1



            PortStatBox{
                id:motor1InputVoltage

                height:container.statBoxHeight
                width:parent.width*.25


                label: "INPUT VOLTAGE"
                labelSize:12
                unit:"V"
                unitColor: motorControllerDimGrey
                color:"transparent"
                valueSize: 64
                unitSize:20
                textColor: "black"
                portColor: "#2eb457"
                labelColor:"black"
                //underlineWidth: 0
                imageHeightPercentage: .5
                bottomMargin: 10
                value: platformInterface.dc_notification.voltage.toFixed(1)

            }
            PortStatBox{
                id:motor1InputCurrent

                height:container.statBoxHeight
                width:parent.width*.25

                label: "INPUT CURRENT"
                labelSize:12
                unit:"mA"
                unitColor: motorControllerDimGrey
                color:"transparent"
                valueSize: 64
                unitSize:20
                textColor: "black"
                portColor: "#2eb457"
                labelColor:"black"
                //underlineWidth: 0
                imageHeightPercentage: .5
                bottomMargin: 10
                value: platformInterface.dc_notification.current.toFixed(0)
            }


        }

        LinearGradient{
            id:column1background
            anchors.top:portInfoRow.bottom
            anchors.topMargin: container.motorColumnTopMargin/2
            anchors.left:parent.left
            //anchors.leftMargin: container.leftMargin
            anchors.bottom:parent.bottom
            width: parent.width/2
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            opacity:.2
            gradient: Gradient {
                GradientStop { position: 0.0; color: motorControllerGrey }
                GradientStop { position: .75; color: motorControllerBlue }
            }
        }

        LinearGradient{
            id:column2background
            anchors.top:portInfoRow.bottom
            anchors.topMargin: container.motorColumnTopMargin/2
            anchors.left:column1background.right
            anchors.bottom:parent.bottom
            width: parent.width/2
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            opacity:.2
            gradient: Gradient {
                GradientStop { position: 0.0; color: motorControllerGrey }
                GradientStop { position: .75; color: motorControllerTeal }
            }
        }

        Column{
            id:motor1Column

            anchors.top:portInfoRow.bottom
            anchors.topMargin: container.motorColumnTopMargin
            anchors.left:parent.left
            anchors.leftMargin: container.leftMargin
            anchors.bottom:parent.bottom
            width: parent.width/3
            spacing: 20




            Row{
                id:motor1SNameRow
                height:container.statBoxHeight
                width: parent.width
                spacing: 20

                Image {
                    id: motor1icon
                    height:container.statBoxHeight
                    fillMode: Image.PreserveAspectFit
                    mipmap:true

                    source:"../images/icon-motor.svg"
                }

                Text{
                    id:motor1Name
                    text: "Motor 1"
                    font {
                        pixelSize: 54
                    }
                    color:"black"
                    opacity:.8
                    anchors {
                        verticalCenter: parent.verticalCenter

                    }
                }
            }


            Row{
                spacing: 10
                id:directionRow1
                anchors.left:parent.left
                width: parent.width

                Text{
                    id:directionLabel
                    color:"black"
                    text: "Direction:"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -5
                    width:65
                }

                Image {
                    id: clockwiseicon
                    height:20
                    fillMode: Image.PreserveAspectFit
                    mipmap:true

                    source:"../images/icon-clockwise-darkGrey.svg"
                }

                SGSwitch{
                    id:directionSwitch
                    width:50
                    grooveFillColor: motorControllerPurple
                    checked: (platformInterface.dc_direction_1_notification.direction === "counterclockwise") ? true : false

                    onToggled:{
                        var value = "clockwise";
                        if (checked)
                            value = "counterclockwise"

                        platformInterface.set_dc_direction_1.update(value);
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
                id:dutyRatioRow
                spacing: 10
                width:parent.width
                Text{
                    text:"Duty ratio:"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -10
                    width:65
                }

                SGSlider{
                    id:dutyRatioSlider
                    //anchors.left:parent.left
                    width:parent.width *.8

                    from: 0
                    to: 100
                    fillColor: motorControllerPurple
                    value: platformInterface.dc_duty_1_notification.duty * 100
                    live: false

                    onUserSet: {
                        platformInterface.set_dc_duty_1.update(value/100);
                    }
                }
                Text{
                    id:dutyRatio1Unit

                    text:"%"
                    font.pixelSize: 18
                    color:motorControllerDimGrey
                }
            }

            SGWidgets09.SGSegmentedButtonStrip {
                id: brushStepperSelector
                labelLeft: false
                anchors.horizontalCenter: parent.horizontalCenter
                textColor: "#666"
                activeTextColor: "white"
                radius: 10
                buttonHeight: 50
                exclusive: true
                buttonImplicitWidth: 100
                hoverEnabled: false

                segmentedButtons: GridLayout {
                    columnSpacing: 2
                    rowSpacing: 2

                    MCSegmentedButton{
                        text: qsTr("start")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "#b3b3b3"
                        textActiveColor: "white"
                        textSize:24
                        onClicked: platformInterface.motor_run_1.update(1);
                    }

                    MCSegmentedButton{
                        text: qsTr("stop")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "#b3b3b3"
                        textActiveColor: "white"
                        textSize:24
                        onClicked: platformInterface.motor_run_1.update(2);
                    }

                    MCSegmentedButton{
                        text: qsTr("standby")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "#b3b3b3"
                        textActiveColor: "white"
                        checked:true
                        textSize:24
                        onClicked: platformInterface.motor_run_1.update(3);
                    }
                }
            }


        }

//-------------------------------------------------------------------------------------------------
//
//      spacer column
//
//-------------------------------------------------------------------------------------------------
        Column{
            id:spacerColumn
            anchors.top:portInfoRow.bottom
            anchors.topMargin: container.motorColumnTopMargin/2
            anchors.left:motor1Column.right
            anchors.bottom:parent.bottom
            //anchors.leftMargin: leftMargin
            width: container.leftMargin*2
            //height:400

            Rectangle{
                height:parent.height
                width: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: "dimgrey"
            }
        }

//-------------------------------------------------------------------------------------------------
//
//      MOTOR 2
//
//-------------------------------------------------------------------------------------------------

        Column{
            id:motor2Column
            anchors.top:portInfoRow.bottom
            anchors.topMargin: container.motorColumnTopMargin
            anchors.left:spacerColumn.right
            width: parent.width/3
            spacing: 20

            Row{
                id:motor2NameRow
                height:container.statBoxHeight
                width: parent.width
                spacing: 20

                Image {
                    id: motor2icon
                    height:container.statBoxHeight
                    fillMode: Image.PreserveAspectFit
                    mipmap:true

                    source:"../images/icon-motor.svg"
                }

                Text{
                    id:motor2Name
                    text: "Motor 2"
                    font {
                        pixelSize: 54
                    }
                    color:"black"
                    opacity:.8
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }



            Row{
                spacing: 10
                id:directionRow2
                anchors.left:parent.left
                width: parent.width

                Text{
                    id:directionLabel2
                    color:"black"
                    text: "Direction:"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -5
                    width:65
                }

                Image {
                    id: clockwiseicon2
                    height:20
                    fillMode: Image.PreserveAspectFit
                    mipmap:true

                    source:"../images/icon-clockwise-darkGrey.svg"
                }

                SGSwitch{
                    id:directionSwitch2
                    width:50
                    grooveFillColor: motorControllerPurple
                    checked: (platformInterface.dc_direction_2_notification.direction === "counterclockwise") ? true: false

                    onToggled: {
                        var value = "clockwise";
                        if (checked)
                            value = "counterclockwise"
                        platformInterface.set_dc_direction_2.update(value);
                    }
                }

                Image {
                    id: counterClockwiseicon2
                    height:20
                    fillMode: Image.PreserveAspectFit
                    mipmap:true

                    source:"../images/icon-counterClockwise-darkGrey.svg"
                }


            }
            Row{
                id:dutyRatioRow2
                spacing: 10
                width:parent.width

                Text{
                    text:"Duty ratio:"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -10
                    width:65
                }

                SGSlider{
                    id:dutyRatioSlider2
                    //anchors.left:parent.left
                    width:parent.width *.8

                    from: 0
                    to: 100
                    fillColor: motorControllerPurple
                    value: platformInterface.dc_duty_2_notification.duty *100
                    live: false

                    onUserSet: {
                        platformInterface.set_dc_duty_2.update(value/100);
                    }                    
                }
                Text{
                    id:dutyRatio1Unit2

                    text:"%"
                    font.pixelSize: 18
                    color:motorControllerDimGrey
                }
            }

            SGWidgets09.SGSegmentedButtonStrip {
                id: brushStepperSelector2
                labelLeft: false
                anchors.horizontalCenter: parent.horizontalCenter
                textColor: "#666"
                activeTextColor: "white"
                radius: 10
                buttonHeight: 50
                exclusive: true
                buttonImplicitWidth: 100
                hoverEnabled:false

                segmentedButtons: GridLayout {
                    columnSpacing: 2
                    rowSpacing: 2

                    MCSegmentedButton{
                        text: qsTr("start")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "#b3b3b3"
                        textActiveColor: "white"
                        textSize:24
                        onClicked: platformInterface.motor_run_2.update(1);
                    }

                    MCSegmentedButton{
                        text: qsTr("stop")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "#b3b3b3"
                        textActiveColor: "white"
                        textSize:24
                        onClicked: platformInterface.motor_run_2.update(2);
                    }

                    MCSegmentedButton{
                        text: qsTr("standby")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "#b3b3b3"
                        textActiveColor: "white"
                        checked: true
                        textSize:24
                        onClicked: platformInterface.motor_run_2.update(3);
                    }
                }
            }


        }


    }
}



