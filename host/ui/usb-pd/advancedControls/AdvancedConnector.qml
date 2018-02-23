import QtQuick 2.0
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0


Rectangle {
    id: connector
    width: parent.width; height: (parent.width * .75)
    color:"transparent"
    property int anchorbottom: 0
    anchors.bottom: if(anchorbottom) { parent.bottom }
    clip:true
    property bool isConnected: false
    signal activated()
    property alias connectanimation: connect
    property alias disconnectanimation: disconnect
    property int portNumber:0;
    property double leftUSBPlugInitialXPosition
    property double originalCableWidth


    Component.onCompleted:{
        //save off the initial x position of the plug, so we can restore it later when
        //the device is unplugged
        leftUSBPlugInitialXPosition = leftUSBPlug.x;
        originalCableWidth = connector.width/1.35;
        if(visible){
            if (portNumber == 1) {
                var state = implementationInterfaceBinding.getUSBCPortState(1);
                if(state === true)
                    connect.start();
            }
            if (portNumber == 2) {
                var state = implementationInterfaceBinding.getUSBCPortState(2);
                if(state === true)
                    connect.start();
            }
        }
    }

    MouseArea {
        anchors { fill: parent }

        onClicked: {
            if (!isConnected){
                isConnected = true;
                connect.start();
            }
            else{
                isConnected = false;
                disconnect.start();
            }
        }
    }

    Connections {
        target: implementationInterfaceBinding

        onUsbCPortStateChanged: {
            if( portNumber === port ) {
                (value == true)?connect.start():disconnect.start();
            }
        }
    }

    //[Prasanth] this property is needed, when the usb-c is connected before the app launch
    //[Prasanth] needs more organisation for this function
    onVisibleChanged: {
        if(visible){
            if (portNumber == 1) {
                var state = implementationInterfaceBinding.getUSBCPortState(1);
                if(state === true)
                    connect.start();
            }
            if (portNumber == 2) {
                var state = implementationInterfaceBinding.getUSBCPortState(2);
                if(state === true)
                    connect.start();
            }
        }
    }

    NumberAnimation {
        id: connect
        target: leftUSBPlug
        property: "x";
        from: leftUSBPlug.x
        to: connector.x - connector.width/4
        easing.type: Easing.InQuad;
        duration: 500
    }


    NumberAnimation {
        id: disconnect
        target: leftUSBPlug
        property: "x";
        from: leftUSBPlug.x
        to: connector.x + connector.width
        easing.type: Easing.OutQuad;
        duration: 500
    }

    Image {
        id: leftUSBPlug
        smooth : true
        width: connector.width/5*4; height: connector.height
        x:  parent.width
        anchors{ verticalCenter: connector.verticalCenter }
        source: "../images/rightUSBPlugWhite.svg"
        }

    Rectangle{
        id:cable
        color:"white"
        anchors.left:leftUSBPlug.right
        anchors.leftMargin:-2
        anchors.verticalCenter: leftUSBPlug.verticalCenter
        width:50
        height:5

    }


}






