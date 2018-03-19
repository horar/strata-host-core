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
                minimumInputVoltageText, minimumInputRect, minimumInputUnitText, minimumInputVoltageSlider,
                faultTempText, faultTempTextField, faultTempUnitText, faultTempSlider]
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
                minimumInputVoltageText, minimumInputTextField, minimumInputUnitText, minimumInputVoltageSlider,
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
        Connections {
            target: implementationInterfaceBinding
            onFaultProtectionChanged:{
                //onsole.log("fault protection message received with value ",protectionMode)
                if( protectionMode === "shutdown" ) {
                    shutdownButton.checked= true
                }
            }
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
        Connections {
            target: implementationInterfaceBinding
            onFaultProtectionChanged:{
                if( protectionMode === "retry" ) {
                    restartButton.checked= true
                }
            }
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

        Connections {
            target: implementationInterfaceBinding
            onFaultProtectionChanged:{
                if( protectionMode === "nothing" ) {
                    noProtectionButton.checked = true
                }
            }
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
            implementationInterfaceBinding.setRedriverConfiguration("charge_only")
        }
        Connections {
            target: implementationInterfaceBinding
            onDataPathConfigurationChanged:{
                if( dataConfiguration === "charge_only" ) {
                    chargeOnlyButton.checked = true
                }
            }
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
            implementationInterfaceBinding.setRedriverConfiguration("passive")
        }
        Connections {
            target: implementationInterfaceBinding
            onDataPathConfigurationChanged:{
                if( dataConfiguration === "passive" ) {
                    passiveButton.checked = true
                }
            }
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
            implementationInterfaceBinding.setRedriverConfiguration("redriver")
        }
        Connections {
            target: implementationInterfaceBinding
            onDataPathConfigurationChanged:{
                if( dataConfiguration === "redriver" ) {
                    redriverButton.checked = true
                }
            }
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

        Component.onCompleted: {
            inputLimitingSwitch.toggle()
            inputLimitingGroup.setInputVoltageLimitingEnabled(inputLimitingSwitch.checked)
        }

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

        function setInputVoltageLimitingEnabled(inEnabled){
            //toggle enablement of the input limiting controls
            startLimitingText.enabled = inEnabled
            startLimitingVoltageRect.enabled = inEnabled
            startLimitingUnitText.enabled = inEnabled
            startLimitingVoltageSlider.enabled = inEnabled
            outputLimitText.enabled = inEnabled
            outputLimitPopup.enabled = inEnabled
            outputLimitUnitText.enabled = inEnabled
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
                inputLimitingGroup.setInputVoltageLimitingEnabled(inputLimitingSwitch.checked)

                implementationInterfaceBinding.setVoltageFoldbackParameters(inputLimitingSwitch.checked,
                                                                            Math.round(startLimitingVoltageSlider.value *10)/10,
                                                                            parseInt(outputLimitPopup.displayText))
            }
            Connections {
                target: implementationInterfaceBinding
                onFoldbackLimitingChanged:{
                    //console.log("input limiting message to set voltage to ",inputVoltageFoldbackEnabled)
                    inputLimitingSwitch.checked = inputVoltageFoldbackEnabled
                    inputLimitingGroup.setInputVoltageLimitingEnabled(inputVoltageFoldbackEnabled)
                }
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

        Rectangle{
             id: startLimitingVoltageRect
             color: enabled ? textEditFieldBackgroundColor : textEditFieldDisabledBackgroundColor
             anchors.left:startLimitingText.right
             anchors.leftMargin: 10
             anchors.verticalCenter: startLimitingText.verticalCenter
             height:15
             width:25

            TextField{
                id:startLimitingTextInput
                anchors.fill: parent
                anchors.leftMargin: 2
                anchors.topMargin: 5

                horizontalAlignment: Qt.AlignLeft

                font.family: "helvetica"
                font.pointSize: smallFontSize
                color:enabled ? enabledTextColor : disabledTextColor
                text: startLimitingVoltageSlider.value
                validator: DoubleValidator {bottom:5; top:32; decimals:0}
                background: Rectangle {
                    color:"transparent"
                }
                onEditingFinished:{
                    startLimitingVoltageSlider.value= text
                    implementationInterfaceBinding.setTemperatureFoldbackParameters(temperatureLimitingSwitch.checked,
                                                                                    Math.round(boardTemperatureSlider.value *10)/10,
                                                                                    parseInt(boardOuputPopup.displayText))

                  }


            }
        }


        Text{
            id:startLimitingUnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            //horizontalAlignment: Text.AlignRight
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:startLimitingVoltageRect.right
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
                startLimitingTextInput.text = Math.round(startLimitingVoltageSlider.value *10)/10
            }

            Connections {
                target: implementationInterfaceBinding
                onFoldbackLimitingChanged:{
                        startLimitingVoltageSlider.value = Math.round(inputVoltageFoldbackStartVoltage *10)/10
                    }
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

            Connections {
                target: implementationInterfaceBinding
                onFoldbackLimitingChanged:{
                    outputLimitPopup.currentIndex = outputLimitPopup.find(parseInt(inputVoltageFoldbackOutputLimit))
                    }
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

        Component.onCompleted: {
            temperatureLimitingSwitch.toggle()
            temperatureLimitingGroup.setTemperatureLimitingEnabled(temperatureLimitingSwitch.checked)
        }

        function setTemperatureLimitingEnabled(inEnabled){
            boardTemperatureText.enabled = inEnabled
            boardTemperatureRect.enabled = inEnabled
            boardTemperatureUnitText.enabled = inEnabled
            boardTemperatureSlider.enabled = inEnabled
            boardOutputLimitText.enabled = inEnabled
            boardOuputPopup.enabled = inEnabled
            boardOutputUnitText.enabled = inEnabled
        }

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
                temperatureLimitingGroup.setTemperatureLimitingEnabled(temperatureLimitingSwitch.checked)

                implementationInterfaceBinding.setTemperatureFoldbackParameters(temperatureLimitingSwitch.checked,
                                                                                Math.round(boardTemperatureSlider.value *10)/10,
                                                                                parseInt(boardOuputPopup.displayText))
            }

            Connections {
                target: implementationInterfaceBinding
                onFoldbackLimitingChanged:{
                    temperatureLimitingSwitch.checked = temperatureFoldbackEnabled
                    temperatureLimitingGroup.setTemperatureLimitingEnabled(temperatureFoldbackEnabled)
                    }
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

        Rectangle{
             id: boardTemperatureRect
             color: enabled ? textEditFieldBackgroundColor : textEditFieldDisabledBackgroundColor
             anchors.left:boardTemperatureText.right
             anchors.leftMargin: 10
             anchors.verticalCenter: boardTemperatureText.verticalCenter
             anchors.verticalCenterOffset: 0
             height:15
             width:25

            TextField{
                id:boardTemperatureTextInput
                anchors.fill: parent
                anchors.leftMargin: 2
                anchors.topMargin: 5

                horizontalAlignment: Qt.AlignLeft

                font.family: "helvetica"
                font.pointSize: smallFontSize
                color:enabled ? enabledTextColor : disabledTextColor
                text: boardTemperatureSlider.value
                validator: DoubleValidator {bottom:25; top:100; decimals:1}
                background: Rectangle {
                    color:"transparent"
                }
                onEditingFinished:{
                    boardTemperatureSlider.value= text
                    implementationInterfaceBinding.setTemperatureFoldbackParameters(temperatureLimitingSwitch.checked,
                                                                                    Math.round(boardTemperatureSlider.value *10)/10,
                                                                                    parseInt(boardOuputPopup.displayText))

                  }
            }
        }



        Text{
            id:boardTemperatureUnitText
            text:"°C"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:boardTemperatureRect.right
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
            value:100
            stepSize: 0.0

            onPressedChanged: {
                if (!pressed){
                    implementationInterfaceBinding.setTemperatureFoldbackParameters(temperatureLimitingSwitch.checked,
                                                                                    Math.round(boardTemperatureSlider.value *10)/10,
                                                                                    parseInt(boardOuputPopup.displayText))
                }
            }

            onMoved: {
                boardTemperatureTextInput.text = Math.round(boardTemperatureSlider.value)
            }

            Connections {
                target: implementationInterfaceBinding
                onFoldbackLimitingChanged:{
                        boardTemperatureSlider.value = Math.round(temperatureFoldbackStartTemp*10)/10
                    }
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

            Connections {
                target: implementationInterfaceBinding
                onFoldbackLimitingChanged:{
                    boardOuputPopup.currentIndex = boardOuputPopup.find(parseInt(temperatureFoldbackOutputLimit))
                    }
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

    Rectangle{
        id: minimumInputRect
        color: textEditFieldBackgroundColor
        anchors.left:minimumInputVoltageText.right
        anchors.leftMargin: 5
        anchors.verticalCenter: minimumInputVoltageText.verticalCenter
        height:15
        width:30

        TextField{
            id:minimumInputTextField
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.topMargin: 5

            horizontalAlignment: Qt.AlignLeft

            font.family: "helvetica"
            font.pointSize: smallFontSize
            color:enabled ? enabledTextColor : disabledTextColor
            text: minimumInputVoltageSlider.value
            validator: DoubleValidator {bottom:5; top:32; decimals:1}
            background: Rectangle {
                color:"transparent"
            }
            onEditingFinished:{
                minimumInputVoltageSlider.value= text
              }
        }
    }


    Text{
        id:minimumInputUnitText
        text:"V"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: enabled ? enabledTextColor : disabledTextColor
        anchors.left:minimumInputRect.right
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
            minimumInputTextField.text = Math.round(minimumInputVoltageSlider.value *10)/10
        }

        Connections {
            target: implementationInterfaceBinding
            onInputUnderVoltageChanged:{
                console.log("minimum input notification received:",value)
                minimumInputVoltageSlider.value = Math.round(value*10)/10
            }
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

    Rectangle{
        id: faultTempRect
        color: textEditFieldBackgroundColor
        anchors.left:faultTempText.right
        anchors.leftMargin: 5
        anchors.verticalCenter: faultTempText.verticalCenter
        height:15
        width:30

        TextField{
            id:faultTempTextField
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.topMargin: 5

            horizontalAlignment: Qt.AlignLeft

            font.family: "helvetica"
            font.pointSize: smallFontSize
            color:enabled ? enabledTextColor : disabledTextColor
            text: faultTempSlider.value
            validator: DoubleValidator {bottom:25; top:100; decimals:1}
            background: Rectangle {
                color:"transparent"
            }
            onEditingFinished:{
                faultTempSlider.value= text
              }
        }
    }




    Text{
        id:faultTempUnitText
        text:"°C"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: enabled ? enabledTextColor : disabledTextColor
        anchors.left:faultTempRect.right
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
            faultTempTextField.text = Math.round(faultTempSlider.value *10)/10

        }
        Connections {
            target: implementationInterfaceBinding
            onMaximumTemperatureChanged:{
                console.log("maximum temperature notification received:",value)
                faultTempSlider.value = Math.round(value*10)/10
            }
        }

    }
}   //board settings rect
