import QtQuick 2.1
import QtQuick.Controls 2.5

Button{
    id:transmitter

    height:300
    width:250
    checkable:true

    property alias title: transmitterName.text
    property alias color: backgroundRect.color
    signal transmitterNameChanged

    background: Rectangle {
        id:backgroundRect
            implicitHeight: 300
            implicitWidth: 250
            color:"slateGrey"
            //border.color:"dimgrey"
            border.color:"gold"
            border.width:3
            radius: 30
        }

    onCheckedChanged: {
        if (checked){
            backgroundRect.color = "green"
        }
         else{
            backgroundRect.color = "slateGrey"
        }
    }
    onDoubleClicked: {
        editor.visible = true;
    }

    Text{
        id:transmitterName
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -30
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 15
        text:"sensor 1"
        font.pixelSize:42
        color:"lightgrey"
    }

    Rectangle {
        id: editor
        anchors.fill: transmitterName
        visible: false
        color: "#0cf"


        TextInput {
            anchors.centerIn: editor
            text: transmitterName.text
            font.pixelSize:transmitterName.font.pixelSize
            onAccepted: {
                transmitterName.text = text;
                editor.visible = false;
                //send a signal with the new text
                transmitter.transmitterNameChanged();
            }
            onVisibleChanged: {
                if (visible) {
                    forceActiveFocus();
                    selectAll();
                }
            }
        }
    }

    SignalStrengthIndicator{
        id:bars
        height:50
        width: 50
        anchors.right: transmitter.right
        anchors.rightMargin:15
        anchors.verticalCenter: transmitterName.verticalCenter
        signalStrength: 4
    }






}
