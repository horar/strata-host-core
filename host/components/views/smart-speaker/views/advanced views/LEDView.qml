import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"
    property int labelWidth:200

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
        text:"LED and touch"
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

    Column{
        anchors.top: underlineRect.bottom
        anchors.topMargin: 10
        anchors.left:parent.left
        anchors.right:parent.right
        spacing:10

        Row{
            id:timeToFullRow
            spacing:10
            width:parent.width

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
                grooveFillColor: hightlightColor
            }
        }

        Row{
            spacing:10
            width:parent.width
            Text{
                id:bottomLightsLabel
                font.pixelSize: 18
                horizontalAlignment: Text.AlignRight
                text:"Bottom lights:"
                color: "black"
                width:labelWidth
            }
            SGSwitch{
                id:bottomLightsSwitch

                anchors.verticalCenter: bottomLightsLabel.verticalCenter
                height:25
                grooveFillColor: hightlightColor

                onToggled:{
                    var theString = "on"
                    if (!bottomLightsSwitch.checked)
                        theString = "off"
                    platformInterface.set_led_state("lower",theString, )
                }

            }
        }
        Row{
            spacing:10
            width:parent.width
            Text{
                id:bottomLightColorLabel
                font.pixelSize: 18
                text:"Bottom light color:"
                color: "black"
                width:labelWidth
                horizontalAlignment: Text.AlignRight
            }
            SGHueSlider{
                id:bottomLightColorlider

                anchors.verticalCenter: bottomLightColorLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                width:160

            }
        }

        Row{
            spacing:10
            width:parent.width
            Text{
                id:bottomLightBrightnessLabel
                font.pixelSize: 18
                horizontalAlignment: Text.AlignRight
                text:"Bottom light brightness:"
                color: "black"
                width:labelWidth
            }
            SGSlider{
                id:bottomLightBrightnessSlider

                anchors.verticalCenter: bottomLightBrightnessLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                width:160
                from:0
                to:100
                inputBox: true
                grooveColor: "grey"
                grooveFillColor: hightlightColor
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
        Row{
            spacing:10
            width:parent.width
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
                grooveFillColor: hightlightColor
            }
        }
    }


}
