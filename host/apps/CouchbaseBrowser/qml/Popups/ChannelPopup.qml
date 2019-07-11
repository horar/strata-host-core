import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import "../Components"

Window {
    id: root
    width: 400
    height: 450
    minimumWidth: 400
    minimumHeight: 450
    maximumHeight: 450
    maximumWidth: 400
    visible: false
    flags: Qt.Tool

    signal start()

    property string rep_type: "pull"
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
    function validate(){
        warningPopup.visible = true
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#393e46"
        border {
            width: 2
            color: "#b55400"
        }
        StatusBar {
            id: statusBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 25
        }
        ColumnLayout {
            spacing: 15
            width: parent.width - 10
            height: parent.height - 130
            anchors {
                centerIn: parent
            }
            Rectangle {
                id: channelLayoutContainer
                Layout.preferredHeight: 160
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
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
            Button {
                id: submitButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignHCenter
                text: "Submit"
                onClicked: validate();
            }
        }
    }
    WarningPopup {
        id: warningPopup
        onAllow: {
            warningPopup.visible = false
            root.close()
            start()
        }
        onDeny: {
            warningPopup.visible = false
        }
    }
}
