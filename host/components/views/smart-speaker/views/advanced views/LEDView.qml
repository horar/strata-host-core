import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 1.0

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"
    property int labelWidth:135
    property int boxLabelWidth:90

    property bool topLightsOn
    property bool bottomLightOn
    property int theRedValue
    property int theGreenValue
    property int theBlueValue
    property int theBottomLightBrightness
    property bool touchButtonsOn: platformInterface.touch_button_state.state



    Text{
        id:ledLabel
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pixelSize: 24
        text:"LED and Touch"
    }
    Rectangle{
        id:underlineRect
        anchors.left:ledLabel.left
        anchors.top:ledLabel.bottom
        anchors.topMargin: -5
        anchors.right:parent.right
        anchors.rightMargin: 10
        height:1
        color:"grey"
    }



    Row{
        id:topLightRow
        spacing:10
        width:parent.width
        anchors.top: underlineRect.bottom
        anchors.topMargin: 10
        anchors.left:parent.left
        anchors.right:parent.right

        Text{
            id:topLightsLabel
            font.pixelSize: 18
            width:labelWidth
            horizontalAlignment: Text.AlignRight
            text:"Top light:"
            color: "black"
        }
        SGSwitch{
            id:topLightsSwitch

            anchors.verticalCenter: topLightsLabel.verticalCenter
            height:25
            width:45
            grooveFillColor: hightlightColor
            checked: platformInterface.led_state.upper_on

            onToggled: {
                platformInterface.set_led_state.update(platformInterface.led_state.lower_on,
                                                       checked,
                                                       platformInterface.led_state.H,
                                                       platformInterface.led_state.V)
            }
        }
    }


    SGSwitch{
        id:bottomLightsSwitch

        anchors.right:bottomLEDGroupBox.right
        anchors.rightMargin: 200
        anchors.bottom:bottomLEDGroupBox.top
        anchors.bottomMargin: -height
        height:25
        width:45
        grooveFillColor: hightlightColor
        checked: platformInterface.led_state.lower_on ? true : false
        z:10

        onToggled:{
            //this should set the V to 0, and either disable or enable the color and brightness sliders
            platformInterface.set_led_state.update(platformInterface.led_state.upper_on,
                                                   checked,
                                                   platformInterface.led_state.H,
                                                   platformInterface.led_state.V)
        }
    }

    GroupBox{
        id: bottomLEDGroupBox
        title:"Bottom lights:"
        anchors.top:topLightRow.bottom
        anchors.topMargin: 10
        anchors.left:parent.left
        anchors.leftMargin: 10
        anchors.right:parent.right
        anchors.rightMargin: 10
        height:125

        label: Label {
            x: bottomLEDGroupBox.leftPadding
            width: bottomLEDGroupBox.availableWidth
            text: bottomLEDGroupBox.title
            color: "black"
            font.pixelSize:18
            elide: Text.ElideRight
        }



        Row{
            id:colorRow
            anchors.top:parent.top
            anchors.topMargin: 10
            anchors.left:parent.left
            anchors.leftMargin: 10
            anchors.right:parent.right
            anchors.rightMargin: 10
            spacing:5
            width:parent.width
            Text{
                id:bottomLightColorLabel
                font.pixelSize: 18
                text:"Color:"
                color: bottomLightsSwitch.checked ? "black": "grey"
                width:boxLabelWidth
                horizontalAlignment: Text.AlignRight
            }
            SGHueSlider{
                id:bottomLightColorlider

                anchors.verticalCenter: bottomLightColorLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                width:220
                enabled: bottomLightsSwitch.checked

                //still need to write code to set the hsl slider based on rgb changes in the platform
                value:Math.round((platformInterface.led_state.H / 359) * 255)

                onMoved: {
                    platformInterface.set_led_state.update(platformInterface.led_state.upper_on,
                                                           platformInterface.led_state.lower_on,
                                                           (value/255)*359,
                                                           platformInterface.led_state.V);
                }

            }
        }

        Row{
            id:brightnessRow
            anchors.left:colorRow.left
            anchors.top:colorRow.bottom
            anchors.topMargin: 10
            spacing:5
            width:parent.width
            Text{
                id:bottomLightBrightnessLabel
                font.pixelSize: 18
                horizontalAlignment: Text.AlignRight
                text:"Brightness:"
                color: bottomLightsSwitch.checked ? "black": "grey"
                width:boxLabelWidth
            }
            SGSlider{
                id:bottomLightBrightnessSlider

                anchors.verticalCenter: bottomLightBrightnessLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                width:220
                from:0
                to:100
                stepSize: 1
                showInputBox: true
                handleSize: 20
                grooveColor: "grey"
                fillColor: hightlightColor
                enabled:  bottomLightsSwitch.checked
                value: platformInterface.led_state.V
                onUserSet: {
                    platformInterface.set_led_state.update(platformInterface.led_state.upper_on,
                                                           platformInterface.led_state.lower_on
                                                           ,platformInterface.led_state.H,
                                                           value);
                }
            }
            Text{
                id:bottomLightBrightnessUnitLabel
                font.pixelSize: 15

                anchors.verticalCenter: bottomLightBrightnessLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                text:"%"
                color: "grey"
            }
        }

    }

    Row{
        id:spacerRow
        height:25
    }

    Row{
        anchors.top: bottomLEDGroupBox.bottom
        anchors.topMargin: 50
        anchors.left:parent.left
        anchors.right:parent.right
        spacing:10
        //width:parent.width
        Text{
            id:touchButtonsLabel
            font.pixelSize: 18
            horizontalAlignment: Text.AlignRight
            text:"Touch buttons:"
            color: "black"
            width:labelWidth
        }
        SGSwitch{
            id:touchButtonsSwitch

            anchors.verticalCenter: touchButtonsLabel.verticalCenter
            height:25
            width:45
            grooveFillColor: hightlightColor
            checked:platformInterface.touch_button_state.state

            onToggled: {
                platformInterface.set_touch_button_state.update(checked)
            }

        }
    }



}
