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
        text:"Volume"
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
        anchors.leftMargin:25
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
            id:bassChannel
            from: 16
            value: platformInterface.volume.sub
            to: 26
            stepSize: 2.5
            snapMode: Slider.SnapAlways

            orientation: Qt.Vertical
            anchors.top: parent.top
            width:channelWidth
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 20

            onMoved:{
                //send the new value to the platformInterface
                platformInterface.set_volume.update(master.value,
                                                    bassChannel.value);
            }
        }

        Rectangle{
            id:spacerRectangle
            height:parent.height
            width:channelWidth*1.65
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
            value: platformInterface.volume.master
            to: 42
            stepSize: 5
            snapMode: Slider.SnapAlways

            orientation: Qt.Vertical
            anchors.top: parent.top
            width:channelWidth
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 20

            onMoved:{
                //send the new value to the platformInterface
                platformInterface.set_volume.update(master.value,
                                                    bassChannel.value);
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

            property var muted: platformInterface.volume
            onMutedChanged:{
                if (platformInterface.volume.sub === 0){
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

               //save the unmutted bass volume so it can be restored when mute is removed
               property real unmutedBassVolume;

               onCheckedChanged: {
                   if (checked){
                       //send message that bass is muted
                       console.log("bass muted")
                       unmutedBassVolume = bassChannel.value;
                       platformInterface.set_volume.update(master.value,0)

                   }
                     else{
                       //send message that bass is not muted
                       console.log("bass unmuted")
                       platformInterface.set_volume.update(master.value,unmutedBassVolume)
                   }
               }
        }
        Label {
            text: ""
            color:"white"
            width:50
        }
        Button{
            id:masterMuteButton
            width:70
            height:20
            text:checked ? "UNMUTE" : "MUTE"
            checkable: true

            property var muted: platformInterface.volume
            onMutedChanged:{
                if (platformInterface.volume.master === -42){
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

               property real unmuttedMasterVolume;

               onCheckedChanged: {
                   if (checked){
                       //send message that bass is muted
                       console.log("bass muted")
                       unmuttedMasterVolume = master.value;
                       platformInterface.set_volume.update(-42,bassChannel.value)

                   }
                     else{
                       //send message that bass is not muted
                       console.log("bass unmuted")
                       platformInterface.set_volume.update(unmuttedMasterVolume, bassChannel.value)
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
                visible:false

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
            width:35
        }
        Button{
            id:protectButton
            width:90
            height:20
            text:checked ? "UNPROTECT" : "PROTECT"
            checkable: true
            checked: (platformInterface.mute_all === "muted") ? true : false
            visible:false

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
            width:80
        }
        Label {
            text: "MASTER"
            color:"white"
            width:channelWidth
            height:20
        }

    }

}
