import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

//-----------------------------------------------
//  Port  settings
//-----------------------------------------------
Rectangle{
    id:port1Settings
    property int fullHeight:300
    property int collapsedHeight:60
    property var portName:"Port n"

    Layout.preferredWidth  : grid.prefWidth(this)
    Layout.preferredHeight : port1Settings.fullHeight
    color: "black"

    NumberAnimation{
        id: collapsePort1Settings
        target: port1Settings;
        property: "Layout.preferredHeight";
        to: port1Settings.collapsedHeight;
        duration: settings.collapseAnimationSpeed
    }

    NumberAnimation {
        id: expandPort1Settings
        target: port1Settings
        property: "Layout.preferredHeight";
        to: port1Settings.fullHeight
        duration: settings.collapseAnimationSpeed;
    }

    Button{
        id: port1SettingsDisclosureButton
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
            id:port1DisclosureButtonImage
            anchors.left:parent.left
            anchors.leftMargin: 3
            anchors.top:parent.top
            height:10
            width:14
            source:"../images/icons/showLessIcon.svg"

            transform: Rotation {
                id: rotatePort1ButtonImage
                origin.x: port1DisclosureButtonImage.width/2;
                origin.y: port1DisclosureButtonImage.height/2;
                axis { x: 0; y: 0; z: 1 }
            }

            NumberAnimation {
                id:collapsePort1DisclosureIcon
                running: false
                loops: 1
                target: rotatePort1ButtonImage;
                property: "angle";
                from: 0; to: 180;
                duration: 1000;
            }

            NumberAnimation {
                id:expandPort1DisclosureIcon
                running: false
                loops: 1
                target: rotatePort1ButtonImage;
                property: "angle";
                from: 180; to: 0;
                duration: 1000;
            }
        }

        onClicked:{
            if (checked == true){
                expandPort1Settings.start();
                expandPort1DisclosureIcon.start();
                }
            else{
                collapsePort1Settings.start();
                collapsePort1DisclosureIcon.start();
              }
        }

    }

    Label{
        id: port1SettingsLabel
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
        id: port1SettingsSeparator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: parent.width/20
        anchors.rightMargin: parent.width/20
        anchors.top: port1SettingsLabel.bottom
        anchors.topMargin: port1SettingsLabel.height
        height: 1
        color:"#CCCCCC"
    }

    Text{
        id:port1MaxPowerText
        text:"Maximum power output:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: "#D8D8D8"
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.6
        anchors.top: port1SettingsSeparator.bottom
        anchors.topMargin: 15
    }

    PopUpMenu{
        id: port1MaxPowerCombo
        model: ["15","27", "36", "45","60","100"]
        anchors.left:port1MaxPowerText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: port1MaxPowerText.verticalCenter
    }


    Text{
        id:port1MaxPowerUnitText
        text:"W"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: "#D8D8D8"
        anchors.left:port1MaxPowerCombo.right
        anchors.leftMargin: 5
        anchors.verticalCenter: port1MaxPowerText.verticalCenter

    }


    Text{
        id:port1CableCompensationText
        text:"Cable compensation step:"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        horizontalAlignment: Text.AlignRight
        color: "#D8D8D8"
        anchors.right:parent.right
        anchors.rightMargin: parent.width*.6
        anchors.top: port1MaxPowerText.bottom
        anchors.topMargin: 10

    }
    TextField{
        id:port1CableCompensationTextInput
        anchors.left:port1CableCompensationText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: port1CableCompensationText.verticalCenter
        color:enabled ? enabledTextColor : disabledTextColor
        placeholderText:port1CableCompensationSlider.value
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
        id:port1CableCompensationUnitText
        text:"A"
        font.family: "helvetica"
        font.pointSize: smallFontSize
        color: "#D8D8D8"
        anchors.left:port1CableCompensationTextInput.right
        anchors.leftMargin: 5
        anchors.verticalCenter: port1CableCompensationText.verticalCenter

    }

    AdvancedSlider{
        id:port1CableCompensationSlider
        anchors.left:port1CableCompensationUnitText.right
        anchors.leftMargin: 5
        anchors.right:parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: port1CableCompensationText.verticalCenter
        height:10
        from: .25
        to:2
        value:.25
        stepSize: 0.0

        onValueChanged: {
            port1CableCompensationTextInput.text = Math.round (port1CableCompensationSlider.value *100)/100
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
        anchors.top: port1CableCompensationText.bottom
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
        id:port1AdvertizedVoltagesGroup
        color:"black"//"#33FFFFFF"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.top: maxCurrentText.bottom
        anchors.topMargin: 10
        height: 150
        Text{
            id:port1AdvertizedVoltagesLabel
            text:"Advertized Voltages:"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.right:parent.right
            anchors.rightMargin: parent.width*.6
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        TextField{
            id:port1voltage1TextInput
            anchors.left:port1AdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: port1AdvertizedVoltagesGroup.top
            anchors.topMargin: 0
            color:"white"//"#838484"
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: "#838484"//"#33FFFFFF"
                    border.color: "#838484"
                }
        }

        Text{
            id:port1voltage1UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.left:port1voltage1TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: port1voltage1TextInput.verticalCenter

        }
        AdvancedSlider{
            id:port1voltage1Slider
            anchors.left:port1voltage1UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: port1voltage1TextInput.verticalCenter
            height:10
            from: 5
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                port1voltage1TextInput.text = Math.round (port1voltage1Slider.value *10)/10
            }
        }



        TextField{
            id:port1voltage2TextInput
            anchors.left:port1AdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: port1voltage1TextInput.bottom
            anchors.topMargin: 5
            color:"white"//"#838484"
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: "#838484"//"#33FFFFFF"
                    border.color: "#838484"
                }
        }

        Text{
            id:port1voltage2UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.left:port1voltage2TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: port1voltage2TextInput.verticalCenter

        }

        AdvancedSlider{
            id:port1voltage2Slider
            anchors.left:port1voltage2UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: port1voltage2UnitText.verticalCenter
            height:10
            from: 5
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                port1voltage2TextInput.text = Math.round (port1voltage2Slider.value *10)/10
            }
        }



        TextField{
            id:port1voltage3TextInput
            anchors.left:port1AdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: port1voltage2TextInput.bottom
            anchors.topMargin: 5
            color:"white"//"#838484"
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: "#838484"//"#33FFFFFF"
                    border.color: "#838484"
                }
        }

        Text{
            id:port1voltage3UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.left:port1voltage3TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: port1voltage3TextInput.verticalCenter

        }

        AdvancedSlider{
            id:port1voltage3Slider
            anchors.left:port1voltage3UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: port1voltage3TextInput.verticalCenter
            height:10
            from: 5
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                port1voltage3TextInput.text = Math.round (port1voltage3Slider.value *10)/10
            }
        }



        TextField{
            id:port1voltage4TextInput
            anchors.left:port1AdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: port1voltage3TextInput.bottom
            anchors.topMargin: 5
            color:"white"//"#838484"
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: "#838484"//"#33FFFFFF"
                    border.color: "#838484"
                }
        }

        Text{
            id:port1voltage4UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.left:port1voltage4TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: port1voltage4TextInput.verticalCenter

        }

        AdvancedSlider{
            id:port1voltage4Slider
            anchors.left:port1voltage4UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: port1voltage4TextInput.verticalCenter
            height:10
            from: 5
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                port1voltage4TextInput.text = Math.round (port1voltage4Slider.value *10)/10
            }
        }



        TextField{
            id:port1voltage5TextInput
            anchors.left:port1AdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: port1voltage4TextInput.bottom
            anchors.topMargin: 5
            color:"white"//"#838484"
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: "#838484"//"#33FFFFFF"
                    border.color: "#838484"
                }
        }

        Text{
            id:port1voltage5UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.left:port1voltage5TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: port1voltage5TextInput.verticalCenter

        }

        AdvancedSlider{
            id:port1voltage5Slider
            anchors.left:port1voltage5UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: port1voltage5TextInput.verticalCenter
            height:10
            from: 5
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                port1voltage5TextInput.text = Math.round (port1voltage5Slider.value *10)/10
            }
        }



        TextField{
            id:port1voltage6TextInput
            anchors.left:port1AdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: port1voltage5TextInput.bottom
            anchors.topMargin: 5
            color:"white"//"#838484"
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: "#838484"//"#33FFFFFF"
                    border.color: "#838484"
                }
        }

        Text{
            id:port1voltage6UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.left:port1voltage6TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: port1voltage6TextInput.verticalCenter

        }

        AdvancedSlider{
            id:port1voltage6Slider
            anchors.left:port1voltage6UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: port1voltage6TextInput.verticalCenter
            height:10
            from: 5
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                port1voltage6TextInput.text = Math.round (port1voltage6Slider.value *10)/10
            }
        }



        TextField{
            id:port1voltage7TextInput
            anchors.left:port1AdvertizedVoltagesLabel.right
            anchors.leftMargin: 5
            anchors.top: port1voltage6TextInput.bottom
            anchors.topMargin: 5
            color:"white"//"#838484"
            placeholderText:"5"
            verticalAlignment: TextInput.AlignTop
            font.family: "helvetica"
            font.pointSize: smallFontSize
            height:15
            width:20
            background: Rectangle {
                    implicitWidth: 15
                    implicitHeight: 10
                    color: "#838484"//"#33FFFFFF"
                    border.color: "#838484"
                }
        }

        Text{
            id:port1voltage7UnitText
            text:"V"
            font.family: "helvetica"
            font.pointSize: smallFontSize
            color: "#D8D8D8"
            anchors.left:port1voltage7TextInput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: port1voltage7TextInput.verticalCenter

        }

        AdvancedSlider{
            id:port1voltage7Slider
            anchors.left:port1voltage7UnitText.right
            anchors.leftMargin: 5
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: port1voltage7TextInput.verticalCenter
            height:10
            from: 5
            to:20
            value:5
            stepSize: 0.0

            onValueChanged: {
                port1voltage7TextInput.text = Math.round (port1voltage7Slider.value *10)/10
            }
        }


    }
}
