import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

ApplicationWindow {
    visible: true
    width: 1200
    height: 900
    title: qsTr("BUBU Interface")

//    SerialInterfaceI2C {
//        id: serial
//        width: parent.width; height: parent.height;

//    }

//    SerialInterfaceUART {
//        x: 9
//        y: 0

//        width: parent.width
//        height: parent.height

//    }


//    SerialInterfaceSPI {
//        x: 0
//        y: 0
//                width: parent.width
//                height: parent.height

//    }
    GPIOConfiguration {
        width: parent.width
        height: parent.height
    }
}
