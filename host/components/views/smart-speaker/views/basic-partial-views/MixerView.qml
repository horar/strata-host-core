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

    property int channelWidth: root.width/8

    Text{
        id:mixerText
        text:"Mixer"
        color:"white"
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
        anchors.leftMargin:20
        //anchors.right: parent.right
        anchors.left:parent.left

        ColumnLayout {
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Label {
                text: "26 dB"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "23 dB"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "21 dB"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "16 dB"
                color:"white"
                Layout.fillHeight: true
            }

        }



        Slider {
            id:channel5
            from: -95
            value: platformInterface.mixer_levels.ch5
            to: 0
            orientation: Qt.Vertical
            anchors.top: parent.top
            width:channelWidth
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 20

            onMoved:{
                //send the new value to the platformInterface
                platformInterface.set_mixer_levels.update(channel1.value,
                                                          channel2.value,
                                                          channel3.value,
                                                          channel4.value,
                                                          channel5.value);
            }
        }

        Rectangle{
            id:spacerRectangle
            height:parent.height
            width:channelWidth*3
            color:"transparent"
        }

        ColumnLayout {
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Label {
                text: "42 dB"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "19 dB"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "-4 dB"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "-27 dB"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "-50 dB"
                color:"white"
                Layout.fillHeight: true
            }
        }

        Slider {
            id:master
            from: -50
            value: platformInterface.volume.value
            to: 42
            orientation: Qt.Vertical
            anchors.top: parent.top
            width:channelWidth
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 20

            onMoved:{
                //send the new value to the platformInterface
                platformInterface.set_volume.update(value);
            }
        }
    }
    Row{
        id:muteButtonsRow
        anchors.left: parent.left
        anchors.leftMargin: 45
        anchors.right:parent.right
        anchors.top:sliderRow.bottom
        anchors.topMargin: -20

        Button{
            id:bassMuteButton
            width:70
            height:20
            text:checked ? "UNMUTE" : "MUTE"
            checkable: true

            property var muted: platformInterface.mute_chan
            onMutedChanged:{
                if (platformInterface.mute_chan.channel === 5)
                    if (platformInterface.mute_chan === "muted"){
                        checked = true;
                    }
                    else{
                        checked = false;
                    }
            }


            contentItem: Text {
                   text: bassMuteButton.text
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
                   color: bassMuteButton.checked ? "dimgrey": "white"
                   border.width: 1
                   radius: width/2
               }

               onCheckedChanged: {
                   if (checked){
                       //send message that bass is muted
                       console.log("bass muted")
                       platformInterface.set_mute_channel("mute",5)

                   }
                     else{
                       //send message that bass is not muted
                       console.log("bass unmuted")
                       platformInterface.set_mute_channel("unmute",5)
                   }
               }
        }
        Label {
            text: ""
            color:"white"
            width:150
        }
        Button{
            id:masterMuteButton
            width:70
            height:20
            text:checked ? "UNMUTE" : "MUTE"
            checkable: true

            property var muted: platformInterface.mute_chan
            onMutedChanged:{
                if (platformInterface.mute_chan.channel === 5)
                    if (platformInterface.mute_chan === "muted"){
                        checked = true;
                    }
                    else{
                        checked = false;
                    }
            }


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

               onCheckedChanged: {
                   if (checked){
                       //send message that bass is muted
                       console.log("bass muted")
                       platformInterface.set_mute_all("mute")

                   }
                     else{
                       //send message that bass is not muted
                       console.log("bass unmuted")
                       platformInterface.set_mute_all("unmute")
                   }
               }
        }
    }

        Row{
            id:boostButtonsRow
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right:parent.right
            anchors.top:muteButtonsRow.bottom
            anchors.topMargin: 5

            Button{
                id:bassBoostButton
                width:80
                height:20
                text:checked ? "UNBOOST" : "BOOST"
                checkable: true

                contentItem: Text {
                       text: bassBoostButton.text
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
                       color: bassBoostButton.checked ? "dimgrey": "white"
                       border.width: 1
                       radius: width/2
                   }

            }

        Label {
            text: ""
            color:"white"
            width:135
        }
        Button{
            id:protectButton
            width:90
            height:20
            text:checked ? "UNPROTECT" : "PROTECT"
            checkable: true
            checked: (platformInterface.mute_all === "muted") ? true : false

            contentItem: Text {
                   text: protectButton.text
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
                   color: protectButton.checked ? "dimgrey": "white"
                   border.width: 1
                   radius: width/2
               }

        }

    }

    Row{
        id:channelLabels
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.right:parent.right
        anchors.top:boostButtonsRow.bottom
        anchors.topMargin: 5

        Label {
            text: "BASS"
            color:"white"
            width:channelWidth
            height:20
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            text: ""
            color:"white"
            width:165
        }
        Label {
            text: "MASTER"
            color:"white"
            width:channelWidth
            height:20
        }

    }

}
