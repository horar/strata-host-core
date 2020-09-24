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
    property color buttonSelectedColor:"#91ABE1"


    Text{
        id:powerModeLabel
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pixelSize: 24
        text:"Audio Power Mode"
    }
    Rectangle{
        id:underlineRect
        anchors.left:powerModeLabel.left
        anchors.top:powerModeLabel.bottom
        anchors.topMargin: -5
        anchors.right:parent.right
        anchors.rightMargin: 10
        height:1
        color:"grey"
    }

    Rectangle{
        id:segmentedBox
        anchors.left:parent.left
        anchors.leftMargin: 10
        anchors.top: underlineRect.bottom
        anchors.topMargin: 28
        anchors.right:parent.right
        anchors.rightMargin: 10
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 10
        color:"transparent"
        border.color:"black"
        border.width: 2
        radius:3

        Rectangle{
            id:topLineEraser
            anchors.left:parent.left
            anchors.leftMargin:40
            anchors.right:parent.right
            anchors.rightMargin: 40
            anchors.top:parent.top
            height:parent.border.width
            color:backgroundColor

        }
    }

    Text{
        id:usbOrBatteryLabel
        anchors.left:parent.left
        anchors.top: underlineRect.bottom
        anchors.topMargin: 20
        horizontalAlignment: Text.AlignRight
        width:125
        font.pixelSize: 18
        text:"Path:"
    }
    SGSegmentedButtonStrip {
        id: usbOrBatteryPowerSegmentedButton
        labelLeft: false
        anchors.left: usbOrBatteryLabel.right
        anchors.leftMargin: 10
        anchors.verticalCenter: usbOrBatteryLabel.verticalCenter
        textColor: "#444"
        activeTextColor: "white"
        radius: buttonHeight/2
        buttonHeight: 30
        exclusive: true
        buttonImplicitWidth: 100
        hoverEnabled:false

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            SGSegmentedButton{
                text: qsTr("")
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                height:40
                onClicked: controlContainer.currentIndex = 0

                Image {
                    id: usbIcon
                    height:parent.height/2
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    mipmap:true
                    source:"../images/usb-c icon.svg"
                }
            }

            SGSegmentedButton{
                text: qsTr("")
                activeColor:buttonSelectedColor
                inactiveColor: "white"
                height:40
                onClicked: controlContainer.currentIndex = 1

                Image {
                    id: batteryIcon
                    height:parent.height/2
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    mipmap:true
                    source:"../images/battery-icon.svg"
                }
            }
        }
    }


    StackLayout {
        id: controlContainer
        anchors {
            top: usbOrBatteryPowerSegmentedButton.bottom
            topMargin: 10
            bottom: parent.bottom
            bottomMargin: 15
            right: parent.right
            rightMargin: 20
            left: parent.left
            leftMargin: 20
        }

        onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0:
                        usbSettings.visible = true;

                        batterySettings.visible = false;

                        break;
                    case 1:
                        usbSettings.visible = false;

                        batterySettings.visible = true;

                        break;

                }
        }

        USBPowerSettings {
            id: usbSettings
        }

        BatteryPowerSettings {
            id: batterySettings
        }
    }


}
