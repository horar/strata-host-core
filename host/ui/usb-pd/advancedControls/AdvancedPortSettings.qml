import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

//-----------------------------------------------
//  Port  settings
//-----------------------------------------------
Rectangle{
    id:portSettings
    property int fullHeight:300
    property int collapsedHeight:60
    property var portName:"Port n"

    property color enabledTextFieldBackgroundColor: "#838484"
    property color disabledTextFieldBackgroundColor: "#33FFFFFF"

    property color enabledTextFieldTextColor: "white"
    property color disabledTextFieldTextColor: "grey"

    Layout.preferredWidth  : grid.prefWidth(this)
    Layout.preferredHeight : portSettings.fullHeight
    color: "black"

    NumberAnimation{
        id: collapsePortSettings
        target: portSettings;
        property: "Layout.preferredHeight";
        to: portSettings.collapsedHeight;
        duration: settings.collapseAnimationSpeed
    }

    NumberAnimation {
        id: expandPortSettings
        target: portSettings
        property: "Layout.preferredHeight";
        to: portSettings.fullHeight
        duration: settings.collapseAnimationSpeed;
    }

    Button{
        id: portSettingsDisclosureButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.topMargin: 20
        height: 20
        width: 20
        checkable: true
        checked: true
        background: Rectangle {
            color: "black"
        }


        Image{
            id:portDisclosureButtonImage
            anchors.left:parent.left
            anchors.leftMargin: 3
            anchors.top:parent.top
            height:10
            width:14
            source:"../images/icons/showLessIcon.svg"

            transform: Rotation {
                id: rotatePortButtonImage
                origin.x: portDisclosureButtonImage.width/2;
                origin.y: portDisclosureButtonImage.height/2;
                axis { x: 0; y: 0; z: 1 }
            }

            NumberAnimation {
                id:collapsePortDisclosureIcon
                running: false
                loops: 1
                target: rotatePortButtonImage;
                property: "angle";
                from: 0; to: 180;
                duration: 1000;
            }

            NumberAnimation {
                id:expandPortDisclosureIcon
                running: false
                loops: 1
                target: rotatePortButtonImage;
                property: "angle";
                from: 180; to: 0;
                duration: 1000;
            }
        }

        onClicked:{
            if (checked == true){
                expandPortSettings.start();
                expandPortDisclosureIcon.start();
                }
            else{
                collapsePortSettings.start();
                collapsePortDisclosureIcon.start();
              }
        }

    }

    Label{
        id: portSettingsLabel
        text: parent.portName + " Settings"
        font.family: "Helvetica"
        font.pointSize: mediumFontSize
        color: "#D8D8D8"
        anchors.left:parent.left
        anchors.top:parent.top
        anchors.leftMargin: 20//parent.width/20
        anchors.topMargin: 20//parent.height/20
    }

    Rectangle{
        id: portSettingsSeparator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: parent.width/20
        anchors.rightMargin: parent.width/20
        anchors.top: portSettingsLabel.bottom
        anchors.topMargin: portSettingsLabel.height
        height: 1
        color:"#CCCCCC"
    }

    Text{
        id:portMaxPowerText
        text:"Maximum power output:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: "#D8D8D8"
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.6
        anchors.top: portSettingsSeparator.bottom
        anchors.topMargin: 15
    }

    PopUpMenu{
        id: portMaxPowerCombo
        model: ["15","27", "36", "45","60","100"]
        anchors.left:portMaxPowerText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: portMaxPowerText.verticalCenter
    }


    Text{
        id:portMaxPowerUnitText
        text:"W"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: "#D8D8D8"
        anchors.left:portMaxPowerCombo.right
        anchors.leftMargin: 5
        anchors.verticalCenter: portMaxPowerText.verticalCenter

    }


    Text{
        id:portCableCompensationText
        text:"Cable compensation step:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: "#D8D8D8"
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.6
        anchors.top: portMaxPowerText.bottom
        anchors.topMargin: 10

    }
    TextField{
        id:portCableCompensationTextInput
        anchors.left:portCableCompensationText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: portCableCompensationText.verticalCenter
        color:enabled ? enabledTextColor : disabledTextColor
        placeholderText:portCableCompensationSlider.value
        font.family: "helvetica"
        font.pointSize: 12
        verticalAlignment: TextInput.AlignTop
        height:15
        width:30
        background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: "#838484"
                border.color: "#838484"
            }
    }
    Text{
        id:portCableCompensationUnitText
        text:"A"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: "#D8D8D8"
        anchors.left:portCableCompensationTextInput.right
        anchors.leftMargin: 5
        anchors.verticalCenter: portCableCompensationText.verticalCenter

    }

    AdvancedSlider{
        id:portCableCompensationSlider
        anchors.left:portCableCompensationUnitText.right
        anchors.leftMargin: 5
        anchors.right:parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: portCableCompensationText.verticalCenter
        height:10
        from: .25
        to:2
        value:.25
        stepSize: 0.0

        onValueChanged: {
            portCableCompensationTextInput.text = Math.round (portCableCompensationSlider.value *100)/100
        }
    }

    Text{
        id:voltageCompensationText
        text:"Voltage compensation:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: "#D8D8D8"
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.6
        anchors.top: portCableCompensationText.bottom
        anchors.topMargin: 10
    }
    TextField{
        id:voltageCompensationTextInput
        anchors.left:voltageCompensationText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: voltageCompensationText.verticalCenter
        color:"white"//"#838484"
        placeholderText:"7"
        verticalAlignment: TextInput.AlignTop
        font.family: "helvetica"
        font.pointSize: smallFontSize
        height:15
        width:30
        background: Rectangle {
                implicitWidth: 15
                implicitHeight: 10
                color: "#838484"//"#33FFFFFF"
                border.color: "#838484"
            }
    }
    Text{
        id:voltageCompensationUnitText
        text:"mV"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: "#D8D8D8"
        anchors.left:voltageCompensationTextInput.right
        anchors.leftMargin: 5
        anchors.verticalCenter: voltageCompensationText.verticalCenter

    }

    AdvancedSlider{
        id:voltageCompensationSlider
        anchors.left:voltageCompensationUnitText.right
        anchors.leftMargin: 5
        anchors.right:parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: voltageCompensationText.verticalCenter
        height:10
        from: 0
        to:200
        value:0
        stepSize: 50.0

        onValueChanged: {
            voltageCompensationTextInput.text = Math.round (voltageCompensationSlider.value *10)/10
        }
    }



    Text{
        id:maxCurrentText
        text:"Current limit:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: "#D8D8D8"
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.6
        anchors.top: voltageCompensationText.bottom
        anchors.topMargin: 10
    }
    TextField{
        id:maxCurrentTextInput
        anchors.left:maxCurrentText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: maxCurrentText.verticalCenter
        color:"white"//"#838484"
        placeholderText:"7"
        verticalAlignment: TextInput.AlignTop
        font.family: "helvetica"
        font.pointSize: smallFontSize
        height:15
        width:30
        background: Rectangle {
                implicitWidth: 15
                implicitHeight: 10
                color: "#838484"//"#33FFFFFF"
                border.color: "#838484"
            }
    }
    Text{
        id:maxCurrentUnitText
        text:"A"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: "#D8D8D8"
        anchors.left:maxCurrentTextInput.right
        anchors.leftMargin: 5
        anchors.verticalCenter: maxCurrentText.verticalCenter

    }

    AdvancedSlider{
        id:maxCurrentSlider
        anchors.left:maxCurrentUnitText.right
        anchors.leftMargin: 5
        anchors.right:parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: maxCurrentText.verticalCenter
        height:10
        from: 3
        to:7.5
        value:0
        stepSize: .5

        onValueChanged: {
            maxCurrentTextInput.text = Math.round (maxCurrentSlider.value *10)/10
        }
    }

    //-----------------------------------------------
    //  advertized voltages group
    //-----------------------------------------------
    Rectangle{
        id:portAdvertizedVoltagesGroup
        color:"black"//"#33FFFFFF"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.top: maxCurrentText.bottom
        anchors.topMargin: 10
        height: 150
        Text{
            id:portAdvertizedVoltagesLabel
            text:"Advertised Voltages:"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.right:parent.right
            anchors.rightMargin: parent.width*.6
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        TextField{
            id:portvoltage1TextInput
            anchors.left:portAdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: portAdvertizedVoltagesGroup.top
            anchors.topMargin: 0
            color:enabled ? enabledTextFieldTextColor : disabledTextFieldTextColor
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: enabled ? enabledTextFieldBackgroundColor : disabledTextFieldBackgroundColor
                }
        }

        Text{
            id:portvoltage1UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:portvoltage1TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: portvoltage1TextInput.verticalCenter

        }
        AdvancedSlider{
            id:portvoltage1Slider
            anchors.left:portvoltage1UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: portvoltage1TextInput.verticalCenter
            height:10
            from: 4.95
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                portvoltage1TextInput.text = Math.round (portvoltage1Slider.value *10)/10
                if (portvoltage1Slider.value < 5){
                    portvoltage1TextInput.enabled = false;
                    portvoltage1TextInput.text = "NA";
                    portvoltage1UnitText.enabled = false;
                    }
                else{
                    portvoltage1TextInput.enabled = true;
                    portvoltage1UnitText.enabled = true;
                }
            }
        }



        TextField{
            id:portvoltage2TextInput
            anchors.left:portAdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: portvoltage1TextInput.bottom
            anchors.topMargin: 5
            color:enabled ? enabledTextFieldTextColor : disabledTextFieldTextColor
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: enabled ? enabledTextFieldBackgroundColor : disabledTextFieldBackgroundColor
                }
        }

        Text{
            id:portvoltage2UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:portvoltage2TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: portvoltage2TextInput.verticalCenter

        }

        AdvancedSlider{
            id:portvoltage2Slider
            anchors.left:portvoltage2UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: portvoltage2UnitText.verticalCenter
            height:10
            from: 4.95
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                portvoltage2TextInput.text = Math.round (portvoltage2Slider.value *10)/10
                if (portvoltage2Slider.value < 5){
                    portvoltage2TextInput.enabled = false;
                    portvoltage2TextInput.text = "NA";
                    portvoltage2UnitText.enabled = false;
                    }
                else{
                    portvoltage2TextInput.enabled = true;
                    portvoltage2UnitText.enabled = true;
                }
            }
        }



        TextField{
            id:portvoltage3TextInput
            anchors.left:portAdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: portvoltage2TextInput.bottom
            anchors.topMargin: 5
            color:enabled ? enabledTextFieldTextColor : disabledTextFieldTextColor
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: enabled ? enabledTextFieldBackgroundColor : disabledTextFieldBackgroundColor
                }
        }

        Text{
            id:portvoltage3UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:portvoltage3TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: portvoltage3TextInput.verticalCenter

        }

        AdvancedSlider{
            id:portvoltage3Slider
            anchors.left:portvoltage3UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: portvoltage3TextInput.verticalCenter
            height:10
            from: 4.95
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                portvoltage3TextInput.text = Math.round (portvoltage3Slider.value *10)/10
                if (portvoltage3Slider.value < 5){
                    portvoltage3TextInput.enabled = false;
                    portvoltage3TextInput.text = "NA";
                    portvoltage3UnitText.enabled = false;
                    }
                else{
                    portvoltage3TextInput.enabled = true;
                    portvoltage3UnitText.enabled = true;
                }
            }
        }



        TextField{
            id:portvoltage4TextInput
            anchors.left:portAdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: portvoltage3TextInput.bottom
            anchors.topMargin: 5
            color:enabled ? enabledTextFieldTextColor : disabledTextFieldTextColor
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: enabled ? enabledTextFieldBackgroundColor : disabledTextFieldBackgroundColor
                }
        }

        Text{
            id:portvoltage4UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:portvoltage4TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: portvoltage4TextInput.verticalCenter

        }

        AdvancedSlider{
            id:portvoltage4Slider
            anchors.left:portvoltage4UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: portvoltage4TextInput.verticalCenter
            height:10
            from: 4.95
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                portvoltage4TextInput.text = Math.round (portvoltage4Slider.value *10)/10
                if (portvoltage4Slider.value < 5){
                    portvoltage4TextInput.enabled = false;
                    portvoltage4TextInput.text = "NA";
                    portvoltage4UnitText.enabled = false;
                    }
                else{
                    portvoltage4TextInput.enabled = true;
                    portvoltage4UnitText.enabled = true;
                }
            }
        }



        TextField{
            id:portvoltage5TextInput
            anchors.left:portAdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: portvoltage4TextInput.bottom
            anchors.topMargin: 5
            color:enabled ? enabledTextFieldTextColor : disabledTextFieldTextColor
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: enabled ? enabledTextFieldBackgroundColor : disabledTextFieldBackgroundColor
                }
        }

        Text{
            id:portvoltage5UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:portvoltage5TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: portvoltage5TextInput.verticalCenter

        }

        AdvancedSlider{
            id:portvoltage5Slider
            anchors.left:portvoltage5UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: portvoltage5TextInput.verticalCenter
            height:10
            from: 4.95
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                portvoltage5TextInput.text = Math.round (portvoltage5Slider.value *10)/10
                if (portvoltage5Slider.value < 5){
                    portvoltage5TextInput.enabled = false;
                    portvoltage5TextInput.text = "NA";
                    portvoltage5UnitText.enabled = false;
                    }
                else{
                    portvoltage5TextInput.enabled = true;
                    portvoltage5UnitText.enabled = true;
                }
            }
        }



        TextField{
            id:portvoltage6TextInput
            anchors.left:portAdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: portvoltage5TextInput.bottom
            anchors.topMargin: 5
            color:enabled ? enabledTextFieldTextColor : disabledTextFieldTextColor
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: enabled ? enabledTextFieldBackgroundColor : disabledTextFieldBackgroundColor
                }
        }

        Text{
            id:portvoltage6UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:portvoltage6TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: portvoltage6TextInput.verticalCenter

        }

        AdvancedSlider{
            id:portvoltage6Slider
            anchors.left:portvoltage6UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: portvoltage6TextInput.verticalCenter
            height:10
            from: 4.95
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                portvoltage6TextInput.text = Math.round (portvoltage6Slider.value *10)/10
                if (portvoltage6Slider.value < 5){
                    portvoltage6TextInput.enabled = false;
                    portvoltage6TextInput.text = "NA";
                    portvoltage6UnitText.enabled = false;
                    }
                else{
                    portvoltage6TextInput.enabled = true;
                    portvoltage6UnitText.enabled = true;
                }
            }
        }



        TextField{
            id:portvoltage7TextInput
            anchors.left:portAdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: portvoltage6TextInput.bottom
            anchors.topMargin: 5
            color:enabled ? enabledTextFieldTextColor : disabledTextFieldTextColor
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: enabled ? enabledTextFieldBackgroundColor : disabledTextFieldBackgroundColor
                }
        }

        Text{
            id:portvoltage7UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: enabled ? enabledTextColor : disabledTextColor
            anchors.left:portvoltage7TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: portvoltage7TextInput.verticalCenter

        }

        AdvancedSlider{
            id:portvoltage7Slider
            anchors.left:portvoltage7UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: portvoltage7TextInput.verticalCenter
            height:10
            from: 4.95
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                portvoltage7TextInput.text = Math.round (portvoltage7Slider.value *10)/10
                if (portvoltage7Slider.value < 5){
                    portvoltage7TextInput.enabled = false;
                    portvoltage7TextInput.text = "NA";
                    portvoltage7UnitText.enabled = false;
                    }
                else{
                    portvoltage7TextInput.enabled = true;
                    portvoltage7UnitText.enabled = true;
                }
            }
        }


    }
}
