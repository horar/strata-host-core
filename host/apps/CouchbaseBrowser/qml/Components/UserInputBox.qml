import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    height: 30
    width: parent.width / 2

    property alias label: label.text
    property alias acceptPassword: inputField.echoMode
    property color borderColor: "transparent"
    property bool isPassword: false
    property string userInput: ""
    function clearField() {
        userInput = ""
    }
    function isEmpty() {
        userInput = inputField.text
        if (userInput === "") {
            fieldBackground.border.color = "red"
            borderColor = "red"
            return true
        }
        fieldBackground.border.color = "transparent"
        return false
    }
    Component.onCompleted: {
        if (isPassword === true) {
            inputField.echoMode = "Password"
        }
    }

    Label {
        id: label
        text: "Default:"
        color: "#eee"
        anchors {
            bottom: inputField.top
            left: inputField.left
        }
    }
    TextField {
        id: inputField
        anchors.fill: parent
        placeholderText: ("Enter " + label.text)
        text: userInput
        onActiveFocusChanged: {
            fieldBackground.border.color = activeFocus ? "#b55400" : "transparent"
        }
        background: Rectangle {
            id: fieldBackground
            border {
                width: 2
                color: borderColor
            }
        }
    }
}
