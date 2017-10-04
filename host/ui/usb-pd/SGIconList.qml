import QtQuick 2.0
import "framework"

Rectangle {
    id: container
    color: "transparent"
    //color: "gray"
    width:container.width; height:container.height


    Column {
        spacing: 8
        anchors { top: container.top; topMargin: parent.height*.15
            bottom:container.bottom}

        SGIconStatistic {
            id: negotiatedValues
            width:container.width/4; height: width
            source: "leftArrow.svg"
            color: "transparent"

            MouseArea {
                anchors { fill: parent }
                onClicked: { voltageAndCurrentGraph.open() }
            }

            SGIconLabel {
                width:container.width/0.99; height: negotiatedValues.width
                anchors{ left:negotiatedValues.right}
                text: "0 V, 0 A"
            }
        }
        SGIconStatistic {
            id: currentVoltageValue
            width: container.width/4; height: width
            source: "rightArrow.svg"
            color: "transparent"

            MouseArea {
                anchors { fill: parent }
                onClicked: { voltageAndCurrentGraph.open() }
            }

            SGIconLabel {
                width:container.width/0.99; height:currentVoltageValue.width
                anchors{ left:currentVoltageValue.right ;  }
                text: "0 V"
            }
        }
        SGIconStatistic {
            id: powerValue
            width:container.width/4; height: width
            source: "voltageIcon.svg"
            color: "transparent"

            MouseArea {
                anchors { fill: parent }
                onClicked: { portPowerAndTemperatureGraph.open() }
            }

            SGIconLabel {
                width:container.width/0.99; height:powerValue.width
                anchors{ left:powerValue.right}
                text: "0 W"
            }
        }
        SGIconStatistic {
            id: temperatureValue
            width:container.width/4; height: width
            source: "temperatureIcon.svg"
            color: "transparent"

            MouseArea {
                anchors { fill: parent }
                onClicked: { portPowerAndTemperatureGraph.open() }
            }

            SGIconLabel {
                width:container.width/0.99; height: temperatureValue.width
                anchors{ left:temperatureValue.right }
                text: "0 °C"
            }
        }
    }

    SGPopup {
        id: voltageAndCurrentGraph
        x: temperatureValue.x - temperatureValue.width ; y: temperatureValue.y - temperatureValue.height
        width: parent.width * 5 ; height: parent.height * 2
        contentItem: SGLineGraph { title: "Device Voltage and Current" }
    }

    SGPopup {
        id: portPowerAndTemperatureGraph
        x: temperatureValue.x - temperatureValue.width ; y: temperatureValue.y - temperatureValue.height
        width: parent.width * 5 ; height: parent.height * 2
        contentItem: SGLineGraph { title: "Port Power and Temperature" }
    }
}
