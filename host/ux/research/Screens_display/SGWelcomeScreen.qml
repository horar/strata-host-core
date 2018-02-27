import QtQuick 2.0
import QtQuick.Controls 1.4
import "images"

Rectangle{
    id:container
    property string userName: "User Name"
    property string imageName: " "
    property var userImages: [["David Priscak","images/dave_priscak.png"] , ["David Somo","images/david_somo.png"], ["Daryl Ostrander","images/daryl_ostrander.png"], ["Paul Mascarenas","images/paul_mascarenas.png"] ]

    function getImages(user_name)
    {
        var i;
        var flag = " ";
        for(i = 0; i < userImages.length; i++) {

            if(user_name === userImages[i][0])

            {
                console.log(userImages[i][1]);
                return userImages[i][1];
            }
        }
    }

    x: 62
    y: 12
    width: parent.width/1.2
    height: parent.height/1.6
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
        property var link: getImages(userName);
        width: 125
        height: 153
        anchors.horizontalCenter: messageContainer.horizontalCenter
        source: link
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
        source: "onLogoGrey.svg"
    }
    Rectangle {
        id: messageContainer
        anchors.top : onIcon.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: onIcon.horizontalCenter
        width: 375
        height: 47
        color: "transparent"

        Label{
            id: welcomeMessage
            width: 168
            height: 40
            font.pixelSize: 36
            color: "white"
            text: "Welcome"


            Label{
                id: username
                anchors.left : welcomeMessage.right
                anchors.leftMargin: 5
                width: 202
                height: 40
                font.pointSize: 21
                text: userName
                color: "white"
            }
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
            id: comboBox
            x: 295
            y: 0
            width: 161
            height: 37
            validator: IntValidator {bottom: 0; top: 10;}
            model: ListModel {
                id: model
                ListElement { text: "PLAT_1" }
                ListElement { text: "PLAT_2" }
                ListElement { text: "PLAT_3" }

            }
        }
    }
}

