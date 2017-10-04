import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtPositioning 5.2
import QtQuick.Window 2.2
import QtCharts 2.2

import QtQuick.Controls 1.4


import tech.spyglass.userinterfacebinding 1.0

import "framework"


Rectangle {
    id:sgWindow
    x:0; y:0

    //    Flipable {
    //        id: flipable
    //        anchors{ fill:parent }
    //        property bool flipped: false
    //        front: FrontSide{}
    //        back: BackSide{}

    //        transform: Rotation {
    //            id: rotation
    //            origin{ x: flipable.width/2; y: flipable.height/2 }
    //            axis{ x: 0; y: -1; z: 0 }    // set axis.y to 1 to rotate around y-axis
    //            angle: 0    // the default angle
    //        }

    //        states: State {
    //            name: "back"
    //            PropertyChanges { target: rotation; angle: 180 }
    //            when: flipable.flipped
    //        }

    //        transitions: Transition {
    //            NumberAnimation { target: rotation; property: "angle"; duration: 2000 }
    //        }

    //    }
    StackView {
        id:stack
        anchors.fill: parent
    }
    Component.onCompleted:{
        stack.push([BackSide, {immediate:true},
                    SGBoardLayout, {immediate:true},
                    FrontSide, {immediate:true}])
    }

    Component {
        id: page1
        FrontSide {}
    }

    Component {
        id: page2
        SGBoardLayout{}
    }

    Component {
        id: page3
        BackSide {}
    }
    Timer {
        interval: 2000;
        running: true;
        repeat: true
        onTriggered:{
            stack.pop()
        }
    }



}
