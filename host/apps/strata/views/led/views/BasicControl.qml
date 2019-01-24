import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.4
import "qrc:/views/led/sgwidgets"
import "qrc:/views/led/views/basic-partial-views"

Rectangle {
    id: root
    anchors.fill:parent
    color:"dimgrey"

    property string textColor: "white"
    property string secondaryTextColor: "grey"
    property string windowsDarkBlue: "#2d89ef"
    property string backgroundColor: "#FF2A2E31"
    property string transparentBackgroundColor: "#002A2E31"
    property string dividerColor: "#3E4042"
    property string switchGrooveColor:"dimgrey"
    property int leftSwitchMargin: 40
    property int rightInset: 50
    property int leftScrimOffset: 310

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

    //----------------------------------------------------------------------------------------
    //                      Views
    //----------------------------------------------------------------------------------------


    Rectangle{
        id:deviceBackground
        color:backgroundColor
        radius:10
        height:(7*parent.height)/16
        anchors.left:root.left
        anchors.leftMargin: 12
        anchors.right: root.right
        anchors.rightMargin: 12
        anchors.top:root.top
        anchors.topMargin: 12
        anchors.bottom:root.bottom
        anchors.bottomMargin: 12

        Rectangle{
            id:pwmContainer
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:parent.top
            height: parent.height/4
            color:"transparent"

            Image{
                id:pwmIcon
                height:50
                width:50
                mipmap:true
                anchors.top:parent.top
                anchors.topMargin: 15
                anchors.left:parent.left
                anchors.leftMargin: 10
                source:"./images/icon-pulse.svg"
            }

            Text{
                id:pwmTitle
                text: "Pulse"
                font.pointSize: 48
                color: textColor
                anchors.top:parent.top
                anchors.topMargin:10
                anchors.left:pwmIcon.right
                anchors.leftMargin: 20
            }

            Text{
                id:pwmSubtitle
                text: "2 Channel PWM RGB Control"
                font.pointSize: 15
                color: secondaryTextColor
                anchors.top:pwmTitle.bottom
                anchors.topMargin:0
                anchors.left:pwmTitle.left
            }

            SGSwitch{
                id:pwmSwitch
                anchors.left:parent.left
                anchors.leftMargin: leftSwitchMargin
                anchors.verticalCenter: parent.verticalCenter
                grooveFillColor:windowsDarkBlue
                grooveColor:"black"
                checked:{
                    console.log("pulse switch enabled changed to",platformInterface.set_pulse_colors_notification.enabled)
                    platformInterface.set_pulse_colors_notification.enabled
                }

                onToggled:{
                    console.log("pulse switch value changed")
                    platformInterface.set_pulse_colors.update(pwmSwitch.checked,
                                                              platformInterface.set_pulse_colors_notification.channel1_color,
                                                              platformInterface.set_pulse_colors_notification.channel2_color);
                }
            }

            RoundButton{
                id:pulseScrim
                anchors.left: parent.left
                anchors.leftMargin:leftScrimOffset
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                anchors.right:parent.right
                visible:!pwmSwitch.checked
                opacity:1
                z:5

                onVisibleChanged:{
                    if (visible){
                        pulseScrimToOpaque.start()
                    }
                    else{
                        pulseScrimToTransparent.start()
                    }
                }

                OpacityAnimator{
                    id:pulseScrimToOpaque
                    target:pulseScrim
                    from: 0
                    to: 1
                    duration:1000
                    running:false
                }

                OpacityAnimator{
                    id:pulseScrimToTransparent
                    target:pulseScrim
                    from: 1
                    to: 0
                    duration:1000
                    running:false
                }

                background:Rectangle{
                    color:"transparent"
                    radius:5
                }

                LinearGradient {
                       anchors.fill: parent
                       start: Qt.point(0, 0)
                       end: Qt.point(parent.width, 0)
                       gradient: Gradient {
                           GradientStop { position: 0.0; color: "#00000000"}
                           GradientStop { position: .15; color: "#66000000" }
                           GradientStop { position: .5; color: "#BB000000" }

                       }
                   }
            }

            Text{
                id:channel1Title
                text: "1"
                font.pointSize: 265
                color: secondaryTextColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:pwmSwitch.right
                anchors.leftMargin: 220
                opacity:.2
            }

            Rectangle {
                id: ledControlContainer
                width: 200
                height: childrenRect.height + 10
                color: "transparent"
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 0
                    left:channel1Title.right
                    leftMargin: 0
                }

                SGHueSlider {

                    id: hueSlider
                    label: ""
                    labelLeft: true
                    value: {
                        var theColorString = platformInterface.set_pulse_colors_notification.channel1_color;

                        //convert the rgb color to a hsv color
                        var r = parseInt(theColorString.substr(0, 2), 16)
                        var g = parseInt(theColorString.substr(2, 2), 16)
                        var b = parseInt(theColorString.substr(4, 2), 16)
                        //console.log("r,g,b=",r,g,b);
                        var hsl = rgbToHsl(r, g, b)
                        //console.log("h,s,v=",hsl.h,hsl.s,hsl.l)

                        //The returned value is between 0 and 1, so scale to match the slider's range
                        return hsl.h * 255;
                    }
                    sliderHeight:50
                    anchors {
                        left: ledControlContainer.left
                        leftMargin: 10
                        right: ledControlContainer.right
                        rightMargin: 10
                        top: ledControlContainer.top
                        topMargin: 10
                    }

                    onValueChanged: {
                        var colorString = hueSlider.hexvalue.substring(1,7); //remove the # from the start of the string

                        platformInterface.set_pulse_colors.update(platformInterface.set_pulse_colors_notification.enabled,
                                                                  colorString,
                                                                  platformInterface.set_pulse_colors_notification.channel2_color);
                    }

                }



                RoundButton {
                    id: whiteButton
                    checkable: false
                    text: "Set to white"

                    height:25
                    width:80
                    radius:5
                    anchors.left:hueSlider.left
                    anchors.top: hueSlider.bottom
                    anchors.topMargin: 10

                    contentItem: Text {
                            text: whiteButton.text
                            font.pixelSize: 12
                            font.underline: true
                            color: whiteButton.pressed ? "grey" : "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                    background: Rectangle {
                            id: backgroundRect
                            implicitWidth: 80
                            implicitHeight: 25
                            radius: whiteButton.radius
                            anchors.fill: parent
                            color: "transparent"
                    }

                    onClicked: {

                        platformInterface.set_pulse_colors.update(platformInterface.set_pulse_colors_notification.enabled,
                                                                  "FFFFFF",
                                                                  platformInterface.set_pulse_colors_notification.channel2_color);
                    }
                }

                SGSubmitInfoBox{
                    id:pwmColorBox1
                    anchors.left:whiteButton.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: whiteButton.verticalCenter
                    infoBoxWidth:80
                    height:20
                    textColor:"white"
                    value: platformInterface.set_pulse_colors_notification.channel1_color

                    onApplied:{
                        platformInterface.set_pulse_colors.update(platformInterface.set_pulse_colors_notification.enabled,
                                                                  pwmColorBox1.value,
                                                                  platformInterface.set_pulse_colors_notification.channel2_color);
                    }
                }


            }



            Column{
                id:leftPWMlights
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: ledControlContainer.right
                anchors.leftMargin: 25
                width:50
                spacing:10

                LEDIndicator{
                    id: pwmLED1
                    ledColor: {
                        var theColor = platformInterface.set_pulse_colors_notification.channel1_color
                        theColor = "#"+theColor
                        return theColor
                    }

                    height: 40
                }
                LEDIndicator{
                    id: pwmLED2
                    ledColor: {
                        var theColor = platformInterface.set_pulse_colors_notification.channel1_color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
                LEDIndicator{
                    id: pwmLED3
                    ledColor: {
                        var theColor = platformInterface.set_pulse_colors_notification.channel1_color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
            }

            Column{
                id:rightPWMlights
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: leftPWMlights.right
                anchors.leftMargin: 10
                width:50
                spacing:10

                LEDIndicator{
                    id: pwmLED4
                    ledColor: {
                        var theColor = platformInterface.set_pulse_colors_notification.channel2_color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
                LEDIndicator{
                    id: pwmLED5
                    ledColor: {
                        var theColor = platformInterface.set_pulse_colors_notification.channel2_color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
                LEDIndicator{
                    id: pwmLED6
                    ledColor: {
                        var theColor = platformInterface.set_pulse_colors_notification.channel2_color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
            }



            Rectangle {
                id: ledControlContainer2
                width: 200
                height: childrenRect.height + 10
                color: "transparent"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right:channel2Title.left
                    rightMargin: 0
                }

                SGHueSlider {
                    property color theColor: "white"

                    id: hueSlider2
                    label: ""
                    labelLeft: true
                    value: {
                        var theColorString = platformInterface.set_pulse_colors_notification.channel2_color;

                        //convert the rgb color to a hsv color
                        var r = parseInt(theColorString.substr(0, 2), 16)
                        var g = parseInt(theColorString.substr(2, 2), 16)
                        var b = parseInt(theColorString.substr(4, 2), 16)
                        var hsl = rgbToHsl(r, g, b)

                        //The returned value is between 0 and 1, so scale to match the slider's range
                        return hsl.h * 255;
                    }
                    sliderHeight:50
                    anchors {
                        left: ledControlContainer2.left
                        leftMargin: 10
                        right: ledControlContainer2.right
                        rightMargin: 10
                        top: ledControlContainer2.top
                        topMargin: 10
                    }

                    onValueChanged: {
                         var colorString = hueSlider2.hexvalue.substring(1,7); //remove the # from the start of the string

                        platformInterface.set_pulse_colors.update(platformInterface.set_pulse_colors_notification.enabled,
                                                                  platformInterface.set_pulse_colors_notification.channel1_color,
                                                                  colorString);
                    }
                }

                RoundButton {
                    id: whiteButton2
                    checkable: false
                    text: "Set to white"

                    height:25
                    width:80
                    radius:5
                    anchors.left:hueSlider2.left
                    anchors.top: hueSlider2.bottom
                    anchors.topMargin: 10

                    contentItem: Text {
                            text: whiteButton2.text
                            font.pixelSize: 12
                            font.underline: true
                            color: whiteButton2.pressed ? "grey" : "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                    background: Rectangle {
                            id: backgroundRect2
                            implicitWidth: 80
                            implicitHeight: 25
                            radius: whiteButton2.radius
                            anchors.fill: parent
                            color: "transparent"
                    }

                    onClicked: {

                        platformInterface.set_pulse_colors.update(platformInterface.set_pulse_colors_notification.enabled,
                                                                  platformInterface.set_pulse_colors_notification.channel1_color,
                                                                  "FFFFFF");
                    }


                }

                SGSubmitInfoBox{
                    id:pwmColorBox2
                    anchors.left:whiteButton2.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: whiteButton2.verticalCenter
                    infoBoxWidth:80
                    height:20
                    textColor:"white"
                    value:platformInterface.set_pulse_colors_notification.channel2_color

                    onApplied:{
                        platformInterface.set_pulse_colors.update(platformInterface.set_pulse_colors_notification.enabled,
                                                                  platformInterface.set_pulse_colors_notification.channel1_color,
                                                                  pwmColorBox2.value);
                    }
                }


            }

            Text{
                id:channel2Title
                text: "2"
                font.pointSize: 265
                color: secondaryTextColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.right:parent.right
                anchors.rightMargin: rightInset
                opacity:.2
            }

            Rectangle {
                id:divider1
                color: dividerColor
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                height:1
            }

        }

//----------------------------------------------------------------------------------------
//                      Linear
//----------------------------------------------------------------------------------------
        Rectangle{
            id:linearContainer
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:pwmContainer.bottom
            height: parent.height/4
            color:"transparent"

            Image{
                id:linearIcon
                height:50
                width:50
                mipmap:true
                anchors.top:parent.top
                anchors.topMargin: 15
                anchors.left:parent.left
                anchors.leftMargin: 10
                source:"./images/icon-linear.svg"
            }

            Text{
                id:linearTitle
                text: "Linear"
                font.pointSize: 48
                color: textColor
                anchors.top:parent.top
                anchors.topMargin:10
                anchors.left:linearIcon.right
                anchors.leftMargin: 20
            }

            Text{
                id:linearSubtitle
                text: "1 Channel Linear RGB Control"
                font.pointSize: 15
                color: secondaryTextColor
                anchors.top:linearTitle.bottom
                anchors.topMargin:0
                anchors.left:linearTitle.left
            }


            SGSwitch{
                id:linearSwitch
                anchors.left:parent.left
                anchors.leftMargin: leftSwitchMargin
                anchors.verticalCenter: parent.verticalCenter
                grooveFillColor:windowsDarkBlue
                grooveColor:switchGrooveColor
                checked:platformInterface.set_linear_color_notification.enabled

                onToggled:{
                    platformInterface.set_linear_color.update(linearSwitch.checked,
                                                              platformInterface.set_linear_color_notification.color);
                }
            }


            RoundButton{
                id:linearScrim
                anchors.left: parent.left
                anchors.leftMargin:leftScrimOffset
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                anchors.right:parent.right
                visible:!linearSwitch.checked
                z:5
                opacity:1

                onVisibleChanged:{
                    if (visible){
                        linearScrimToOpaque.start()
                    }
                    else{
                        linearScrimToTransparent.start()
                    }
                }

                OpacityAnimator{
                    id:linearScrimToOpaque
                    target:linearScrim
                    from: 0
                    to: 1
                    duration:1000
                    running:false
                }

                OpacityAnimator{
                    id:linearScrimToTransparent
                    target:linearScrim
                    from: 1
                    to: 0
                    duration:1000
                    running:false
                }

                background:Rectangle{
                    color:"transparent"
                    radius:5
                }

                LinearGradient {
                       anchors.fill: parent
                       start: Qt.point(0, 0)
                       end: Qt.point(parent.width, 0)
                       gradient: Gradient {
                           GradientStop { position: 0.0; color: "#00000000"}
                           GradientStop { position: .15; color: "#66000000" }
                           GradientStop { position: .5; color: "#BB000000" }
                       }
                   }
            }

            Rectangle {
                id: linearControlContainer
                width: 200
                height: childrenRect.height + 10
                color: "transparent"
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 0
                    right:linearPWMlights.left
                    rightMargin: 100
                }

                SGHueSlider {
                    property color theColor:"white"

                    id: linearHueSlider
                    label: ""
                    labelLeft: true
                    value: {
                        var theColorString = platformInterface.set_linear_color_notification.color;

                        //convert the rgb color to a hsv color
                        var r = parseInt(theColorString.substr(0, 2), 16)
                        var g = parseInt(theColorString.substr(2, 2), 16)
                        var b = parseInt(theColorString.substr(4, 2), 16)
                        //console.log("linear color=",theColorString,"rgb=",r,g,b)
                        var hsl = rgbToHsl(r, g, b)

                        //The returned value is between 0 and 1, so scale to match the slider's range
                        return hsl.h * 255;
                    }
                    sliderHeight:50
                    anchors {
                        //verticalCenter: whiteButton.verticalCenter
                        left: linearControlContainer.left
                        leftMargin: 10
                        right: linearControlContainer.right
                        rightMargin: 10
                        top: linearControlContainer.top
                        topMargin: 10
                    }

                    onValueChanged: {
                        var colorString = linearHueSlider.hexvalue.substring(1,7); //remove the # from the start of the string

                        platformInterface.set_linear_color.update(platformInterface.set_linear_color_notification.enabled,
                                                                  colorString);
                    }

                    Component.onCompleted: {

                    }
                }

                RoundButton {
                    id: linearWhiteButton
                    checkable: false
                    text: "Set to white"

                    height:25
                    width:80
                    radius:5
                    anchors.left: linearHueSlider.left
                    anchors.top: linearHueSlider.bottom
                    anchors.topMargin: 10

                    contentItem: Text {
                            text: linearWhiteButton.text
                            font.pixelSize: 12
                            font.underline: true
                            color: linearWhiteButton.pressed ? "grey" : "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                    background: Rectangle {
                            id: linearWhiteButtonBackground
                            implicitWidth: 80
                            implicitHeight: 25
                            radius: linearWhiteButton.radius
                            anchors.fill: parent
                            color: "transparent"
                    }

                    onClicked: {
                        platformInterface.set_linear_color.update(platformInterface.set_linear_color_notification.enabled,
                                                                  "FFFFFF");
                    }
                }

                SGSubmitInfoBox{
                    id:linearColorBox
                    anchors.left:linearWhiteButton.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: linearWhiteButton.verticalCenter
                    infoBoxWidth:80
                    height:20
                    textColor:"white"
                    value:platformInterface.set_linear_color_notification.color

                    onApplied:{
                        platformInterface.set_linear_color.update(platformInterface.set_linear_color_notification.enabled,
                                                                  inearColorBox.value);
                    }
                }


            }



            Column{
                id:linearPWMlights
                anchors.top:parent.top
                anchors.topMargin: parent.height/8
                anchors.right: parent.right
                anchors.rightMargin: rightInset
                width:50
                spacing:10

                LEDIndicator{
                    id: linearLED1
                    ledColor: {
                        var theColor = platformInterface.set_linear_color_notification.color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
                LEDIndicator{
                    id: linearLED2
                    ledColor: {
                        var theColor = platformInterface.set_linear_color_notification.color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
                LEDIndicator{
                    id: linearLED3
                    ledColor: {
                        var theColor = platformInterface.set_linear_color_notification.color
                        theColor = "#"+theColor
                        return theColor
                    }
                    height: 40
                }
            }

            Rectangle {
                id:divider2
                color: dividerColor
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                height:1
            }
        }

//----------------------------------------------------------------------------------------
//                      Buck
//----------------------------------------------------------------------------------------
        Rectangle{
            id:buckContainer
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:linearContainer.bottom
            height: parent.height/4
            color:"transparent"

            Image{
                id:buckIcon
                height:50
                width:50
                mipmap:true
                anchors.top:parent.top
                anchors.topMargin: 15
                anchors.left:parent.left
                anchors.leftMargin: 10
                source:"./images/icon-buck.svg"
            }

            Text{
                id:buckTitle
                text: "Buck"
                font.pointSize: 48
                color: textColor
                anchors.top:parent.top
                anchors.topMargin:10
                anchors.left:buckIcon.right
                anchors.leftMargin: 20
            }

            Text{
                id:buckSubtitle
                text: "High Current AECQ Buck"
                font.pointSize: 15
                color: secondaryTextColor
                anchors.top:buckTitle.bottom
                anchors.left:buckTitle.left
            }

            SGSwitch{
                id:buckSwitch
                anchors.left:parent.left
                anchors.leftMargin: leftSwitchMargin
                anchors.verticalCenter: parent.verticalCenter
                grooveFillColor:windowsDarkBlue
                grooveColor:switchGrooveColor
                checked:platformInterface.set_buck_intensity_notification.enabled

                onToggled:{
                    platformInterface.set_buck_intensity.update(buckSwitch.checked,
                                                              platformInterface.set_buck_intensity_notification.intensity);
                }
            }

            RoundButton{
                id:buckScrim
                anchors.left: parent.left
                anchors.leftMargin:leftScrimOffset
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                anchors.right:parent.right
                visible:!buckSwitch.checked
                opacity:1
                z:5

                onVisibleChanged:{
                    if (visible){
                        buckScrimToOpaque.start()
                    }
                    else{
                        buckScrimToTransparent.start()
                    }
                }

                OpacityAnimator{
                    id:buckScrimToOpaque
                    target:buckScrim
                    from: 0
                    to: 1
                    duration:1000
                    running:false
                }

                OpacityAnimator{
                    id:buckScrimToTransparent
                    target:buckScrim
                    from: 1
                    to: 0
                    duration:1000
                    running:false
                }

                background:Rectangle{
                    color:"transparent"
                    radius:5
                }

                LinearGradient {
                       anchors.fill: parent
                       start: Qt.point(0, 0)
                       end: Qt.point(parent.width, 0)
                       gradient: Gradient {
                           GradientStop { position: 0.0; color: "#00000000"}
                           GradientStop { position: .15; color: "#66000000" }
                           GradientStop { position: .5; color: "#BB000000" }
                       }
                   }
            }

            PortInfo{
                id:buckTelemetry
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: buckSwitch.right
                anchors.leftMargin: 240
                width:275
                boxHeight:60

                property int theRunningTotal: 0
                property int theEfficiencyCount: 0
                property int theEfficiencyAverage: 0
                property var periodicValues: platformInterface.led_buck_power_notification

                onPeriodicValuesChanged: {
                    var theInputPower = platformInterface.led_buck_power_notification.input_voltage * platformInterface.led_buck_power_notification.input_current +2;//PTJ-1321 2 Watt compensation
                    var theOutputPower = platformInterface.led_buck_power_notification.output_voltage * platformInterface.led_buck_power_notification.output_current;

                    //sum eight values of the efficiency and average before displaying
                    var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                    buckTelemetry.theRunningTotal += theEfficiency;
                    //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                    buckTelemetry.theEfficiencyCount++;

                    if (buckTelemetry.theEfficiencyCount === 8){
                        buckTelemetry.theEfficiencyAverage = buckTelemetry.theRunningTotal/8;
                        buckTelemetry.theEfficiencyCount = 0;
                        buckTelemetry.theRunningTotal = 0
                    }
                }

                inputVoltage:{
                    return (platformInterface.led_buck_power_notification.input_voltage).toFixed(1);
                }
                outputVoltage:{
                    return (platformInterface.led_buck_power_notification.output_voltage).toFixed(1);
                }
                inputCurrent:{
                    return (platformInterface.led_buck_power_notification.input_current).toFixed(0)
                }
                outputCurrent:{
                    return (platformInterface.led_buck_power_notification.output_current).toFixed(0)
                }
                temperature:{
                    return (platformInterface.led_buck_power_notification.temperature).toFixed(0)
                }
                efficiency: theEfficiencyAverage
            }

            SGSlider {
                id: ledIntensity
                width:330
                label: "Intensity:"
                value: platformInterface.set_buck_intensity_notification.intensity
                labelTopAligned: true
                startLabel: "0%"
                endLabel: "100%"
                grooveColor: "dimgrey"
                grooveFillColor: windowsDarkBlue
                textColor: "white"
                from: 0
                to: 100
                stepSize: 1
                anchors {
                    left: buckTelemetry.right
                    leftMargin: 30
                    verticalCenter: parent.verticalCenter
                }

                onUserSet:{
                    //console.log("new value:",ledIntensity.value);
                    platformInterface.set_buck_intensity.update(platformInterface.set_buck_intensity_notification.enabled,
                                                              ledIntensity.value);
                }

            }

            LEDIndicator{
                id: buckLED1
                ledColor: {
                    var thePercentage = platformInterface.set_buck_intensity_notification.intensity/100
                    var theColor = parseInt((255 * (thePercentage)).toFixed(0))
                    //console.log("boost color value is",theColor)
                    var theHexValue = theColor.toString(16).toUpperCase();
                    if (theHexValue.length % 2) {
                      theHexValue = '0' + theHexValue;
                    }

                    var theHexColor ="#" + theHexValue + theHexValue + theHexValue
                    return theHexColor
                }
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right:parent.right
                anchors.rightMargin: rightInset + 10
            }

            Rectangle {
                id:divider3
                color: dividerColor
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                height:1
            }
        }

//----------------------------------------------------------------------------------------
//                      Boost
//----------------------------------------------------------------------------------------
        Rectangle{
            id:boostContainer
            height: parent.height/4
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:buckContainer.bottom
            anchors.bottom:parent.bottom
            color:"transparent"

            Image{
                id:boostIcon
                height:50
                width:50
                mipmap:true
                anchors.top:parent.top
                anchors.topMargin: 15
                anchors.left:parent.left
                anchors.leftMargin: 10
                source:"./images/icon-boost.svg"
            }

            Text{
                id:boostTitle
                text: "Boost"
                font.pointSize: 48
                color: textColor
                anchors.top:parent.top
                anchors.topMargin:10
                anchors.left:boostIcon.right
                anchors.leftMargin: 20
            }

            Text{
                id:boostSubtitle
                text: "Controller for LED Backlighting"
                font.pointSize: 15
                color: secondaryTextColor
                anchors.top:boostTitle.bottom
                anchors.left:boostTitle.left
            }


            SGSwitch{
                id:boostSwitch
                anchors.left:parent.left
                anchors.leftMargin: leftSwitchMargin
                anchors.verticalCenter: parent.verticalCenter
                grooveFillColor:windowsDarkBlue
                grooveColor:switchGrooveColor
                checked:platformInterface.set_boost_intensity_notification.enabled

                onToggled:{
                    platformInterface.set_boost_intensity.update(checked,
                                                              platformInterface.set_boost_intensity_notification.intensity);
                }
            }

            RoundButton{
                id:boostScrim
                anchors.left: parent.left
                anchors.leftMargin:leftScrimOffset
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                anchors.right:parent.right
                visible:!boostSwitch.checked
                z:5

                onVisibleChanged:{
                    if (visible){
                        boostScrimToOpaque.start()
                    }
                    else{
                        boostScrimToTransparent.start()
                    }
                }

                OpacityAnimator{
                    id:boostScrimToOpaque
                    target:boostScrim
                    from: 0
                    to: 1
                    duration:1000
                    running:false
                }

                OpacityAnimator{
                    id:boostScrimToTransparent
                    target:boostScrim
                    from: 1
                    to: 0
                    duration:1000
                    running:false
                }

                LinearGradient {
                       anchors.fill: parent
                       start: Qt.point(0, 0)
                       end: Qt.point(parent.width, 0)
                       gradient: Gradient {
                           GradientStop { position: 0.0; color: "#00000000"}
                           GradientStop { position: .15; color: "#66000000" }
                           GradientStop { position: .5; color: "#BB000000" }
                       }
                   }

                background:Rectangle{
                    color:"transparent"
                    radius:5
                }
            }

            SGSlider {
                id: boostIntensity
                label: "Intensity:"
                width: 350
                value: {
                    //console.log("boost intensity set to",platformInterface.set_boost_intensity_notification.intensity)
                    return platformInterface.set_boost_intensity_notification.intensity
                }
                labelTopAligned: true
                startLabel: "0%"
                endLabel: "100%"
                grooveColor:"dimgrey"
                grooveFillColor: windowsDarkBlue
                textColor: "white"
                from: 0
                to: 100
                stepSize: 1
                anchors {
                    left: boostSwitch.right
                    leftMargin: 500
                    verticalCenter: parent.verticalCenter
                }

                onUserSet:{
                    //setBoostLEDs();
                    platformInterface.set_boost_intensity.update(platformInterface.set_boost_intensity_notification.enabled,
                                                              boostIntensity.value);
                }

                Component.onCompleted:{
                    //setBoostLEDs();
                }



            }


            Column{
                id:boostPWMlights
                anchors.top:parent.top
                anchors.topMargin: parent.height/8
                anchors.right: boostPWMlights2.left
                anchors.rightMargin: 10
                width:50
                spacing:10

                function setBoostLEDs(){
                    var thePercentage = platformInterface.set_boost_intensity_notification.intensity/100
                    var theColor = parseInt((255 * (thePercentage)).toFixed(0))
                    //console.log("boost color value is",theColor)
                    var theHexValue = theColor.toString(16).toUpperCase();
                    if (theHexValue.length % 2) {
                      theHexValue = '0' + theHexValue;
                    }

                    var hexvalue ="#" + "00" + theHexValue + "00"

                    //console.log("new value:",hexvalue);
                    boostLED1.ledColor = hexvalue;
                    boostLED2.ledColor = hexvalue;
                    boostLED3.ledColor = hexvalue;
                    boostLED4.ledColor = hexvalue;
                    boostLED5.ledColor = hexvalue;
                    boostLED6.ledColor = hexvalue;
                    boostLED7.ledColor = hexvalue;
                    boostLED8.ledColor = hexvalue;
                    boostLED9.ledColor = hexvalue;
                }

                property var boostIntensity: platformInterface.set_boost_intensity_notification.intensity

                onBoostIntensityChanged:{
                    setBoostLEDs();
                }

                LEDIndicator{
                    id: boostLED1
                    ledColor: "green"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED2
                    ledColor: "green"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED3
                    ledColor: "green"
                    height: 40
                }
            }

            Column{
                id:boostPWMlights2
                anchors.top:parent.top
                anchors.topMargin: parent.height/8
                anchors.right: boostPWMlights3.left
                anchors.rightMargin: 10
                width:50
                spacing:10

                LEDIndicator{
                    id: boostLED4
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED5
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED6
                    ledColor: "white"
                    height: 40
                }
            }

            Column{
                id:boostPWMlights3
                anchors.top:parent.top
                anchors.topMargin: parent.height/8
                anchors.right: parent.right
                anchors.rightMargin: rightInset
                width:50
                spacing:10

                LEDIndicator{
                    id: boostLED7
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED8
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED9
                    ledColor: "white"
                    height: 40
                }
            }
        }


    }



}
