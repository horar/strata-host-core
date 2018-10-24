import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "qrc:/statusbar-partial-views"
import "js/navigation_control.js" as NavigationControl
import fonts 1.0

Rectangle{
    id:container

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

    // DEBUG test butt-un to simulate signal data
    //        Button {
    //            text: "TEST"

    //            onClicked: {

    ////                // DEBUG inject test data for testing offline
    ////                var list = [
    ////                            {
    ////                                "verbose":"usb-pd",
    ////                                "uuid":"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af",
    ////                                "connection":"view"
    ////                            },
    ////                            {
    ////                                "verbose":"bubu",
    ////                                "uuid":"P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671",
    ////                                "connection":"connected"
    ////                            },
    ////                            {
    ////                                "verbose":"motor-vortex",
    ////                                "uuid":"SEC.2017.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3",
    ////                                "connection":"connected"
    ////                            }];

    ////                var handshake = {"list":list};
    ////                console.log("TEST platformList: ", JSON.stringify(handshake));
    ////                platformContainer.populatePlatforms(JSON.stringify(handshake));

    //                coreInterface.sendHandshake();
    //            }
    //        }

    anchors.fill: parent
    clip: true

    Image {
        id: background
        source: "qrc:/images/login-background.svg"
        height: 1080
        width: 1920
        x: (parent.width - width)/2
        y: (parent.height - height)/2
    }

    Item {
        id: upperContainer
        anchors {
            left: container.left
            right: container.right
            top: container.top
        }
        height: container.height * 0.5
        z: 2

        Item {
            id: userContainer
            anchors {
                verticalCenter: upperContainer.verticalCenter
                horizontalCenter: upperContainer.horizontalCenter
                horizontalCenterOffset: -200
            }
            height: welcomeMessage.height + user_img.height
            width: Math.max (welcomeMessage.width, user_img.width)

            Image {
                id: user_img
                sourceSize.width: 135
                height: 1.1333 * width
                anchors {
                    top : userContainer.top
                    horizontalCenter: welcomeMessage.horizontalCenter
                }
                source: "qrc:/images/" + getUserImage(user_id)
                visible: false
            }

            Rectangle {
                id: mask
                width: 135
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
                    topMargin: 0
                }
                font {
                    family: Fonts.franklinGothicBold
                    pixelSize: 32
                }
                text: getUserName(user_id)
            }
        }

        Rectangle {
            id: divider
            color: "#999"
            anchors {
                left: userContainer.right
                leftMargin: 30
                top: userContainer.top
                bottom: userContainer.bottom
            }
            width: 2
        }

        Item {
            id: platformContainer
            anchors {
                verticalCenter: userContainer.verticalCenter
                left: divider.right
                leftMargin: 30
            }
            height: strataLogo.height + platformSelector.height + platformSelector.anchors.topMargin + cbSelector.height + cbSelector.anchors.topMargin
            width: cbSelector.width

            Image {
                id: strataLogo
                width: 2 * height
                height: upperContainer.height > 264 ? 175 : 100
                anchors {
                    horizontalCenter: cbSelector.horizontalCenter
                }
                source: "qrc:/images/strata-logo.svg"
                mipmap: true;
            }

            Label {
                id: platformSelector
                text: "SELECT PLATFORM:"
                font {
                    pixelSize: 20
                    family: Fonts.franklinGothicBold
                }
                anchors {
                    top: strataLogo.bottom
                    topMargin: 20
                    horizontalCenter: cbSelector.horizontalCenter
                }
            }


            SGPlatformSelector {
                id: cbSelector
                anchors {
                    top: platformSelector.bottom
                    topMargin: 10
                    left: platformContainer.left
                }
                comboBoxWidth: 350
            }
        }
    }

    Item {
        id: lowerContainer
        anchors {
            left: container.left
            right: container.right
            bottom: container.bottom
        }
        height: container.height * 0.5
        z: 1

        Item {
            id: adContainer
            anchors {
                verticalCenter: lowerContainer.verticalCenter
                horizontalCenter: lowerContainer.horizontalCenter
            }
            height: lowerContainer.height * 0.86
            width: height / 0.53
            clip: true

            SwipeView {
                id: adSwipe
                anchors {
                    fill: parent
                }

                Image {
                    source: "qrc:/images/demo-ads/1.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }

                Image {
                    source: "qrc:/images/demo-ads/2.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }

                Image {
                    source: "qrc:/images/demo-ads/3.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }

                Image {
                    source: "qrc:/images/demo-ads/4.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }
            }

            Timer {
                interval: 3000
                running: true
                repeat: true
                onTriggered: {
                    if (adSwipe.currentIndex < 3) {
                        adSwipe.currentIndex++
                    } else {
                        adSwipe.currentIndex = 0
                    }
                }
            }

            PageIndicator {
                id: indicator

                count: adSwipe.count
                currentIndex: adSwipe.currentIndex

                anchors.bottom: adSwipe.bottom
                anchors.horizontalCenter: adSwipe.horizontalCenter
            }
        }
    }
}
