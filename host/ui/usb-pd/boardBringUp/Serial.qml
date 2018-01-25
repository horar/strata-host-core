import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle{
    id:serialTab
    objectName: "serialTab"
    opacity: 0
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
        x: 65
        y: 28
        width: 755
        height: 75

        background: Rectangle {
             color: "lightgray"
         }

        currentIndex: swipeView.currentIndex
       // anchors { middle: parent.middle}
        transform: Rotation{ angle: 90  }
        TabButton { id: tabButton; x: 0; y: -22; width: 286; height: 63; font.bold: true; font.pointSize: 19;spacing: 9;
            Text{
                id: i2c
                y: 50
                anchors.centerIn: parent.Center
                text: "I2C"
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: -39
                font.pointSize: 14
                font.bold: true
                z:2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                transform: Rotation{ angle: -90 }
            }
            checkable: true
            checked: false
            onClicked: checked ? i2c.color = "green" : i2c.color = "black"
        }

        TabButton { x: 272; y: -15; width: 286; height: 63; font.bold: true;font.pointSize: 19
            Text{
                id: spi
                y: 50
//                anchors.centerIn: parent.Center
                text: "SPI"
                anchors.left: parent.horizontalCenter
                font.pointSize: 14
                font.bold: true
                z:2
               //horizontalAlignment: Text.AlignHCenter
                //verticalAlignment: Text.AlignVCenter
                transform: Rotation{ angle: -90 }
            }
            checkable: true
            checked: false


        }
        TabButton { x: 533; y: -18; width: 287
            height: 63
            Text{
                id: uART
                x: 81
                y: 63
                anchors.centerIn: parent.Center
                text: "UART"
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: -41
                font.pointSize: 14
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
