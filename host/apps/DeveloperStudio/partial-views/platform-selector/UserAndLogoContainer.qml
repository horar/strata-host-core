import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0

Row {
    id: upperContainer
    Layout.preferredHeight: Math.max(userContainer.height, strataLogo.height)
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
            text: first_name + " " + last_name
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
