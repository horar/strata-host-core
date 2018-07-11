import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

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
                icon:"\u0045"
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
                icon:"\u003B"
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
                icon:"\ue808"
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

            SGDrawerMenuItem {
                drawerColor: "lightgreen"
                divider: false
                contentDrawerWidth: 350
                drawerContent: Text {
                    text: "<b>Settings</b>"
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
