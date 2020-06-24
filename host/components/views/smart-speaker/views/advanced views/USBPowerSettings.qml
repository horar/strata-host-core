import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"

    property bool isConnected: platformInterface.usb_pd_port_connect.connection_state === "connected"

    Rectangle{
        id:notConnectedScrim
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.bottom:parent.bottom
        anchors.right:parent.right
        color:"transparent"
        visible:!isConnected
        Text{
            id:notConnectedText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: parent.height/8
            text:"not \nconnected"
            horizontalAlignment: Text.AlignHCenter
            color:hightlightColor
            font.pixelSize: 72
            opacity:.75
        }
    }

    Text{
        id:sinkCapLabel
        font.pixelSize: 18
        anchors.left:parent.left
        anchors.leftMargin:10
        anchors.top: parent.top
        text:"Sink capabilities:"
        color: "black"
        visible:isConnected
    }

    SGSegmentedButtonStrip {
        id: sinkCapSegmentedButton
        labelLeft: false
        anchors.left: sinkCapLabel.right
        anchors.leftMargin: 10
        anchors.verticalCenter: sinkCapLabel.verticalCenter
        textColor: "#444"
        activeTextColor: "white"
        radius: buttonHeight/2
        buttonHeight: 20
        exclusive: true
        buttonImplicitWidth: 50
        hoverEnabled:false
        visible:isConnected

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            SGSegmentedButton{
                text: qsTr("5V 3A")
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                //height:40
                onClicked: {}


            }

            SGSegmentedButton{
                text: qsTr("7V 3A")
                activeColor:buttonSelectedColor
                inactiveColor: "white"
                //height:40
                onClicked: {}
            }
            SGSegmentedButton{
                text: qsTr("9V 3A")
                activeColor:buttonSelectedColor
                inactiveColor: "white"
                //height:40
                onClicked: {}
            }
            SGSegmentedButton{
                text: qsTr("12V 3A")
                activeColor:buttonSelectedColor
                inactiveColor: "white"
                //height:40
                onClicked: {}
            }
        }
    }
}
