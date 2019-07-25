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
    property alias searchKeyword: inputField.text

    color: "#222831"
    function closePopup() {
        hiddenContainer.close()
    }

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
                color: inputField.activeFocus ? "steelblue" : "transparent"
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
                    id: inputField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    placeholderText: "Search or Enter new channel"
                    background: Item {}
                    onPressed: searchButton.clicked()
                    onAccepted: addButton.clicked()
                    onTextChanged: {
                        suggestionList.searchKeyword = text
                        hiddenContainer.visible = true
                    }
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
                            height: Math.min(inputContainer.height - 20,contentHeight)
                            anchors.top: parent.top
                            model: listModel
                            displaySelected: false
                            onClicked: {
                                suggestionList.forceLayout()
                                channels.push(listModel.get(index).text)
                            }
                            onContentHeightChanged: hiddenContainer.visible = contentHeight !== 0
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
                        if(inputField.text !== ""){
                            listModel.append({ "text" : inputField.text, "selected" : true})
                            channels.push(inputField.text)
                            inputField.text = ""
                            hiddenContainer.visible = false
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
                    channels.splice(channels.indexOf(listModel.get(index).text),1)
                }
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 25
            CustomButton {
                id: backButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Back"
                onClicked: goBack()
            }
            CustomButton {
                id: submitButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Submit"
                onClicked: submit()
            }
            CustomButton {
                id: clearButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Clear All"
                onClicked: {
                    searchKeyword = ""
                    for (let i = 0; i<model.count; i++) model.get(i).selected = false
                    channels = []
                }
            }
        }
    }

    ListModel {
        id: listModel
    }
}
