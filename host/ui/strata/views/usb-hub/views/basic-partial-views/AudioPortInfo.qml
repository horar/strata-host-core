import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/views/usb-pd-multiport/sgwidgets"

Rectangle {
    id: root

    property bool portConnected: true
    property color portColor: "#30a2db"
    property int portNumber: 1
    property alias portName: portTitle.text

    property int basicTitleBackgroundHeight: 50//(2*root.height)/16;
    property int advancedTitleBackgroundHeight: advancedAudioPortHeight/4
    signal showGraph()

    color: "lightgoldenrodyellow"
    radius: 5
    border.color: "black"
    width: 150

    onPortConnectedChanged:{
        if (portConnected){
            hideStats.start()
            audioDataTimer.start()
        }
         else{
            showStats.start()
            audioDataTimer.stop()
        }
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

    function transitionToAdvancedView(){
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
            target:volumneText
            property: "opacity"
            to:1
            duration: tabTransitionTime
        }
        PropertyAnimation{
            target:volumeSlider
            property: "opacity"
            to:1
            duration: tabTransitionTime
        }
    }

    function transitionToBasicView(){
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
            target:volumneText
            property: "opacity"
            to:0
            duration: tabTransitionTime
        }
        PropertyAnimation{
            target:volumeSlider
            property: "opacity"
            to:0
            duration: tabTransitionTime
        }


    }

    Timer{
        //generate sample data to drive the audio graph when a
        //device is connected. This is for testing, and will be removed when real audio data is available
        id:audioDataTimer
        interval: 500
        repeat: true
        onTriggered: {
            var sampleValue = Math.random();
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
        height:basicTitleBackgroundHeight
        radius:5

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
            anchors {
                verticalCenter: statsContainer.verticalCenter
            }
            color: root.portConnected ? "black" : "#bbb"
        }
    }

    Image{
        id:placeholderImage
        source: "../images/soundwave.png"
        anchors.verticalCenter: root.verticalCenter
        anchors.left:root.left
        anchors.right:root.right
        fillMode:Image.PreserveAspectFit
    }

    AudioGraph{
        id:audioWaveform
        visible: false
    }

    Text{
        id:volumneText
        text:"VOLUME:"
        anchors.top: placeholderImage.bottom
        anchors.left: root.left
        anchors.right:root.right
        anchors.leftMargin: 10
        opacity:0
    }

    SGSlider{
        id:volumeSlider
        startLabel: ""
        endLabel: ""
        anchors.top: volumneText.bottom
        anchors.left: root.left
        anchors.leftMargin: 10
        anchors.right:root.right
        anchors.rightMargin: 10
        opacity:0
    }

    Rectangle {
        id: connectionContainer
        opacity: 1

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
