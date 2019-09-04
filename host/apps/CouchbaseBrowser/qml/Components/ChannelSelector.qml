import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

Rectangle {
    id: root

    color: "#222831"

    property alias model: listModel
    property alias searchKeyword: inputField.text
    property var channels: []
    property int channelsLength: 0

    signal submit()
    signal goBack()

    function closePopup() {
        hiddenContainer.close()
    }
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent

        visible: true
        spacing: 10
        Rectangle {
            id: searchBackground
            Layout.preferredHeight: 30
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter

            border {
                color: inputField.activeFocus ? "steelblue" : "transparent"
                width: 2
            }
            radius: 5
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Button {
                    id: searchButton
                    Layout.preferredHeight: parent.height - 10
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.leftMargin: 5

                    onClicked: hiddenContainer.visible = true
                    background: Image {
                        anchors.fill: parent
                        source: "../Images/magnifying-glass-icon.svg"
                        fillMode: Image.PreserveAspectFit
                        opacity: searchButton.hovered ? 1 : 0.5
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
                        if (text.length !== 0) {
                            hiddenContainer.visible = true
                        }
                    }
                    Popup {
                        id: hiddenContainer
                        width: searchBackground.width - searchButton.width - addButton.width
                        height: suggestionList.height + 20
                        x: 0
                        y: parent.height - 1

                        visible: false
                        opacity: visible ? 1.0 : 0
                        padding: 10
                        onVisibleChanged: {
                            if (visible) {
                                suggestionList.positionViewAtBeginning()
                            }
                        }
                        background: DropShadow {
                            height: hiddenContainer.height
                            width: hiddenContainer.width
                            horizontalOffset: 3
                            verticalOffset: 3

                            source: popupBackground
                            spread: 0
                            radius: 10
                            samples: 21
                            color: "#aa000000"
                            Rectangle {
                                id: popupBackground
                                anchors.fill: parent

                                color: "white"
                                border {
                                    width: 1
                                    color: "lightgrey"
                                }
                            }
                        }

                        CustomListView {
                            id: suggestionList
                            width: parent.width
                            height: Math.min(inputContainer.height - 20,contentHeight+topMargin+bottomMargin)
                            anchors.top: parent.top

                            model: listModel
                            displaySelected: false
                            onClicked: {
                                channels.push(listModel.get(index).text)
                                channelsLength = channels.length
                                selectedList.positionViewAtEnd()
                            }
                            onContentHeightChanged: hiddenContainer.visible = contentHeight !== 0
                        }
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

                        source: "../Images/plus-icon.svg"
                        fillMode: Image.PreserveAspectFit
                        opacity: addButton.hovered ? 1 : 0.5
                    }
                    onClicked: {
                        if(inputField.text !== ""){
                            let existed = false
                            for (let i=0; i<listModel.count; i++)
                            if (listModel.get(i).text === inputField.text) {
                                existed = true;
                                if (!listModel.get(i).selected) {
                                    hiddenContainer.visible = false
                                    listModel.get(i).selected = true;
                                    channels.push(inputField.text)
                                    channelsLength = channels.length
                                }
                                break;
                            }
                            if (!existed) {
                                hiddenContainer.visible = false
                                listModel.append({ "text" : inputField.text, "selected" : true})
                                channels.push(inputField.text)
                                channelsLength = channels.length
                            }
                            inputField.text = ""
                            selectedList.positionViewAtEnd()
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
                anchors.fill:parent
                anchors.margins: 10

                model: listModel
                displayUnselected: false
                displayCancelBtn: true
                enableMouseArea: false
                onCancel: {
                    channels.splice(channels.indexOf(listModel.get(index).text),1)
                    channelsLength = channels.length
                }
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter
            CustomButton {
                id: backButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80

                text: "Back"
                onClicked: {
                    searchKeyword = ""
                    for (let i = 0; i<model.count; i++) {
                        model.get(i).selected = false
                    }
                    channels = []
                    channelsLength = 0
                    goBack()
                }
            }
            CustomButton {
                id: submitButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80

                text: "Submit"
                enabled: channelsLength !== 0
                onClicked: submit()
            }
            CustomButton {
                id: clearButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80

                text: "Clear All"
                enabled: channelsLength !== 0
                onClicked: {
                    searchKeyword = ""
                    for (let i = 0; i<model.count; i++) {
                        model.get(i).selected = false
                    }
                    channels = []
                    channelsLength = 0
                }
            }
        }
    }

    ListModel {
        id: listModel
    }
}
