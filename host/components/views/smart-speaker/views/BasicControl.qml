import QtQuick 2.10
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9 as Widget09
import "../views/basic-partial-views"

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 900
    minimumWidth: 1300
    scrollBarColor: hightlightColor

    property string borderColor: "#002C74"
    property string backgroundColor: "#91ABE1"
    property string hightlightColor: "#F8BB2C"

    Rectangle {
        id: container
        parent: root.contentItem
        color:borderColor
        anchors {
            fill: parent
        }

        Rectangle{
            id:deviceBackground
            color:backgroundColor
            radius:10
            height:(7*parent.height)/16
            anchors.left:parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top:parent.top
            anchors.topMargin: 12
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 12
        }

        //----------------------------------------------------------------------------------------
        //                      Views
        //----------------------------------------------------------------------------------------



        Text{
            id:boardName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: 10
            text:"Voice User Interface"
            color:"black"
            font.pixelSize: 75
        }
        Row{
            id: vuiRow
            anchors.top:boardName.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            VoiceUIView{
                id:voiceUIView
                height:75
                width:825
            }
        }

        Row{
            id:mixerRow
            anchors.top:vuiRow.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            MixerView{
                id:mixerView
                height:500
                width:150
            }


            EqualizerView{
                id:eqView
                height:500
                width:660
            }
        }

        //bottom row
        Row{
            anchors.top:mixerRow.bottom
            anchors.topMargin: 30
            anchors.left: mixerRow.left
            spacing: 20

            BluetoothView{
                id:bluetoothView
                height:100
                width:270
            }

            PlaybackControlView{
                id:playbackControlView
                height:100
                width:250
            }

            AmplifierView{
                id:amplifierView
                height:100
                width:270
            }

        }




    }
}

