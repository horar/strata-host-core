import QtQuick 2.10
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
//import "qrc:/views/smart-speaker/sgwidgets"
import "../views/basic-partial-views"

Rectangle {
    id: root
    anchors.fill:parent
    color:"dimgrey"

    property string textColor: "white"
    property string secondaryTextColor: "grey"
    property string windowsDarkBlue: "#2d89ef"
    property string backgroundColor: "#FF2A2E31"
    property string transparentBackgroundColor: "#002A2E31"
    property string dividerColor: "#3E4042"
    property string switchGrooveColor:"dimgrey"
    property int leftSwitchMargin: 40
    property int rightInset: 50
    property int leftScrimOffset: 310
    property bool pulseColorsLinked: false

    property real widthRatio: root.width / 1200


    //----------------------------------------------------------------------------------------
    //                      Views
    //----------------------------------------------------------------------------------------


    Rectangle{
        id:deviceBackground
        color:backgroundColor
        radius:10
        height:(7*parent.height)/16
        anchors.left:root.left
        anchors.leftMargin: 12
        anchors.right: root.right
        anchors.rightMargin: 12
        anchors.top:root.top
        anchors.topMargin: 12
        anchors.bottom:root.bottom
        anchors.bottomMargin: 12


        Text{
            id:boardName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            text:"smart speaker"
            color:"white"
            font.pixelSize: 75
        }

        ParametricEQView{
            id:eqView
            height:500
            width:400
            anchors.left:parent.left
            anchors.leftMargin:50
            anchors.top:boardName.bottom
            anchors.topMargin:50

        }
        CrossoverFrequencyView{
            id:crossoverView
            height:500
            width:100
            anchors.left: eqView.right
            anchors.leftMargin: 20
            anchors.verticalCenter: eqView.verticalCenter

            crossoverFrequency:200
        }

        MixerView{
            id:mixerView
            height:500
            width:600
            anchors.left:crossoverView.right
            anchors.leftMargin:20
            anchors.verticalCenter: eqView.verticalCenter
        }

        //bottom row

        BluetoothView{
            id:bluetoothView
            height:200
            width:200
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.top: eqView.bottom
            anchors.topMargin:50
        }

        WirelessView{
            id:wirelessView
            height:200
            width:200
            anchors.left: bluetoothView.right
            anchors.leftMargin: 50
            anchors.verticalCenter: bluetoothView.verticalCenter

            networkName:"network"
        }

        PortInfo{
            id:portInfoView
            height:200
            anchors.left: wirelessView.right
            anchors.leftMargin: 50
            anchors.verticalCenter: bluetoothView.verticalCenter
        }

        InputVoltageView{
            id:inputVoltageView
            height:200
            width:200
            anchors.left: portInfoView.right
            anchors.leftMargin: 50
            anchors.verticalCenter: bluetoothView.verticalCenter

            inputVoltage:"20"
        }
    }

}
