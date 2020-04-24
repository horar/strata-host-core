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
        anchors.right: bulbGroup.left
        anchors.rightMargin: 20
        text:"one-to-many"
        font.pixelSize: 72
    }

    MSwitch{
        id:switchOutline
        height:320
        width:200
        anchors.left:parent.left
        anchors.leftMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter

        property var button: platformInterface.demo_click_notification
        onButtonChanged:{
            if (platformInterface.demo_click_notification.demo === "one_to_many")
                if (platformInterface.demo_click_notification.button === "switch")
                    if (platformInterface.demo_click_notification.value === "on")
                        switchOutline.isOn = true;
                       else
                        switchOutline.isOn = false;

        }

        onIsOnChanged: {
            if (isOn){
                lightBulb1.onOpacity =1
                lightBulb2.onOpacity =1
                lightBulb3.onOpacity =1
                platformInterface.demo_click.update("one_to_many","switch","on")
            }
              else{
                lightBulb1.onOpacity =0
                lightBulb2.onOpacity =0
                lightBulb3.onOpacity =0
                platformInterface.demo_click.update("one_to_many","switch","off")
            }
        }
    }

    Image{
        id:arrowImage
        anchors.left:switchOutline.right
        anchors.right:bulbGroup.left
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/rightArrow.svg"
        height:25
        fillMode: Image.PreserveAspectFit
        mipmap:true
    }

    Rectangle{
        id: bulbGroup
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.1
        anchors.top:parent.top
        anchors.topMargin: 100
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 100
        width:200
        color:"transparent"
        border.color:"lightgrey"
        border.width: 3

        Column{
            anchors.fill:parent
            topPadding: 20
            spacing:(parent.height - (lightBulb1.height*3) -topPadding*2)/2

            MLightBulb{
                id:lightBulb1
                anchors.horizontalCenter: parent.horizontalCenter
                onBulbClicked: {
                    platformInterface.demo_click.update("one_to_many","bulb1","on")
                    console.log("bulb1 clicked")
                }
            }

            MLightBulb{
                id:lightBulb2
                anchors.horizontalCenter: parent.horizontalCenter
                onBulbClicked: {
                    platformInterface.demo_click.update("one_to_many","bulb2","on")
                    console.log("bulb1 clicked")
                }
            }

            MLightBulb{
                id:lightBulb3
                anchors.horizontalCenter: parent.horizontalCenter
                onBulbClicked: {
                    platformInterface.demo_click.update("one_to_many","bulb3","on")
                    console.log("bulb1 clicked")
                }
            }
        }


    }



    Button{
        id:resetButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 20
        text:"configure"

        contentItem: Text {
                text: resetButton.text
                font.pixelSize: 20
                opacity: enabled ? 1.0 : 0.3
                color: "grey"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: resetButton.down ? "lightgrey" : "transparent"
                border.color: "grey"
                border.width: 2
                radius: 10
            }

            onClicked: {
                platformInterface.set_demo.update("one_to_many")
                root.resetUI()
            }
    }

    function resetUI(){
        switchOutline.isOn = false
    }


}
