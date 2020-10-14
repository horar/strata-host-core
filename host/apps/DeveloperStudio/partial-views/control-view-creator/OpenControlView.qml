import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0

Rectangle {
    id: openProjectContainer

    property alias fileUrl: filePath.text
    property url url
    property string configFileName: "previousProjects.json"
    property var previousFileURL: { "projects" : [] }
    color: "#ccc"

    Component.onCompleted:  {
        loadSettings()
    }

    function saveSettings() {
        sgUserSettings.writeFile(configFileName, previousFileURL);
    }

    function loadSettings() {
        let config = sgUserSettings.readFile(configFileName)
        var projectsList  = JSON.parse(JSON.stringify(config))
        if(projectsList.projects) {
            for (var i = 0; i < projectsList.projects.length; ++i) {
                previousFileURL.projects.push(projectsList.projects[i])
                listModelForUrl.append({ url: previousFileURL.projects[i] })
            }
        }
    }

    function addToTheProjectList (fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if(previousFileURL.projects[i] === fileUrl) {
                return
            }
        }
        if(previousFileURL.projects.length > 5) {
            previousFileURL.projects.pop()
            listModelForUrl.remove(listModelForUrl.count - 1)
        }

        previousFileURL.projects.unshift(fileUrl)
        listModelForUrl.insert(0,{ url: fileUrl })
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

        SGText {
            id: recentProjText
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Recent Projects:"
            visible: (listModelForUrl.count > 0) ? true : false
        }

        ListView {
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height
            orientation: ListView.Vertical
            model:ListModel{
                id: listModelForUrl
            }
            highlightFollowsCurrentItem: true
            spacing: 10
            delegate:  Rectangle {
                id: rectangle
                color: "white"
                width: openProjectContainer.width - 40
                height: 40

                RowLayout {
                    anchors {
                        fill: rectangle
                        margins: 5
                    }

                    SGIcon {
                        Layout.preferredHeight: rectangle.height*.5
                        Layout.preferredWidth: Layout.preferredHeight
                        source: "qrc:/sgimages/file-blank.svg"
                    }

                    SGText {
                        Layout.fillWidth:true
                        text: model.url
                        elide:Text.ElideRight
                        horizontalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        maximumLineCount: 1
                        color:  urlMouseArea.containsMouse ?  "#bbb" : "black"
                    }
                }

                MouseArea {
                    id: urlMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        openProjectContainer.url = model.url
                        toolBarListView.currentIndex = toolBarListView.editTab
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
                        text: "Select a .QRC file..."
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
                        openProjectContainer.url = fileDialog.fileUrl
                        toolBarListView.currentIndex = toolBarListView.editTab
                        addToTheProjectList(fileDialog.fileUrl.toString())
                        filePath.text = "Select a .QRC file..."
                    }
                }
            }

            SGButton {
                text: "Cancel"

                onClicked: {
                    toolBarListView.currentIndex = -1
                }
            }
        }

        Item {
            // space filler
            Layout.fillHeight: true
        }
    }
}
