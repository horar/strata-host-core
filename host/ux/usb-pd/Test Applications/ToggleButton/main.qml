import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGToggleButton")

    Rectangle {
        id: toggleButtonOutline
        width: 200; height: 100
        border.width:3
        border.color:"lightgrey"
        radius: height/2
        color: "white"
        anchors.centerIn: parent

        Rectangle {
            id: thumb
            height: toggleButtonOutline.height*.9
            width: height
            radius: height/2
            anchors.verticalCenter: parent.verticalCenter
            x:5
            border.color: "white"
            border.width: 1
            layer.enabled:true

            layer.effect: DropShadow {
                    anchors.fill: thumb
                    horizontalOffset:0
                    verticalOffset: 3
                    radius: 18.0
                    samples: 17
                    color: "#80000000"
                    source: thumb
                }

            property var isOn: false
            property var isExpanded: false
            property var resizeSpeed: 250
            property var movementSpeed: 500


            ParallelAnimation{
                id:onToOff
                PropertyAnimation {target:toggleButtonOutline; properties: "color"; to: "white"; duration:thumb.movementSpeed}
                PropertyAnimation {target:toggleButtonOutline; properties: "border.color"; to: "lightgrey"; duration:thumb.movementSpeed}
                PropertyAnimation {target: thumb; properties: "x"; to: 5;  duration:thumb.movementSpeed}
            }

            ParallelAnimation{
                id:offToOn
                PropertyAnimation {target:toggleButtonOutline; properties: "color"; to: "green"; duration:thumb.movementSpeed}
                PropertyAnimation {target:toggleButtonOutline; properties: "border.color"; to: "green"; duration:thumb.movementSpeed}
                PropertyAnimation {target: thumb; properties: "x"; to: toggleButtonOutline.width - thumb.height-5; duration:thumb.movementSpeed}
            }

            ParallelAnimation{
                id: expandLeft
                PropertyAnimation{target:thumb; properties:"x";
                    to:toggleButtonOutline.width - (1.2* thumb.width) -5
                    duration: thumb.resizeSpeed}
                PropertyAnimation{target: thumb; properties:"width"
                    to: thumb.width*1.2
                    duration: thumb.resizeSpeed}
            }

            ParallelAnimation{
                id: contractRight
                PropertyAnimation{target:thumb; properties:"x";
                    to:toggleButtonOutline.width - thumb.height -5
                    duration: thumb.resizeSpeed}
                PropertyAnimation{target: thumb; properties:"width"
                    to: thumb.height
                    duration: thumb.resizeSpeed}
            }

            ParallelAnimation{
                id: expandRight
                PropertyAnimation{target: thumb; properties:"width"
                    to: thumb.height*1.2
                    duration: thumb.resizeSpeed}
            }

            ParallelAnimation{
                id: contractLeft
                PropertyAnimation{target: thumb; properties:"width"
                    to: thumb.height
                    duration: thumb.resizeSpeed}
            }
        }

        MouseArea {
            id: mouseArea;
            anchors.fill: parent;
            onClicked: {
                if (thumb.isOn){
                    thumb.isOn = false;
                    if (thumb.isExpanded){
                        thumb.isExpanded = false
                        contractRight.start()
                    }
                    onToOff.start();
                }
                else{
                    thumb.isOn = true;
                    if (thumb.isExpanded){
                        thumb.isExpanded = false
                        contractLeft.start()
                    }
                    offToOn.start()
                }
            }

            onPressed: {
                if (thumb.isOn){
                    thumb.isExpanded= true
                    expandLeft.start()
                }
                else{
                    thumb.isExpanded= true
                    expandRight.start()
                }
            }

            onReleased: {
                if (thumb.isOn){
                    if (thumb.isExpanded){
                        thumb.isExpanded = false
                        contractRight.start()
                    }
                }
                else if (!thumb.isOn){
                    if (thumb.isExpanded){
                        thumb.isExpanded = false
                        contractLeft.start()
                    }
                }
            }
        }
    }
}
