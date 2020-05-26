import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0

Rectangle{
    id:root
    color:"transparent"
    height:270
    width:150
    radius:20
    border.color:"black"
    border.width: height > 100 ? 5 : 2

    property bool isOn:false
    signal clicked


    onIsOnChanged: {
        if (isOn){
            turningOnAnimation.start()
        }
        else
            turningOffAnimation.start()
    }

    ColorAnimation {
        id:turningOnAnimation
        target:switchOutline
        from: "lightgrey"
        to: "lightgrey"
        properties:"color"
        duration: 600
        running:false

    }

    ColorAnimation {
        id:turningOffAnimation
        target:switchOutline
        from: "lightgrey"
        to: "lightgrey"
        properties:"color"
        duration: 600
        running:false
    }

    Rectangle{
        id:upperScrew
        height:parent.width/10
        width:height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: parent.height/8
        radius:height/2
        color:"lightgrey"

    }

    Rectangle{
        id:lowerScrew
        height:parent.width/10
        width:height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: parent.height/8
        radius:height/2
        color:"lightgrey"

    }


    Rectangle{
        id:switchOutline
        height:parent.height/2
        width:parent.width/2
        anchors.centerIn: parent
        radius:height>20? parent.width/8 : 5
        color: "lightgrey"


        Rectangle{
            id:switchThumb
            height: switchOutline.width-20
            width:height
            y:root.isOn ? 10 : switchOutline.height/2-5
            x:10
            color:"white"
            radius:height>50? 20 : 5
            border.width: height>50 ? 10 : 2

            Behavior on y {
                NumberAnimation {
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
    MouseArea{
        id:toggleMouseAreea
        height:parent.height
        width:parent.width

        onClicked: {
            //root.isOn = !root.isOn
            root.clicked()
        }
    }

}
