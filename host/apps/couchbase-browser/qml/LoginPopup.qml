import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3

Window {
    id: root
    width: 500
    height: 700
    minimumWidth: 500
    minimumHeight: 700
    visible: false
    flags: Qt.Tool

    signal start()

    property alias url: urlField.text
    property alias username: usernameField.text
    property alias password: passwordField.text

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
            channelViewField.text += temp + "\n"
        }
        channelInputField.text = ""
    }
    function clearInput()
    {
        urlField.text = ""
        usernameField.text = ""
        passwordField.text = ""
    }
    function clearLast(){
        channelViewField.text = ""
        for (let i = 0; i < channels.length - 1; i++){
            channelViewField.text += channels[i] + "\n"
        }
        channels.pop();
    }

    function validate(){
        if(url.length !== 0){
            warningPopup.visible = true
        }
        else {
            urlFieldBackground.border.color = "red"
            urlFieldBackground.border.width = 2
            header.text = "Invalid Input"
        }
    }

    WarningPopup {
        id: warningPopup
        onAllow: {
            warningPopup.visible = false
            start()
        }
        onDeny: {
            warningPopup.visible = false
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#393e46"
        border {
            width: 2
            color: "#b55400"
        }
        Rectangle {
            id: statusBar
            width: parent.width
            height: 25
            anchors {
                top: parent.top
            }
            color: "#b55400"
            TextArea {
                height: parent.height
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: "#eee"
                text: ""
                readOnly: true
            }
        }

        ColumnLayout {
            spacing: 1
            width: parent.width - 10
            height: parent.height - 25
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: statusBar.bottom

            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: urlContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "URL:"
                        color: "#eee"
                        anchors {
                            bottom: urlContainer.top
                            left: urlContainer.left
                        }
                    }
                    TextField {
                        id: urlField
                        anchors.fill: parent
                        placeholderText: "Enter URL"
                        onActiveFocusChanged: {
                            urlFieldBackground.border.color = "transparent"
                            header.text = "Please enter the requested information"
                        }
                        Rectangle {
                            id: urlFieldBackground
                            width: parent.width
                            height: parent.height
                            color: "transparent"
                        }
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: usernameContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Username:"
                        color: "#eee"
                        anchors {
                            bottom: usernameContainer.top
                            left: usernameContainer.left
                        }
                    }
                    TextField {
                        id: usernameField
                        anchors.fill: parent
                        placeholderText: "Enter Username"
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: passwordContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Password:"
                        color: "#eee"
                        anchors {
                            bottom: passwordContainer.top
                            left: passwordContainer.left
                        }
                    }
                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        placeholderText: "Enter Password"
                        echoMode: "Password"
                    }
                }

            }
            Rectangle {
                id: channelLayoutContainer
                Layout.preferredHeight: 160
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                Layout.topMargin: 20
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

                    anchors {
                        top: parent.top
                    }
                    ScrollView {
                        anchors.fill: parent
                        TextArea {
                            id: channelViewField
                            wrapMode: "Wrap"
                            selectByMouse: true
                            text: ""
                            color: "black"
                            readOnly: true
                        }
                    }
                }
                Rectangle {
                    id: channelInputContainer
                    height: 30
                    width: parent.width
                    color: "transparent"
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
                        Keys.onReturnPressed: add()
                        Keys.onEnterPressed: add()

                    }
                    Button {
                        id: addButton
                        width: 50
                        height: parent.height

                        anchors {
                            top: parent.top
                            right: parent.right
                        }
                        text: "Add"
                        onClicked: {
                            add()
                        }
                        background: Rectangle{
                            color: "#b55400"
                        }

                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: buttonContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    color: "transparent"
                    anchors {
                        centerIn: parent
                    }
                    RowLayout {
                        spacing: 2
                        anchors.fill: parent
                        Button {
                            id: clearAllButton
                            Layout.alignment: Qt.AlignHCenter
                            width: (parent.width / 2) - 1
                            height: parent.height - 2
                            text:  "Clear All"
                            onClicked: channelViewField.text = ""
                        }
                        Button {
                            id: clearLastButton
                            Layout.alignment: Qt.AlignHCenter
                            width: (parent.width / 2) - 1
                            height: parent.height - 2
                            text: "Clear Last"
                            onClicked: {
                                //make view remove last selection
                                clearLast();
                            }
                        }
                    }
                }

            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: selectorContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    color: "transparent"
                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -10
                    }
                    RowLayout {
                        anchors.fill: parent

                        RadioButton {
                            id: pushButton
                            text: qsTr("")
                            Layout.alignment: Qt.AlignLeft
                            onClicked: rep_type = "push"
                        }
                        RadioButton {
                            id: pushAndPullButton
                            text: qsTr("")
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: rep_type = "pushpull"
                        }
                        RadioButton {
                            id: pullButton
                            checked: true
                            text: qsTr("")
                            Layout.alignment: Qt.AlignRight
                            onClicked: rep_type = "pull"
                        }
                    }
                    Label {
                        id: pushLabel
                        text: "Push"
                        color: "#eee"
                        anchors {
                            top: selectorContainer.bottom
                            left: selectorContainer.left
                            leftMargin: 10
                        }
                    }
                    Label {
                        id: pullLabel
                        text: "Pull"
                        color: "#eee"
                        anchors {
                            top: selectorContainer.bottom
                            right: selectorContainer.right
                            rightMargin: 12
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

            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Button {
                    id: submitButton
                    height: parent.height / 2
                    width: parent.width / 4
                    text: "Submit"
                    anchors.centerIn: parent
                    onClicked: validate();
                }
            }
        }
    }
}
