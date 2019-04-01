import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "qrc:/statusbar-partial-views"
import "qrc:/statusbar-partial-views/platform-selector"
import "js/navigation_control.js" as NavigationControl
import Fonts 1.0
import QtWebEngine 1.6

Rectangle{
    id:container
    anchors.fill: parent
    clip: true

    // Context properties that get passed when created dynamically
    property string user_id: ""

    // Hardcoded mapping
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

    Image {
        id: background
        source: "qrc:/images/login-background.svg"
        height: 1080
        width: 1920
        x: (parent.width - width)/2
        y: (parent.height - height)/2
    }

    Row {
        id: upperContainer
        anchors {
            horizontalCenter: container.horizontalCenter
            top: container.top
            topMargin: Math.max((container.height - upperContainer.height - platformSelector.height)/3, 0)
        }
        height: Math.max(userContainer.height, strataLogo.height)
        z: 2
        spacing: 20


        Item {
            id: userContainer
            anchors {
                verticalCenter: upperContainer.verticalCenter
            }
            height: childrenRect.height
            width: Math.max (welcomeMessage.width, user_img.width)

            Image {
                id: user_img
                sourceSize.height: 160
                fillMode: Image.PreserveAspectFit
                anchors {
                    top : userContainer.top
                    horizontalCenter: userContainer.horizontalCenter
                }
                source: "qrc:/images/" + getUserImage(user_id)
                visible: false
            }

            Rectangle {
                id: mask
                width: 120
                height: width
                radius: width/2
                visible: false
            }

            OpacityMask {
                anchors {
                    top: user_img.top
                    horizontalCenter: user_img.horizontalCenter
                }
                height: 135
                width: 135
                source: user_img
                maskSource: mask
            }

            Label {
                id: welcomeMessage
                anchors {
                    top: user_img.bottom
                    topMargin: -20
                    horizontalCenter: userContainer.horizontalCenter
                }
                font {
                    family: Fonts.franklinGothicBold
                    pixelSize: 20
                }
                text: getUserName(user_id)
            }
        }

        Rectangle {
            id: divider
            color: "#999"
            height: userContainer.height
            anchors {
                verticalCenter: userContainer.verticalCenter
            }
            width: 2
        }

        Image {
            id: strataLogo
            anchors {
                verticalCenter: userContainer.verticalCenter
            }
            sourceSize.height: 175
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/strata-logo.svg"
            mipmap: true;
        }
    }

    SGPlatformSelectorListView {
        id: platformSelector
        anchors {
            top: upperContainer.bottom
            horizontalCenter: container.horizontalCenter
            topMargin: upperContainer.anchors.topMargin
        }
        height: container.height * .625
    }

    Popup {
        id: orderPopup
        x: container.width/2 - orderPopup.width/2
        y: container.height/2 - orderPopup.height/2
        width: container.width-100
        height: container.height - 100
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        onOpened: webview.url = "https://www.onsemi.com/PowerSolutions/locateSalesSupport.do"


        DropShadow {
            width: orderPopup.width
            height: orderPopup.height
            horizontalOffset: 1
            verticalOffset: 3
            radius: 15.0
            samples: 30
            color: "#cc000000"
            source: orderPopup.background
            z: -1
            cached: true
        }

        Rectangle {
            id: popupContainer
            width: orderPopup.width
            height: orderPopup.height
            clip: true
            color: "white"

            Rectangle {
                id: title
                height: 30
                width: popupContainer.width
                anchors {
                    top: popupContainer.top
                }
                color: "lightgrey"

                Text {
                    id: close
                    text: "\ue805"
                    color: close_hover.containsMouse ? "#eee" : "white"
                    font {
                        family: Fonts.sgicons
                        pixelSize: 20
                    }
                    anchors {
                        right: title.right
                        verticalCenter: title.verticalCenter
                        rightMargin: 10
                    }

                    MouseArea {
                        id: close_hover
                        anchors {
                            fill: close
                        }
                        onClicked: orderPopup.close()
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            WebEngineView {
                id: webview
                anchors {
                    top: title.bottom
                    left: popupContainer.left
                    right: popupContainer.right
                    bottom: popupContainer.bottom
                }
                url: ""
            }
        }
    }

}
