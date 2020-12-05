import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "navigation"
import "qrc:/js/constants.js" as Constants
import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: controlViewCreatorRoot

    property bool isConfirmCloseOpen: false
    property bool rccInitialized: false
    property bool recompileRequested: false
    property var debugPlatform: ({
      deviceId: Constants.NULL_DEVICE_ID,
      classId: ""
    })

    onDebugPlatformChanged: {
        recompileControlViewQrc();
    }
    property alias openFilesModel: editor.openFilesModel
    property alias confirmClosePopup: confirmClosePopup

    SGUserSettings {
        id: sgUserSettings
        classId: "controlViewCreator"
        user: NavigationControl.context.user_id
    }

    ConfirmClosePopup {
        id: confirmClosePopup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: mainWindow.contentItem

        titleText: "You have unsaved changes in " + unsavedFileCount + " files."
        popupText: "Your changes will be lost if you choose to not save them."
        acceptButtonText: "Save all"

        property int unsavedFileCount

        onPopupClosed: {
            if (closeReason === confirmClosePopup.closeFilesReason) {
                controlViewCreator.openFilesModel.closeAll()
                mainWindow.close()
            } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                controlViewCreator.openFilesModel.saveAll()
                mainWindow.close()
            }
            isConfirmCloseOpen = false
        }
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

            ColumnLayout {
                id: toolBarListView

                anchors.fill: parent
                spacing: 5

                property int currentIndex: 0
                property int startTab: 0
                property int editTab: 1
                property int viewTab: 2
                property bool recompiling: false

                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case startTab:
                        viewStack.currentIndex = 0
                        break;
                    case editTab:
                        viewStack.currentIndex = 1
                        break;
                    case viewTab:
                        if (rccInitialized == false) {
                            toolBarListView.recompiling = true
                            recompileControlViewQrc();
                        } else {
                            viewStack.currentIndex = 2
                        }

                        break;
                    default:
                        viewStack.currentIndex = 0
                        break;
                    }
                }

                /*****************************************
                  Main Navigation Items
                    * Start
                    * Editor
                    * View
                *****************************************/
                Repeater {
                    id: mainNavItems

                    model: [
                        { imageSource: "qrc:/sgimages/list.svg", imageText: "Start" },
                        { imageSource: "qrc:/sgimages/edit.svg", imageText: "Edit" },
                        { imageSource: "qrc:/sgimages/eye.svg", imageText: "View" },
                    ]

                    delegate: SGSideNavItem {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        modelIndex: index
                        iconLeftMargin: index === toolBarListView.editTab ? 7 : 0
                    }
                }

                /*****************************************
                  Additional items go below here, but above filler
                *****************************************/

                Item {
                    id: filler
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                SideNavFooter {
                    id: footer
                    Layout.preferredHeight: 70
                    Layout.minimumHeight: footer.implicitHeight
                    Layout.fillWidth: true
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

            Editor {
                id: editor
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Rectangle {
                id: controlViewContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "white"

                Loader {
                    id: controlViewLoader
                    anchors.fill: parent
                    asynchronous: true

                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            // Tear Down creation context
                            delete NavigationControl.context.class_id
                            delete NavigationControl.context.device_id

                            toolBarListView.recompiling = false
                            if (toolBarListView.currentIndex === toolBarListView.viewTab
                                    || source === NavigationControl.screens.LOAD_ERROR) {
                                viewStack.currentIndex = 2
                            }
                        } else if (status === Loader.Error) {
                            // Tear Down creation context
                            delete NavigationControl.context.class_id
                            delete NavigationControl.context.device_id

                            toolBarListView.recompiling = false
                            console.error("Error while loading control view")
                            setSource(NavigationControl.screens.LOAD_ERROR,
                                      { "error_message": "Failed to load control view" }
                            );
                        }
                    }
                }
            }
        }
    }

    function recompileControlViewQrc () {
        if (editor.fileTreeModel.url.toString() !== '') {
            recompileRequested = true
            sdsModel.resourceLoader.recompileControlViewQrc(editor.fileTreeModel.url)
        }
    }

    function loadDebugView (compiledRccFile) {
        controlViewLoader.setSource("")

        let uniquePrefix = new Date().getTime().valueOf()
        uniquePrefix = "/" + uniquePrefix

        // Register debug control view object
        if (!sdsModel.resourceLoader.registerResource(compiledRccFile, uniquePrefix)) {
            console.error("Failed to register resource")
            return
        }

        let qml_control = "qrc:" + uniquePrefix + "/Control.qml"

        Help.setClassId(debugPlatform.deviceId)
        NavigationControl.context.class_id = debugPlatform.classId
        NavigationControl.context.device_id = debugPlatform.deviceId

        controlViewLoader.setSource(qml_control, Object.assign({}, NavigationControl.context))
    }

    function blockWindowClose() {
        let unsavedCount = editor.openFilesModel.getUnsavedCount();
        if (unsavedCount > 0 && !controlViewCreatorRoot.isConfirmCloseOpen) {
            confirmClosePopup.unsavedFileCount = unsavedCount;
            confirmClosePopup.open();
            controlViewCreatorRoot.isConfirmCloseOpen = true;
            return true
        }
        return false
    }
}
