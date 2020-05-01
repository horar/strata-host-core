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

    Rectangle{
        id:nodeRectangle
        width: switchOutline.width + 100
        height:switchOutline.height + 200
        anchors.horizontalCenter: switchOutline.horizontalCenter
        anchors.verticalCenter: switchOutline.verticalCenter
        radius:10
        border.color:"black"

        Text{
            property int nodeNumber: 1
            id:nodeText
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text:"node " + nodeNumber
            font.pixelSize: 18
        }

        Text{
            property int address: 2
            id:nodeAddressText
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text:"uaddr " + address
            font.pixelSize: 18
        }

        Rectangle{
            id:primaryElementRectangle
            anchors.left:parent.left
            anchors.leftMargin:15
            anchors.right:parent.right
            anchors.rightMargin: 15
            anchors.top:parent.top
            anchors.topMargin:25
            anchors.bottom:parent.bottom
            anchors.bottomMargin:25
            radius:10
            border.color:"black"

            Text{
                id:primaryElementText
                anchors.top:parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text:"primary element "
                font.pixelSize: 18
            }

            Text{
                property int address: 2
                id:primaryElementAddressText
                anchors.bottom:parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text:"uaddr " + address
                font.pixelSize: 18
            }

            Rectangle{
                id:modelRectangle
                anchors.left:parent.left
                anchors.leftMargin:15
                anchors.right:parent.right
                anchors.rightMargin: 15
                anchors.top:parent.top
                anchors.topMargin:25
                anchors.bottom:parent.bottom
                anchors.bottomMargin:25
                radius:10
                border.color:"black"

                Text{
                    id:modelText
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"light hsl client model"
                    font.pixelSize: 12
                }

                Text{
                    property int address: 1309
                    id:modelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"model id 0x" + address
                    font.pixelSize: 18
                }
            }
        }

    }


    MSwitch{
        id:switchOutline
        height:160
        width:100
        anchors.left:parent.left
        anchors.leftMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter

        property var button: platformInterface.demo_click_notification
        onButtonChanged:{
            if (platformInterface.demo_click_notification.demo === "one_to_many")
                if (platformInterface.demo_click_notification.button === "switch")
                    if (platformInterface.demo_click_notification.value === "on"){
                        switchOutline.isOn = true;
                        lightBulb1.onOpacity =1
                        lightBulb2.onOpacity =1
                        lightBulb3.onOpacity =1
                    }
                    else{
                        switchOutline.isOn = false;
                        lightBulb1.onOpacity =0
                        lightBulb2.onOpacity =0
                        lightBulb3.onOpacity =0
                    }

        }

        onClicked:{
            if (!isOn){     //turning the lightbulb on
                lightBulb1.onOpacity =1
                lightBulb2.onOpacity =1
                lightBulb3.onOpacity =1
                platformInterface.light_hsl_set.update(65535,0,0,100);  //set color to white
                switchOutline.isOn = true
              }
              else{         //turning the lightbulb off
                lightBulb1.onOpacity =0
                lightBulb2.onOpacity =0
                lightBulb3.onOpacity =0
                platformInterface.light_hsl_set.update(65535,0,0,0);  //set color to black
                switchOutline.isOn = false
              }
        }


    }

    Image{
        id:arrowImage
        anchors.left:nodeRectangle.right
        anchors.right:bulbGroup.left
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/rightArrow.svg"
        height:25
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Text{
            property int address: 3
            id:messageText
            anchors.top:parent.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text:"message to uaddr " + address
            font.pixelSize: 18
        }
    }

    Rectangle{
        id: bulbGroup
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.05
        anchors.top:parent.top
        anchors.topMargin: 50
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 50
        width:200
        color:"transparent"
        border.color:"lightgrey"
        border.width: 3

        Column{
            anchors.fill:parent
            topPadding: 10
            spacing:(parent.height - (bulbNodeRectangle.height*3) -topPadding*2)/2

            Rectangle{
                id:bulbNodeRectangle
                height:lightBulb1.height + 150
                width:parent.width-10
                anchors.horizontalCenter: parent.horizontalCenter
                radius:10
                border.color:"black"

                Text{
                    property int nodeNumber: 2
                    id:blubNodeText
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"node " + nodeNumber
                    font.pixelSize: 15
                }

                Text{
                    property int address: 3
                    id:bulbNodeAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"uaddr " + address
                    font.pixelSize: 15
                }

                Rectangle{
                    id:bulbPrimaryElementRectangle
                    anchors.left:parent.left
                    anchors.leftMargin:15
                    anchors.right:parent.right
                    anchors.rightMargin: 15
                    anchors.top:parent.top
                    anchors.topMargin:25
                    anchors.bottom:parent.bottom
                    anchors.bottomMargin:25
                    radius:10
                    border.color:"black"

                    Text{
                        id:bulbPrimaryElementText
                        anchors.top:parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"primary element"
                        font.pixelSize: 15
                    }

                    Text{
                        property int address: 3
                        id:bulbPrimaryElementAddressText
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"uaddr " + address
                        font.pixelSize: 15
                    }

                    Rectangle{
                        id:bulbModelRectangle
                        anchors.left:parent.left
                        anchors.leftMargin:15
                        anchors.right:parent.right
                        anchors.rightMargin: 15
                        anchors.top:parent.top
                        anchors.topMargin:25
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin:25
                        radius:10
                        border.color:"black"

                        Text{
                            id:bulbModelText
                            anchors.top:parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"light hsl server model"
                            font.pixelSize: 12
                        }

                        MLightBulb{
                            id:lightBulb1
                            height:50
                            anchors.top: bulbModelText.bottom
                            anchors.topMargin: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            onBulbClicked: {
                                platformInterface.demo_click.update("one_to_many","bulb1","on")
                                console.log("bulb1 clicked")
                            }
                        }

                        Text{
                            property int address: 1307
                            id:bulbModelAddressText
                            anchors.bottom:parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"model id 0x" + address
                            font.pixelSize: 15
                        }
                    }
                }

            }


            Rectangle{
                id:bulbNodeRectangle2
                height:lightBulb2.height + 150
                width:parent.width-10
                anchors.horizontalCenter: parent.horizontalCenter
                radius:10
                border.color:"black"

                Text{
                    property int nodeNumber: 2
                    id:blubNodeText2
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"node " + nodeNumber
                    font.pixelSize: 15
                }

                Text{
                    property int address: 3
                    id:bulbNodeAddressText2
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"uaddr " + address
                    font.pixelSize: 15
                }

                Rectangle{
                    id:bulbPrimaryElementRectangle2
                    anchors.left:parent.left
                    anchors.leftMargin:15
                    anchors.right:parent.right
                    anchors.rightMargin: 15
                    anchors.top:parent.top
                    anchors.topMargin:25
                    anchors.bottom:parent.bottom
                    anchors.bottomMargin:25
                    radius:10
                    border.color:"black"

                    Text{
                        id:bulbPrimaryElementText2
                        anchors.top:parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"primary element"
                        font.pixelSize: 15
                    }

                    Text{
                        property int address: 3
                        id:bulbPrimaryElementAddressText2
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"uaddr " + address
                        font.pixelSize: 15
                    }

                    Rectangle{
                        id:bulbModelRectangle2
                        anchors.left:parent.left
                        anchors.leftMargin:15
                        anchors.right:parent.right
                        anchors.rightMargin: 15
                        anchors.top:parent.top
                        anchors.topMargin:25
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin:25
                        radius:10
                        border.color:"black"

                        Text{
                            id:bulbModelText2
                            anchors.top:parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"light hsl server model"
                            font.pixelSize: 12
                        }

                        MLightBulb{
                            id:lightBulb2
                            height:50
                            anchors.top: bulbModelText2.bottom
                            anchors.topMargin: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            onBulbClicked: {
                                platformInterface.demo_click.update("one_to_many","bulb2","on")
                                console.log("bulb1 clicked")
                            }
                        }

                        Text{
                            property int address: 1307
                            id:bulbModelAddressText2
                            anchors.bottom:parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"model id 0x" + address
                            font.pixelSize: 15
                        }
                    }
                }

            }

            Rectangle{
                id:bulbNodeRectangle3
                height:lightBulb1.height + 150
                width:parent.width-10
                anchors.horizontalCenter: parent.horizontalCenter
                radius:10
                border.color:"black"

                Text{
                    property int nodeNumber: 2
                    id:blubNodeText3
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"node " + nodeNumber
                    font.pixelSize: 15
                }

                Text{
                    property int address: 3
                    id:bulbNodeAddressText3
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"uaddr " + address
                    font.pixelSize: 15
                }

                Rectangle{
                    id:bulbPrimaryElementRectangle3
                    anchors.left:parent.left
                    anchors.leftMargin:15
                    anchors.right:parent.right
                    anchors.rightMargin: 15
                    anchors.top:parent.top
                    anchors.topMargin:25
                    anchors.bottom:parent.bottom
                    anchors.bottomMargin:25
                    radius:10
                    border.color:"black"

                    Text{
                        id:bulbPrimaryElementText3
                        anchors.top:parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"primary element"
                        font.pixelSize: 15
                    }

                    Text{
                        property int address: 3
                        id:bulbPrimaryElementAddressText3
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"uaddr " + address
                        font.pixelSize: 15
                    }

                    Rectangle{
                        id:bulbModelRectangle3
                        anchors.left:parent.left
                        anchors.leftMargin:15
                        anchors.right:parent.right
                        anchors.rightMargin: 15
                        anchors.top:parent.top
                        anchors.topMargin:25
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin:25
                        radius:10
                        border.color:"black"

                        Text{
                            id:bulbModelText3
                            anchors.top:parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"light hsl server model"
                            font.pixelSize: 12
                        }

                        MLightBulb{
                            id:lightBulb3
                            height:50
                            anchors.top: bulbModelText3.bottom
                            anchors.topMargin: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            onBulbClicked: {
                                platformInterface.demo_click.update("one_to_many","bulb3","on")
                                console.log("bulb1 clicked")
                            }
                        }

                        Text{
                            property int address: 1307
                            id:bulbModelAddressText3
                            anchors.bottom:parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"model id 0x" + address
                            font.pixelSize: 15
                        }
                    }
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
