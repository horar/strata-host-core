import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

ColumnLayout {
    id: root
    z: 5

    spacing: 2

    property alias showButton: icon.visible
    property alias showLabel: label.visible
    property alias color: icon.iconColor
    property alias path: icon.source
    property alias placeholderText: inputField.placeholderText
    property alias label: label.text
    property alias userInput: inputField.text
    property color borderColor: "white"
    property bool isPassword: false
    property real iconSize: 0

    signal clicked()
    signal accepted()

    function clear(){
        inputField.text = ""
    }
    function isEmpty(){
        fieldBorder.border.color = (inputField.text === "") ? "red" : "transparent"
    }
    Label {
        id: label
        color: "#eee"
        visible: false
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

                selectByMouse: true
                validator: RegExpValidator { regExp: /(^$|^(?!\s*$).+)/ }
                background: Item {}
                Component.onCompleted: {
                    inputField.echoMode = isPassword ? TextInput.Password : TextInput.Normal
                }
                onAccepted: root.accepted()
            }
            SGIcon {
                id: icon
                Layout.preferredHeight: iconSize === 0 ? inputField.height - 5 : iconSize
                Layout.preferredWidth: iconSize === 0 ? Layout.preferredHeight : iconSize
                Layout.rightMargin: 5

                opacity: 0.5
                visible: false
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: icon.opacity = 1
                    onExited: icon.opacity = 0.5
                    onClicked: {
                        root.clicked()
                    }
                }
            }
        }
    }
}

