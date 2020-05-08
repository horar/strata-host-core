import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root
    color:"transparent"

    Text{
        id:title
        anchors.top:parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text:"one-to-one"
        font.pixelSize: 72
    }

//    Image{
//        anchors.centerIn: parent
//        source: "qrc:/views/meshNetwork/images/oneToOneDemo.png"
//        height:parent.height * .34
//        fillMode: Image.PreserveAspectFit
//        mipmap:true
//    }

    MSwitch{
        id:switchOutline
        anchors.left:parent.left
        anchors.leftMargin:parent.width*.2
        anchors.verticalCenter: parent.verticalCenter

        onIsOnChanged: {
            if (isOn){
                lightBulb.onOpacity = 1
                platformInterface.demo_click.update("one_to_one","switch","on")
            }
              else{
                lightBulb.onOpacity = 0
                platformInterface.demo_click.update("one_to_one","switch","off")
            }
        }
    }

    Image{
        id:arrowImage
        anchors.left:switchOutline.right
        anchors.right:lightBulb.left
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/rightArrow.svg"
        height:25
        fillMode: Image.PreserveAspectFit
        mipmap:true
    }

    MLightBulb{
        id:lightBulb
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.2
        anchors.verticalCenter: parent.verticalCenter

        onBulbClicked: {
            platformInterface.demo_click.update("one_to_one","bulb1","on")
            console.log("bulb clicked")
        }
    }


    Button{
        id:resetButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 20
        text:"reconfigure"

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
                platformInterface.set_demo.update("one_to_one")
            }
    }
}
