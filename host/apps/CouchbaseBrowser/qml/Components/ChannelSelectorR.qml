import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3

Rectangle {
    property bool fillState: false
    radius: 5
    ColumnLayout {
        id: mainLayout
        height: parent.height
        width: parent.width - 2
        anchors.centerIn: parent
        visible: true
        spacing: 2
        Rectangle {
            id: searchBackground
            Layout.preferredHeight: 30
            Layout.preferredWidth: parent.width
            Layout.topMargin: 3
            Layout.alignment: Qt.AlignCenter
            border {
                width: 2
                color: "steelblue"
            }
            radius: 5
            RowLayout {
                spacing: 0
                anchors.fill: parent
                Button {
                    id: suggestButton
                    Layout.preferredHeight: parent.height - 5
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: height
                    onClicked: fillState = !fillState
                    background: Rectangle {
                        color: "transparent"
                    }
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        opacity: 0.5
                        source: "../Images/searchIcon.svg"
                        fillMode: Image.PreserveAspectFit
                    }
                }
                TextField {
                    id: searchField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    placeholderText: "Search"
                    background: Item {}
                    onPressed: {
                        fillState = true
                        hiddenContainer.visible = true
                    }
                }
            }
        }

        Rectangle {
            id: hiddenContainer
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: fillState
            ListView {
                width: parent.width
                height: parent.height - 2
                anchors.top: parent.top
                spacing: 2
                model: listModel
                delegate: listItem
            }
            Rectangle {
                id: seperator
                color: "black"
                height: 2
                width: parent.width
                anchors.bottom: parent.bottom
            }

        }
        Rectangle {
            id: inputContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            ListView {
                anchors.fill: parent
                spacing: 2
                model: listModel
                delegate: listItem
            }

        }
        Rectangle {
            id: userInputBackground
            Layout.preferredHeight: 30
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            radius: 5
            border {
                width: 2
                color: "limegreen"
            }
            RowLayout {
                spacing: 0
                anchors.fill: parent
                TextField {
                    id: channelEntryField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    placeholderText: "Enter channel name"
                    onPressed: {
                        fillState = false
                        hiddenContainer.visible = false
                    }
                    background: Item {}
                }
                Button {
                    id: dropDownButton
                    Layout.preferredHeight: parent.height - 5
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: height
                    background: Rectangle {
                        color: "transparent"
                    }
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        opacity: 0.5
                        source: "../Images/plusIcon.png"
                        fillMode: Image.PreserveAspectFit
                    }
                }

            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignCenter
            Button {
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Back"
            }
            Button {
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Submit"
            }
        }
    }
    Component {
        id: listItem
        Rectangle {
            width: parent.width - 15
            height: 25
            color: "steelblue"
            anchors.margins: 5
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                id: cancelButton
                width: 8
                height: 8
                source: "../Images/cancelIcon.png"
                anchors {
                    right: parent.right
                    rightMargin: 5
                    verticalCenter: parent.verticalCenter
                }
            }
            Text {
                anchors.centerIn: parent
                font.pixelSize: 15
                text: channel
            }
        }
    }
    ListModel {
        id: listModel
        ListElement {
            channel: "item 1"
        }
        ListElement {
            channel: "item 2"
        }
        ListElement {
            channel: "item 3"
        }

    }


}

