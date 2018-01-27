import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle{
    id:serialTab
    objectName: "serialTab"
    opacity: 1
    anchors.fill:parent



    //    Text{
    //        anchors.centerIn: parent
    //        text:"serial"
    //        font.pointSize: 100
    //        font.family: "helvetica"
    //    }

    SwipeView {
        id: swipeView
        anchors {fill: parent}
        width: parent.width
        currentIndex: tabBar.currentIndex
        SerialInterfaceI2C { id: pageI2C}
        SerialInterfaceSPI { id: pageSPI}
        SerialInterfaceUART { id: pageUART}


    }

    TabBar {
        id: tabBar
        x: 71;y: 0
        width: parent.width
        height: parent.height
        anchors.bottomMargin: 0
        anchors.bottom: parent.bottom

        background: Rectangle {
            color: "lightgray"
        }

        currentIndex: swipeView.currentIndex
        // anchors { middle: parent.middle}
        transform: Rotation{ angle: 90  }
        TabButton { id: tabButton; x: 0; y: 9; width: 286; height: 74; font.bold: true; font.pointSize: 19;spacing: 9;
            Text{
                id: i2c
                y: 54
                anchors.centerIn: parent.Center
                text: "I2C"
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: -23
                font.pointSize: 12
                font.bold: true
                z:2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                transform: Rotation{ angle: -90 }
            }
            checkable: true
            checked: false
        }

        TabButton { x: 292; y: 0; width: 286; height: 74; font.bold: true;font.pointSize: 19
            Text{
                id: spi
                y: 64
                //                anchors.centerIn: parent.Center
                text: "SPI"
                anchors.leftMargin: 0
                anchors.left: parent.horizontalCenter
                font.pointSize: 12
                font.bold: true
                z:2
                //horizontalAlignment: Text.AlignHCenter
                //verticalAlignment: Text.AlignVCenter
                transform: Rotation{ angle: -90 }
            }
            checkable: true
            checked: false


        }
        TabButton { x: 579; y: 0; width: 287
            height: 74
            Text{
                id: uART
                x: 81
                y: 65
                anchors.centerIn: parent.Center
                text: "UART"
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 29
                font.pointSize: 11
                font.bold: true
                z:2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                transform: Rotation{ angle: -90 }


            }
            checkable: true
            checked: false




        }



    }


}
