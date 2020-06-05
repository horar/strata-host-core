import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"

    property bool batteryIsMissing: platformInterface.battery_status.no_battery_indicator

    Rectangle{
        id:notConnectedScrim
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.bottom:parent.bottom
        anchors.right:parent.right
        color:"transparent"
        visible:batteryIsMissing
        Text{
            id:notConnectedText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: parent.height/8
            text:"no \nbattery"
            horizontalAlignment: Text.AlignHCenter
            color:hightlightColor
            font.pixelSize: 72
            opacity:.75
        }
    }

    Text{
        id:audioVoltageLabel
        font.pixelSize: 18
        anchors.left:parent.left
        anchors.leftMargin:10
        anchors.top: parent.top
        anchors.topMargin: 10
        text:"Audio voltage:"
        color: "black"
        visible:!batteryIsMissing
    }
    SGSlider{
        id:audioVoltageSlider
        anchors.left: audioVoltageLabel.right
        anchors.leftMargin: 5
        anchors.verticalCenter: audioVoltageLabel.verticalCenter
        anchors.verticalCenterOffset: 5
        height:25
        from:100
        to:600
        inputBox: true
        grooveColor: "grey"
        grooveFillColor: hightlightColor
        visible:!batteryIsMissing
    }

    Text{
        id:controllerBypassLabel
        font.pixelSize: 18
        anchors.left:parent.left
        anchors.leftMargin:10
        anchors.top: audioVoltageLabel.bottom
        anchors.topMargin: 20
        text:"Controller bypass:"
        color: "black"
        visible:!batteryIsMissing
    }
    SGSwitch{
        id:controllerBypassSwitch
        anchors.left:controllerBypassLabel.right
        anchors.leftMargin: 5
        anchors.verticalCenter: controllerBypassLabel.verticalCenter
        height:25
        grooveFillColor: hightlightColor
        visible:!batteryIsMissing
    }

    Text{
        id:sinkCapLabel
        font.pixelSize: 18
        anchors.left:parent.left
        anchors.leftMargin:10
        anchors.top: controllerBypassLabel.bottom
        anchors.topMargin: 20
        text:"Sink capabilities:"
        color: "black"
        visible:!batteryIsMissing
    }

    SGSegmentedButtonStrip {
        id: sinkCapSegmentedButton
        labelLeft: false
        anchors.left: sinkCapLabel.right
        anchors.leftMargin: 10
        anchors.verticalCenter: sinkCapLabel.verticalCenter
        textColor: "black"
        activeTextColor: "black"
        radius: buttonHeight/2
        buttonHeight: 20
        exclusive: true
        buttonImplicitWidth: 50
        hoverEnabled:false
        enabled: false
        visible:!batteryIsMissing

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            SGSegmentedButton{
                text: qsTr("5V 3A")
                activeColor: "lightgrey"
                inactiveColor: "white"
                checked: true
                //height:40
                onClicked: {}


            }

            SGSegmentedButton{
                text: qsTr("7V 3A")
                activeColor:"lightgrey"
                inactiveColor: "white"
                //height:40
                onClicked: {}
            }
            SGSegmentedButton{
                text: qsTr("9V 3A")
                activeColor:"lightgrey"
                inactiveColor: "white"
                //height:40
                onClicked: {}
            }
            SGSegmentedButton{
                text: qsTr("12V 3A")
                activeColor:"lightgrey"
                inactiveColor: "white"
                //height:40
                onClicked: {}
            }
        }
    }
}