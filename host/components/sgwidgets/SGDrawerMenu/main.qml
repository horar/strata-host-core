import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window {
    id: wind
    visible: true
    width: 640
    height: 480
    title: qsTr("SGDrawerMenu")

    SGDrawerMenu {
        id: sgDrawerMenu

        drawerMenuItems: Item {

            SGDrawerMenuItem {
                label: "Users"
                icon:"icons/users-solid.svg"
                contentDrawerWidth: 250
                drawerContent: Text {
                    text: "<b>Users</b>"
                    font {
                        pixelSize: 50
                    }
                    color: "#fff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            SGDrawerMenuItem {
                label: "Chat"
                icon:"icons/comments-solid.svg"
                drawerColor: "lightsalmon"
                drawerContent: Text {
                    text: "<b>Chat</b>"
                    font {
                        pixelSize: 50
                    }
                    color: "#fff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            SGDrawerMenuItem {
                label: "Help"
                icon:"icons/question-circle-solid.svg"
                drawerColor: "burlywood"
                contentDrawerWidth: 400
                drawerContent: Text {
                    text: "<b>Help</b>"
                    font {
                        pixelSize: 50
                    }
                    color: "#fff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
