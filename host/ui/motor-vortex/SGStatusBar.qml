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

    color: "#0c54e5"

    function getWidth(string) {
        return (string.match(/width=\"([0-9]+)\"/))
    }

    function getHeight(string) {
        return (string.match(/height=\"([0-9]+)\"/))
    }

    property var userImages: {
        "davidpriscak" : "dave_priscak.png",
        "davidsomo" : "david_somo.png",
        "darylostrander" : "daryl_ostrander.png",
        "paulmascarenas" : "paul_masarenas.png",
        "blankavatar" : "blank_avatar.png"
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

    Image {
        id: user_img
        sourceSize.width: 1024
        sourceSize.height: 1024
        height: parent.height
        anchors.left: container.left
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/" + getUserImage(user_id)
    }

    Label {
        id: userNameLabel
        height: parent.height
        text:  user_id
        font.pointSize: 18
        font.bold: true
        color: "white"
        anchors.left: user_img.right
        anchors.leftMargin: 10
        anchors.verticalCenter: container.verticalCenter
        anchors.verticalCenterOffset: 10

    }


    Image {
        height: parent.height
        anchors.right: parent.right
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/icons/onLogoGreen.svg"
    }

    ToolButton {
            id: settingsToolButton
            x: 170
            width: 30
            height: parent.height
            onClicked: settingsMenu.open()
            anchors.left: userNameLabel.right
            anchors.leftMargin: 10
            opacity:1
            z:2
            Image {
                id: setting_icon
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/icons/SettingIcon.svg"
            }
            Menu{
                id: settingsMenu
                title: "setting"
                MenuItem{
                    text: qsTr("Log out")
                    onClicked: {
                    NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
                    }
                }

                MenuItem{
                    text: qsTr("My Profile")
                }

            }
        }
}
