import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4

import "js/navigation_control.js" as NavigationControl

Rectangle{
    id:container

    // Context properties that get passed when created dynamically
    property string user_id: ""

    // Hardcoded mapping
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

    anchors.fill: parent
    color: "#d9dfe1"
    gradient: Gradient {
        GradientStop {
            position: 0
            color: "#d9dfe1"
        }

        GradientStop {
            position: 1
            color: "#000000"
        }
    }

    Image {
        id: user_img
        width: 135
        height: 153
        anchors.horizontalCenter: messageContainer.horizontalCenter
        source: "qrc:/images/" + getUserImage(user_id)
        anchors.top: messageContainer.bottom
        anchors.topMargin: 20
    }


    Image {
        id: onIcon
        anchors.horizontalCenter: container.horizontalCenter
        anchors.top: container.top
        anchors.topMargin: 100
        width: 123
        height: 118
        source: "qrc:/images/icons/onLogoGrey.svg"
    }
    Rectangle {
        id: messageContainer
        anchors.top : onIcon.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: container.horizontalCenter
        width: 375
        height: 47
        color: "transparent"

        Label{
            id: welcomeMessage
            //width: 168
            //height: 40
            font.pixelSize: 36
            color: "white"
            text: "Welcome " + user_id + "!"
            anchors.centerIn: messageContainer
        }
    }
    Rectangle {
        id: platformSelectorContainer
        width: 430
        height: 69
        color: "transparent"
        anchors.horizontalCenter: onIcon.horizontalCenter
        anchors.top: user_img.bottom
        anchors.topMargin: 20
        Label {
            id: platformSelector
            width: 262
            height: 41
            text: "Select Platform:"
            font.pointSize: 21
            color: "white"
        }

        ComboBox {
            id: cbSelector
            anchors.left: platformSelector.right
            textRole: "text"
            model: ListModel {
                id: model
                ListElement { text: "USB-PD 100W";  name: "usb-pd"}
                ListElement { text: "Motor Vortex"; name: "motor-vortex"}
                ListElement { text: "BuBu Interface"; name: "bubu"}
            }
            onActivated: {
                var data = { platform_name: model.get(cbSelector.currentIndex).name}
                NavigationControl.updateState(NavigationControl.events.OFFLINE_MODE_EVENT, data)
            }
        }
    }
}

