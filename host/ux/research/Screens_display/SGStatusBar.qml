import QtQuick 2.0
//import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "images"

Rectangle {
    id: container
    property string userName: "User Name"
    color: "#a0b6a0"
    width: parent.width
    height: parent.height/20

    Label {
        width: 100
        height: parent.height
        text: userName
        font.bold: true
        anchors.left: container.left
        anchors.verticalCenter: container.verticalCenter
    }
        RowLayout {
            anchors.fill:parent


    ToolButton {
        id: settingsToolButton
        x: 292
        y: -10
        width: 74
        height: 76
        onClicked: settingsMenu.open()
        anchors.right: parent.right
        opacity:0.5
        z:2
        Image {
            id: setting_icon
//            x: 6
//            y: -6

            width: 72
            height: parent.height
            source: "images/eat_logos_business_setting.png"
        }
        Menu{
            id: settingsMenu
            title: "setting"
            MenuItem{
                text: qsTr("Log out")
                //  font.family: "helvetica"
                // font.pointSize: (Qt.platform.os === "osx") ? 14  : 10;
            }

            MenuItem{
                text: qsTr("My Profile")
                //  font.family: "helvetica"
                // font.pointSize: (Qt.platform.os === "osx") ? 14  : 10;
            }

        }
    }
        }
}
