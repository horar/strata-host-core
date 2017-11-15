import QtQuick 2.7
import "framework"
import "sgLiveGraph"
import tech.spyglass.ImplementationInterfaceBinding 1.0
import QtQuick.Controls 1.4



Rectangle {
    id: container
    color: "transparent"
    width:container.width; height:container.height
    //visible: false
    property point theDialogStartPosition;
    property int portNumber:0;

    property double outputVoltage: 0;
    property double targetVoltage: 0;
    property double portCurrent: 0;
    property double portTemperature: 0;
    property double portPower: 0;


    Label {
        id: disconnectMessage
        text: " No connected
        device"
        opacity: 0.0
        anchors.centerIn: parent
    }

    // Values are being Signalled from ImplementationInterfaceBinding.cpp
    Connections {
        target: implementationInterfaceBinding

        // output voltage
        onPortOutputVoltageChanged: {
            if( portNumber === port ) {
                container.outputVoltage = value;
            }
        }

        // target voltage
        onPortTargetVoltageChanged: {
            if( portNumber === port ) {
                container.targetVoltage = value;
            }
        }

        // port current
        onPortCurrentChanged: {
            if( portNumber === port ) {
                container.portCurrent = value;
            }
        }

        // port temperature
        onPortTemperatureChanged: {
            if( portNumber === port ) {
                container.portTemperature = value;
            }
        }

        // port power
        onPortPowerChanged: {
            if( portNumber === port ) {
                container.portPower = value;
            }
        }
        onUsbCPortStateChanged: {

            if( portNumber === port ) {
                if (value == true) {
                    console.log("USB-PD Connected");
                      negotiatedValues.opacity = 1.0;
                      currentVoltageValue.opacity = 1.0;
                      powerValue.opacity = 1.0;
                      temperatureValue.opacity = 1.0;
                      targetVoltage.opacity = 1.0;
                      outputVoltage.opacity = 1.0;
                      portPower.opacity = 1.0;
                      portTemperature.opacity = 1.0;
                      disconnectMessage.opacity = 0.0;
                }
                else {
                    console.log("USB-PD Disconnected");
                    negotiatedValues.opacity = 0.0;
                    currentVoltageValue.opacity = 0.0;
                    powerValue.opacity = 0.0;
                    temperatureValue.opacity = 0.0;
                    targetVoltage.opacity = 0.0;
                    outputVoltage.opacity = 0.0;
                    portPower.opacity = 0.0;
                    portTemperature.opacity = 0.0;
                    disconnectMessage.opacity = 1.0;
                }
            }
        }


    }

    property alias power: powerValue;

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
                onClicked: { outputVoltageAndCurrentGraph.open()
                    //in order to get the dialog to appear out of the voltage icon, we have to know where that icon is
                    //located in root QML item coordinates.
                    //theDialogStartPosition = negotiatedValues.mapFromItem(null, negotiatedValues.x, negotiatedValues.y)
                }

            }

            SGIconLabel {
                id:targetVoltage
                width:container.width/0.99; height: negotiatedValues.width
                anchors{ left:negotiatedValues.right}
                text: container.targetVoltage.toFixed(1) +" V   "//+ container.portCurrent.toFixed(1)+" A"
                portNumber: container.portNumber;

            }
        }

        SGIconStatistic {
            id: currentVoltageValue
            width: container.width/4; height: width
            source: "rightArrow.svg"
            color: "transparent"

            MouseArea {
                anchors { fill: parent }
                onClicked: { targetVoltageGraph.open() }
            }

            SGIconLabel {
                id: outputVoltage
                width:container.width/0.99; height:currentVoltageValue.width
                anchors{ left:currentVoltageValue.right ;  }
                text: container.outputVoltage.toFixed(1) + " V"
                portNumber: container.portNumber;
            }
        }
        SGIconStatistic {
            id: powerValue
            width:container.width/4; height: width
            source: "voltageIcon.svg"
            color: "transparent"

            MouseArea {
                anchors { fill: parent }
                onClicked: { portPowerGraph.open() }
            }

            SGIconLabel {
                id: portPower
                width:container.width/0.99; height:powerValue.width
                anchors{ left:powerValue.right}
                text: container.portPower.toFixed(1)+" W"
                portNumber: container.portNumber;
            }
        }
        SGIconStatistic {
            id: temperatureValue
            width:container.width/4; height: width
            source: "temperatureIcon.svg"
            color: "transparent"

            MouseArea {
                anchors { fill: parent }
                onClicked: { portTemperatureGraph.open()
                }
            }

            SGIconLabel {
                id: portTemperature
                width:container.width/0.99; height: temperatureValue.width
                anchors{ left:temperatureValue.right }
                text: container.portTemperature.toFixed(0) +" °C"
                portNumber: container.portNumber;
            }
        }
}

    SGPopup {
        id: outputVoltageAndCurrentGraph
        startPositionX: theDialogStartPosition.x
        startPositionY: theDialogStartPosition.y
        width: boardRect.width/0.8 ;height: boardRect.height/2
        leftMargin : 30
        rightMargin : 30
        topMargin: 30
        bottomMargin:30
        axisXLabel: "Time (S)"
        axisYLabel: "Voltage (V)"
        chartType: "Target Voltage"
        portNumber: container.portNumber

    }
    SGPopup {
        id: targetVoltageGraph
        startPositionX: theDialogStartPosition.x
        startPositionY: theDialogStartPosition.y
        width: boardRect.width/0.8 ;height: boardRect.height/2
        leftMargin : 30
        rightMargin : 30
        topMargin: 30
        bottomMargin:30
        axisXLabel: "Time (S)"
        axisYLabel: "Voltage (V)"
        chartType: "Output Voltage"
        portNumber: container.portNumber
    }

    SGPopup {
        id: portPowerGraph
        startPositionX: theDialogStartPosition.x
        startPositionY: theDialogStartPosition.y
        width: boardRect.width/0.8 ;height: boardRect.height/2
        leftMargin : 30
        rightMargin : 30
        topMargin: 30
        bottomMargin:30
        axisXLabel: "Time (S)"
        axisYLabel: "Power (W)"
        chartType: "Port Power"
        portNumber: container.portNumber
    }

    SGPopup {
        id: portTemperatureGraph
        startPositionX: theDialogStartPosition.x
        startPositionY: theDialogStartPosition.y
        width: boardRect.width/0.8 ;height: boardRect.height/2
        leftMargin : 30
        rightMargin : 30
        topMargin: 30
        bottomMargin:30
        axisXLabel: "Time (S)"
        axisYLabel: "Temperature (C)"
        chartType: "Port Temperature"
        portNumber: container.portNumber
    }

}
