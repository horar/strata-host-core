import QtQuick 2.7
import tech.spyglass.ImplementationInterfaceBinding 1.0
import QtQuick.Controls 1.4
import "../framework"


Rectangle {
    id: container
    color: "transparent"
    width:container.width; height:container.height
    property point theDialogStartPosition;
    property int portNumber:0;

    property double outputVoltage: 0;
    property double targetVoltage: 0;
    property double portCurrent: 0;
    property double portTemperature: 0;
    property double portPower: 0;
    property double portNegotiatedContractVoltage:0;
    property double portNegotiatedContractAmperage:0;
    property double portMaximumPower:0;

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

        onPortNegotiatedContractChanged:{
            if( portNumber === port ) {
                container.portNegotiatedContractVoltage = voltage;
                container.portNegotiatedContractAmperage = maxCurrent;
            }
        }

        onPortNegotiatedVoltageChanged:{
            if( portNumber === port ) {
                container.portNegotiatedContractVoltage = voltage;
                //console.log("new negotiated voltage:", voltage);
            }
        }

        onPortNegotiatedCurrentChanged:{
            if( portNumber === port ) {
                container.portNegotiatedContractAmperage = current;
                //console.log("new negotiated current:", current);
            }
        }

        onPortMaximumPowerChanged:{
            if( portNumber === port ) {
                container.portMaximumPower = watts;
                //console.log("new port max power:", watts);
            }
        }
    }

    property alias power: powerValue;

    Column {
        spacing: 5
        anchors { top: container.top; //topMargin: parent.height*.15
            bottom:container.bottom}

        SGIconListItem {
            id: negotiatedValues
            width:container.width/4; height: width
            icon: "../images/icons/leftArrow.svg"
            text: container.portNegotiatedContractVoltage.toFixed(0) +" V," + container.portNegotiatedContractAmperage.toFixed(1)+" A," +
                 container.portNegotiatedContractVoltage.toFixed(0) * container.portNegotiatedContractAmperage.toFixed(1)+" W"

            MouseArea {
                anchors { fill: parent }
                onClicked: { outputVoltageAndCurrentGraph.open() }
            }
        }

        SGIconListItem {
            id:  maximumPowerValue
            width: container.width/4; height: width
            icon: "../images/icons/maxPowerIcon.svg"
            text: container.portMaximumPower.toFixed(1) + " W"

        }

        SGIconListItem {
            id: currentVoltageValue
            width: container.width/4; height: width
            icon: "../images/icons/rightArrow.svg"
            text: container.outputVoltage.toFixed(1) + " V"

            MouseArea {
                anchors { fill: parent }
                onClicked: { targetVoltageGraph.open() }
            }

        }
        SGIconListItem {
            id: powerValue
            width:container.width/4; height: width
            icon: "../images/icons/voltageIcon.svg"
            text: container.portPower.toFixed(1)+" W"

            MouseArea {
                anchors { fill: parent }
                onClicked: { portPowerGraph.open() }
            }

        }
        SGIconListItem {
            id: temperatureValue
            width:container.width/4; height: width
            icon: "../images/icons/temperatureIcon.svg"
            text: container.portTemperature.toFixed(0) +" °C"

            MouseArea {
                anchors { fill: parent }
                onClicked: { portTemperatureGraph.open()
                }
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
        efficencyLabel: false
        powerMessageVisible: false;
        graphVisible: true;
        overlimitVisibility: false;
        underlimitVisibility: false;

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
        efficencyLabel: false
        powerMessageVisible: false;
        graphVisible: true;
        overlimitVisibility: false;
        underlimitVisibility: false;
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
        efficencyLabel: false
        powerMessageVisible: false;
        graphVisible: true;
        overlimitVisibility: false;
        underlimitVisibility: false;
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
        efficencyLabel: false
        powerMessageVisible: false;
        graphVisible: true;
        overlimitVisibility: true;
        underlimitVisibility: false;
    }

}
