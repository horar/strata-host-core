import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0

import "qrc:/partial-views/general"

Rectangle {
    id: openProjectContainer

    property alias fileUrl: filePath.text
    property url url
    property string configFileName: "previousProjects.json"
    property var previousFileURL: { "projects" : [] }
    color: "#ccc"
    onVisibleChanged: {
        if(!openProjectContainer.visible) {
            alertMessage.visible = false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: alertMessage.visible = false
    }

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

    function removeFromProjectList(fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if(previousFileURL.projects[i] === fileUrl) {
                listModelForUrl.remove(i)
                previousFileURL.projects.splice(i,1)
                saveSettings()
                return
            }
        }
    }


    ColumnLayout {
        id:recentProjColumn
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

        SGNotificationToast {
            id: alertMessage
            Layout.preferredWidth: parent.width/1.5
            Layout.preferredHeight: 35
            interval : 0
            z:3
            color : "red"
            text : "This project does not exist anymore. Removing it from your recent projects..."
            visible: false
            MouseArea {
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.fill: alertMessage
                onClicked: alertMessage.visible = false
            }
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
                id: projectUrlContainer
                width: openProjectContainer.width - 40
                height: 40
                color: removeProjectMenu.opened  ? "lightgray" : "white"

                RowLayout {
                    anchors {
                        fill: projectUrlContainer
                        margins: 5
                    }

                    SGIcon {
                        Layout.preferredHeight: projectUrlContainer.height*.5
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

                Menu {
                    id: removeProjectMenu
                    width: {
                        var result = 0;
                        var padding = 0;
                        for (var i = 0; i < count; ++i) {
                            var item = itemAt(i);
                            result = Math.max(item.contentItem.implicitWidth, result);
                            padding = Math.max(item.padding, padding);
                        }
                        return result + padding * 2;
                    }
                    MenuItem {
                        text: "Remove Projects From Recent Project"
                        onTriggered: {
                            removeFromProjectList(editor.treeModel.url.toString())
                        }
                    }
                    MenuItem {
                        text: "Clear Recent Project List"
                        onTriggered: {
                            previousFileURL.projects = []
                            listModelForUrl.clear()
                            saveSettings()

                        }
                    }
                }


                MouseArea {
                    id: urlMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        editor.treeModel.url = model.url
                        if(mouse.button === Qt.RightButton) {
                            removeProjectMenu.popup()
                        }
                        else  {
                            if(!SGUtilsCpp.exists(SGUtilsCpp.urlToLocalFile(editor.treeModel.url))) {
                                alertMessage.visible = true
                                removeFromProjectList(editor.treeModel.url.toString())
                            }
                            else {
                                viewStack.currentIndex = editUseStrip.offset
                                editUseStrip.checkedIndices = 1
                            }
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
                        viewStack.currentIndex = editUseStrip.offset
                        editUseStrip.checkedIndices = 1
                        addToTheProjectList(fileDialog.fileUrl.toString())
                        filePath.text = "Select a .QRC file..."
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
