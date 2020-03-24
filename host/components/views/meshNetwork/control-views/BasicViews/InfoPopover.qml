import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget10


Popup {
    id:root
    height:200
    width:100

    //    leftMargin: 10
    //    topMargin: 0
    //    rightMargin: 0
    //    bottomMargin: 0

    opacity: .85

    property int leftTextMargin:10
    property int modelsLeftMargin:20
    property int modelsPreferredRowHeight:30
    property int sectionItemFontSize:15
    property alias title:title.text
    property string nodeNumber:"0"

    property bool hasLEDModel:false
    property bool hasBuzzerModel:false
    property bool hasVibrationModel:false
    property bool hasNoModels: (!hasLEDModel && !hasBuzzerModel && !hasVibrationModel)
    property color backgroundColor: "lightgrey"
    property color textColor: "black"

    onAboutToShow:{
        //configure the view to match the current settings.
        platformInterface.get_alarm_mode.update(nodeNumber);
        platformInterface.get_dimmer_mode.update(nodeNumber);
        platformInterface.get_relay_mode.update(nodeNumber);
        platformInterface.get_high_power_mode.update(nodeNumber);
        platformInterface.get_hsl_color.update(nodeNumber);
    }

    property bool alarmModeIsOn: platformInterface.alarm_mode.value;
    onAlarmModeIsOnChanged: {
        if (alarmModeIsOn && platformInterface.alarm_mode.uaddr === nodeNumber)
            alarmSwitch.checked = true;
    }
    property bool dimmerModeIsOn: platformInterface.dimmer_mode.value;
    onDimmerModeIsOnChanged: {
        if (dimmerModeIsOn && platformInterface.dimmer_mode.uaddr === nodeNumber)
            dimmerSwitch.checked = true;
    }
    property bool relayModeIsOn: platformInterface.relay_mode.value;
    onRelayModeIsOnChanged: {
        if (relayModeIsOn && platformInterface.relay_mode.uaddr === nodeNumber)
            relayModeIsOn.checked = true;
    }
    property bool highPowerIsOn: platformInterface.high_power_mode.value;
    onHighPowerIsOnChanged: {
        if (highPowerIsOn && platformInterface.high_power_mode.uaddr === nodeNumber)
            highPowerIsOn.checked = true;
    }
    property var hslColor: platformInterface.hsl_color.uaddr;
    onHslColorChanged: {
        if (platformInterface.hsl_color.uaddr === nodeNumber){
            //the h value should be between 1 and 360. Divide this by 360 and multiply by
            //255 to get the corresponding hue slider value
            hueSlider.value = (hslColor/360) * 255
            //the hue slider has no way to display or represent saturation or lightness,
            //so we'll ignore these values
        }
    }

    background: Rectangle{
        id:background
        //        anchors.top:root.top
        //        anchors.right:root.right
        //        anchors.bottom:root.bottom
        //        anchors.left:root.left
        //        anchors.leftMargin: 50

        anchors.fill:parent
        color:"transparent"
        border.color:"transparent"


        Rectangle{
            id:filledBackground
            anchors.top:background.top
            anchors.right:background.right
            anchors.bottom:background.bottom
            anchors.left:background.left
            anchors.leftMargin: 10

            color:"transparent"
            border.color:"transparent"
        }

        Canvas {
            id: outline

            width: filledBackground.width
            height: filledBackground.height
            contextType: "2d"
            property var startY: filledBackground.height/8
            property var triangleHeight: 20
            property var triangleDepth: 10
            property var cornerRadius: 10

            onPaint: {
                //console.log("painting arrow on infoPopover",startY)
                var context = getContext("2d")
                context.fillStyle = "lightgrey";
                context.strokeStyle = "grey";
                context.lineWidth = 1;

                context.beginPath();
                context.moveTo(outline.x + triangleDepth + cornerRadius,0);
                context.lineTo(outline.x + outline.width-cornerRadius,0)
                context.arcTo(outline.x + outline.width,0,outline.x + outline.width,outline.y +cornerRadius,cornerRadius);
                context.lineTo(outline.x + outline.width, outline.height-cornerRadius);
                context.arcTo(outline.x + outline.width, outline.y + outline.height,outline.x + outline.width-cornerRadius,outline.height,cornerRadius);
                context.lineTo(triangleDepth+cornerRadius,outline.y + outline.height);
                context.arcTo(triangleDepth,outline.y + outline.height, triangleDepth,outline.y + outline.height-cornerRadius,cornerRadius);
                context.lineTo(triangleDepth,startY+triangleHeight)
                context.lineTo(0, startY+triangleHeight/2);
                context.lineTo(triangleDepth, outline.y+startY);
                context.lineTo(triangleDepth, outline.y + cornerRadius);
                context.arcTo(outline.x + triangleDepth,outline.y,outline.x + triangleDepth+cornerRadius,outline.y,cornerRadius);

                context.closePath();
                context.fill();
                context.stroke();
            }
        }
    }



    Text{
        id:title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: 10
        text:"Node Info"
        font.pixelSize:24
    }

    Text{
        id:modelsText
        anchors.top:title.bottom
        anchors.topMargin: 20
        anchors.left:parent.left
        anchors.leftMargin:leftTextMargin
        text:"Models:"
        font.pixelSize:18
    }

    GridLayout{
        id:modelColumn
        anchors.top:modelsText.bottom
        anchors.topMargin: 10
        anchors.left:parent.left
        anchors.leftMargin:modelsLeftMargin
        columns:2
        rows:4
        rowSpacing: 0


        //first row
        Text{
            id:alarmText
            width:100
            Layout.fillWidth: true
            //Layout.preferredHeight: hasLEDModel ? modelsPreferredRowHeight : 0
            Layout.preferredHeight: modelsPreferredRowHeight
            horizontalAlignment: Text.AlignRight
            text:"Alarm armed:"
            font.pixelSize:sectionItemFontSize
        }


        SGSwitch{
            id:alarmSwitch
            Layout.preferredHeight:  18
            Layout.bottomMargin: 10
            grooveFillColor:"dimgrey"

            onToggled:{
                console.log("alarm on/off, value is",alarmSwitch.checked);
                platformInterface.set_alarm_mode.update(parseInt(nodeNumber),alarmSwitch.checked)

            }
        }



        //second row
        Text{
            id:dimmerText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight:  modelsPreferredRowHeight
            horizontalAlignment: Text.AlignRight
            text:"Dimmer:"
            font.pixelSize:sectionItemFontSize
        }

        SGSwitch{
            id:dimmerSwitch
            Layout.preferredHeight:  18
            Layout.bottomMargin: 10
            grooveFillColor:"dimgrey"

            onClicked:{
                console.log("dimmer on/off");
                platformInterface.set_dimmer_mode.update(parseInt(nodeNumber),checked)
            }
        }


        //third row
        Text{
            id:relayText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight:  modelsPreferredRowHeight
            horizontalAlignment: Text.AlignRight
            text:"Relay:"
            font.pixelSize:sectionItemFontSize
        }

        SGSwitch{
            id:relaySwitch
            Layout.preferredHeight:  18
            Layout.bottomMargin: 10
            grooveFillColor:"dimgrey"

            onClicked:{
                console.log("relay on/off");
                platformInterface.set_relay_mode.update(parseInt(nodeNumber),checked)

            }
        }

        //fourth row
        Text{
            id:highPowerText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight:  modelsPreferredRowHeight
            horizontalAlignment: Text.AlignRight
            text:"High power:"
            font.pixelSize:sectionItemFontSize
        }

        SGSwitch{
            id:highPowerSwitch
            Layout.preferredHeight:  18
            Layout.bottomMargin: 10
            grooveFillColor:"dimgrey"

            onClicked:{
                //console.log("high power on/off");
                platformInterface.set_high_power_mode.update(parseInt(nodeNumber),checked)
            }
        }

        //fifth row:
        Text{
            id:hueSliderText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight:  modelsPreferredRowHeight
            horizontalAlignment: Text.AlignRight
            text:"LED color:"
            font.pixelSize:sectionItemFontSize
        }

        Widget10.SGHueSlider {
            id: hueSlider
            height:50
            width:150
            live: false

            onValueChanged: {
                //            //The returned value is between 0 and 1, so scale to match the slider's range
                //            return hsl.h * 255;
                //take the h value /360 * 255 to get the slider value
                platformInterface.set_hsl_color.update(parseInt(nodeNumber),
                                                       value,
                                                       100,
                                                       100);

            }

        }

    }

    Button{
        id:closeButton
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        height:30
        text:"close"
        font.pixelSize:18

        contentItem: Text {
            text: closeButton.text
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            font.pixelSize: 24
            opacity: enabled ? 1.0 : 0.3
            color: "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 80
            color: closeButton.down ? "grey" : "darkgrey"
            border.width: 1
            border.color:"black"
            radius: 10
        }

        onClicked:{
            root.close()
        }
    }


}
