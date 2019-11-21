import QtQuick 2.9
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.12
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
        color: motorControllerGrey

        property int leftMargin: width/12
        property int statBoxHeight:100
        property int motorColumnTopMargin: 50

        SGSlider{
            id:pwmSlider
            height:50
            anchors.top:parent.top
            anchors.topMargin: 50
            anchors.left:parent.left
            anchors.leftMargin:container.leftMargin*3
            anchors.right:parent.right
            anchors.rightMargin: container.leftMargin * 3

            from: .01
            to: .99
            stepSize:.01
            label: "PWM Fequency:"
            toolTipDecimalPlaces:2
            grooveFillColor: motorControllerTeal

            property var frequency: platformInterface.pwm_frequency_notification.frequency

            onFrequencyChanged: {
                pwmSlider.setValue(frequency)
            }

            onUserSet: {
                //console.log("setting frequency to",value);
                platformInterface.set_pwm_frequency.update(value);
            }

        }

        PortStatBox{
            id:motor1InputVoltage

            height:container.statBoxHeight
            width:parent.width/6
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: pwmSlider.bottom
            anchors.topMargin: 20
            label: "INPUT VOLTAGE"
            unit:"V"
            color:"transparent"
            valueSize: 64
            unitSize:20
            textColor: "black"
            portColor: "#2eb457"
            labelColor:"black"
            //underlineWidth: 0
            imageHeightPercentage: .5
            bottomMargin: 10
            value: platformInterface.dc_notification.Voltage

        }
        PortStatBox{
            id:motor1InputCurrent

            height:container.statBoxHeight
            width:parent.width/6
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: motor1InputVoltage.bottom
            anchors.topMargin: 20
            label: "INPUT CURRENT"
            unit:"mA"
            color:"transparent"
            valueSize: 64
            unitSize:20
            textColor: "black"
            portColor: "#2eb457"
            labelColor:"black"
            //underlineWidth: 0
            imageHeightPercentage: .5
            bottomMargin: 10
            value: platformInterface.dc_notification.Current
        }

        LinearGradient{
            id:column1background
            anchors.top:motor1InputCurrent.bottom
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
            anchors.top:motor1InputCurrent.bottom
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

            anchors.top:motor1InputCurrent.bottom
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
                        pixelSize: 72
                    }
                    color:"black"
                    opacity:.8
                    anchors {
                        //horizontalCenter: parent.horizontalCenter
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
                    horizontalAlignment: Text.AlignRight
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
                    label:""
                    grooveFillColor: motorControllerTeal
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

                SGSlider{
                    id:dutyRatioSlider
                    //anchors.left:parent.left
                    width:parent.width *.95

                    from: 0
                    to: 100
                    label: "Duty ratio:"
                    grooveFillColor: motorControllerTeal
                    value: platformInterface.dc_duty_1_notification.duty

                    onMoved: {
                        platformInterface.set_dc_duty_1.update(value);
                    }
                }
                Text{
                    id:dutyRatio1Unit

                    text:"%"
                    font.pixelSize: 18
                    color:"dimgrey"
                }
            }

            SGSegmentedButtonStrip {
                id: brushStepperSelector
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
                        onClicked: platformInterface.dc_start_1.update();
                    }

                    SGSegmentedButton{
                        text: qsTr("stop")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "black"
                        textActiveColor: "white"
                        onClicked: platformInterface.dc_brake_1.update();
                    }

                    SGSegmentedButton{
                        text: qsTr("standby")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "black"
                        textActiveColor: "white"
                        onClicked: platformInterface.dc_open_1.update();
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
            anchors.top:motor1InputCurrent.bottom
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
            anchors.top:motor1InputCurrent.bottom
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
                        pixelSize: 72
                    }
                    color:"black"
                    opacity:.8
                    anchors {
                        //horizontalCenter: parent.horizontalCenter
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
                    horizontalAlignment: Text.AlignRight
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
                    label:""
                    //anchors.left:parent.left
                    //anchors.leftMargin: 5
                    grooveFillColor: motorControllerTeal
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

                SGSlider{
                    id:dutyRatioSlider2
                    //anchors.left:parent.left
                    width:parent.width *.95

                    from: 0
                    to: 100
                    label: "Duty ratio:"
                    grooveFillColor: motorControllerTeal
                    value: platformInterface.dc_duty_2_notification.duty

                    onMoved: {
                        platformInterface.set_dc_duty_2.update(value);
                    }
                }
                Text{
                    id:dutyRatio1Unit2

                    text:"%"
                    font.pixelSize: 18
                    color:"dimgrey"
                }
            }

            SGSegmentedButtonStrip {
                id: brushStepperSelector2
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
                        onClicked: platformInterface.dc_start_2.update();
                    }

                    SGSegmentedButton{
                        text: qsTr("stop")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "black"
                        textActiveColor: "white"
                        onClicked: platformInterface.dc_brake_2.update();
                    }

                    SGSegmentedButton{
                        text: qsTr("standby")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: "black"
                        textActiveColor: "white"
                        onClicked: platformInterface.dc_open_2.update();
                    }
                }
            }


        }


    }
}



