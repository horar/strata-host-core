import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0

Rectangle{
    id:switchOutline
    height:270
    width:150
    radius:20
    color: "lightgrey"

    property bool isOn:false


    onIsOnChanged: {
        if (isOn)
            turningOnAnimation.start()
        else
            turningOffAnimation.start()
    }

    ColorAnimation {
        id:turningOnAnimation
        target:switchOutline
        from: "lightgrey"
        to: "limegreen"
        properties:"color"
        duration: 600
        running:false

    }

    ColorAnimation {
        id:turningOffAnimation
        target:switchOutline
        from: "limegreen"
        to: "lightgrey"
        properties:"color"
        duration: 600
        running:false
    }


    Rectangle{
        id:switchThumb
        height: 130
        width:130
        y:switchOutline.isOn ? 10 : 130
        x:10
        color:"white"
        radius:20
        border.width: 10

        Behavior on y {
           NumberAnimation {
             duration: 600
             easing.type: Easing.OutCubic
             }
         }
    }

    MouseArea{
        id:switchOnMouseArea
        height:135
        width:150

        onClicked: {
            switchOutline.isOn = true
        }
    }

    MouseArea{
        id:switchOffMouseArea
        x:0
        y:135
        height:135
        width:150

        onClicked: {
            switchOutline.isOn = false

        }
    }
}
