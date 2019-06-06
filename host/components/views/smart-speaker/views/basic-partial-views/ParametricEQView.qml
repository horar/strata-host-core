import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12

Rectangle {
    id: root
    width: 200
    height:200
    color:"dimgray"
    opacity:1
    radius: 10

    property int bandWidth: root.width/6

    Text{
        id:eqText
        text:"Parametric EQ"
        color:"white"
        font.pixelSize: 36
        anchors.top:parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row{
        id:dialRow1
        anchors.top:eqText.bottom
        //anchors.bottom:parent.bottom
        //anchors.bottomMargin:50
        width:parent.width
        height:100
        spacing: 20

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
            inputMode: "Vertical"
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }
    }

    Row{
        id:dialRow2
        anchors.top:dialRow1.bottom
        width:parent.width
        spacing: 20
        height:100

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
            inputMode: "Vertical"
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }
    }

    Row{
        id:dialRow3
        anchors.top:dialRow2.bottom
        width:parent.width
        spacing: 20
        height:100

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
            inputMode: "Vertical"
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }

        Dial {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 50
            width:50
        }
    }
    Row{
        id:dialRow10
        anchors.top: dialRow1.bottom

//        Label {
//            text: "Volume"
//            Layout.alignment: Qt.AlignHCenter
//            //Layout.topMargin: 12
//            color:"white"
//            width:50
//        }




    }

}
