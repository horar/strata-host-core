import QtQuick 2.0
import "framework"

Rectangle {
    id: container
    color: "transparent"
    width:container.width; height:container.height
    //visible: false
    property point theDialogStartPosition;

//    SGDisconnectMessage {
//        id: disconnectMessage
//        //visible: false
//        width: 50; height : 50
//        anchors.centerIn: parent
//    }
    function message()
    {
        console.log("hi");
      // disconnectMessage.visible = true;

    }

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
                onClicked: { voltageAndCurrentGraph.open()
                    //in order to get the dialog to appear out of the voltage icon, we have to know where that icon is
                    //located in root QML item coordinates.
                    //theDialogStartPosition = negotiatedValues.mapFromItem(null, negotiatedValues.x, negotiatedValues.y)
                }

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
        startPositionX: theDialogStartPosition.x
        startPositionY: theDialogStartPosition.y
        width: boardRect.width/0.8 ;height: boardRect.height/2
        leftMargin : 30
        rightMargin : 30
        topMargin: 30
        bottomMargin:30
        axisXLabel: "Time (S)"
        axisYLabel: "Voltage (V)"
        axisY2Label: "Current (A)"
        graphTitle: "Device Voltage and Current"
        inVariable1Name:  "Voltage"
        inVariable2Name:  "Current"
        inVariable1Color: "blue"
        inVariable2Color: "red"

    }

    SGPopup {
        id: portPowerAndTemperatureGraph
        startPositionX: theDialogStartPosition.x
        startPositionY: theDialogStartPosition.y
        width: boardRect.width/0.8 ;height: boardRect.height/2
        leftMargin : 30
        rightMargin : 30
        topMargin: 30
        bottomMargin:30
        graphTitle: "Port Power and Temperature"
        axisXLabel: "Time (S)"
        axisYLabel: "Power (W)"
        axisY2Label: "Temperature (C)"
        inVariable1Name:  "Power"
        inVariable2Name:  "Temperature"
        inVariable1Color: "blue"
        inVariable2Color: "red"
    }

}
