import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0


Rectangle{
    id: boardSettings
    property int fullHeight:350
    property int collapsedHeight:55
    Layout.preferredWidth  : grid.prefWidth(this)
    Layout.preferredHeight : boardSettings.fullHeight
    color: "black"

    SequentialAnimation{
        id: collapseBoardSettings

        PropertyAnimation{
            targets: [faultProtectionLabel, shutdownButton, restartButton, noProtectionButton, dataConfigurationLabel,
                chargeOnlyButton, passiveButton, redriverButton,
                inputLimitingGroup, temperatureLimitingGroup,
                minimumInputVoltageText, minimumInputLabel, minimumInputUnitText, minimumInputVoltageSlider,
                faultTempText, faultTempLabel, faultTempUnitText, faultTempSlider]
            property:"opacity"
            to: 0
            duration:500
        }
        NumberAnimation{
            target: boardSettings;
            property: "Layout.preferredHeight";
            to: boardSettings.collapsedHeight;
            duration: settings.collapseAnimationSpeed;
        }
    }

    SequentialAnimation{
        id: expandBoardSettings

        NumberAnimation {
            target: boardSettings
            property: "Layout.preferredHeight";
            to: boardSettings.fullHeight;
            duration: settings.collapseAnimationSpeed;
        }
        PropertyAnimation{
            targets: [faultProtectionLabel, shutdownButton, restartButton, noProtectionButton, dataConfigurationLabel,
                chargeOnlyButton, passiveButton, redriverButton,
                inputLimitingGroup,  temperatureLimitingGroup,
                minimumInputVoltageText, minimumInputLabel, minimumInputUnitText, minimumInputVoltageSlider,
                faultTempText, faultTempLabel, faultTempUnitText, faultTempSlider]

            property:"opacity"
            to: 1.0
            duration:500
        }

    }

    Button{
        id: boardSettingsDisclosureButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.topMargin: 20
        height: 20
        width: 20
        checkable: true
        checked: true
        background: Rectangle {
            color:"black"
        }


        Image{
            id:boardSettingsDisclosureButtonImage
            anchors.left:parent.left
            anchors.leftMargin: 3
            anchors.top:parent.top
            height:10
            width:14
            source:"../images/icons/showLessIcon.svg"

            transform: Rotation {
                id: rotateBoardSettingsButtonImage
                origin.x: boardSettingsDisclosureButtonImage.width/2;
                origin.y: boardSettingsDisclosureButtonImage.height/2;
                axis { x: 0; y: 0; z: 1 }
            }

            NumberAnimation {
                id:collapseBoardSettingsDisclosureIcon
                running: false
                loops: 1
                target: rotateBoardSettingsButtonImage;
                property: "angle";
                from: 0; to: 180;
                duration: 1000;
            }

            NumberAnimation {
                id:expandBoardSettingsDisclosureIcon
                running: false
                loops: 1
                target: rotateBoardSettingsButtonImage;
                property: "angle";
                from: 180; to: 0;
                duration: 1000;
            }
        }


        onClicked:{
            if (checked == true){
                expandBoardSettings.start();
                expandBoardSettingsDisclosureIcon.start()
            }
            else{
                collapseBoardSettings.start();
                collapseBoardSettingsDisclosureIcon.start()
            }
        }

    }

    Label{
        id: boardSettingsLabel
        text: "System Settings"
        font.family: "Helvetica"
        font.pointSize: mediumFontSize
        color: "#D8D8D8"
        anchors.left:parent.left
        anchors.top:parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 20
    }

    Rectangle{
        id: boardSettingsSeparator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: parent.width/20
        anchors.rightMargin: parent.width/20
        anchors.top: boardSettingsLabel.bottom
        anchors.topMargin: boardSettingsLabel.height
        height: 1
        color:"#CCCCCC"
    }

    Label{
        id:faultProtectionLabel
        text:"Fault Protection:"
        font.family: "helvetica"
        font.pointSize: mediumFontSize
        color: enabledTextColor
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.top: boardSettingsSeparator.bottom
        anchors.topMargin: 10
    }

    ButtonGroup { id: faultProtectionGroup
        exclusive: true
    }

    LeftSegmentedButton{
        id:shutdownButton
        anchors.left: faultProtectionLabel.right
        anchors.leftMargin: 5
        anchors.verticalCenter: faultProtectionLabel.verticalCenter
        text: "Shutdown"
        font.capitalization: Font.MixedCase
        font.pointSize: smallFontSize
        checkedColor: "#767676"
        unCheckedColor: "#4C4A48"
        checkedTextColor: enabledTextColor
        uncheckedTextColor: unselectedButtonSegmentTextColor
        ButtonGroup.group: faultProtectionGroup
        height: 25
        width:90
        onClicked: {
            implementationInterfaceBinding.setFaultMode("shutdown")
        }

    }
    MiddleSegmentedButton{
        id:restartButton
        anchors.left: shutdownButton.right
        anchors.leftMargin: 0
        anchors.verticalCenter: faultProtectionLabel.verticalCenter
        text:"Restart"
        font.pointSize: smallFontSize
        font.capitalization: Font.MixedCase
        checkedColor: "#767676"
        unCheckedColor: "#4C4A48"
        checkedTextColor: enabledTextColor
        uncheckedTextColor: unselectedButtonSegmentTextColor
        ButtonGroup.group: faultProtectionGroup
        height: 25
        width:65
        onClicked: {
            implementationInterfaceBinding.setFaultMode("retry")
        }
    }
    RightSegmentedButton{
        id:noProtectionButton
        anchors.left: restartButton.right
        anchors.leftMargin: 0
        anchors.verticalCenter: faultProtectionLabel.verticalCenter
        text:"None"
        font.capitalization: Font.MixedCase
        font.pointSize: smallFontSize
        checkedColor: "#767676"
        unCheckedColor: "#4C4A48"
        checkedTextColor: enabledTextColor
        uncheckedTextColor: unselectedButtonSegmentTextColor
        ButtonGroup.group: faultProtectionGroup
        height: 25
        width:75
        onClicked: {
            implementationInterfaceBinding.setFaultMode("nothing")
        }
    }

    Label{
        id:dataConfigurationLabel
        text:"Data Configuration:"
        font.family: "helvetica"
        font.pointSize: mediumFontSize
        color: "#D8D8D8"
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: faultProtectionLabel.bottom
        anchors.topMargin: 15
    }

    ButtonGroup { id: dataConfigurationGroup
        exclusive: true
    }

    LeftSegmentedButton{
        id:chargeOnlyButton
        anchors.left: dataConfigurationLabel.right
        anchors.leftMargin: 5
        anchors.verticalCenter: dataConfigurationLabel.verticalCenter
        text: "Charge only"
        font.capitalization: Font.MixedCase
        font.pointSize: smallFontSize
        checkedColor: "#767676"
        unCheckedColor: "#4C4A48"
        checkedTextColor: enabledTextColor
        uncheckedTextColor: unselectedButtonSegmentTextColor
        ButtonGroup.group: dataConfigurationGroup
        height: 25
        width:90
        onClicked: {
            implementationInterfaceBinding.setRedriverCount(0)
        }

    }
    MiddleSegmentedButton{
        id:passiveButton
        anchors.left: chargeOnlyButton.right
        anchors.leftMargin: 0
        anchors.verticalCenter: dataConfigurationLabel.verticalCenter
        text:"Passive"
        font.pointSize: smallFontSize
        font.capitalization: Font.MixedCase
        checkedColor: "#767676"
        unCheckedColor: "#4C4A48"
        checkedTextColor: enabledTextColor
        uncheckedTextColor: unselectedButtonSegmentTextColor
        ButtonGroup.group: dataConfigurationGroup
        height: 25
        width:65
        onClicked: {
            implementationInterfaceBinding.setRedriverCount(1)
        }
    }
    RightSegmentedButton{
        id:redriverButton
        anchors.left: passiveButton.right
        anchors.leftMargin: 0
        anchors.verticalCenter: dataConfigurationLabel.verticalCenter
        text:"Redriver"
        font.capitalization: Font.MixedCase
        font.pointSize: smallFontSize
        checkedColor: "#767676"
        unCheckedColor: "#4C4A48"
        checkedTextColor: enabledTextColor
        uncheckedTextColor: unselectedButtonSegmentTextColor
        ButtonGroup.group: dataConfigurationGroup
        height: 25
        width:75
        onClicked: {
            implementationInterfaceBinding.setRedriverCount(2)
        }
    }

    Rectangle{
        id:inputLimitingGroup
        color:"#33FFFFFF"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.top: dataConfigurationLabel.bottom
        anchors.topMargin: dataConfigurationLabel.height
        height: 75

        Text{
            id:inputLimitingText
            text:"Input Limiting"
            font.family: "helvetica"
            font.pointSize: mediumFontSize
            color: "#D8D8D8"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        Switch{
            id: inputLimitingSwitch
            anchors.left: inputLimitingText.right
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 5
            height: 15
            width:30
            checked:true
            //this is the background of the switch
            indicator: Rectangle {
                implicitWidth: 30
                implicitHeight: 15
                x: inputLimitingSwitch.leftPadding
                y: parent.height / 2 - height / 2
                radius: 7
                color: inputLimitingSwitch.checked ? "#0078D7"  : "black"
                border.color: inputLimitingSwitch.checked ? "#0078D7" : "white"

                //this is the thumb that moves
                Rectangle {
                    x: inputLimitingSwitch.checked ? parent.width - width : 0
                    y: parent.height / 2 - height / 2
                    width: 10
                    height: 10
                    radius: 5
                    color: "white"
                }
            }
            onToggled: {
                //toggle enablement of the input limiting controls
                startLimitingText.enabled = inputLimitingSwitch.checked
                startLimitingVoltageLabel.enabled = inputLimitingSwitch.checked
                startLimitingUnitText.enabled = inputLimitingSwitch.checked
                startLimitingVoltageSlider.enabled = inputLimitingSwitch.checked
                outputLimitText.enabled = inputLimitingSwitch.checked
                outputLimitPopup.enabled = inputLimitingSwitch.checked
                outputLimitUnitText.enabled = inputLimitingSwitch.checked

                implementationInterfaceBinding.setVoltageFoldbackParameters(inputLimitingSwitch.checked,
                                                                            Math.round(startLimitingVoltageSlider.value *10)/10,
                                                                            parseInt(outputLimitPopup.displayText))
            }
        }

        Text{
            id:startLimitingText
            text:"Start limiting at:"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            horizontalAlignment: Text.AlignRight
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.right:parent.right
            anchors.rightMargin: parent.width*.6
            anchors.top: inputLimitingText.bottom
            anchors.topMargin: 10

        }

        Label{
            id:startLimitingVoltageLabel
            anchors.left:startLimitingText.right
            anchors.leftMargin: 10
            anchors.verticalCenter: startLimitingText.verticalCenter
            color:enabled ? enabledTextColor : disabledTextColor
            text:startLimitingVoltageSlider.value
            verticalAlignment: TextInput.AlignVCenter
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
        }


        Text{
            id:startLimitingUnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            //horizontalAlignment: Text.AlignRight
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:startLimitingVoltageLabel.right
            anchors.leftMargin: 5
            anchors.verticalCenter: startLimitingText.verticalCenter

        }

        AdvancedSlider{
            id:startLimitingVoltageSlider
            anchors.left:startLimitingUnitText.right
            anchors.leftMargin: 5
            anchors.verticalCenter: startLimitingText.verticalCenter
            anchors.right:parent.right
            anchors.rightMargin: 5
            from: 5
            to:32
            value:5
            stepSize: 0.0

            onPressedChanged: {
                if (!pressed){
                    implementationInterfaceBinding.setVoltageFoldbackParameters(inputLimitingSwitch.checked,
                                                                                Math.round(startLimitingVoltageSlider.value *10)/10,
                                                                                parseInt(outputLimitPopup.displayText))
                }
            }

            onMoved: {
                startLimitingVoltageLabel.text = Math.round(startLimitingVoltageSlider.value *10)/10
            }
        }

        Text{
            id:outputLimitText
            text:"Limit Board Output to:"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            horizontalAlignment: Text.AlignRight
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.right:parent.right
            anchors.rightMargin: parent.width*.6
            anchors.top: startLimitingText.bottom
            anchors.topMargin: 10
        }

        PopUpMenu{
            id: outputLimitPopup
            model: ["15","27", "36", "45","60","100"]
            anchors.left:outputLimitText.right
            anchors.leftMargin: 10
            anchors.verticalCenter: outputLimitText.verticalCenter

            onActivated: {
                implementationInterfaceBinding.setVoltageFoldbackParameters(inputLimitingSwitch.checked,
                                                                            Math.round(startLimitingVoltageSlider.value *10)/10,
                                                                            parseInt(outputLimitPopup.displayText))
            }
        }


        Text{
            id:outputLimitUnitText
            text:"W"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:outputLimitPopup.right
            anchors.leftMargin: 5
            anchors.verticalCenter: outputLimitText.verticalCenter

        }



    }

    //------------------------------------
    //  temperature limit Group
    //---------------------------------
    Rectangle{
        id:temperatureLimitingGroup
        color:"#33FFFFFF"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.top: inputLimitingGroup.bottom
        anchors.topMargin: boardSettingsLabel.height
        height: 75

        Text{
            id:temperatureLimitingText
            text:"Temperature Limiting"
            font.family: "helvetica"
            font.pointSize: mediumFontSize
            color: "#D8D8D8"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        Switch{
            id: temperatureLimitingSwitch
            anchors.left: temperatureLimitingText.right
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 5
            height: 15
            width:30
            checked:true
            //this is the background of the switch
            indicator: Rectangle {
                implicitWidth: 30
                implicitHeight: 15
                x: temperatureLimitingSwitch.leftPadding
                y: parent.height / 2 - height / 2
                radius: 7
                color: temperatureLimitingSwitch.checked ? "#0078D7"  : "black"
                border.color: temperatureLimitingSwitch.checked ? "#0078D7" : "white"

                //this is the thumb that moves
                Rectangle {
                    x: temperatureLimitingSwitch.checked ? parent.width - width : 0
                    y: parent.height / 2 - height / 2
                    width: 10
                    height: 10
                    radius: 5
                    color: "white"
                }
            }
            onToggled: {
                //toggle enablement of the input limiting controls
                boardTemperatureText.enabled = temperatureLimitingSwitch.checked
                boardTemperatureLabel.enabled = temperatureLimitingSwitch.checked
                boardTemperatureUnitText.enabled = temperatureLimitingSwitch.checked
                boardTemperatureSlider.enabled = temperatureLimitingSwitch.checked
                boardOutputLimitText.enabled = temperatureLimitingSwitch.checked
                boardOuputPopup.enabled = temperatureLimitingSwitch.checked
                boardOutputUnitText.enabled = temperatureLimitingSwitch.checked

                implementationInterfaceBinding.setTemperatureFoldbackParameters(temperatureLimitingSwitch.checked,
                                                                                Math.round(boardTemperatureSlider.value *10)/10,
                                                                                parseInt(boardOuputPopup.displayText))
            }
        }

        Text{
            id:boardTemperatureText
            text:"When board temperature reaches:"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            horizontalAlignment: Text.AlignRight
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.right:parent.right
            anchors.rightMargin: parent.width*.4
            anchors.top: temperatureLimitingText.bottom
            anchors.topMargin: 10

        }
        Label{
            id:boardTemperatureLabel
            anchors.left:boardTemperatureText.right
            anchors.leftMargin: 10
            anchors.verticalCenter: boardTemperatureText.verticalCenter
            anchors.verticalCenterOffset: 2
            color:enabled ? enabledTextColor : disabledTextColor
            text:boardTemperatureSlider.value
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
        }


        Text{
            id:boardTemperatureUnitText
            text:"°C"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:boardTemperatureLabel.right
            anchors.leftMargin: 5
            anchors.verticalCenter: boardTemperatureText.verticalCenter

        }

        AdvancedSlider{
            id:boardTemperatureSlider
            anchors.left:boardTemperatureUnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: boardTemperatureText.verticalCenter
            height:10
            from: 25
            to:100
            value:5
            stepSize: 0.0

            onPressedChanged: {
                if (!pressed){
                    implementationInterfaceBinding.setTemperatureFoldbackParameters(temperatureLimitingSwitch.checked,
                                                                                    Math.round(boardTemperatureSlider.value *10)/10,
                                                                                    parseInt(boardOuputPopup.displayText))
                }
            }

            onMoved: {
                boardTemperatureLabel.text = Math.round(boardTemperatureSlider.value *10)/10
            }
        }

        Text{
            id:boardOutputLimitText
            text:"Limit Board Output to:"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            horizontalAlignment: Text.AlignRight
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.right:parent.right
            anchors.rightMargin: parent.width*.4
            anchors.top: boardTemperatureText.bottom
            anchors.topMargin: 10
        }

        PopUpMenu{
            id: boardOuputPopup
            model: ["15","27", "36", "45","60","100"]
            anchors.left:boardOutputLimitText.right
            anchors.leftMargin: 10
            anchors.verticalCenter: boardOutputLimitText.verticalCenter

            onActivated: {
                implementationInterfaceBinding.setTemperatureFoldbackParameters(temperatureLimitingSwitch.checked,
                                                                                Math.round(boardTemperatureSlider.value *10)/10,
                                                                                parseInt(boardOuputPopup.displayText))
            }
        }

        Text{
            id:boardOutputUnitText
            text:"W"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:boardOuputPopup.right
            anchors.leftMargin: 5
            anchors.verticalCenter: boardOutputLimitText.verticalCenter

        }
    }

    //--------------------------------------
    //     System faults
    //--------------------------------------

    Text{
        id:minimumInputVoltageText
        text:"Fault when input falls below:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: enabled ? enabledTextColor : disabledTextColor
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.5
        anchors.top: temperatureLimitingGroup.bottom
        anchors.topMargin: 10
    }
    Label{
        id:minimumInputLabel
        anchors.left:minimumInputVoltageText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: minimumInputVoltageText.verticalCenter
        anchors.verticalCenterOffset: 2
        color:enabled ? enabledTextColor : disabledTextColor
        text:minimumInputVoltageSlider.value
        verticalAlignment: TextInput.AlignTop
        font.family: "helvetica"
        font.pointSize: smallFontSize
        height:15
        width:20
    }
    Text{
        id:minimumInputUnitText
        text:"V"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: enabled ? enabledTextColor : disabledTextColor
        anchors.left:minimumInputLabel.right
        anchors.leftMargin: 5
        anchors.verticalCenter: minimumInputVoltageText.verticalCenter

    }

    AdvancedSlider{
        id:minimumInputVoltageSlider
        anchors.left:minimumInputUnitText.right
        anchors.leftMargin: 5
        anchors.right:parent.right
        anchors.rightMargin: 25
        anchors.verticalCenter: minimumInputVoltageText.verticalCenter
        height:10
        from: 5
        to:32
        value:5
        stepSize: 0.0

        onPressedChanged: {
            if (!pressed){
                implementationInterfaceBinding.setInputVoltageLimiting(Math.round(minimumInputVoltageSlider.value *10)/10)
            }
        }

        onMoved: {
            minimumInputLabel.text = Math.round(minimumInputVoltageSlider.value *10)/10
        }
    }

    Text{
        id:faultTempText
        text:"Fault when temperature reaches:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: enabled ? enabledTextColor : disabledTextColor
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.5
        anchors.top: minimumInputVoltageText.bottom
        anchors.topMargin: 10
    }

    Label{
        id:faultTempLabel
        anchors.left:faultTempText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: faultTempText.verticalCenter
        anchors.verticalCenterOffset: 2
        color:enabled ? enabledTextColor : disabledTextColor
        text:faultTempSlider.value
        verticalAlignment: TextInput.AlignTop
        font.family: "helvetica"
        font.pointSize: smallFontSize
        height:15
        width:20
    }


    Text{
        id:faultTempUnitText
        text:"°C"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: enabled ? enabledTextColor : disabledTextColor
        anchors.left:faultTempLabel.right
        anchors.leftMargin: 5
        anchors.verticalCenter: faultTempText.verticalCenter

    }

    AdvancedSlider{
        id:faultTempSlider
        anchors.left:faultTempUnitText.right
        anchors.leftMargin: 5
        anchors.right:parent.right
        anchors.rightMargin: 25
        anchors.verticalCenter: faultTempText.verticalCenter
        height:10
        from: 25
        to:100
        value:5
        stepSize: 0.0

        onPressedChanged: {
            if (!pressed){
                implementationInterfaceBinding.setMaximumTemperature(Math.round(faultTempSlider.value *10)/10)
            }
        }
        onMoved: {
            faultTempLabel.text = Math.round(faultTempSlider.value *10)/10

        }
    }
}   //board settings rect
