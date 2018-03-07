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

    function generateToken(n) {
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        var token = '';
        for(var i = 0; i < n; i++) {
            token += chars[Math.floor(Math.random() * chars.length)];
        }
        return token;
    }

    color: backgroundColor

    Popup {
        id: remoteSupportConnect
        x: 400; y: 200
        width: 400; height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent


        Rectangle {
            anchors {
                fill: parent
            }

            Column{
                anchors.fill: parent
                anchors.centerIn: parent
                Label {
                    id: tokenLabel
                    height: 30
                    text: "Enter token"
                    font.pointSize: 15
                    font.bold: true
                    color: "dark blue"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Rectangle{
                    width: 300
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    TextField {
                        id: tokenField
                        width: 184; height: 38
                        focus: true
                        placeholderText: qsTr("TOKEN")
                        cursorPosition: 1
                        font.pointSize: Qt.platform.os == "osx"? 13 :8
                        Keys.onReturnPressed:{
                            console.log("TOKEN: ", text);
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Button{
                        text: "Submit"
                        width: 80; height: 38
                        anchors{
                            left:tokenField.right
                        }

                    }
                }



            }
        }
    }

    Popup {
        id: remoteSupportRequest
        x: 400; y: 200
        width: 400; height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            anchors {fill: parent }

            Label {
                id:displayTokenLabel
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    margins: 30
                }
                text: "TOKEN: " + generateToken(7);
                font.pointSize: 15
                font.bold: true
                color: "dark blue"
            }
            Label {
                id:supportPhoneNumber
                anchors {
                    top:displayTokenLabel.bottom
                    horizontalCenter: parent.horizontalCenter
                    margins: 30
                }
                text: "Call: 1800-onsemi-support"
                font.pointSize: 15
                font.bold: true
                color: "black"
            }
            Rectangle{
                height: 100
                width: 100

                anchors{
                    top:supportPhoneNumber.bottom
                    margins: 10
                    horizontalCenter: parent.horizontalCenter
                }
                Image {
                    id: phoneIcon
                    anchors.centerIn: parent
                    sourceSize.width: 100; sourceSize.height: 100
                    height: parent.height
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/phone-icon.png"
                }

            }


        }
        onAboutToShow: function(){
            displayTokenLabel.text = "TOKEN: " + generateToken(7);
        }
    }

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
                text: qsTr("Remote Support FAE")

                onClicked: {
                    remoteSupportConnect.open()

                }
            }

            MenuItem {
                text: qsTr("Remote Support CUSTOMER")

                onClicked: {
                    remoteSupportRequest.open()
                }
            }

            MenuItem {
                text: qsTr("My Profile")
            }

        }
    }
}
