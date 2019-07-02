import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    id: root
    anchors.fill: parent
    color: "transparent"

    property alias model: keySelectorComboBox.model
    property alias currentIndex: keySelectorComboBox.currentIndex

    ColumnLayout {
        id: comboBoxContainer
        width: parent.width
        height: implicitHeight
        spacing: 5
        Label {
            id: keySelectorLabel
            text: "<b>Select Document:</b>"
            color: "white"
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 5
            Layout.topMargin: 10
        }
        ComboBox {
            id: keySelectorComboBox
            width: parent.width
            Layout.alignment: Qt.AlignHCenter
            model:[]
            delegate: ItemDelegate {
                width: keySelectorComboBox.width
                contentItem: Text {
                    width: keySelectorComboBox.width
                    text: modelData
                    color: "#b55400"
                }
                highlighted: keySelectorComboBox.highlightedIndex === index
            }
            background: Rectangle {
                implicitWidth: keySelectorComboBox.width
                implicitHeight: 40
                color: "lightgrey"
                border.color: keySelectorComboBox.pressed ? "#17a81a" : "#b55400"
                radius: 2
            }
            popup: Popup {
                height: Math.min(root.height,contentHeight)
                width: keySelectorComboBox.width
                contentItem:  ListView {
                    clip: true
                    implicitHeight: contentHeight
                    implicitWidth: keySelectorComboBox.width
                    model: keySelectorComboBox.popup.visible ? keySelectorComboBox.delegateModel : null
                    currentIndex: keySelectorComboBox.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
                }
                background: Rectangle {
                    color: "lightgrey"
                }
            }
        } 
    }
}
