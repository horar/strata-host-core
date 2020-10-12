import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

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

    RowLayout {
        anchors {
            fill: parent
        }
        spacing:  0

        Rectangle {
            id: tool
            Layout.fillHeight: true
            Layout.preferredWidth: 70
            Layout.maximumWidth: 70
            Layout.alignment: Qt.AlignTop
            color: "#444"

            ListView {
                id: toolBarListView

                anchors.fill: parent

                spacing: 5
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
                        if (currentFileUrl != editor.treeModel.url) {
                            recompileControlViewQrc();
                            currentFileUrl = editor.treeModel.url
                        } else {
                            viewStack.currentIndex = 4
                        }

                        break;
                    default:
                        viewStack.currentIndex = 0
                        break;
                    }
                }

                model: [
                    { imageSource: "qrc:/sgimages/folder-open-solid.svg", imageText: "Open" },
                    { imageSource: "qrc:/sgimages/folder-plus.svg", imageText: "New" },
                    { imageSource: "qrc:/sgimages/edit.svg", imageText: "Edit" },
                    { imageSource: "qrc:/sgimages/eye.svg", imageText: "View" },
                ]

                delegate: SGSideNavItem {
                    iconLeftMargin: index === toolBarListView.editTab ? 7 : 0
                }

                footer: Item {
                    implicitHeight: divider.height + recompileNavButton.height
                    implicitWidth: toolBarListView.width

                    Rectangle {
                        id: divider
                        height: 1
                        width: toolBarListView.width
                        color: "lightgrey"
                        anchors.top: parent.top
                    }

                    SGSideNavItem {
                        id: recompileNavButton
                        iconText: "Build"
                        iconSource: "qrc:/sgimages/bolt.svg"
                        enabled: editor.treeModel.url.toString() !== "" && !recompiling
                        anchors.top: divider.bottom

                        property bool recompiling: false

                        function onClicked() {
                            recompiling = true;
                            recompileControlViewQrc();
                        }

                        Connections {
                            target: sdsModel.resourceLoader

                            onFinishedRecompiling: {
                                if (filepath !== '') {
                                    loadDebugView(filepath)
                                } else {
                                    NavigationControl.removeView(controlViewContainer)
                                    let error_str = sdsModel.resourceLoader.getLastLoggedError()
                                    sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlViewContainer, {"error_message": error_str});
                                }

                                recompileNavButton.recompiling = false

                                if (toolBarListView.currentIndex === toolBarListView.viewTab) {
                                    viewStack.currentIndex = 4
                                }
                            }
                        }
                    }
                }

                footerPositioning: ListView.OverlayFooter
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
            sdsModel.resourceLoader.recompileControlViewQrc(editor.treeModel.url)
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
