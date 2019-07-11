import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3

Rectangle {
    id: root
    width: parent.width
    height: parent.height
    color: "transparent"

    property var channels: []

    function checkDuplicate(arr,value){
        for(let i = 0; i < arr.length; i++){
            if(arr[i] === value){
                return true
            }
        }
        return false
    }
    function add(){
        var temp = channelInputField.text
        if(checkDuplicate(channels,temp) === false){
            channels.push(temp)
            channelModel.append({"name" : temp})
        }
        channelInputField.text = ""
    }
    function clearLast(){
        if(channels.length > 0){
            channelModel.remove(channels.length - 1)
            channels.pop();
        }
    }

    Label {
        text: "Selected Channels:"
        color: "#eee"
        anchors {
            bottom: parent.top
            left: parent.left
        }
    }
    Rectangle {
        id: channelViewContainer
        width: parent.width
        height: parent.height -20
        color: "#d9d9d9"
        border {
            width: 1
            color: "#eee"
        }
        anchors {
            top: parent.top
        }
        ListView {
            id: list
            width: parent.width
            height: parent.height - 18
            clip: true
            model: channelModel
            delegate: channelDelegate
            spacing: 3
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -5
            currentIndex: list.count - 1
        }
        ListModel {
            id: channelModel
        }
        Component {
            id: channelDelegate
            Rectangle {
                height: 18
                width: parent.width - 8
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#b55400"
                border {
                    width: 1
                    color: "black"
                }
                Text {
                    id: delegateText
                    anchors.centerIn: parent
                    text: name;
                    font.pixelSize: 12
                    color: "#eee"
                }
            }

        }
    }
    Rectangle {
        id: channelInputContainer
        height: 30
        width: parent.width
        color: "orange"
        anchors {
            bottom: channelLayoutContainer.bottom
        }
        TextField {
            id: channelInputField
            height: parent.height
            width: parent.width - 50
            autoScroll: true
            anchors {
                right: addButton.left
            }
            placeholderText: "Enter Channel"
            Keys.onReturnPressed: {
                add()
            }
            Keys.onEnterPressed: add()
            onActiveFocusChanged: {
                channelInputBackground.border.color = activeFocus ? "#b55400" : "transparent"
            }
            background: Rectangle {
                id: channelInputBackground
                border {
                    width: 2
                    color: "transparent"
                }
            }
        }
        Button {
            id: addButton
            width: 50
            height: parent.height
            hoverEnabled: true
            onHoveredChanged: {
                buttonBackground.color = hovered ? "#8c4100" : "#b55400"
            }
            anchors {
                top: parent.top
                right: parent.right
            }
            text: "Add"
            onClicked: {
                add()
            }
            background: Rectangle {
                id: buttonBackground
                color: "#b55400"
            }
        }
        RowLayout {
            spacing: 2
            width: parent.width
            anchors {
                top: channelInputContainer.bottom
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            Button {
                id: clearAllButton
                Layout.preferredWidth: (parent.width / 2) - 1
                Layout.preferredHeight: 30
                text:  "Clear All"
                onClicked: {
                    channelModel.clear()
                    while(channels.length > 0) {
                        channels.pop()
                    }
                }
            }
            Button {
                id: clearLastButton
                Layout.preferredWidth: (parent.width / 2) - 1
                Layout.preferredHeight: 30
                text: "Clear Last"
                onClicked: {
                    clearLast();
                }
            }
        }
    }
}
