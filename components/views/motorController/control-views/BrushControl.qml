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


    Rectangle {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }
        //color: motorControllerGrey
        color:"white"

        property int leftMargin: width/12
        property int statBoxHeight:100
        property int motorColumnTopMargin: 50

        property bool inOverCurrentProtection: platformInterface.dc_ocp_notification.ocp_set === "on"

        Text{
            id:pwmSliderLabel
            text: "PWM frequency:"
            font.pixelSize:24
            anchors.right:pwmSlider.left
            anchors.rightMargin: 5
            anchors.verticalCenter: pwmSlider.verticalCenter
            anchors.verticalCenterOffset: -10
            color: pwmSlider.enabled ? "black" : "grey"
        }

        SGSlider{
            id:pwmSlider
            height:40
            anchors.top:parent.top
            anchors.topMargin: 50
            anchors.left:parent.left
            anchors.leftMargin:container.leftMargin*3
            anchors.right:parent.right
            anchors.rightMargin: container.leftMargin * 2
            from: 500
            to: 10000
            stepSize:100
            grooveColor: enabled ? "lightgrey" : "grey"
            fillColor: enabled ? motorControllerPurple : "grey"
            enabled: !motor1IsRunning && !motor2IsRunning //&& !container.inOverCurrentProtection
            live:false
            fromText.color: enabled ? "black" : "grey"
            toText.color: enabled ? "black" : "grey"
            textColor: enabled ? "black" : "grey"
            inputBox.boxColor : enabled ? "white" : "grey"
            handleObject.color: enabled? "white" : "grey "

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
            color: pwmSlider.enabled ? "motorControllerDimGrey" : "grey"
        }







        RowLayout{
            id:portInfoRow
            height:container.statBoxHeight
            width: parent.width*.50
            anchors.left:parent.left
            anchors.leftMargin: parent.width*.22
            anchors.top: pwmSliderLabel.bottom
            anchors.topMargin: 60

            spacing: parent.width*.1


            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                //color:"pink"

                PortStatBox{
                    id:motor1InputVoltage
                    height:container.statBoxHeight
                    width:250
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
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                //color:"lightblue"

                PortStatBox{
                    id:motor1InputCurrent
                    height:container.statBoxHeight
                    width:250
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


                Rectangle{
                    id: overCurrentProtectionRectangle
                    //border.color:"black"
                    //opacity:.5
                    anchors.left: motor1InputCurrent.right
                    anchors.leftMargin: 110
                    anchors.top: motor1InputCurrent.top
                    anchors.topMargin: 0
                    width: 150
                    height:100

                    Text{
                        id:overCurrentProtectionText
                        anchors.top: overCurrentProtectionRectangle.top
                        anchors.topMargin: 0
                        anchors.left:overCurrentProtectionRectangle.left
                        anchors.leftMargin: 5
                        text:"OCP"
                        font.pixelSize: 24

                    }

                    SGSwitch{
                        id:ocpSwitch
                        anchors.top: ocpIndicatorLight.bottom
                        anchors.topMargin: 5
                        anchors.horizontalCenter: ocpIndicatorLight.horizontalCenter
                        width:50
                        grooveFillColor: motorControllerPurple
                        checked: (platformInterface.ocp_enable_notification.enable === "on") ? true : false
                        enabled: !container.inOverCurrentProtection

                        onToggled:{
                            var value = "off";
                            if (checked)
                                value = "on"
                            platformInterface.ocp_enable.update(value);
                        }

                    }

                    Rectangle {
                        id: ocpIndicatorLight
                        width: 50
                        height: width
                        radius: width/2
                        anchors.top: overCurrentProtectionText.bottom
                        anchors.topMargin:  0
                        anchors.horizontalCenter:overCurrentProtectionText.horizontalCenter
                        color: "transparent"
                        border.color: "grey"
                        border.width: 3
                        property alias lightcolor: lightColorLayer.color
                        Rectangle {
                            id: lightColorLayer
                            anchors.centerIn: ocpIndicatorLight
                            width: ocpIndicatorLight.width * .6
                            height: width
                            radius: width/2
                            color: "green"

                            property var stepOverCurrentProtection: platformInterface.dc_ocp_notification.ocp_set
                            onStepOverCurrentProtectionChanged: {
                                if (platformInterface.dc_ocp_notification.ocp_set === "on")
                                    color = "red"
                                else
                                    color = "green"
                            }

                            property var overCurrentProtectionEnabled: platformInterface.ocp_enable_notification
                            onOverCurrentProtectionEnabledChanged: {
                                if (platformInterface.ocp_enable_notification.enable === "off")
                                    color = "grey"
                                else{   //ocp protection is on
                                    if (platformInterface.dc_ocp_notification.ocp_set === "on")
                                        color = "red"
                                    else
                                        color = "green"
                                }
                            }

                        }
                    }

                    SGButton{
                        id:ocpResetButton
                        width:100
                        height:40
                        anchors.left: ocpIndicatorLight.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: ocpIndicatorLight.verticalCenter
                        text: "reset"
                        fontSizeMultiplier:2

                        visible: platformInterface.dc_ocp_notification.ocp_set === "on" ? true : false

                        onClicked:{
                            platformInterface.dc_ocp_reset.update()
                        }
                    }
                }
            }

        }   //row



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
                    color: !container.inOverCurrentProtection ? "black" : "grey"
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
                    enabled: !container.inOverCurrentProtection

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
                id: pwmModeRow
                spacing:10
                width:parent.width

                Text{
                    text:"PWM mode:"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -5
                    width:65
                    color: !container.inOverCurrentProtection ? "black" : "grey"
                }

                SGWidgets09.SGSegmentedButtonStrip {
                    id: pwmModeSelector
                    labelLeft: false
                    textColor: "#666"
                    activeTextColor: "white"
                    radius: 4
                    buttonHeight: 20
                    exclusive: true
                    buttonImplicitWidth: 50
                    hoverEnabled:false
                    enabled: !container.inOverCurrentProtection

                    property var pwmMode1:  platformInterface.dc_pwm_mode_1_notification.mode

                    onPwmMode1Changed: {
                        console.log("received a new pwm mode notification. Units are",platformInterface.dc_pwm_mode_1_notification.mode)
                        if (pwmMode1 === "on_off"){
                            index = 0;
                        }
                        else if (pwmMode1 === "on_brake"){
                            index = 1;
                        }
                        console.log("index is now",index)

                    }

                    segmentedButtons: GridLayout {
                        columnSpacing: 2
                        rowSpacing: 2

                        SGWidgets09.SGSegmentedButton{
                            id:onOffSegmentedButton
                            text: qsTr("on \u2194 off")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: motorControllerInactiveButtonText
                            textActiveColor: "white"
                            checked: true
                            onClicked: platformInterface.set_pwm_mode_1.update("on_off")
                        }

                        SGWidgets09.SGSegmentedButton{
                            id:onBrakeSegmentedButton
                            text: qsTr("on \u2194 brake")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: motorControllerInactiveButtonText
                            textActiveColor: "white"
                            onClicked: platformInterface.set_pwm_mode_1.update("on_brake")
                        }

                    }
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
                    color: !container.inOverCurrentProtection ? "black" : "grey"
                }

                SGSlider{
                    id:dutyRatioSlider
                    width:parent.width *.8

                    from: 0
                    to: 100
                    stepSize: 1
                    fillColor: motorControllerPurple
                    value: (platformInterface.dc_duty_1_notification.duty * 100)
                    live: false
                    enabled: !container.inOverCurrentProtection

                    onUserSet: {
                        platformInterface.set_dc_duty_1.update((value/100));
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
                enabled: !container.inOverCurrentProtection

                property int motor1State: platformInterface.motor_run_1_notification.mode
                onMotor1StateChanged:{
                    if (motor1State == 1)
                        index = 0
                    else if (motor1State == 2)
                        index = 1
                    else
                        index = 2
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
                        textSize:24
                        onClicked:{
                            if (platformInterface.motor_run_1_notification.mode !== 1)
                                platformInterface.motor_run_1.update(1);
                        }
                    }

                    MCSegmentedButton{
                        text: qsTr("stop")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: motorControllerInactiveButtonText
                        textActiveColor: "white"
                        textSize:24
                        onClicked:{
                            if (platformInterface.motor_run_1_notification.mode !== 2)
                                platformInterface.motor_run_1.update(2);
                        }
                    }

                    MCSegmentedButton{
                        text: qsTr("standby")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: motorControllerInactiveButtonText
                        textActiveColor: "white"
                        checked:true
                        textSize:24
                        onClicked:{
                            if (platformInterface.motor_run_1_notification.mode !== 3)
                                platformInterface.motor_run_1.update(3);
                        }
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
                    color: "black"
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
                    color: !container.inOverCurrentProtection ? "black" : "grey"
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
                    enabled: !container.inOverCurrentProtection

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
                id: pwmModeRow2
                spacing:10
                width:parent.width

                Text{
                    text:"PWM mode:"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -5
                    width:65
                    color: !container.inOverCurrentProtection ? "black" : "grey"
                }

                SGWidgets09.SGSegmentedButtonStrip {
                    id: pwmModeSelector2
                    labelLeft: false
                    textColor: "#666"
                    activeTextColor: "white"
                    radius: 4
                    buttonHeight: 20
                    exclusive: true
                    buttonImplicitWidth: 50
                    hoverEnabled:false
                    enabled: !container.inOverCurrentProtection

                    property var pwmMode2:  platformInterface.dc_pwm_mode_2_notification.mode

                    onPwmMode2Changed: {
                        console.log("received a new pwm mode notification. Units are",platformInterface.dc_pwm_mode_2_notification.mode, index)
                        if (pwmMode2 === "on_off"){
                            index = 0;
                        }
                        else if (pwmMode2 === "on_brake"){
                            index = 1;
                        }
                        console.log("index is now",index)

                    }
                    onIndexChanged: {
                        console.log("index changed called. index is now",index)
                    }

                    segmentedButtons: GridLayout {
                        columnSpacing: 2
                        rowSpacing: 2

                        SGWidgets09.SGSegmentedButton{
                            id:onOffSegmentedButton2
                            text: qsTr("on \u2194 off")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: motorControllerInactiveButtonText
                            textActiveColor: "white"
                            checked: true
                            onClicked: platformInterface.set_pwm_mode_2.update("on_off")
                            onCheckedChanged: console.log("on off button now checked")
                        }

                        SGWidgets09.SGSegmentedButton{
                            id:onBrakeSegmentedButton2
                            text: qsTr("on \u2194 brake")
                            activeColor: "dimgrey"
                            inactiveColor: "gainsboro"
                            textColor: motorControllerInactiveButtonText
                            textActiveColor: "white"
                            onClicked: platformInterface.set_pwm_mode_2.update("on_brake")
                            onCheckedChanged: console.log("on brake button now checked")
                        }

                    }
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
                    color: !container.inOverCurrentProtection ? "black" : "grey"
                }

                SGSlider{
                    id:dutyRatioSlider2
                    //anchors.left:parent.left
                    width:parent.width *.8

                    from: 0
                    to: 100
                    stepSize: 1
                    fillColor: motorControllerPurple
                    value: platformInterface.dc_duty_2_notification.duty *100
                    live: false
                    enabled:!container.inOverCurrentProtection

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
                enabled:!container.inOverCurrentProtection

                property int motor2State: platformInterface.motor_run_2_notification.mode
                onMotor2StateChanged:{
                    if (motor2State == 1)
                        index = 0
                    else if (motor2State == 2)
                        index = 1
                    else
                        index = 2
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
                        textSize:24
                        onClicked: {
                            if (platformInterface.motor_run_2_notification.mode !== 1)
                                platformInterface.motor_run_2.update(1);
                        }
                    }

                    MCSegmentedButton{
                        text: qsTr("stop")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: motorControllerInactiveButtonText
                        textActiveColor: "white"
                        textSize:24
                        onClicked: {
                            if (platformInterface.motor_run_2_notification.mode !== 2)
                                platformInterface.motor_run_2.update(2);
                        }
                    }

                    MCSegmentedButton{
                        text: qsTr("standby")
                        activeColor: "dimgrey"
                        inactiveColor: "gainsboro"
                        textColor: motorControllerInactiveButtonText
                        textActiveColor: "white"
                        checked: true
                        textSize:24
                        onClicked:{
                            if (platformInterface.motor_run_2_notification.mode !== 3)
                                platformInterface.motor_run_2.update(3);
                        }
                    }
                }
            }


        }


    }
}



