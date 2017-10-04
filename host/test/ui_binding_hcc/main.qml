import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick 2.6
import QtQuick.Controls 2.0
import io.qt.ImplementationInterfaceBinding 1.0

ApplicationWindow {
    id: root
    width: 300
    height: 480
    visible: true

    ImplementationInterfaceBinding {
        id: implementationInterfaceBinding

        onPlatformIdChanged: {
            console.log("on signal")
            currentLabel3.text=implementationInterfaceBinding.Id
        }
        onInputVoltagePort0Changed: {
            voltageLabel1.text=implementationInterfaceBinding.inputVoltagePort0
        }
        onOutputCurrentPort0Changed: {
            currentLabel1.text=implementationInterfaceBinding.outputCurrentPort0
        }
        onPowerPort0Changed: {
            power2.text=implementationInterfaceBinding.powerPort0
        }
        onOutputVoltagePort0Changed: {
            voltageLabel3.text=implementationInterfaceBinding.outputVoltagePort0
        }
        onTimeChanged: {
            currentLabel5.text=implementationInterfaceBinding.time
        }

        onPlatformStateChanged: {
            currentLabel7.text=implementationInterfaceBinding.platformState
        }
    }

    Label {
        id: voltageLabel
        x: 7
        y: 186
        width: 90
        height: 15
        text: "input Voltage"
    }

    Label {
        id: voltagePort
        x: 118; y: 186
        width: 51; height: 15
        text: "port0"
    }

    Label {
        id: voltageLabel1
        x: 208; y: 186
        width: 51; height: 15
    }

    Label {
        id: currentLabel
        x: 7
        y: 151
        width: 65
        height: 15
        text: "Current"
    }

    Label {
        id: currentPort
        x: 118
        y: 151
        width: 51
        height: 15
        text: "port0"
    }

    Label {
        id: currentLabel1
        x: 208
        y: 151
        width: 51
        height: 15
    }

    Label {
        id: currentLabel2
        x: 7
        y: 101
        width: 65
        height: 15
        text: "PlatformId"
    }

    Label {
        id: currentLabel3
        x: 118
        y: 101
        width: 51
        height: 15
        text: ""
    }

    Label {
        id: currentLabel4
        x: 7
        y: 287
        width: 65
        height: 15
        text: "Time"
    }

    Label {
        id: currentLabel5
        x: 118
        y: 287
        width: 51
        height: 15
        text: ""
    }

    Label {
        id: power
        x: 7
        y: 253
        width: 65
        height: 15
        text: "Power"
    }

    Label {
        id: power1
        x: 118
        y: 253
        width: 51
        height: 15
        text: "port0"
    }

    Label {
        id: power2
        x: 208
        y: 253
        width: 51
        height: 15
    }

    Label {
        id: voltageLabel2
        x: 7
        y: 223
        width: 90
        height: 15
        text: "output voltage"
    }

    Label {
        id: voltagePort1
        x: 118
        y: 223
        width: 51
        height: 15
        text: "port0"
    }

    Label {
        id: voltageLabel3
        x: 208
        y: 223
        width: 51
        height: 15
    }

    Button {
        id: button
        x: 81
        y: 357
        text: qsTr("send ")

        onPressed: {

            implementationInterfaceBinding.request;
        }
    }

    Button {
        id: button1
        x: 81
        y: 417
        text: qsTr("send_again")
        onPressed: {

            implementationInterfaceBinding.request;
        }
    }

    Label {
        id: currentLabel6
        x: 7
        y: 63
        width: 65
        height: 15
        text: "Con State"
    }

    Label {
        id: currentLabel7
        x: 118
        y: 64
        width: 51
        height: 14
    }

}
