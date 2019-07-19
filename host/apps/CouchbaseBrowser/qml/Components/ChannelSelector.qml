import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

Rectangle {
    id: root

    property bool showRemoveButton: true
    signal submit()
    signal goBack()

    color: "#222831"
    anchors {
        margins: 2
    }
    border {
        color: "silver"
        width: 1
    }
    Rectangle {
        id: hiddenContainer
        visible: false
        width: searchBackground.width - 100
        height: inputContainer.height - 50
        border {
            width: 1
            color: "black"
        }
        z: 2
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 43
        }
        layer.enabled: true
        layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 5
                        verticalOffset: 3
                    }
        ListView {
            width: parent.width
            height: parent.height - 10
            clip: true
            anchors {
                top: parent.top
                topMargin: 5
                bottomMargin: 5
            }
            spacing: 4
            model: suggestionModel
            delegate: listItem
        }

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
                width: 2
                color: "transparent"
            }
            radius: 5
            RowLayout {
                spacing: 0
                anchors.fill: parent
                Button {
                    Layout.preferredHeight: parent.height - 5
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: height
                    Layout.leftMargin: 5
                    background: Rectangle {
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onHoveredChanged: {
                                suggestButton.opacity = containsMouse ? 1 : 0.5
                            }
                            onClicked: {
                                hiddenContainer.visible = !hiddenContainer.visible
                            }

                        }
                        color: "transparent"
                    }
                    Image {
                        id: suggestButton
                        anchors {
                            fill: parent
                            margins: 3
                        }
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
                    focus: false
                    onFocusChanged: {
                        searchBackground.border.color = focus ? "steelblue" : "transparent"
                    }
                    background: Item {}
                    onPressed: {
                        hiddenContainer.visible = true
                        showRemoveButton = false
                    }
                }
            }
        }

        Rectangle {
            id: inputContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            radius: 5
            z: 1
            ListView {
                clip: true
                anchors {
                    topMargin: 5
                    fill: parent
                    bottomMargin: 5
                }
                spacing: 4
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
                    focus: true
                    Keys.onReturnPressed: {
                        listModel.append({"channel":channelEntryField.text,"selected":false})
                        channelEntryField.text = ""
                    }
                    onFocusChanged: {
                        userInputBackground.border.color = focus ? "limegreen" : "transparent"
                    }
                    onPressed: {
                        hiddenContainer.visible = false
                    }
                    background: Item {}
                }
                Button {
                    id: dropDownButton
                    Layout.preferredHeight: parent.height - 5
                    Layout.rightMargin: 5
                    Layout.alignment: Qt.AlignVCenter
                    opacity: 0.5
                    Layout.preferredWidth: height
                    background: Rectangle {
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onHoveredChanged: {
                                dropDownButton.opacity = containsMouse ? 1 : 0.5
                            }
                            onClicked: {
                                listModel.append({ "channel" : channelEntryField.text, "selected" : false })
                                channelEntryField.text = ""
                            }
                        }
                        color: "transparent"
                    }
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        opacity: 0.5
                        source: "../Images/plusIcon.svg"
                        fillMode: Image.PreserveAspectFit
                    }
                }

            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignCenter
            Layout.bottomMargin: 25
            Button {
                id: backButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                text: "Back"
                onClicked: {
                    root.visible = false
                    goBack()
                }
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
                onClicked: {
                    root.visible = false
                    submit()
                }
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
                onClicked: {
                    listModel.clear()
                }
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
    Component {
        id: listItem
        Rectangle {
            id: listItemBackground
            clip: true
            width: parent.width - 10
            height: 25
            color: "steelblue"
            opacity: 0.8
            anchors.margins: 5
            radius: 13
            Component.onCompleted: {
                cancelButton.visible = showRemoveButton ? true : false
            }
            border {
                width: 2
                color: "transparent"
            }
            anchors.horizontalCenter: parent.horizontalCenter
            layer.enabled: true
            MouseArea {
                id: delegateButton
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if(selected === false){
                        listItemBackground.opacity = containsMouse ? 1 : 0.8
                    }

                }
                onClicked: {
                    selected = !selected
                    listItemBackground.border.color = selected === true ? "limegreen" : "transparent"
                    listItemBackground.opacity = selected === true ? 1 : 0.8
                }
            }
            layer.effect: DropShadow {
                            transparentBorder: true
                            horizontalOffset: 5
                            verticalOffset: 3
                        }
            Image {
                id: cancelButton
                width: 12
                height: 12
                source: "../Images/cancelIcon_white.svg"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: cancelButton.source = containsMouse ? "../Images/cancelIcon_red.svg" : "../Images/cancelIcon_white.svg"
                    onClicked: listModel.remove(index)
                }
                anchors {
                    right: parent.right
                    rightMargin: 5
                    verticalCenter: parent.verticalCenter
                }
            }
            TextField {
                anchors.centerIn: parent
                anchors {
                    rightMargin: 25
                    leftMargin: 25
                }
                font.pixelSize: 15
                readOnly: true
                background: Rectangle{
                    color: "transparent"
                }
                color: "#eee"
                text: channel
            }
        }
    }
    ListModel {
        id: listModel
    }
    ListModel {
        id: suggestionModel
        ListElement {
            channel: "selection 1"
            selected: false
        }
        ListElement {
            channel: "selection 2"
            selected: false
        }
        ListElement {
            channel: "selection 3"
            selected: false
        }
        ListElement {
            channel: "selection 4"
            selected: false
        }
    }
}

