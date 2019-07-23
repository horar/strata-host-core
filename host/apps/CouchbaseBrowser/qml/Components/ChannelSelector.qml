import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

Rectangle {
    id: root

    signal submit()
    signal goBack()

    property alias model: listModel
    property var channels: []
    property int selected: 0

    color: "#222831"

    ColumnLayout {
        id: mainLayout
        height: parent.height - 15
        width: parent.width - 15
        anchors.centerIn: parent
        visible: true
        spacing: 4
        Rectangle {
            id: searchBackground
            Layout.preferredHeight: 30
            Layout.preferredWidth: parent.width
            Layout.topMargin: 3
            Layout.alignment: Qt.AlignCenter
            border {
                color: searchField.activeFocus ? "steelblue" : "transparent"
                width: 2
            }
            radius: 5
            RowLayout {
                spacing: 0
                anchors.fill: parent
                Button {
                    id: searchButton
                    Layout.preferredHeight: parent.height - 10
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.leftMargin: 5
                    background: Image {
                        anchors.fill: parent
                        source: "../Images/searchIcon.svg"
                        fillMode: Image.PreserveAspectFit
                        opacity: searchButton.hovered ? 1 : 0.5
                    }
                    onClicked: {
                        hiddenContainer.visible = true
                        suggestionList.forceLayout()
                    }
                }
                TextField {
                    id: searchField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    placeholderText: "Search"
                    background: Item {}
                    onPressed: searchButton.clicked()
                    Popup {
                        id: hiddenContainer
                        visible: false
                        x: (parent.width - searchButton.width - width) / 2
                        y: parent.height - 1
                        width: searchBackground.width - 100
                        height: suggestionList.height + 20
                        background: DropShadow {
                            height: hiddenContainer.height
                            width: hiddenContainer.width
                            source: popupBackground
                            horizontalOffset: 5
                            verticalOffset: 5
                            spread: 0
                            color: "#aa000000"
                            Rectangle {
                                id: popupBackground
                                anchors.fill: parent
                                color: "white"
                            }
                        }

                        CustomListView {
                            id: suggestionList
                            width: parent.width
                            height: Math.min(inputContainer.height - 20,(listModel.count-root.selected)*30)
                            anchors.top: parent.top
                            model: listModel
                            displaySelected: false
                            onClicked: {
                                selected++
                                suggestionList.forceLayout()
                                channels.push(listModel.get(index).channel)
                                if (listModel.count === root.selected) {
                                    hiddenContainer.visible = false
                                }
                            }
                        }

                        opacity: visible ? 1.0 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.Linear
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: inputContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            radius: 5
            CustomListView {
                id: selectedList
                anchors {
                    fill: parent
                    topMargin: 5
                    bottomMargin: 5
                }
                model: listModel
                displayUnselected: false
                displayCancelBtn: true
                enableMouseArea: false
                onCancel: {
                    root.selected--
                    channels.splice(channels.indexOf(listModel.get(index).channel),1)
                }
            }

        }
        Rectangle {
            id: userInputBackground
            Layout.preferredHeight: 30
            Layout.fillWidth: true
            radius: 5
            border {
                width: 2
                color: channelEntryField.activeFocus ? "limegreen" : "transparent"
            }
            RowLayout {
                spacing: 0
                anchors.fill: parent
                TextField {
                    id: channelEntryField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    placeholderText: "Enter channel name"
                    onAccepted: addButton.clicked()
                    background: Item {}
                }

                Button {
                    id: addButton
                    Layout.preferredHeight: parent.height - 10
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 5
                    opacity: 0.5
                    background: Image {
                        anchors.fill: parent
                        source: "../Images/plusIcon.svg"
                        fillMode: Image.PreserveAspectFit
                        opacity: addButton.hovered ? 1 : 0.5
                    }
                    onClicked: {
                        if(channelEntryField.text !== ""){
                            listModel.append({ "channel" : channelEntryField.text, "selected" : true})
                            selected++
                            channels.push(channelEntryField.text)
                            channelEntryField.text = ""
                        }
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 25
            Button {
                id: backButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Back"
                onClicked: goBack()
                background: Rectangle {
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0 ; color: backButton.hovered ? "#fff" : "#eee"}
                        GradientStop { position: 1 ; color: backButton.hovered ? "#aaa" : "#999" }
                    }
                }
            }
            Button {
                id: submitButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Submit"
                onClicked: submit()
                background: Rectangle {
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0 ; color: submitButton.hovered ? "#fff" : "#eee"}
                        GradientStop { position: 1 ; color: submitButton.hovered ? "#aaa" : "#999" }
                    }
                }
            }
            Button {
                id: clearButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Clear All"
                onClicked: listModel.clear()
                background: Rectangle {
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0 ; color: clearButton.hovered ? "#fff" : "#eee"}
                        GradientStop { position: 1 ; color: clearButton.hovered ? "#aaa" : "#999" }
                    }
                }
            }
        }
    }

    ListModel {
        id: listModel
        ListElement {
            channel: "1"
            selected: false
        }
        ListElement {
            channel: "2"
            selected: false
        }
        ListElement {
            channel: "3"
            selected: false
        }
    }
}
