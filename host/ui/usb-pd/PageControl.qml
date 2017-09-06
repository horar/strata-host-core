import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtPositioning 5.2
import QtQuick.Window 2.2
import QtCharts 2.2

import QtQuick.Controls 1.4


import tech.spyglass.userinterfacebinding 1.0

import "framework"

Rectangle {
    id: sgWindow
    property alias image: windowboarder
    property alias rectangle: outterboarder
    property QtObject hold: null
    property bool isConnected: false

    UserInterfaceBinding {
        id: userinterfaceBinding
        onInputVoltagePort0Changed: {
            console.log("Port 0 Voltage Changed");
            resultingVoltage.text =userinterfaceBinding.inputVoltagePort0.toFixed(2) + " V"
        }

        onPort0TimeChanged: {
            console.log("Port 0 time");
            timeRequired.text = userinterfaceBinding.time.toFixed(2) + " ms"
        }

        onOutputVoltagePort0Changed: {
            console.log("Port 0 Voltage output");
            newVoltageResult.text=userinterfaceBinding.outputVoltagePort0.toFixed(2) + "V"
        }

        onPowerPort0Changed: {
            console.log("Port 0 power");
            voltageValue.text = userinterfaceBinding.powerPort0.toFixed(2) + " W"
        }
    }

    Rectangle {
        id: outterboarder
        x: 6;y: 25
        height: parent.height /2;width : outterboarder.height
        anchors {centerIn: sgWindow}
        color: "white"
        opacity: 1.0

        Image{
            id: windowboarder
            anchors{top: parent.top
                bottom: parent.bottom
                left : parent.left
                right : parent.right}
            visible: true
            source: "boarder.svg"

            Rectangle{
                id:valueboarder
                width: parent.width/9;height: parent.height/3 * 1.50
                y: parent.height/2 - valueboarder.height/2 + parent.y
                x: parent.width/10 * 7 - valueboarder.width/2 + parent.x
                property int label_height : valueboarder.height/6
                property int spaceHeight: label_height/2

                Label {
                    id: voltageValue
                    x: 0;y:0
                    //font.pointSize: Math.abs(parent.width/4) /// ummm ....
                    font.pointSize: 10
                    opacity: 1.0
                    text : ""
                }
                Label {
                    id: resultingVoltage
                    x: 0
                    y: valueboarder.label_height + valueboarder.spaceHeight
                    //font.pointSize:Math.abs(parent.width/4)  // ummmmm ....
                    font.pointSize: 10
                    opacity: 1.0
                    text : ""
                }
                Label {
                    id: newVoltageResult
                    x: 0
                    y: 2 * (valueboarder.label_height + valueboarder.spaceHeight)
                    //font.pointSize: Math.abs(parent.width/4) /// uuummmmmmmmmm ....
                    font.pointSize: 10
                    opacity: 1.0
                    text : ""
                }
                Label {
                    id: timeRequired
                    x: 0
                    y: 3 * (valueboarder.label_height + valueboarder.spaceHeight)
                    //font.pointSize: Math.abs(parent.width/4) /// ummmmm ....
                    font.pointSize: 10
                    opacity: 1.0
                    text : ""
                }
            }

            Label {
                id: windowTitle
                anchors{
                    top: windowboarder.top
                    topMargin: 20
                    horizontalCenter: windowboarder.horizontalCenter
                }

                font{
                    family: "Helvetica"
                    //pointSize: Math.abs(parent.width/30)  // compiler and run time warnings told you this was wrong
                    pointSize: 20
                }

                text: qsTr("Automotive USB-PD")
                color: "gray"

                Label {
                    id: windowSubtitle
                    anchors { top: windowTitle.bottom
                              horizontalCenter: windowTitle.horizontalCenter
                    }
                    text: qsTr("2 X 100W Source")
                    font {
                        pointSize: 10
                        family: "Helvetica" }
                    color: "gray"
                }
            }

            Label {
                id: portPowerTitle
                color: "#949494"
                height: parent.height/10 * 2 /// more advanced location math
                width: portPowerTitle.height
                text: qsTr("Port 0")
                anchors {
                    left: parent.left
                    verticalCenter:  parent.verticalCenter
                    leftMargin: parent.width/10 * 3  // advanced location math. I bet 100.00 dollars you can't figure out where this is =)
                }

                font {
                    family: "Helvetica"
                    bold: true
                    //pointSize: parent.width/30 /// ah jeeze ...
                    // the warning output even tells you are wrong: "QFont::setPointSizeF: Point size <= 0 (0.000000), must be greater than 0"
                    pointSize: 10
                }

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        portPowerandTemperatureGraph.open()
                    }
                }
            }

            SGPopup {
                id: portPowerandTemperatureGraph
                x : portPowerTitle.x - portPowerTitle.width / 2; y: portPowerTitle.y - portPowerTitle.height / 2
                width :sgWindow.width/2; height: sgWindow.height/2

                contentItem: SGLineGraph {
                    title: "Power and Temperature Graph"
                }
            }

        }

        Timer {
            id: timer
            running: false
            repeat: false
            property bool callback_connected: false

        }

        Image {
            id: onlogoImage
            anchors{
                left: parent.left
                verticalCenter:  parent.verticalCenter
                leftMargin: parent.width/10  // more advanced math and magic hard coded numbers divide by 10????
                                             // this is nearly meaningless and any real information provided
            }
            height: parent.height/10 * 2; width: onlogoImage.height // more advanced positional math ... weee math ...
            source: "ONLogo.png"

            MouseArea {
                anchors{ fill: parent }
                onClicked: {
                    inputPowergraph.open()
                }
            }
        }

        SGPopup {
            id:inputPowergraph
            //x : onlogoImage.x - onlogoImage.width / 2; y: onlogoImage.y - onlogoImage.height / 2
            x : 0; y: 0
            width: sgWindow.width / 2; height: sgWindow.height / 2

            contentItem: SGLineGraph {
                title: "Input Power Graph"
            }
        }

        Rectangle {
            id: divider
            anchors { left: parent.left
                verticalCenter:  parent.verticalCenter
                leftMargin: parent.width/10 * 6
            }
            height: parent.height/3* 1.50;width: parent.width/42
            color: "black"
            opacity: 1.0

        }

    Rectangle{
        id: iconboarder
        width: parent.width/15
        height: parent.height/3 * 1.50
        y: parent.height/2 - iconboarder.height/2 + parent.y
        x: parent.width/2 - iconboarder.width/2 + parent.x
        anchors { centerIn: windowboarder }
        property int circle_height: iconboarder.height/6
        property int spaceHeight: circle_height/2

        Image {
            id:leftArrowimage
            x: 0; y : 0
            height: parent.height/6
            width: leftArrowimage.height
            source: "leftArrow.svg"
        }

        Image {
            id:rightArrowimage
            x: 0
            y : iconboarder.circle_height + iconboarder.spaceHeight
            height: parent.height/6;width: rightArrowimage.height
            source: "rightArrow.svg"
        }

        Image {
            id:voltageIconimage
            x : 0
            y : 2* (iconboarder.circle_height + iconboarder.spaceHeight)
            height: parent.height/6
            width: voltageIconimage.height
            source: "voltageIcon.svg"

        }

        Image {
            id: clockIcon

            // I love math as much as the next engineer ... but seriously
            x : 0; y : 3* (iconboarder.circle_height + iconboarder.spaceHeight)
            height: parent.height/6; width: clockIcon.height
            source: "clockIcon.svg"

            MouseArea{
                anchors { fill: parent }
                onClicked: {
                    voltageAndCurrentGraph.open()
                }
            }
        }
    }

    SGPopup {
        id: voltageAndCurrentGraph
        x: clockIcon.x - clockIcon.width / 2; y: clockIcon.y - clockIcon.height / 2
        width: sgWindow.width / 2; height: sgWindow.height / 2

        contentItem: SGLineGraph {
            title: "Voltage and Current Graph"
        }
    }

    Canvas {
            id: cable
            x: leftUSBPlug.x + leftUSBPlug.width
            y: leftUSBPlug.y
            anchors.left: leftUSBPlug.right
            anchors.right: deviceimage.left
            height: 100
            property color strokeStyle:  "black"
            property color fillStyle: "#b40000" // red
            property int lineWidth: 2
            property bool fill: true
            property bool stroke: true
            property real alpha: 1.0
            property real halfWidth: width/2
            //antialiasing: true

            onWidthChanged:requestPaint()
            onHalfWidthChanged: requestPaint()

            onPaint: {
                var ctx = cable.getContext('2d');
                ctx.fillStyle = Qt.rgba(1, 0, 0, 1);    //red

                //clear the viewport. This seems to be key to animating a redraw of the line
                //not driven by a change in the frame size
                ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

                var halfConnectorHeight = leftUSBPlug.height/2
                var halfHeight = height/2
                var quarterWidth = halfWidth/2
                var eighthWidth = halfWidth/4
                var sixteenthWidth = halfWidth/8
                var thirtysecondWidth = halfWidth/16

                ctx.save();
                ctx.strokeStyle = cable.strokeStyle;
                ctx.fillStyle = cable.fillStyle;
                ctx.lineWidth = cable.lineWidth;

                //for debugging
                //ctx.fillRect(0, 0, width, height)
                //ctx.strokeRect(0,0, width, height)


                ctx.beginPath();
                ctx.moveTo(width/2, cable.top)
                ctx.lineTo(cable.width/2, cable.bottom)

                ctx.moveTo(0,halfConnectorHeight);
                //a bit of rigidity from the cable on the left
                ctx.quadraticCurveTo(sixteenthWidth,halfConnectorHeight,eighthWidth,halfConnectorHeight*1.5);

                //bottom middle of the span
                ctx.quadraticCurveTo(halfWidth, height, width - eighthWidth,halfConnectorHeight*1.5)

                //a bit of rigidity on the right
                ctx.quadraticCurveTo(width - sixteenthWidth,halfConnectorHeight,width,halfConnectorHeight);

                ctx.stroke();
                ctx.restore();
            }
        }

    Image {
        id: leftUSBPlug
        width: parent.height / 20;height: parent.height/10
        visible: true
        x: windowboarder.x + windowboarder.width + windowboarder.width/20

        // a negative value? am I reading this right?
        //
        y: - leftUSBPlug.height/2 + windowboarder.y + windowboarder.height/2
        anchors{verticalCenter: windowboarder.verticalCenter}

        anchors.leftMargin: parent.width/10
        source: "leftUSBPlug.svg"
        SequentialAnimation{
            running: false
            id: connect

            NumberAnimation {
                target: leftUSBPlug
                property: "x";
                from: leftUSBPlug.x
                to: windowboarder.x + windowboarder.width;
                easing.type: Easing.InQuad;
                duration: 500
            }

            //swing left
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:cable.width/2;
                to: cable.width/4;
                easing.type: Easing.OutQuad;
                duration: 500
            }

            //swing right
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:cable.width/4;
                to: 3* cable.width/4;
                easing.type: Easing.OutQuad;
                duration: 750
            }

            //swing back to center
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:3* cable.width/4;
                to: cable.width/2;
                easing.type: Easing.OutQuad;
                duration: 1000
            }
        }

        SequentialAnimation {
            running: false
            id: disconnect

            NumberAnimation {
                target: leftUSBPlug
                property: "x";
                from: windowboarder.x + windowboarder.width;
                to: windowboarder.x + windowboarder.width + windowboarder.width/20
                easing.type: Easing.OutQuad;
                duration: 500
            }

            //swing right
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:cable.width/2;
                to: 5* cable.width/8;
                easing.type: Easing.OutQuad;
                duration: 500
            }

            //swing left
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:5*cable.width/8;
                to: 3*cable.width/8;
                easing.type: Easing.OutQuad;
                duration: 750
            }

            //swing back to center
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:3*cable.width/8;
                to: 5*cable.width/16;
                easing.type: Easing.OutQuad;
                duration: 1000
            }
        }
    }

    Connections {
        target: button
        onClicked: {
            if (!isConnected){
                isConnected = true;
                connect.start()
                button.text = "Disconnect"
            }
            else{
                isConnected = false;
                button.text = "Connect"
                disconnect.start()
            }
        }
        }

        Image {
            id:deviceimage
            anchors.left: parent.left
            anchors.verticalCenter:parent.verticalCenter
            width: parent.width/1.5
            height: parent.height/20 * 8
            anchors.leftMargin: parent.width/10 * 13
            source:"deviceOutline.svg"

            Label {
                id: devicelabel
                anchors.horizontalCenter: deviceimage.horizontalCenter
                anchors.topMargin: parent.width/15
                font.bold: true
                font.family: "Helvetica"
                //font.pointSize: parent.width/20  /// font size based on width !!!!?!?!?!?  This even had a warning.
                font.pointSize: 10  // oh ... that seems way simpler and less math =)
                anchors.top: parent.top
                text: qsTr("Voltage Request")
            }

            SGSlider {
                id: portVoltageSlider
                width: parent.width/3*1.5  // more advanced math
                height: parent.height/20
                maximumValue: 20
                minimumValue: 0
                value: 0.00
                stepSize: 10
                anchors.centerIn: parent
                property bool state_of: false
            }

            Button {
                id: button

                // Are you kidding? Calculus level math for height and width? please include dx/dt and dy/dt and other cool calcs =)
                //  I will give you 100.00 if you can locate this on the screen
                //
                height :parent.height/10 * 1.90;width :parent.width/3
                opacity: 1
                visible: true
                text: qsTr("Connect")
                anchors { bottom : parent.bottom
                    horizontalCenter: deviceimage.horizontalCenter
                    bottomMargin: parent.height/10 }
                style: ButtonStyle {
                    label : Text {
                        //font.pointSize: parent.height/2 /// more font ... that some big font !!
                        // not to mention this is based on the "parent of the parent" calculations.
                        // parent.height = parent.height/10 * 1.90 (WOW)
                        //
                        font.pointSize: 10
                        text : control.text
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors{fill : parent}

                    }
                }
            }
        }

        Image  {
            id: portconnector
            anchors {
                left: parent.left
                verticalCenter:parent.verticalCenter
                leftMargin: parent.width/10 * 9.9  /// HAHAHAHA !!! divide by 10 and then multiply by 9.9? HAHAHAHAHA this is just too funny to be believed !!
            }
            width: parent.width/35;height:parent.height/45*8  /// LOL !!! width / 45 times 8 .... HAHAHA !!
            source:"PortConnector.png"
        }
    }
}
