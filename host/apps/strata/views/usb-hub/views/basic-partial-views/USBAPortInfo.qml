import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/views/usb-pd-multiport/sgwidgets"

Rectangle {
    id: root

    property bool portConnected: false
    property bool isUSBAPort: true     //used to hide information not available for USB-A ports
    property color portColor: "#30a2db"
    property int portNumber: 0
    property alias portName: portTitle.text
    property alias portSubtitle: portSubtitle.text

    property alias outputVoltage: outputVoltageBox.value
    property alias maxPower: maxPowerBox.value
    property alias inputPower: powerInBox.value
    property alias outputPower: powerOutBox.value
    property alias portTemperature: temperatureBox.value

    property int basicTitleBackgroundHeight: 50//(2*root.height)/16;
    property int advancedTitleBackgroundHeight: advancedDisplayPortPortHeight/4

    onPortConnectedChanged:{
        if (portConnected)
            hideStats.start()
         else
            showStats.start()
    }

    OpacityAnimator {
        id: hideStats
        target: connectionContainer
        from: 1
        to: 0
        duration: 1000
    }

    OpacityAnimator {
        id: showStats
        target: connectionContainer
        from: 0
        to: 1
        duration: 1000
    }



    signal showGraph()

    color: "lightgoldenrodyellow"
    radius: 5
    border.color: "black"
    width: 150

    function transitionToAdvancedView(){
        outputVoltageBox.anchors.topMargin = 3;
        maxPowerBox.anchors.topMargin = 3;
        powerInBox.anchors.topMargin = 3;
        powerOutBox.anchors.topMargin = 3;
        temperatureBox.anchors.topMargin = 3;
        portToAdvanced.start()
    }

    ParallelAnimation{
        id: portToAdvanced
        running: false

        PropertyAnimation{
            target:titleBackground
            property: "height"
            to:advancedTitleBackgroundHeight
            duration: tabTransitionTime
        }

        PropertyAnimation{
            target:powerInBox
            property: "height"
            to:-5
            duration: tabTransitionTime
        }

        PropertyAnimation{
            target:portSubtitle
            property: "opacity"
            to:0
            duration: tabTransitionTime
        }

        PropertyAnimation{
            target:chargingRectangle
            property: "opacity"
            to:1
            duration: tabTransitionTime
        }
    }

    function transitionToBasicView(){
        outputVoltageBox.anchors.topMargin = 8;
        maxPowerBox.anchors.topMargin = 8;
        powerInBox.anchors.topMargin = 8;
        powerOutBox.anchors.topMargin = 8;
        temperatureBox.anchors.topMargin = 8;
        portToBasic.start()
    }

    ParallelAnimation{
        id: portToBasic
        running: false

        PropertyAnimation{
            target:titleBackground
            property: "height"
            to:basicTitleBackgroundHeight
            duration: tabTransitionTime
        }

        PropertyAnimation{
            target:powerInBox
            property: "height"
            to:40
            duration: tabTransitionTime
        }

        PropertyAnimation{
            target:portSubtitle
            property: "opacity"
            to:1
            duration: tabTransitionTime
        }

        PropertyAnimation{
            target:chargingRectangle
            property: "opacity"
            to:0
            duration: tabTransitionTime
        }
    }

    Rectangle{
        id:titleBackground
        color:"lightgrey"
        anchors.top: root.top
        anchors.topMargin: 1
        anchors.left:root.left
        anchors.leftMargin: 1
        anchors.right: root.right
        anchors.rightMargin: 1
        height: 50//(2*root.height)/16
        radius:5
        z:1

        Rectangle{
            id:squareBottomBackground
            color:"lightgrey"
            anchors.top:titleBackground.top
            anchors.topMargin:(titleBackground.height)/2
            anchors.left:titleBackground.left
            anchors.right: titleBackground.right
            height: (titleBackground.height)/2
        }

        Text {
            id: portTitle
            text: "foo"
            anchors.horizontalCenter: titleBackground.horizontalCenter
            anchors.verticalCenter: titleBackground.verticalCenter
            font {
                pixelSize: 28
            }

            color: root.portConnected ? "black" : "#bbb"
        }
        Text {
            id: portSubtitle
            text: ""
            anchors.horizontalCenter: titleBackground.horizontalCenter
            anchors.top: portTitle.bottom
            anchors.topMargin: -5
            font {
                pixelSize: 12
            }

            color: "darkGrey"
        }
    }

    PortStatBox{
        id:outputVoltageBox
        anchors.left:root.left
        anchors.leftMargin: 10
        anchors.top: titleBackground.bottom
        anchors.topMargin: 8
        anchors.right: root.right
        anchors.rightMargin: 10
        height:40
        label: "VOLTAGE OUT"
        color:"transparent"
    }

    PortStatBox{
        id:maxPowerBox
        anchors.left:root.left
        anchors.leftMargin: 10
        anchors.top: outputVoltageBox.bottom
        anchors.topMargin: 8
        anchors.right: root.right
        anchors.rightMargin: 10
        height:40
        label: "MAXIMUM POWER"
        unit: "W"
        color:"transparent"
        icon: "../images/icon-max.svg"
    }

    PortStatBox{
        id:powerInBox
        anchors.left:root.left
        anchors.leftMargin: 10
        anchors.top: maxPowerBox.bottom
        anchors.topMargin: 8
        anchors.right: root.right
        anchors.rightMargin: 10
        height:40
        label: "POWER IN"
        unit:"W"
        color:"transparent"
        icon: "../images/icon-voltage.svg"
        visible: !isUSBAPort
    }

    PortStatBox{
        id:powerOutBox
        anchors.left:root.left
        anchors.leftMargin: 10
        anchors.top: powerInBox.bottom
        anchors.topMargin: 8
        anchors.right: root.right
        anchors.rightMargin: 10
        height:40
        label: "POWER OUT"
        unit:"W"
        color:"transparent"
        icon: "../images/icon-voltage.svg"
    }

    PortStatBox{
        id:temperatureBox
        anchors.left:root.left
        anchors.leftMargin: 10
        anchors.top: powerOutBox.bottom
        anchors.topMargin: 8
        anchors.right: root.right
        anchors.rightMargin: 10
        height:40
        label: "TEMPERATURE"
        unit:"°C"
        color:"transparent"
        icon: "../images/icon-temp.svg"
    }

    Rectangle{
        id:chargingRectangle
        anchors.left:root.left
        anchors.top: temperatureBox.bottom
        anchors.topMargin: 3
        anchors.right: root.right
        anchors.rightMargin: 10
        height:20
        opacity: 0
        color:"transparent"

        Text {
            id:chargingText
            text: "CHARGING"
            anchors.left:chargingRectangle.left
            anchors.leftMargin: 10
            anchors.verticalCenter: chargingRectangle.verticalCenter
        }

        RadioButton {
            id: chargingIndicator
            anchors.right:chargingRectangle.right
            anchors.rightMargin: 61
            anchors.verticalCenter: chargingRectangle.verticalCenter
            height:15
            autoExclusive : false
            indicator: Rectangle{
                implicitWidth: 15
                implicitHeight: 15
                x: chargingIndicator.x
                y: chargingIndicator.y
                radius: 7
                color: chargingIndicator.checked ? "green": "white"
                border.color: chargingIndicator.checked ? "black": "grey"
            }
        }
    }

    Rectangle {
        id: connectionContainer
        opacity: 1
        z:1

        anchors {
            top:titleBackground.bottom
            left:root.left
            leftMargin: 2
            right:root.right
            rightMargin: 2
            bottom:root.bottom
            bottomMargin: 2
        }

        Image {
            id: connectionIcon
            source: "../images/icon-usb-disconnected.svg"
            height: connectionContainer.height/4
            width: height * 0.6925
            anchors {
                centerIn: parent
                verticalCenterOffset: -connectionText.font.pixelSize / 2
            }
        }

        Text {
            id: connectionText
            color: "#ccc"
            text: "<b>Port Disconnected</b>"
            anchors {
                top: connectionIcon.bottom
                topMargin: 5
                horizontalCenter: connectionIcon.horizontalCenter
            }
            font {
                pixelSize: 14
            }
        }
    }
}
    /*
    Item {
        id: margins
        anchors {
            fill: parent
            topMargin: 15
            leftMargin: 15
            rightMargin: 0
            bottomMargin: 15
        }

        Item {
            id: statsContainer
            anchors {
                top: margins.top
                bottom: margins.bottom
                right: margins.right
                left: margins.left
            }

            Text {
                id: portTitle
                text: "<b>Port " + portNumber + "</b>"
                font {
                    pixelSize: 25
                }
                anchors {
                    verticalCenter: statsContainer.verticalCenter
                }
                color: root.portConnected ? "black" : "#bbb"
            }

            Button {
                id: showGraphs
                text: "Graphs"
                anchors {
                    bottom: statsContainer.bottom
                    horizontalCenter: portTitle.horizontalCenter
                }
                height: 20
                width: 60
                onClicked: root.showGraph()
            }

            Rectangle {
                id: divider
                width: 1
                height: statsContainer.height
                color: "#ddd"
                anchors {
                    left: portTitle.right
                    leftMargin: 10
                }
            }

            Item {
                id: stats
                anchors {
                    top: statsContainer.top
                    left: divider.right
                    leftMargin: 10
                    right: statsContainer.right
                    bottom: statsContainer.bottom
                }

                Item {
                    id: connectionContainer
                    visible: !root.portConnected

                    anchors {
                        centerIn: parent
                    }

                    Image {
                        id: connectionIcon
                        source: "../images/icon-usb-disconnected.svg"
                        height: stats.height * 0.666
                        width: height * 0.6925
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: -connectionText.font.pixelSize / 2
                        }
                    }

                    Text {
                        id: connectionText
                        color: "#ccc"
                        text: "<b>Port Disconnected</b>"
                        anchors {
                            top: connectionIcon.bottom
                            topMargin: 5
                            horizontalCenter: connectionIcon.horizontalCenter
                        }
                        font {
                            pixelSize: 14
                        }
                    }
                }

                Column {
                    id: column1
                    visible: root.portConnected
                    anchors {
                        verticalCenter: stats.verticalCenter
                    }
                    width: stats.width/2-1
                    spacing: 3

                    PortStatBox {
                        id:advertisedVoltageBox
                        label: "PROFILE"
                        //value: "20"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "V"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:maxPowerBox
                        label: "MAX CAPACITY"
                        //value: "100"
                        icon: "../images/icon-max.svg"
                        portColor: root.portColor
                        unit: "W"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:inputPowerBox
                        label: "POWER IN"
                        //value: "9"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "W"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:outputPowerBox
                        label: "POWER OUT"
                        //value: "7.8"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "W"
                        height: (root.height - 10)/4
                    }

                }

                Column {
                    id: column2
                    visible: root.portConnected
                    anchors {
                        left: column1.right
                        leftMargin: column1.spacing
                        verticalCenter: column1.verticalCenter
                    }
                    spacing: column1.spacing
                    width: stats.width/2 - 2

                    PortStatBox {
                        id:outputVoltageBox
                        label: "VOLTAGE OUT"
                        //value: "20.4"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "V"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:portTemperatureBox
                        label: "TEMPERATURE"
                        //value: "36"
                        icon: "../images/icon-temp.svg"
                        portColor: root.portColor
                        unit: "°C"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:efficencyBox
                        label: "EFFICIENCY"
                        //value: "92"
                        icon: "../images/icon-efficiency.svg"
                        portColor: root.portColor
                        unit: "%"
                        height: (root.height - 10)/4
                    }
                }
            }
        }
    }
}
*/
