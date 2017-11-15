import QtQuick 2.0
import QtQuick.Controls 2.0


Rectangle {
    id:container
    width: container.width; height: container.height
    property alias text: valueString.text
    color: "transparent"
    property int portNumber:0;
//    property bool hardwareStatus:  {

//        if( portNumber === 1 ) {
//            var state = implementationInterfaceBinding.usbCPort1State;
//            if(state == true)
//                valueString.color = "red";
//        }

//        else if(portNumber === 2) {

//            var state = implementationInterfaceBinding.usbCPort2State;
//            if(state == true)
//                valueString.color = "red";
//        }

//        implementationInterfaceBinding.platformState
//    }

    Connections {
        target: implementationInterfaceBinding

        onUsbCPortStateChanged: {
            if( portNumber === port ) {
                (value == true)?valueString.color = "black":valueString.color = "black";
            }
        }
    }

    Label {
        id: valueString
        anchors{ verticalCenter:container.verticalCenter; left: parent.left; leftMargin: 10 }
        opacity: 1.0
    }

    Component.onCompleted: {
        //adjust font size based on platform
        if (Qt.platform.os === "osx"){

            valueString.font.pointSize = parent.width/10 > 0 ? parent.width/1.5 : 1;
            }
          else{
            fontSizeMode : Label.Fit
            }
    }
}
