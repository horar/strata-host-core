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
    property string backgroundColor: "#2A2E31"
    property string dividerColor: "#3E4042"
    property string switchGrooveColor:"dimgrey"
    property int leftSwitchMargin: 40
    property int rightInset: 50


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
                text: "2-Channel PWM RGB Control"
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
                //uncheckedLabel:"off"
            }

            Text{
                id:channel1Title
                text: "1"
                font.pointSize: 265
                color: secondaryTextColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:pwmSwitch.right
                anchors.leftMargin: 200
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
                    //value: platformInterface.ledSlider
                    sliderHeight:50
                    //transform: Rotation { axis { x: 1; y: 0; z: 0 } angle: 70}
                    anchors {
                        //verticalCenter: whiteButton.verticalCenter
                        left: ledControlContainer.left
                        leftMargin: 10
                        right: ledControlContainer.right
                        rightMargin: 10
                        top: ledControlContainer.top
                        topMargin: 10
                    }

                    onValueChanged: {
                        pwmColorBox1.value = hueSlider.hexvalue;
                        pwmLED1.ledColor = hueSlider.hexvalue;
                        pwmLED2.ledColor = hueSlider.hexvalue;
                        pwmLED3.ledColor = hueSlider.hexvalue;
                        //platformInterface.set_color_mixing.update(hueSlider.color1, hueSlider.color_value1, hueSlider.color2, hueSlider.color_value2)
                        //platformInterface.ledSlider = value
                        //platformInterface.turnOffChecked = false
                    }

                    Component.onCompleted: {
                        pwmColorBox1.value = "#008080";
                        pwmLED1.ledColor = "#008080";
                        pwmLED2.ledColor = "#008080";
                        pwmLED3.ledColor = "#008080";
                    }
                }

                Text{
                    id:whiteButtonLabel
                    text:"white:"
                    color:"white"

                    anchors.left: hueSlider.left
                    anchors.top: hueSlider.bottom
                    anchors.topMargin: 10

                }

                RoundButton {
                    id: whiteButton
                    checkable: false
                    //text: "White"
                    height:30
                    width:30
                    anchors.verticalCenter: whiteButtonLabel.verticalCenter
                    anchors.left:whiteButtonLabel.right
                    anchors.leftMargin: 5
                    onClicked: {
                        pwmColorBox1.value = "#FFFFFF";
                        pwmLED1.ledColor = "#FFFFFF";
                        pwmLED2.ledColor = "#FFFFFF";
                        pwmLED3.ledColor = "#FFFFFF";
                        //platformInterface.set_led_outputs_on_off.update("white")
                        //platformInterface.turnOffChecked = false
                    }
                }

                SGSubmitInfoBox{
                    id:pwmColorBox1
                    anchors.left:whiteButton.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: whiteButton.verticalCenter
                    //anchors.right:hueSlider.right
                    infoBoxWidth:80
                    height:20
                    textColor:"white"
                    value:"#008080"

                    onApplied:{
                        pwmLED1.ledColor = pwmColorBox1.value;
                        pwmLED2.ledColor = pwmColorBox1.value;
                        pwmLED3.ledColor = pwmColorBox1.value;
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
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: pwmLED2
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: pwmLED3
                    ledColor: "white"
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
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: pwmLED5
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: pwmLED6
                    ledColor: "white"
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
                    id: hueSlider2
                    label: ""
                    labelLeft: true
                    //value: platformInterface.ledSlider
                    sliderHeight:50
                    //transform: Rotation { axis { x: 1; y: 0; z: 0 } angle: 70}
                    anchors {
                        //verticalCenter: whiteButton.verticalCenter
                        left: ledControlContainer2.left
                        leftMargin: 10
                        right: ledControlContainer2.right
                        rightMargin: 10
                        top: ledControlContainer2.top
                        topMargin: 10
                    }

                    onValueChanged: {
                        //console.log("slider changed:",hueSlider2.rgbArray[0], hueSlider2.rgbArray[1], hueSlider2.rgbArray[2])
                        //console.log("hex value is:",hueSlider2.hexvalue)
                        pwmColorBox2.value = hueSlider2.hexvalue;
                        pwmLED4.ledColor = hueSlider2.hexvalue;
                        pwmLED5.ledColor = hueSlider2.hexvalue;
                        pwmLED6.ledColor = hueSlider2.hexvalue;
                        //platformInterface.set_color_mixing.update(hueSlider.color1, hueSlider.color_value1, hueSlider.color2, hueSlider.color_value2)
                        //platformInterface.ledSlider = value
                        //platformInterface.turnOffChecked = false
                    }

                    Component.onCompleted: {
                        pwmColorBox2.value = "#008080";
                        pwmLED4.ledColor = "#008080";
                        pwmLED5.ledColor = "#008080";
                        pwmLED6.ledColor = "#008080";
                    }
                }

                Text{
                    id:whiteButtonLabel2
                    text:"white:"
                    color:"white"

                    anchors.left: hueSlider2.left
                    anchors.top: hueSlider2.bottom
                    anchors.topMargin: 10

                }

                RoundButton {
                    id: whiteButton2
                    checkable: false
                    height:30
                    width:30
                    anchors.verticalCenter: whiteButtonLabel2.verticalCenter
                    anchors.left:whiteButtonLabel2.right
                    anchors.leftMargin: 5
                    onClicked: {
                        pwmColorBox2.value = "#FFFFFF";
                        pwmLED4.ledColor = "#FFFFFF";
                        pwmLED5.ledColor = "#FFFFFF";
                        pwmLED6.ledColor = "#FFFFFF";

                        //platformInterface.set_led_outputs_on_off.update("white")
                        //platformInterface.turnOffChecked = false
                    }


                }

                SGSubmitInfoBox{
                    id:pwmColorBox2
                    anchors.left:whiteButton2.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: whiteButton2.verticalCenter
                    //anchors.right:hueSlider.right
                    infoBoxWidth:80
                    height:20
                    textColor:"white"
                    value:"#008080"

                    onApplied:{
                        pwmLED4.ledColor = pwmColorBox2.value;
                        pwmLED5.ledColor = pwmColorBox2.value;
                        pwmLED6.ledColor = pwmColorBox2.value;
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
            }


            Rectangle {
                id: linearControlContainer
                width: 200
                height: childrenRect.height + 10
                color: "transparent"
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 0
                    left:linearSwitch.right
                    leftMargin: 320
                }

                SGHueSlider {
                    id: linearHueSlider
                    label: ""
                    labelLeft: true
                    //value: platformInterface.ledSlider
                    sliderHeight:50
                    //transform: Rotation { axis { x: 1; y: 0; z: 0 } angle: 70}
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
                        linearColorBox.value = linearHueSlider.hexvalue;
                        linearLED1.ledColor = linearHueSlider.hexvalue;
                        linearLED2.ledColor = linearHueSlider.hexvalue;
                        linearLED3.ledColor = linearHueSlider.hexvalue;
                        //platformInterface.set_color_mixing.update(hueSlider.color1, hueSlider.color_value1, hueSlider.color2, hueSlider.color_value2)
                        //platformInterface.ledSlider = value
                        //platformInterface.turnOffChecked = false
                    }

                    Component.onCompleted: {
                        linearColorBox.value = "#008080";
                        linearLED1.ledColor = "#008080";
                        linearLED2.ledColor = "#008080";
                        linearLED3.ledColor = "#008080";
                    }
                }

                Text{
                    id:linearWhiteButtonLabel
                    text:"white:"
                    color:"white"

                    anchors.left: linearHueSlider.left
                    anchors.top: linearHueSlider.bottom
                    anchors.topMargin: 10

                }

                RoundButton {
                    id: linearWhiteButton
                    checkable: false
                    //text: "White"
                    height:30
                    width:30
                    anchors.verticalCenter: linearWhiteButtonLabel.verticalCenter
                    anchors.left:linearWhiteButtonLabel.right
                    anchors.leftMargin: 5
                    onClicked: {
                        linearColorBox.value = "#FFFFFF";
                        linearLED1.ledColor = "#FFFFFF";
                        linearLED2.ledColor = "#FFFFFF";
                        linearLED3.ledColor = "#FFFFFF";
                        //platformInterface.set_led_outputs_on_off.update("white")
                        //platformInterface.turnOffChecked = false
                    }
                }

                SGSubmitInfoBox{
                    id:linearColorBox
                    anchors.left:linearWhiteButton.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: linearWhiteButton.verticalCenter
                    //anchors.right:hueSlider.right
                    infoBoxWidth:80
                    height:20
                    textColor:"white"
                    value:"#008080"

                    onApplied:{
                        linearLED1.ledColor = linearColorBox.value;
                        linearLED2.ledColor = linearColorBox.value;
                        linearLED3.ledColor = linearColorBox.value;
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
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: linearLED2
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: linearLED3
                    ledColor: "white"
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
            //border.color:"tran"
            //border.width:1

            Image{
                id:buckIcon
                height:50
                width:50
                anchors.top:parent.top
                anchors.topMargin: 15
                anchors.left:parent.left
                anchors.leftMargin: 10
                source:"./images/icon-voltage.svg"
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
            }

            PortInfo{
                id:highCurrentInfo
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: buckSwitch.right
                anchors.leftMargin: 200
                width:250
                boxHeight:60
            }

            SGSlider {
                id: ledIntensity
                width:350
                label: "Intensity:"
                //                value: {
                //                    if (platformInterface.output_current_exceeds_maximum.port === portNumber){
                //                        return platformInterface.output_current_exceeds_maximum.current_limit;
                //                    }
                //                    else{
                //                        return currentLimit.value;
                //                    }

                //                }
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
                    left: highCurrentInfo.right
                    leftMargin: 50
                    verticalCenter: parent.verticalCenter
                }

                onUserSet:{
                    setBuckLEDs();
                    console.log("new value:",ledIntensity.value);
                    //platformInterface.request_over_current_protection.update(portNumber, value)
                }

                Component.onCompleted:{
                    setBuckLEDs();
                }

                function setBuckLEDs(){
                    var theColor = parseInt((255 * (ledIntensity.value/100)).toFixed(0))

                    var theHexValue = theColor.toString(16).toUpperCase();
                    if (theHexValue.length % 2) {
                      theHexValue = '0' + theHexValue;
                    }

                    var hexvalue ="#" + theHexValue + theHexValue + theHexValue
                    console.log("new value:",hexvalue);
                    buckLED1.ledColor = hexvalue;
                }

            }

            LEDIndicator{
                id: buckLED1
                ledColor: "white"
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right:parent.right
                anchors.rightMargin: rightInset
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
                anchors.top:parent.top
                anchors.topMargin: 15
                anchors.left:parent.left
                anchors.leftMargin: 10
                source:"./images/icon-voltage.svg"
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
                text: "Boost Controller for LED Backlighting"
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
            }

            SGSlider {
                id: boostIntensity
                label: "Intensity:"
                width: 350
                //                value: {
                //                    if (platformInterface.output_current_exceeds_maximum.port === portNumber){
                //                        return platformInterface.output_current_exceeds_maximum.current_limit;
                //                    }
                //                    else{
                //                        return currentLimit.value;
                //                    }

                //                }
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
                    setBoostLEDs();
                    //platformInterface.request_over_current_protection.update(portNumber, value)
                }

                Component.onCompleted:{
                    setBoostLEDs();
                }

                function setBoostLEDs(){
                    var theColor = parseInt((255 * (boostIntensity.value/100)).toFixed(0))
                    var theHexValue = theColor.toString(16).toUpperCase();
                    if (theHexValue.length % 2) {
                      theHexValue = '0' + theHexValue;
                    }

                    var hexvalue ="#" + theHexValue + theHexValue + theHexValue

                    console.log("new value:",hexvalue);
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

            }


            Column{
                id:boostPWMlights
                anchors.top:parent.top
                anchors.topMargin: parent.height/8
                anchors.right: boostPWMlights2.left
                anchors.rightMargin: 10
                width:50
                spacing:10

                LEDIndicator{
                    id: boostLED1
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED2
                    ledColor: "white"
                    height: 40
                }
                LEDIndicator{
                    id: boostLED3
                    ledColor: "white"
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
