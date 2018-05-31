import QtQuick 2.0
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
//import tech.spyglass.ImplementationInterfaceBinding 1.0

GroupBox {
    property var output_voltages: [5, 12, 15, 20]
    property int port_number: 0
//    Connections {
//        target: implementationInterfaceBinding

//        onUsbCPortStateChanged: {
//            if( port === 1 ) {
//                if(value == false)
//                    button.checked = true;
//            }
//        }
//    }
    //set flat to be true, and fill with a white rectangle to hide the GroupBox background
    flat:true
    Rectangle {
        anchors.fill:parent
        color: "white"
        border.color: "white"
    }

    ColumnLayout {
        anchors { centerIn: parent }


        ExclusiveGroup { id: tabPositionGroup }
        RadioButton {
            text: "5 V"
            id: button
            checked: true
            exclusiveGroup: tabPositionGroup

            onClicked: {
//                implementationInterfaceBinding.setOutputVoltageVBUS(port_number,5);
            }
        }
        RadioButton {
            text: "9 V"
            exclusiveGroup: tabPositionGroup
            onClicked: {
//                implementationInterfaceBinding.setOutputVoltageVBUS(port_number,9);
            }
        }
        RadioButton {
            text: "12 V"
            exclusiveGroup: tabPositionGroup
            onClicked: {
//                implementationInterfaceBinding.setOutputVoltageVBUS(port_number,12);
            }
        }
        RadioButton {
            text: "15 V"
            exclusiveGroup: tabPositionGroup
            onClicked: {
//                implementationInterfaceBinding.setOutputVoltageVBUS(port_number,15);
            }
        }

    }
}
