import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0
import tech.strata.SGQrcListModel 1.0

Rectangle {
    id: openProjectContainer

    property alias fileUrl: filePath.text
    property string configFileName: "previousProjects.json"
    property var previousFileURL: { "projects" : [] }
    property var projectsList : ""
    color: "#ccc"


    Component.onCompleted:  {
        loadSettings()

        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            listModel.append ({ name: previousFileURL.projects[i] })
        }

    }




    function saveSettings() {
        console.info(previousFileURL,JSON.stringify(previousFileURL))
        sgUserSettings.writeFile(configFileName, previousFileURL);
    }

    function loadSettings() {
        let config = sgUserSettings.readFile(configFileName)
        projectsList  = JSON.parse(JSON.stringify(config))
        if(projectsList.projects.length !== undefined) {
            for (var i = 0; i < projectsList.projects.length; ++i) {
                previousFileURL.projects.push(projectsList.projects[i])
            }
        }
    }

    function addToTheProjectList (fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if(previousFileURL.projects[i] === fileUrl) {
                console.info("it's the same")
                return
            }
        }
        return previousFileURL.projects.push(fileUrl)

    }

    Component.onDestruction: {
        saveSettings()
    }


    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 10

        SGText {
            color: "#666"
            fontSizeMultiplier: 2
            text: "Open Control View Project"
        }

        Rectangle {
            // divider line
            color: "#333"
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }


        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height/7
            color: "transparent"
            ListView{
                id: data
                anchors.fill: parent
                orientation: ListView.Vertical
                model: ListModel{
                    id: listModel
                }
                delegate:  SGText{
                    text: model.name
                    textFormat: Text.RichText
                    // color: mouseArea.focus ? "#17a81a" : "#21be2b"

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onReleased: {
                            if (containsMouse)
                                console.info("Hovering");
                            else console.info("ll");
                        }

                        onClicked: {
                            console.info(model.name)
                            fileModel.url = model.name
                            viewStack.currentIndex = editUseStrip.offset
                            editUseStrip.checkedIndices = 1
                        }
                    }
                }
            }

        }


        SGAlignedLabel {
            Layout.topMargin: 20
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Select control view project .QRC file:"
            target: directoryInput

            RowLayout {
                id: directoryInput

                SGButton {
                    text: "Select"
                    onClicked: {
                        fileDialog.open()
                    }
                }

                FileDialog {
                    id: fileDialog
                    nameFilters: ["*.qrc"]
                    selectMultiple: false
                    selectFolder: false

                    onAccepted: {
                        filePath.text = fileDialog.fileUrl
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 40
                    color: "#eee"
                    border.color: "#333"
                    border.width: 1

                    TextInput {
                        id: filePath
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 10
                        }
                        text: fileDialog.fileUrl.toString() === "" ? "Select a .qrc file" : fileDialog.fileUrl.toString()
                        color: "#333"
                    }
                }
            }
        }

        RowLayout {
            Layout.topMargin: 20
            Layout.fillWidth: false
            spacing: 20

            SGButton {
                text: "Open Project"

                onClicked: {
                    if (fileDialog.fileUrl.toString() !== "") {
                        fileModel.url = fileDialog.fileUrl
                        viewStack.currentIndex = editUseStrip.offset
                        editUseStrip.checkedIndices = 1
                        addToTheProjectList(fileUrl)
                    }
                }
            }

            SGButton {
                text: "Cancel"

                onClicked: {
                    viewStack.currentIndex = 0
                }
            }
        }

        Item {
            // space filler
            Layout.fillHeight: true
        }


    }


}
