import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import "qrc:/partial-views"
import "qrc:/partial-views/platform-selector"
import "js/navigation_control.js" as NavigationControl

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Rectangle{
    id:container
    anchors.fill: parent
    clip: true

    // Context properties that get passed when created dynamically
    property string user_id: ""

    Image {
        id: background
        source: "qrc:/images/circuits-background-tiled.svg"
        anchors.fill: parent
        fillMode: Image.Tile
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
                source: "qrc:/images/" + "blank_avatar.png"
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
                text: user_id
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

    Item {
        id: orderPopup

        function open() {
            var salesPopup = NavigationControl.createView("qrc:/partial-views/SGSalesPopup.qml", orderPopup)
            salesPopup.width = container.width-100
            salesPopup.height = container.height - 100
            salesPopup.x = container.width/2 - salesPopup.width/2
            salesPopup.y =  container.height/2 - salesPopup.height/2
            salesPopup.open()
        }
    }
}
