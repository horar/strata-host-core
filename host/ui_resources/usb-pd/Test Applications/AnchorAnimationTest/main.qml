import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: theWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Component.onCompleted: {
        console.log("starting bounce animation")
        //bounceTheTextSequence.start()
        rotation.start()
    }

    Text {
        id: theText
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.horizontalCenter: parent.horizontalCenter
//        x: theWindow.width/2
//        y: theWindow.height/2
        text: "B"
        font.family: "Helvetica"
        font.pointSize: 144
        color: "black"

        transform: Rotation {
                       id: zRot
                       origin.x: theText.width/2; origin.y: theText.height/2;
                       axis { x: 0; y: 1; z: 0 }
                       angle: 360
                   }
        NumberAnimation {
                    id:rotation
                   running: false
                   loops: 100
                   target: zRot;
                   property: "angle";
                   from: 0; to: 360;
                   duration: 4000;
               }

//        transform:
//            Rotation {
//            id:spinTheText;
//            origin.x: theText.x+theText.width/2;
//            //origin.y: theText.y+theText.height/2;
//            angle: 45
//        }

//        SequentialAnimation{
//            id: bounceTheTextSequence

//            PropertyAnimation {
//                id: bounceTheText1;
//                target: theText;
//                running: false
//                property: "y";
//                to: theWindow.height/2 - 50;
//                easing.type: Easing.OutQuad;
////                easing.amplitude: 2.0;
////                easing.period: 1.5
//                duration: 500 }

//            PropertyAnimation {
//                id: bounceTheText2;
//                target: theText;
//                running: false
//                property: "y";
//                to: theWindow.height/2;
//                easing.type: Easing.OutBounce;
//                easing.amplitude: 2.0;
//                easing.period: 1.5
//                duration: 2000 }
//        }
    }


}
