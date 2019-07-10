import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    height: 30
    width: parent.width / 2

    property alias label: label.text
    property alias userInput: inputField.text
    property alias acceptPassword: inputField.echoMode
    property color borderColor: "transparent"
    property bool isPassword: false
    function clearField(){
        inputField.text = ""
    }
    Component.onCompleted: {
        if(isPassword === true){
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
