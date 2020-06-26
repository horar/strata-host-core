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
    property int labelWidth:200

    property bool topLightsOn
    property bool bottomLightOn
    property int theRedValue
    property int theGreenValue
    property int theBlueValue
    property int theBottomLightBrightness
    property bool touchButtonsOn: platformInterface.touch_button_state.state

    function rgbToHsl(r, g, b) {
      r /= 255
      g /= 255
      b /= 255
      var max = Math.max(r, g, b), min = Math.min(r, g, b)
      var h, s, l = (max + min) / 2
      if (max == min) {
        h = s = 0
      } else {
        var d = max - min
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
        switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0)
          break
        case g:
          h = (b - r) / d + 2
          break
        case b:
          h = (r - g) / d + 4
          break
        }
        h /= 6;
      }
      return {"h":h, "s":s, "l":l};
    }

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

    Column{
        anchors.top: underlineRect.bottom
        anchors.topMargin: 10
        anchors.left:parent.left
        anchors.right:parent.right
        spacing:10

        Row{
            id:topLightRow
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
                checked: platformInterface.led_state.upper_on

                onToggled: {
                    platformInterface.set_led_state.update("upper",checked,platformInterface.led_state.r,
                                                                           platformInterface.led_state.g,
                                                                           platformInterface.led_state.b)
                }
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
                checked: platformInterface.led_state.lower_on

                onToggled:{
                    platformInterface.set_led_state.update("lower",checked,platformInterface.led_state.r,
                                                                           platformInterface.led_state.g,
                                                                           platformInterface.led_state.b)
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

                //still need to write code to set the hsl slider based on rgb changes in the platform
                value:{
                    var r = platformInterface.led_state.r
                    var g = platformInterface.led_state.g
                    var b = platformInterface.led_state.b

                    //console.log("r,g,b=",r,g,b);
                    var hsl = rgbToHsl(r, g, b)
                    //console.log("h,s,v=",hsl.h,hsl.s,hsl.l)

                    //The returned value is between 0 and 1, so scale to match the slider's range
                    return hsl.h * 255;
                }

                onMoved: {
                    platformInterface.set_led_state.update("lower",platformInterface.led_state.lower_on,
                                                           bottomLightColorlider.rgbArray[0],
                                                           bottomLightColorlider.rgbArray[1],
                                                           bottomLightColorlider.rgbArray[2],)
                }

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
                showInputBox: true
                grooveColor: "grey"
                fillColor: hightlightColor
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
                checked:platformInterface.touch_button_state.state

                onToggled: {
                    platformInterface.set_touch_button_state.update(checked)
                }

            }
        }
    }


}
