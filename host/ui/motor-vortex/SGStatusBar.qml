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
    property string generalTitle: "Guest"
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
                "ian.cain@onsemi.com" : "ian.cain.jpg",
                "blankavatar" : "blank_avatar.png"
    }

    property var userNames: {
        "dave.priscak@onsemi.com" : "Dave Priscak",
                "david.somo@onsemi.com"   : "David Somo",
                "daryl.ostrander@onsemi.com" : "Daryl Ostrander",
                "paul.mascarenas@onsemi.com" : "Paul Mascarenas",
                "ian.cain@onsemi.com" : "Ian Cain"
    }

    property var userJobtitle: {
        "dave.priscak@onsemi.com" : "VP Solutions Engineering",
                "david.somo@onsemi.com"   : "Vice President, Corporate Strategy and Marketing",
                "daryl.ostrander@onsemi.com" : "Director ON Semiconductor",
                "paul.mascarenas@onsemi.com" : "Director ON Semiconductor",
                "ian.cain@onsemi.com" : "Corporate Tech Ladder-Apps Mgmt (TL)"
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

    function getJobTitle(user_name){
        var user_lower = user_name.toLowerCase()
        if(userJobtitle.hasOwnProperty(user_lower)){
            return userJobtitle[user_lower]
        }
        else{
            return generalTitle;
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

        Popup {
            id: profilePopup
            width: 500
            height: 500
            modal: true
            focus: true
            x: 200; y: 200
            Rectangle {
                id: popupContainer
                anchors.fill: parent
                width: profilePopup.width;height: profilePopup.height
                color: "lightgray"

                Rectangle {
                    id: title
                    height: 30
                    width: popupContainer.width
                    anchors.top: popupContainer.top
                    color: "gray"

                    Label {
                        id: profileTitle
                        anchors {
                            left: title.left
                            leftMargin: 10
                        }
                        text: "My Profile"
                        font.pointSize: 10
                        font.bold: true
                    }
                }

                Image {
                    id: profile_image
                    anchors { horizontalCenter: popupContainer.horizontalCenter
                        top: popupContainer.top
                        topMargin: 60
                    }
                    width: 100; height: 100
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/" + getUserImage(user_id)
                }
                Label {
                    id:profile_userId
                    text: getUserName(user_id)
                    anchors {
                        top: profile_image.bottom
                        topMargin: 5
                        horizontalCenter: popupContainer.horizontalCenter

                    }
                    font.pointSize: 15
                    font.bold: true
                    color: "black"
                }

                Label {
                    id: profile_username
                    anchors {
                        top: profile_userId.bottom
                        horizontalCenter: popupContainer.horizontalCenter

                    }
                    text: getUserName(user_id) + "@onsemi.com"
                    anchors.horizontalCenterOffset: 1
                    //anchors.topMargin: 18
                    font.pointSize: 15
                    font.bold: true
                    color: "black"
                }

                Label {
                    id: email
                    text : getJobTitle(user_id)
                    anchors.top: profile_username.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter:  popupContainer.horizontalCenter
                }

                Label {
                    id: cusomerSupport
                    text: "Customer Support: 1800-onsemi-support"
                    anchors.top: email.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter:  popupContainer.horizontalCenter


                }

            }
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
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
                onClicked: profilePopup.open();
            }

        }
    }
}
