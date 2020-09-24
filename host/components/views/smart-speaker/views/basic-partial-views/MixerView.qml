import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    width: 200
    height:200
    color:backgroundColor
    opacity:1
    radius: 10

    property int channelWidth: root.width * .2
    property color grooveColor: "#353637"
    property color grooveFillColor: "#E4E4E4"
    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"

    Text{
        id:mixerText
        text:"Volume"
        color:"black"
        font.pixelSize: 36
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }


    Row{
        id:sliderRow
        anchors.top:mixerText.bottom
        anchors.bottom:parent.bottom
        anchors.bottomMargin:50
        anchors.leftMargin:25
        //anchors.right: parent.right
        anchors.left:parent.left



        ColumnLayout {
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Label {
                text: "42 dB"
                color:accentColor
                Layout.fillHeight: true
            }
            Label {
                text: "21 dB"
                color:accentColor
                Layout.fillHeight: true
            }
            Label {
                text: "0 dB"
                color:accentColor
                Layout.fillHeight: true
            }
            Label {
                text: "-21 dB"
                color:accentColor
                Layout.fillHeight: true
            }
            Label {
                text: "-42 dB"
                color:accentColor
                Layout.fillHeight: true
            }
        }

        SGSlider {
            id:master
            from: -42
            value: {
                if (!masterMuteButton.checked)
                    return platformInterface.volume.master
                }
            to: 42
            stepSize: 5
            snapMode: Slider.SnapAlways
            live: false //done to test throttling of messages
            showInputBox: false
            showLabels: false
            showToolTip: false
            grooveColor: root.grooveColor
            fillColor: hightlightColor


            orientation: Qt.Vertical
            anchors.top: parent.top
            width:channelWidth
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 25

            onMoved:{
                //send the new value to the platformInterface
                console.log("sending new master volume",master.value)
                platformInterface.set_volume.update(master.value);
            }
        }  //slider
    } //row

    Row{
        id:textBoxRow
        anchors.left: parent.left
        anchors.leftMargin: 65
        anchors.right:parent.right
        anchors.top:sliderRow.bottom
        anchors.topMargin: -20

        TextField{
            id:volumeText
            height:25
            width:35
            text: master.value.toFixed(0)

            onEditingFinished: {
                master.value = text;
            }
        }
    }

    Row{
        id:muteButtonsRow
        anchors.left: parent.left
        anchors.leftMargin: 45
        anchors.right:parent.right
        anchors.top:textBoxRow.bottom
        anchors.topMargin: 10
        Button{
            id:masterMuteButton
            width:70
            height:20
            text:checked ? "UNMUTE" : "MUTE"
            checkable: true


            contentItem: Text {
                   text: masterMuteButton.text
                   font.pixelSize: 12
                   opacity: enabled ? 1.0 : 0.3
                   color: "black"
                   horizontalAlignment: Text.AlignHCenter
                   verticalAlignment: Text.AlignVCenter
                   elide: Text.ElideRight
               }

               background: Rectangle {
                   opacity: .8
                   border.color: "black"
                   color: masterMuteButton.checked ? "dimgrey": "white"
                   border.width: 1
                   radius: width/2
               }

               property real unmuttedMasterVolume;

               onCheckedChanged: {
                   if (checked){
                       //send message that bass is muted
                       console.log("bass muted")
                       unmuttedMasterVolume = master.value;
                       platformInterface.set_volume.update(-42)

                   }
                     else{
                       //send message that bass is not muted
                       console.log("bass unmuted")
                       platformInterface.set_volume.update(unmuttedMasterVolume)
                       master.value = unmuttedMasterVolume;
                   }
               }
        }



    }


    Row{
        id:channelLabels
        anchors.left: parent.left
        anchors.leftMargin: 55
        anchors.right:parent.right
        anchors.top:muteButtonsRow.bottom
        anchors.topMargin: 5

        Label {
            text: "MASTER"
            color:accentColor
            width:channelWidth
            height:20
            visible:false
        }



    }

}
