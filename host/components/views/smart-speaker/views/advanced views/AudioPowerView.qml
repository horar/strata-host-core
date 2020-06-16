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
        id:audioPowerTitleText
        font.pixelSize: 24
        anchors.top:parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height:0
        text:"Audio Power Mode"
        color: "black"
        visible:false
    }

    SGSegmentedButtonStrip {
        id: usbOrBatteryPowerSegmentedButton
        labelLeft: false
        anchors.top: audioPowerTitleText.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        textColor: "#444"
        activeTextColor: "white"
        radius: buttonHeight/2
        buttonHeight: 80
        exclusive: true
        buttonImplicitWidth: 100
        hoverEnabled:false

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            SGSegmentedButton{
                text: qsTr("A")
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
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
                text: qsTr("B")
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
            top: audioPowerTitleText.bottom
            topMargin: 20
            bottom: parent.bottom
            right: parent.right
            left: parent.left
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
