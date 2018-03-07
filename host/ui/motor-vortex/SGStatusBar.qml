import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "js/navigation_control.js" as NavigationControl

Rectangle {
    id: container
    anchors.fill: parent

    // Context properties that get passed when created dynamically
    property string user_id: ""
    property bool is_logged_in: false
    //property color backgroundColor: "#0c54e5"
    property color backgroundColor: "#C0C0C0"


    function getWidth(string) {
        return (string.match(/width=\"([0-9]+)\"/))
    }

    function getHeight(string) {
        return (string.match(/height=\"([0-9]+)\"/))
    }

    property var userImages: {
        "dave.priscak@onsemi.com" : "dave_priscak.png",
        "david.somo@onsemi.com" : "david_somo.png",
        "daryl.ostrander@onsemi.com" : "daryl_ostrander.png",
        "paul.mascarenas@onsemi.com" : "paul_mascarenas.png",
        "blankavatar" : "blank_avatar.png"
    }

    property var userNames: {
        "dave.priscak@onsemi.com" : "Dave Priscak",
        "david.somo@onsemi.com"   : "David Somo",
        "daryl.ostrander@onsemi.com" : "Daryl Ostrander",
        "paul.mascarenas@onsemi.com" : "Paul Mascarenas",
    }

    function getUserImage(user_name){
        user_name = user_name.toLowerCase()
        if(userImages.hasOwnProperty(user_name)){
            return userImages[user_name]
        }
        else{
            return userImages["blankavatar"]
        }
    }

    function getUserName(user_name){
        var user_lower = user_name.toLowerCase()
        if(userNames.hasOwnProperty(user_lower)){
            return userNames[user_lower]
        }
        else{
            return user_name
        }
    }
    color: backgroundColor

    Image {
        id: user_img
        anchors { left: container.left }
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        sourceSize.width: 1024; sourceSize.height: 1024

        height: parent.height
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/" + getUserImage(user_id)
    }

    Label {
        id: userNameLabel

        anchors {
            left: user_img.right;
            leftMargin: 10;
            verticalCenter: container.verticalCenter;
            verticalCenterOffset: 10
        }

        height: parent.height
        text:  getUserName(user_id)
        font.pointSize: 15
        font.bold: true
        color: "white"
    }

    Image {
        height: parent.height
        anchors { right: parent.right }
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/icons/onLogoGrey.svg"
    }

    ToolButton {
        id: settingsToolButton

        anchors { left: userNameLabel.right;  leftMargin: 10 }
        width: 30; height: parent.height
        onClicked: settingsMenu.open()
        opacity: 1

        Label {
            anchors { fill: parent }

            text: qsTr("\u22EE")
            elide: Label.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            Layout.fillWidth: true
            font.pixelSize: 20
            font.bold: true
            color: "black"

            background: Rectangle {
                anchors { fill: parent }
                color: backgroundColor
            }

        }

        Menu {
            id: settingsMenu
            title: "setting"
            MenuItem {
                text: qsTr("Log out")
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
                }
            }

            MenuItem {
                text: qsTr("Remote Support")
            }

            MenuItem {
                text: qsTr("My Profile")
            }

        }
    }
}
