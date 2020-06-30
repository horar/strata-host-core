import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"
    property color buttonSelectedColor:"#91ABE1"
    property int telemetryTextWidth:250
    property int currentLimitTextWidth:100
    property int currentLimitSliderWidth:300


    Text{
        id:chargerLabel
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pixelSize: 24
        text:"Charger"
    }
    Rectangle{
        id:underlineRect
        anchors.left:chargerLabel.left
        anchors.top:chargerLabel.bottom
        anchors.topMargin: -5
        anchors.right:parent.right
        anchors.rightMargin: 10
        height:1
        color:"grey"
    }

    Column{
        id:telemetryColumn
        anchors.top: underlineRect.bottom
        anchors.topMargin: 20
        anchors.left:parent.left
        anchors.right:parent.right
        spacing: 10
        Row{
            spacing:10
            width:parent.width

            Text{
                id:ocpLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"VBUS over voltage protection:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSegmentedButtonStrip {
                id: ocpSegmentedButton
                labelLeft: false
                anchors.verticalCenter: ocpLabel.verticalCenter
                textColor: "#444"
                activeTextColor: "white"
                radius: buttonHeight/2
                buttonHeight: 20
                exclusive: true
                buttonImplicitWidth: 40
                hoverEnabled:false

                segmentedButtons: GridLayout {
                    columnSpacing: 2
                    rowSpacing: 2

                    property var overVoltage: platformInterface.vbus_ovp_level
                    onOverVoltageChanged: {
                        switch(platformInterface.vbus_ovp_level.value){
                            case 6.5:   overVoltageButton1.checked = true;  break;
                            case 10.5:  overVoltageButton2.checked = true;  break;
                            case 13.7:  overVoltageButton3.checked = true;  break;
                            }
                        }

                    SGSegmentedButton{
                        id:overVoltageButton1
                        text: qsTr("6.5V")
                        activeColor: buttonSelectedColor
                        inactiveColor: "white"
                        checked: true
                        //height:40
                        onClicked: {
                            platformInterface.set_vbus_ovp_level.update(6.5);
                        }
                    }

                    SGSegmentedButton{
                        id:overVoltageButton2
                        text: qsTr("10.5V")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {
                            platformInterface.set_vbus_ovp_level.update(10.5);
                        }
                    }
                    SGSegmentedButton{
                        id:overVoltageButton3
                        text: qsTr("13.7V")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {
                            platformInterface.set_vbus_ovp_level.update(13.7);
                        }
                    }

                }
            }

        }

        Row{
            spacing:10

            Text{
                id:temperatureThresholdLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Temperature threshold:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSegmentedButtonStrip {
                id: tempThresholdSegmentedButton
                labelLeft: false
                anchors.verticalCenter: temperatureThresholdLabel.verticalCenter
                textColor: "#444"
                activeTextColor: "white"
                radius: buttonHeight/2
                buttonHeight: 20
                exclusive: true
                buttonImplicitWidth: 40
                hoverEnabled:false

                segmentedButtons: GridLayout {
                    columnSpacing: 2
                    rowSpacing: 2

                    property var protection: platformInterface.thermal_protection_temp
                    onProtectionChanged: {
                        switch(platformInterface.thermal_protection_temp.value){
                            case 70:
                                thermalProtectionButton1.checked = true;
                                break;
                            case 85:
                                thermalProtectionButton2.checked = true;
                                break;
                            case 100:
                                thermalProtectionButton3.checked = true;
                                break;
                            case 120:
                                thermalProtectionButton4.checked = true;
                                break;
                        }
                    }

                    SGSegmentedButton{
                        id:thermalProtectionButton1
                        text: qsTr("70°C")
                        activeColor: buttonSelectedColor
                        inactiveColor: "white"
                        checked: true
                        //height:40
                        onClicked: {
                            platformInterface.set_thermal_protection_temp.update(70)
                        }
                    }

                    SGSegmentedButton{
                        id:thermalProtectionButton2
                        text: qsTr("85°C")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {
                            platformInterface.set_thermal_protection_temp.update(85)
                        }
                    }
                    SGSegmentedButton{
                        id:thermalProtectionButton3
                        text: qsTr("100°C")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {
                            platformInterface.set_thermal_protection_temp.update(100)
                        }
                    }
                    SGSegmentedButton{
                        id:thermalProtectionButton4
                        text: qsTr("120°C")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {
                            platformInterface.set_thermal_protection_temp.update(120)
                        }
                    }

                }
            }


        }
        Row{
            spacing:10

            Text{
                id:floatVoltageLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Float voltage:"
                horizontalAlignment: Text.AlignRight
                color: "black"
            }

            Text{
                id:floatVoltageText
                anchors.verticalCenter: floatVoltageLabel.verticalCenter
                font.pixelSize: 15
                text: platformInterface.charger_status.float_voltage.toFixed(1)
                color: "black"
            }

            Text{
                id:floatVoltageUnit
                anchors.verticalCenter: floatVoltageLabel.verticalCenter
                font.pixelSize: 15
                text: "V"
                color: "grey"
            }
        }

        GroupBox{
            id: currentLimitGroupBox
            title:"Current limits"
            anchors.left:parent.left
            anchors.leftMargin: 10
            anchors.right:parent.right
            anchors.rightMargin: 10

            label: Label {
                    x: currentLimitGroupBox.leftPadding
                    width: currentLimitGroupBox.availableWidth
                    text: currentLimitGroupBox.title
                    color: "black"
                    font.pixelSize:18
                    elide: Text.ElideRight
                }


            Column{
                id:currentLimitColumn
                spacing: 10

                Row{
                    spacing:10

                    Text{
                        id:ibusCurrentLabel
                        font.pixelSize: 18
                        width:currentLimitTextWidth
                        text:"IBUS:"
                        horizontalAlignment: Text.Text.AlignRight
                        color: "black"
                    }
                    SGSlider{
                        id:ibusCurrentLimitSlider
                        anchors.verticalCenter: ibusCurrentLabel.verticalCenter
                        anchors.verticalCenterOffset: 5
                        height:25
                        width:currentLimitSliderWidth
                        from:100
                        to:3000
                        stepSize: 25
                        inputBox: true
                        grooveColor: "grey"
                        grooveFillColor: hightlightColor
                        value: platformInterface.charger_status.ibus_limit.toFixed(0)
                        onUserSet: {
                            platformInterface.set_charger_current.update("set_vbus_current_limit", value);
                        }
                    }
                    Text{
                        id:busCurrentLimitUnit
                        anchors.verticalCenter: ibusCurrentLabel.verticalCenter
                        anchors.verticalCenterOffset: 10
                        font.pixelSize: 15
                        text:"mA"
                        color: "grey"
                    }

                }
                Row{
                    spacing:10

                    Text{
                        id:fastChargeLabel
                        font.pixelSize: 18
                        width:currentLimitTextWidth
                        text:"Fast charge:"
                        horizontalAlignment: Text.Text.AlignRight
                        color: "black"
                    }
                    SGSlider{
                        id:fastChargeSlider
                        anchors.verticalCenter: fastChargeLabel.verticalCenter
                        anchors.verticalCenterOffset: 5
                        height:25
                        width:currentLimitSliderWidth
                        from:200
                        stepSize: 50
                        to:3000
                        inputBox: true
                        grooveColor: "grey"
                        grooveFillColor: hightlightColor
                        value:platformInterface.charger_status.fast_chg_current.toFixed(0)
                        onUserSet: {
                            platformInterface.set_charger_current.update("set_fast_current_limit", value);
                        }
                    }
                    Text{
                        id:fastChargeUnit
                        anchors.verticalCenter: fastChargeLabel.verticalCenter
                        anchors.verticalCenterOffset: 10
                        font.pixelSize: 15
                        text:"mA"
                        color: "grey"
                    }

                }
                Row{
                    spacing:10

                    Text{
                        id:prechargeCurrentLabel
                        font.pixelSize: 18
                        width:currentLimitTextWidth
                        text:"Precharge:"
                        horizontalAlignment: Text.Text.AlignRight
                        color: "black"
                    }
                    SGSlider{
                        id:preChargeCurrentSlider
                        anchors.verticalCenter: prechargeCurrentLabel.verticalCenter
                        anchors.verticalCenterOffset: 5
                        height:25
                        width:currentLimitSliderWidth
                        from:200
                        to:800
                        stepSize: 50
                        inputBox: true
                        grooveColor: "grey"
                        grooveFillColor: hightlightColor
                        value: platformInterface.charger_status.precharge_current.toFixed(0)
                        onUserSet: {
                            platformInterface.set_charger_current.update("set_precharge_current_limit", value);
                        }
                    }

                    Text{
                        id:prechargeCurrentLimitUnit
                        anchors.verticalCenter: prechargeCurrentLabel.verticalCenter
                        anchors.verticalCenterOffset: 10
                        font.pixelSize: 15
                        text:"mA"
                        color: "grey"
                    }
                }
                Row{
                    spacing:10

                    Text{
                        id:terminationCurrentLabel
                        font.pixelSize: 18
                        width:currentLimitTextWidth
                        text:"Termination:"
                        horizontalAlignment: Text.Text.AlignRight
                        color: "black"
                    }
                    SGSlider{
                        id:terminationCurrentLimitSlider
                        anchors.verticalCenter: terminationCurrentLabel.verticalCenter
                        anchors.verticalCenterOffset: 5
                        height:25
                        width:currentLimitSliderWidth
                        from:100
                        to:600
                        stepSize: 50
                        inputBox: true
                        grooveColor: "grey"
                        grooveFillColor: hightlightColor
                        value: platformInterface.charger_status.termination_current.toFixed(0)
                        onUserSet: {
                            platformInterface.set_charger_current.update("set_termination_current_limit", value);
                        }
                    }

                    Text{
                        id:terminationCurrentLimitUnit
                        anchors.verticalCenter: terminationCurrentLabel.verticalCenter
                        anchors.verticalCenterOffset: 10
                        font.pixelSize: 15
                        text:"mA"
                        color: "grey"
                    }
                }
            }
        }



    }
}
