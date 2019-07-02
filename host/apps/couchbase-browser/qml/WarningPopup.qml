import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3

Popup {
    id: root
    width: message.width + 50
    height: 300
    visible: false
    padding: 0

    Rectangle {
        anchors.fill: parent
        color: "#222831"
        border.color: "#b55400"
        Label {
            id: message
            anchors.centerIn: parent
            color: "#eee"
            text: "WARNING! STARTING REPLICATION WILL OVERWRITE ANY UNSAVED DATA. DO YOU WISH TO CONTINUE?"
        }
        Button {
            id: yesButton
            width: 100
            height: 40
            anchors {
                centerIn: parent
                horizontalCenterOffset: -100
                verticalCenterOffset: 50
            }
            text: "Yes"
        }
        Button {
            id: noButton
            width: 100
            height: 40
            anchors {
                centerIn: parent
                horizontalCenterOffset: 100
                verticalCenterOffset: 50
            }
            text: "No"
        }
    }
}
