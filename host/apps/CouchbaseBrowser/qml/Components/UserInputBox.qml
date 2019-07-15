import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

ColumnLayout {
    id: root
//    color: "transparent"
    z: 5
    spacing: 2

    signal buttonClick()

    property color borderColor: "white"

    property bool showButton: false
    property bool showLabel: false
    property bool isPassword: false

    property alias path: icon.source
    property alias placeholderText: inputField.placeholderText
    property alias label: label.text
    property alias userInput: inputField.text

    function clear(){
        inputField.text = ""
    }
    function isEmpty(){
        fieldBorder.border.color = (inputField.text === "") ? "red" : "transparent"
    }

    Label {
        id: label
        color: "#eee"
    }

    Rectangle {
        id: fieldBorder
        Layout.preferredHeight: row.height + 10
        Layout.preferredWidth: root.width
        border.width: 3
        border.color: "transparent"

        RowLayout {
            id:row
            width: parent.width
            anchors {
                verticalCenter: fieldBorder.verticalCenter
            }

            TextField {
                id: inputField
                Layout.fillWidth: true
                Component.onCompleted: {
                    inputField.echoMode = isPassword ? TextInput.Password : TextInput.Normal
                }
                background: Item {}
            }
            Image {
                id: icon
                Layout.preferredHeight: inputField.height - 5
                Layout.preferredWidth: Layout.preferredHeight
                Layout.rightMargin: 5
                MouseArea {
                    id: mouseArea
                    onClicked: {
                        buttonClick()
                    }
                    anchors.fill: parent
                }
                source: "../Images/openFolderIcon.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}

