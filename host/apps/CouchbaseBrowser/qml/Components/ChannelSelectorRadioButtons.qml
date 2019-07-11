import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3

Rectangle {
    id: selectorContainer
    Layout.preferredHeight: 30
    Layout.preferredWidth: parent.width / 2
    Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
    color: "transparent"
    RadioButton {
        id: pushButton
        width: 30
        height: 30
        text: qsTr("")
        anchors {
            left: parent.left
        }
        onCheckedChanged: {
            pushButtonBackground.color = pushButton.checked ? "#b55400" : "transparent"
        }
        onClicked: {
            rep_type = "push"
        }
        indicator: Rectangle {
            width: 30
            height: 30
            radius: 13
            border.color: "#b55400"
            border.width: 2
            color: "transparent"

            Rectangle {
                id: pushButtonBackground
                width: 20
                height: 20
                anchors.centerIn: parent
                color: "transparent"
                radius: 13
            }
        }
    }
    RadioButton {
        id: pushAndPullButton
        width: 30
        height: 30
        text: qsTr("")
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: rep_type = "pushpull"
        onCheckedChanged: {
            pushAndPullButtonBackground.color = pushAndPullButton.checked ? "#b55400" : "transparent"
        }

        indicator: Rectangle {
            width: 30
            height: 30
            radius: 13
            border.color: "#b55400"
            border.width: 2
            color: "transparent"

            Rectangle {
                id: pushAndPullButtonBackground
                width: 20
                height: 20
                anchors.centerIn: parent
                color: "transparent"
                radius: 13
            }
        }
    }
    RadioButton {
        id: pullButton
        width: 30
        height: 30
        checked: true
        text: qsTr("")
        anchors {
            right: parent.right
        }
        Component.onCompleted: pullButtonBackground.color = pullButton.checked ? "#b55400" : "transparent"
        onClicked: rep_type = "pull"
        onCheckedChanged: {
            pullButtonBackground.color = pullButton.checked ? "#b55400" : "transparent"
        }
        indicator: Rectangle {
            width: 30
            height: 30
            radius: 13
            border.color: "#b55400"
            border.width: 2
            color: "transparent"

            Rectangle {
                id: pullButtonBackground
                width: 20
                height: 20
                anchors.centerIn: parent
                color: "transparent"
                radius: 13
            }
        }
    }
    Label {
        id: pushLabel
        text: "Push"
        color: "#eee"
        anchors {
            top: selectorContainer.bottom
            left: selectorContainer.left
        }
    }
    Label {
        id: pullLabel
        text: "Pull"
        color: "#eee"
        anchors {
            top: selectorContainer.bottom
            right: selectorContainer.right
        }
    }
    Label {
        id: pushAndPullLabel
        text: "Push & Pull"
        color: "#eee"
        anchors {
            top: selectorContainer.bottom
            horizontalCenter: selectorContainer.horizontalCenter
        }
    }
}

