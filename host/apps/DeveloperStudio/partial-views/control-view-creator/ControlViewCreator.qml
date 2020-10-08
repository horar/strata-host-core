import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import "qrc:/js/navigation_control.js" as NavigationControl

Rectangle {
    id: controlViewCreatorRoot
    objectName: "ControlViewCreator"

    property url currentFileUrl: ""

    SGUserSettings {
        id: sgUserSettings
        classId: "controlViewCreator"
        user: NavigationControl.context.user_id
    }

    ColumnLayout {
        anchors {
            fill: parent
        }
        spacing:  0

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 70
            Layout.maximumWidth: 70
            Layout.alignment: Qt.AlignTop
            color: "#666"

            ListView {
                id: toolBarListView

                anchors.fill: parent
                spacing: 4
                orientation: Qt.Vertical
                currentIndex: -1

                property int openTab: 0
                property int newTab: 1
                property int editTab: 2
                property int viewTab: 3

                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case openTab:
                        viewStack.currentIndex = 1
                        break;
                    case newTab:
                        viewStack.currentIndex = 2
                        break;
                    case editTab:
                        viewStack.currentIndex = 3
                        break;
                    case viewTab:
                        if (currentFileUrl != fileModel.url) {
                            recompileControlViewQrc()
                            currentFileUrl = fileModel.url
                        }
                        viewStack.currentIndex = 4
                        break;
                    default:
                        viewStack.currentIndex = 0
                        break;
                    }
                }

                model: [
                    { imageSource: "qrc:/sgimages/file-blank.svg", imageText: "Open" },
                    { imageSource: "qrc:/sgimages/file-add.svg", imageText: "New" },
                    { imageSource: "qrc:/sgimages/edit.svg", imageText: "Edit" },
                    { imageSource: "qrc:/sgimages/eye.svg", imageText: "View" }
                ]

                delegate: Rectangle {
                    width: parent.width
                    height: 60

                    color: ListView.isCurrentItem ? "#999" : "transparent"
                    enabled: modelData.imageText === "Edit" && fileModel.url.toString() === "" ? false : true


                    ColumnLayout {
                        anchors.margins: 5
                        anchors.fill: parent

                        SGIcon {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.preferredHeight: 30
                            Layout.leftMargin: modelData.imageText === "Edit" ? 6 : 0
                            Layout.fillWidth: true

                            iconColor: parent.enabled ? "white" : Qt.rgba(102, 102, 102, 0.25)
                            source: modelData.imageSource
                        }

                        SGText {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter

                            text: modelData.imageText
                            color: parent.enabled ? "white" : Qt.rgba(102, 102, 102, 0.30)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: parent.enabled

                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.OpenHandCursor
                        onClicked: {
                            toolBarListView.currentIndex = index
                        }
                    }
                }
            }
        }

        StackLayout {
            id: viewStack
            Layout.fillHeight: true
            Layout.fillWidth: true

            Start {
                id: startContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            OpenControlView {
                id: openProjectContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            NewControlView {
                id: newControlViewContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Editor {
                id: editor
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Rectangle {
                id: controlViewContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "lightcyan"

                SGText {
                    anchors {
                        centerIn: parent
                    }
                    fontSizeMultiplier: 2
                    text: "Control view from RCC loaded here"
                    opacity: .25
                }
            }
        }
    }

    function recompileControlViewQrc () {
        if (editor.treeModel.url !== '') {
            let compiledRccFile = sdsModel.resourceLoader.recompileControlViewQrc(editor.treeModel.url)
            if (compiledRccFile !== '') {
                loadDebugView(compiledRccFile)
            } else {
                NavigationControl.removeView(controlViewContainer)
                let error_str = sdsModel.resourceLoader.getLastLoggedError()
                sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlViewContainer, {"error_message": error_str});
            }
        }
    }

    function loadDebugView (compiledRccFile) {
        NavigationControl.removeView(controlViewContainer)

        let uniquePrefix = new Date().getTime().valueOf()
        uniquePrefix = "/" + uniquePrefix

        // Register debug control view object
        if (!sdsModel.resourceLoader.registerResource(compiledRccFile, uniquePrefix)) {
            console.error("Failed to register resource")
            return
        }

        let qml_control = "qrc:" + uniquePrefix + "/Control.qml"
        let obj = sdsModel.resourceLoader.createViewObject(qml_control, controlViewContainer);
        if (obj === null) {
            let error_str = sdsModel.resourceLoader.getLastLoggedError()
            sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlViewContainer, {"error_message": error_str});
            console.error("Could not load view: " + error_str)
        }
    }
}
