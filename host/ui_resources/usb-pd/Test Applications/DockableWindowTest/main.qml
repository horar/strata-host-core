import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Dockable views")

    Window {
        width: 400;
        height: 400;
        visible: false;
        id: blueFloatingWindow

        Item {
            id:blueFloatingContentItem
            width: blueFloatingWindow.width
            height:blueFloatingWindow.height

        }

        onClosing: {
            blueRect.docked = true
            blueRect.parent = mainContentItem
            blueRect.height = blueRect.parent.height/2
            blueRect.width = blueRect.parent.width/2
        }

    }

    Window {
        width: 400;
        height: 400;
        visible: false;
        id: redFloatingWindow

        Item {
            id:redFloatingContentItem
            width: redFloatingWindow.width
            height:redFloatingWindow.height

        }

        onClosing: {
            redRect.docked = true
            redRect.parent = mainContentItem
            redRect.height = redRect.parent.height/2
            redRect.width = redRect.parent.width/2
        }

    }

    Window {
        width: 400;
        height: 400;
        visible: false;
        id: greenFloatingWindow

        Item {
            id:greenFloatingContentItem
            width: greenFloatingWindow.width
            height:greenFloatingWindow.height

        }

        onClosing: {
            greenRect.docked = true
            greenRect.parent = mainContentItem
            greenRect.height = greenRect.parent.height/2
            greenRect.width = greenRect.parent.width/2
        }

    }

    Window {
        width: 400;
        height: 400;
        visible: false;
        id: yellowFloatingWindow

        Item {
            id:yellowFloatingContentItem
            width: yellowFloatingWindow.width
            height:yellowFloatingWindow.height

        }

        onClosing: {
            yellowRect.docked = true
            yellowRect.parent = mainContentItem
            yellowRect.height = yellowRect.parent.height/2
            yellowRect.width = yellowRect.parent.width/2
        }

    }

    Item {
        id:mainContentItem
        anchors.fill:parent


        Rectangle {
            id: blueRect
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width/2
            height: parent.height/2
            color: "blue"

            property var docked: true

            Text{
                anchors.centerIn: parent
                text:"1"
                font{family:"helvetica"; pointSize:200}
            }

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    if(blueRect.docked == true){
                        blueRect.docked = false
                        blueRect.parent = blueFloatingContentItem
                        blueRect.width = blueRect.parent.width
                        blueRect.height = blueRect.parent.height
                        blueFloatingWindow.visible = true
                    }
                    else{
                        blueRect.docked = true
                        blueRect.parent = mainContentItem
                        blueFloatingWindow.visible = false
                        blueRect.height = blueRect.parent.height/2
                        blueRect.width = blueRect.parent.width/2
                    }
                }
            }
        }

        Rectangle {
            id: redRect
            anchors.right: parent.right
            anchors.top: parent.top
            width: parent.width/2
            height: parent.height/2
            color: "red"

            property var docked: true

            Text{
                anchors.centerIn: parent
                text:"2"
                font{family:"helvetica"; pointSize:200}
            }

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    if(redRect.docked == true){
                        redRect.docked = false
                        redRect.parent = redFloatingContentItem
                        redRect.width = redRect.parent.width
                        redRect.height = redRect.parent.height
                        redFloatingWindow.visible = true
                    }
                    else{
                        redRect.docked = true
                        redRect.parent = mainContentItem
                        redFloatingWindow.visible = false
                        redRect.height = redRect.parent.height/2
                        redRect.width = redRect.parent.width/2
                    }
                }
            }
        }

        Rectangle {
            id: greenRect
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: parent.width/2
            height: parent.height/2
            color: "green"

            property var docked: true

            Text{
                anchors.centerIn: parent
                text:"3"
                font{family:"helvetica"; pointSize:200}
            }

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    if(greenRect.docked == true){
                        greenRect.docked = false
                        greenRect.parent = greenFloatingContentItem
                        greenRect.width = greenRect.parent.width
                        greenRect.height = greenRect.parent.height
                        greenFloatingWindow.visible = true
                    }
                    else{
                        greenRect.docked = true
                        greenRect.parent = mainContentItem
                        greenFloatingWindow.visible = false
                        greenRect.height = greenRect.parent.height/2
                        greenRect.width = greenRect.parent.width/2
                    }
                }
            }
        }

        Rectangle {
            id: yellowRect
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: parent.width/2
            height: parent.height/2
            color: "yellow"

            property var docked: true

            Text{
                anchors.centerIn: parent
                text:"4"
                font{family:"helvetica"; pointSize:200}
            }

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    if(yellowRect.docked == true){
                        yellowRect.docked = false
                        yellowRect.parent = yellowFloatingContentItem
                        yellowRect.width = yellowRect.parent.width
                        yellowRect.height = yellowRect.parent.height
                        yellowFloatingWindow.visible = true
                    }
                    else{
                        yellowRect.docked = true
                        yellowRect.parent = mainContentItem
                        yellowFloatingWindow.visible = false
                        yellowRect.height = yellowRect.parent.height/2
                        yellowRect.width = yellowRect.parent.width/2
                    }
                }
            }
        }
    }
}
