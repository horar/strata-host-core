import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "images"

Rectangle {
    id: container
    property string userName: "User Name"
    property var link: getImages(userName);
    color: "#0c54e5"
    width: parent.width
    height: parent.height/20

    function getWidth(string) {
        return (string.match(/width=\"([0-9]+)\"/))
    }

    function getHeight(string) {
        return (string.match(/height=\"([0-9]+)\"/))
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
        source: link
    }

    Label {
        id: userNameLabel
        width: getWidth(userName)
        height: parent.height
        text: userName
        font.pointSize: 10
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
        source: "images/onLogoGreen.svg"
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
                source: "images/SettingIcon.svg"
            }
            Menu{
                id: settingsMenu
                title: "setting"
                MenuItem{
                    text: qsTr("Log out")
                }

                MenuItem{
                    text: qsTr("My Profile")
                }

            }
        }
}
