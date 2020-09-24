import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root

    onVisibleChanged: {
        if (visible)
            resetUI();
    }

    Text{
        id:title
        anchors.top:parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text:"Multiple Model"
        font.pixelSize: 72
    }

    Column{
        id:column1
        anchors.top:parent.top
        anchors.topMargin: parent.height*.2
        anchors.left:parent.left
        anchors.leftMargin:parent.width*.2
        width:parent.width * .2
        spacing: -outlineThickness

        property int outlineThickness: 5

        Rectangle{
            id:leftRectangle1
            width:parent.width
            height:200
            border.width:column1.outlineThickness
            MSwitch{
                id:switchOutline1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height:180
                width:100

                property var button: platformInterface.demo_click_notification
                onButtonChanged:{
                    if (platformInterface.demo_click_notification.demo === "multiple_models")
                        if (platformInterface.demo_click_notification.button === "switch1")
                            if (platformInterface.demo_click_notification.value === "on")
                                relaySwitch.isOn = true;
                               else
                                relaySwitch.isOn = false;

                }

                onIsOnChanged: {
                    if (isOn){
                        lightBulb.onOpacity = 1
                        platformInterface.demo_click.update("multiple_models","switch1","on")
                    }
                    else{
                        lightBulb.onOpacity = 0
                        platformInterface.demo_click.update("multiple_models","switch1","off")
                    }
                }
            }
        }
        Rectangle{
            id:leftRectangle2
            width:parent.width
            height:200
            border.width:column1.outlineThickness
            MSwitch{
                id:switchOutline2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height:180
                width:100

                property var button: platformInterface.demo_click_notification
                onButtonChanged:{
                    if (platformInterface.demo_click_notification.demo === "multiple_models")
                        if (platformInterface.demo_click_notification.button === "switch2")
                            if (platformInterface.demo_click_notification.value === "on")
                                relaySwitch.isOn = true;
                               else
                                relaySwitch.isOn = false;

                }

                onIsOnChanged: {
                    if (isOn){
                        //this should trigger the buzzer in a node, but not change anything in the UI
                        platformInterface.demo_click.update("multiple_models","switch2","on")
                    }
                    else{
                        platformInterface.demo_click.update("multiple_models","switch2","off")
                    }
                }
            }
        }
    }   //column 1

    Column{
        id:column2
        anchors.top:parent.top
        anchors.topMargin: parent.height*.2
        anchors.left:column1.right
        //anchors.leftMargin:parent.width*.1
        width:parent.width * .2


        Rectangle{
            id:centerRectangle1
            width:parent.width
            height:200
            border.width:0

            Image{
                id:arrowImage
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../images/rightArrow.svg"
                height:25
                fillMode: Image.PreserveAspectFit
                mipmap:true
            }
        }
        Rectangle{
            id:centerRectangle2
            width:parent.width
            height:200
            border.width:0

            Image{
                id:arrowImage2
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../images/rightArrow.svg"
                height:25
                fillMode: Image.PreserveAspectFit
                mipmap:true
            }
        }
    }   //column 2



    Column{
        id:column3
        anchors.top:parent.top
        anchors.topMargin: parent.height*.2
        anchors.left:column2.right
        width:parent.width * .2
        spacing: -outlineThickness

        property int outlineThickness: 5

        Rectangle{
            id:rightRectangle1
            width:parent.width
            height:200
            border.width:column3.outlineThickness
            MLightBulb{
                id:lightBulb
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height:150

                onBulbClicked: {
                    //platformInterface.demo_click.update("multiple_models","bulb1","on")
                    //console.log("bulb clicked")
                }
            }
        }
        Rectangle{
            id:rightRectangle2
            width:parent.width
            height:200
            border.width:column3.outlineThickness

            Image{
                id:bellImage
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../images/Bell.svg"
                height:200
                fillMode: Image.PreserveAspectFit
                mipmap:true
            }


        }
    }

    function resetUI(){
        switchOutline1.isOn = false
        switchOutline2.isOn = false
    }

}
