import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Rectangle {
    id: root
    implicitHeight: downloadControlsContainer.height + downloadControlsContainer.anchors.topMargin
    implicitWidth: parent.width
    color: Qt.darker("#666")

    function resetModel(model) {
        buttons.radioButtons.model = model
    }

    MouseArea {
        // Blocks clickthroughs
        anchors { fill: root }
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: false
    }

    Item {
        id: downloadControlsContainer
        width: root.width - 20
        height: contentColumn.height
        anchors {
            top: root.top
            topMargin: 20
            horizontalCenter: root.horizontalCenter
        }

        Column {
            id: contentColumn
            anchors {
                horizontalCenter: downloadControlsContainer.horizontalCenter
            }
            width: downloadControlsContainer.width
            spacing: 20

            Text {
                id: title
                text: "<b>Select files for download:</b>"
                color: "white"
                font {
                    pixelSize: 16
                }
            }

            Item {
                id: radioButtonIndent
                height: buttons.height
                width: buttons.width

                SGRadioButtonContainer {
                    id: buttons

                    textColor: "white"      // Default: "#000000"  (black)
                    radioColor: "white"     // Default: "#000000"  (black)
                    exclusive: false         // Default: true

                    radioGroup: Column {
                        id: column
                        spacing: contentColumn.spacing

                        property alias selectAll: selectAll
                        property alias downloadListView: downloadListView
                        property alias model: downloadListView.model

                        property bool anythingChecked: false  // represents both if nothing or >0 things are checked
                        property bool allChecked: false

                        SGRadioButton {
                            id: selectAll
                            text: "Select All"
                            checked: allChecked
                            onCheckedChanged: {
                                if (checked) {
                                    for (var i = 0; i < downloadListView.contentItem.children.length; i++){
                                        if (downloadListView.contentItem.children[i].objectName === "radioButton"){
                                            downloadListView.contentItem.children[i].checked = true;
                                        }
                                    }
                                } else if ( allChecked ) {
                                    for (var j = 0; j < downloadListView.contentItem.children.length; j++){
                                        if (downloadListView.contentItem.children[j].objectName === "radioButton"){
                                            downloadListView.contentItem.children[j].checked = false;
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: listViewContainer
                            border {
                                width: 1
                                color: "#ccc"
                            }
                            color: "transparent"
                            height: downloadListView.height + 20
                            width: contentColumn.width
                            clip: true

                            ListView {
                                id: downloadListView
                                anchors {
                                    centerIn: listViewContainer
                                }
                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AlwaysOn
                                }
                                height: Math.min(600, contentItem.childrenRect.height)
                                width: listViewContainer.width - 20

                                section {
                                    property: "dirname"
                                    delegate: Item {
                                        id: sectionContainer
                                        width: downloadListView.width - 20
                                        height: delegateText.height + 10

                                        Item {
                                            id: sectionBackground
                                            anchors {
                                                topMargin: 5
                                                fill: parent
                                                bottomMargin: 1
                                            }

                                            Rectangle {
                                                id: underline
                                                color: "#33b13b"
                                                height: 1
                                                width: sectionBackground.width
                                                anchors {
                                                    bottom: sectionBackground.bottom
                                                }
                                            }
                                        }

                                        Text {
                                            id: delegateText
                                            text: "<b>" + section + "</b>"
                                            color: "white"
                                            anchors {
                                                verticalCenter: sectionContainer.verticalCenter
                                                right: sectionContainer.right
                                            }
                                            width: sectionContainer.width - 5
                                            wrapMode: Text.Wrap
                                            font.capitalization: Font.Capitalize
                                        }
                                    }
                                }

                                delegate:  Item {
                                    id: delegateContainer
                                    height: Math.max(delegateRadio.height+10, delegateText.height + 10)
                                    width: downloadListView.width - 20
                                    property alias checked: delegateRadio.checked
                                    property alias text: delegateText.text
                                    property string uri: model.uri
                                    objectName: "radioButton"

                                    Rectangle {
                                        anchors {
                                            fill: delegateContainer
                                            bottomMargin: 1
                                        }

                                        color: mouseArea.pressed ? "#888": mouseArea.containsMouse ? "#666" : "#444"
                                    }

                                    SGRadioButton {
                                        id: delegateRadio
                                        text: ""
                                        onCheckedChanged: {
                                            whichChecked ()
                                        }
                                        anchors {
                                            left: delegateContainer.left
                                            leftMargin: 5
                                            verticalCenter: delegateContainer.verticalCenter
                                        }
                                        ButtonGroup.group: buttonGroup
                                    }

                                    Text {
                                        id: delegateText
                                        text: model.filename
                                        color: "white"
                                        anchors {
                                            verticalCenter: delegateRadio.verticalCenter
                                            left: delegateRadio.right
                                            leftMargin: 10
                                            right: delegateContainer.right
                                            rightMargin: 5
                                        }
                                        wrapMode: Text.Wrap
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors {
                                            fill: delegateText
                                        }
                                        hoverEnabled: true
                                        onClicked: {
                                            delegateRadio.checked = !delegateRadio.checked
                                        }
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    }
                                }

                                ButtonGroup {
                                    id: buttonGroup
                                    exclusive: false
                                }
                            }
                        }

                        function whichChecked() { // This functionality is integrated in QT 5.11 in buttonGroup.checkState, but for now, have to manually do it in 5.10
                            var all = true
                            var none = true
                            var anything = false
                            for (var i = 0; i < downloadListView.contentItem.children.length; i++){
                                if (downloadListView.contentItem.children[i].objectName === "radioButton" && downloadListView.contentItem.children[i].checked === false) {
                                    all = false
                                } else if (downloadListView.contentItem.children[i].objectName === "radioButton" && downloadListView.contentItem.children[i].checked === true) {
                                    anything = true;
                                    none = false
                                }
                            }
                            if (none) {
                                anythingChecked = false
                                allChecked = false
                            } else if (all) {
                                anythingChecked = true
                                allChecked = true
                            } else if (anything) {
                                anythingChecked = true
                                allChecked = false
                            }
                        }
                    }
                }
            }

            Button {
                id: fileDialogButton
                text: "Select Where to Download"
                onClicked: fileDialog.visible = true
                anchors {
                    horizontalCenter: contentColumn.horizontalCenter
                }
            }

            TextEdit {
                id: selectedDir
                text: "No Download Directory Selected"
                color: "white"
                wrapMode: TextEdit.Wrap
                width: downloadControlsContainer.width
            }

            Button {
                id: download
                enabled: buttons.radioButtons.anythingChecked && fileDialog.fileUrl != ""
                anchors {
                    horizontalCenter: contentColumn.horizontalCenter
                }
                opacity: enabled ? 1 : .2

                contentItem: Text {
                    color: "white"
                    text: "Download"
                    opacity: 1
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                background: Rectangle {
                    color: "#33b13b"
                    implicitWidth: 100
                    implicitHeight: 40
                }

                onClicked: {
                    downloadActiveCoverup.visible = true
                    progressBarFake.start()

                    var download_json = {
                        "hcs::cmd":"download_files",
                        "payload": []
                    }

                    for (var i = 0; i < buttons.radioButtons.downloadListView.contentItem.children.length; i++){
                        if (buttons.radioButtons.downloadListView.contentItem.children[i].objectName === "radioButton" && buttons.radioButtons.downloadListView.contentItem.children[i].checked) {
                            download_json.payload.push({
                                                           "file":buttons.radioButtons.downloadListView.contentItem.children[i].uri,
                                                           "path":fileDialog.fileUrl.toString(),
                                                           "name":buttons.radioButtons.downloadListView.contentItem.children[i].text
                                                       })
                        }
                    }

                    console.log("sending the jwt json to hcs",JSON.stringify(download_json))
                    coreInterface.sendCommand(JSON.stringify(download_json))
                }
            }

            Item {
                id: spacer7
                height: 1
                width: contentColumn.width
            }
        }
    }

    Rectangle {
        id: downloadActiveCoverup
        color: Qt.darker("#666")
        visible: false
        anchors {
            fill: downloadControlsContainer
        }

        MouseArea {
            id: mouseDisabler
            anchors {
                fill: downloadActiveCoverup
            }
        }

        Rectangle {
            id: progressBarContainer
            height: 30
            border {
                width: 1
                color: "white"
            }
            color: "transparent"
            width: downloadActiveCoverup.width
            anchors {
                centerIn: downloadActiveCoverup
            }

            Rectangle {
                id: progressBar
                color: "#33b13b"
                height: progressBarContainer.height - 6
                anchors {
                    verticalCenter: progressBarContainer.verticalCenter
                    left: progressBarContainer.left
                    leftMargin: 3
                }
                width: 1

                PropertyAnimation {
                    id: progressBarFake
                    target: progressBar
                    property: "width"
                    from: 1
                    to: progressBarContainer.width - 6
                    duration: 2000
                }
            }
        }

        Text {
            id: progressStatus
            text: "" + (100 * progressBar.width / (progressBarContainer.width - 6)).toFixed(0) + "% complete"
            color: "white"
            anchors {
                bottom: progressBarContainer.top
                right: progressBarContainer.right
                bottomMargin: 3
            }
        }

        Button {
            id: progressButton
            anchors {
                top: progressBarContainer.bottom
                topMargin: 30
                horizontalCenter: progressBarContainer.horizontalCenter
            }
            text: "Back"
            onClicked: downloadActiveCoverup.visible = false
        }
    }


    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home
        selectFolder: true
        selectMultiple: false
        onAccepted: {
            selectedDir.text = "Files will be downloaded to: " + fileDialog.fileUrl
            //            console.log("You chose: " + fileDialog.fileUrl)
        }
        onRejected: {
            //            console.log("Canceled")
        }
    }
}
