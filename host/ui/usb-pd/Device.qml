import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import "framework"

Rectangle {
    id: device
    height: parent.height*.4
    width: parent.width *.75 //allow a little space on the right of the screen
    color:"transparent"

    property alias image: deviceOutline
    property int verticalOffset: 0
    property int port_number: 0

    anchors { left:parent.left
        verticalCenter: parent.verticalCenter
        verticalCenterOffset: verticalOffset }

    Image {
        id:deviceOutline
        source: "./images/deviceOutline.svg"
        anchors.fill:parent
        mipmap: true
    }

    DropShadow {
        anchors.fill: deviceOutline
        horizontalOffset: 3
        verticalOffset: 6
        radius: 12.0
        samples: 24
        color: "#60000000"
        source: deviceOutline
    }

//    SGRadioButton {
//        id: radioButtonList
//        anchors { centerIn:  parent; topMargin: 20 }
//        width : 100; height: 150
//        port_number : device.port_number
//    }


}
