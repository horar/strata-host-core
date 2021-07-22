import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0

import "Editor/"
import "Sidebar/"
import "qrc:/js/platform_selection.js" as PlatformSelection
import "../"

Item {
    id: editorRoot

    property alias editorToolBar: editorToolBar
    property alias openFilesModel: openFilesModel
    property alias fileTreeModel: treeModel
    property alias errorRectangle: parsingErrorRect
    property alias sideBar: sideBar

    SGQrcTreeModel {
        id: treeModel

        onModelAboutToBeReset: {
            openFilesModel.clear()
            parsingErrorRect.errorMessage = ""
            parsingErrorRect.visible = false
        }

        onErrorParsing: {
            parsingErrorRect.errorMessage = error;
            parsingErrorRect.visible = true
            openProjectContainer.url = ""
        }

        onUrlChanged: {
            debugPanel.collapse()
        }
    }

    SGFileTabModel {
        id: openFilesModel

        onTabOpened: {
            treeModel.startWatchingPath(SGUtilsCpp.urlToLocalFile(filepath))
        }

        onTabClosed: {
            treeModel.stopWatchingPath(SGUtilsCpp.urlToLocalFile(filepath))
        }
    }

    SGSortFilterProxyModel {
        id: connectedPlatforms
        sourceModel: PlatformSelection.platformSelectorModel
        invokeCustomFilter: true

        function filterAcceptsRow(index) {
            return sourceModel.get(index).connected;
        }
    }

    SGSplitView {
        anchors.fill: parent

        Shortcut {
            sequence: "Ctrl+R"
            onActivated: {
                if (cvcUserSettings.openViewOnBuild) {
                   viewStack.currentIndex = 2
                }
                recompileControlViewQrc()
            }
        }

        SideBar {
            id: sideBar
            Layout.fillHeight: true
            Layout.minimumWidth: 250
            Layout.maximumWidth: parent.width * 0.75
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0

            Rectangle {
                color: editorToolBar.buttonColor
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                Layout.maximumHeight: 26

                RowLayout {
                    id: editorToolBar
                    anchors {
                        fill: parent
                    }
                    spacing: 0

                    property color buttonColor: "#777"

                    signal saveClicked()
                    signal undoClicked()
                    signal redoClicked()

                    Repeater {
                        id: mainButtons

                        model: [
                            { buttonType: "save", iconSource: "qrc:/sgimages/save.svg" },
                            { buttonType: "undo", iconSource: "qrc:/sgimages/undo.svg" },
                            { buttonType: "redo", iconSource: "qrc:/sgimages/redo.svg" }
                        ]

                        delegate: Button {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height

                            enabled: openFilesModel.count > 0

                            background: Rectangle {
                                radius: 0
                                color: editorToolBar.buttonColor
                            }

                            SGIcon {
                                id: icon
                                anchors.fill: parent
                                anchors.margins: 4
                                iconColor: parent.enabled ? "white" : Qt.rgba(255, 255, 255, 0.4)
                                source: modelData.iconSource
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: parent.enabled
                                hoverEnabled: true
                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onPressed: {
                                    icon.iconColor = Qt.darker(icon.iconColor, 1.5)
                                }

                                onReleased: {
                                    icon.iconColor = "white"
                                }

                                onClicked: {
                                    switch (modelData.buttonType) {
                                        case "save":
                                            editorToolBar.saveClicked()
                                            break
                                        case "undo":
                                            editorToolBar.undoClicked()
                                            break
                                        case "redo":
                                            editorToolBar.redoClicked()
                                            break
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        // space filler
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    SGComboBox {
                        Layout.fillHeight: true
                        Layout.topMargin: 0
                        Layout.preferredWidth: 350

                        model: connectedPlatforms
                        placeholderText: "Select a platform to connect to..."
                        enabled: model.count > 0
                        textRole: "verbose_name"
                        boxColor: editorToolBar.buttonColor
                        textColor: "white"

                        onCurrentIndexChanged: {
                            let platform = connectedPlatforms.get(currentIndex);
                            controlViewCreatorRoot.debugPlatform = {
                                deviceId: platform.device_id,
                                classId: platform.class_id
                            };
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 45
                Layout.minimumHeight: 45
                Layout.fillWidth: true
                x: 2.5
                color: "#ccc"

                ListView {
                    id: fileTabRepeater
                    model: openFilesModel

                    anchors.fill: parent

                    clip: true
                    orientation: ListView.Horizontal
                    layoutDirection: Qt.LeftToRight
                    spacing: 1
                    currentIndex: openFilesModel.currentIndex

                    delegate: Button {
                        id: fileTab
                        hoverEnabled: true

                        property color color: "#aaaaaa"
                        property int modelIndex: index

                        MouseArea {
                            anchors.fill: fileTab
                            acceptedButtons: Qt.MiddleButton

                            onClicked: {
                                 closeFileTab(index, model)
                            }
                        }

                        onClicked: {
                            openFilesModel.currentIndex = index
                        }

                        background: Rectangle {
                            implicitHeight: 45
                            color: fileTab.ListView.isCurrentItem ? "white" : fileTab.color
                        }

                        contentItem: Item {
                            implicitWidth: tabText.paintedWidth + tabText.anchors.leftMargin + 3 + closeFileIcon.implicitWidth + closeFileIcon.anchors.rightMargin
                            anchors.verticalCenter: parent.verticalCenter

                            SGText {
                                id: tabText
                                text: model.filename + (!model.exists ? " <font color='red'>(deleted)</font>" : "")
                                color: "black"
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 5
                                }
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                textFormat: Text.RichText
                            }

                            SGIcon {
                                id: closeFileIcon
                                source: "qrc:/sgimages/times-circle.svg"
                                height: tabText.paintedHeight
                                width: height
                                implicitWidth: height
                                visible: fileTab.hovered
                                iconColor: "black"
                                anchors {
                                    left: tabText.right
                                    leftMargin: 4
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 2
                                }
                                verticalAlignment: Qt.AlignVCenter

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        cursorShape = Qt.PointingHandCursor
                                    }

                                    onClicked: {
                                        closeFileTab(index, model)
                                    }
                                }
                            }

                            SGIcon {
                                id: unsavedChangesIcon
                                source: "qrc:/sgimages/asterisk.svg"
                                height: tabText.paintedHeight * .75
                                width: height
                                implicitWidth: height
                                iconColor: "black"
                                visible: !closeFileIcon.visible && model.unsavedChanges
                                anchors {
                                    left: tabText.right
                                    leftMargin: 4
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 2
                                }
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: parsingErrorRect
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#666"
                visible: false

                property string errorMessage: ""

                SGText {
                    id: errorText

                    anchors {
                        centerIn: parent
                    }

                    color: "white"
                    font.bold: true
                    fontSizeMultiplier: 2
                    text: "Error: " + parsingErrorRect.errorMessage
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ConfirmClosePopup {
                id: confirmClosePopup
                parent: controlViewCreatorRoot
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                titleText: "Do you want to save the changes made to " + filename + (!exists ? " (deleted)?" : "?")

                property string filename: ""
                property int index
                property bool exists

                onPopupClosed: {
                    if (closeReason === confirmClosePopup.closeFilesReason) {
                        openFilesModel.closeTabAt(index)
                    } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                        openFilesModel.saveFileAt(index, true)
                    }
                    controlViewCreatorRoot.isConfirmCloseOpen = false
                }
            }

            StackLayout {
                id: fileStack
                Layout.fillHeight: true
                Layout.fillWidth: true
                currentIndex: openFilesModel.currentIndex
                visible: !parsingErrorRect.visible

                Repeater {
                    id: fileEditorRepeater
                    model: openFilesModel

                    delegate: Component {
                        Loader {
                            id: fileLoader
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            source: {
                                switch (model.filetype) {
                                    case "svg":
                                    case "jpg":
                                    case "jpeg":
                                    case "png":
                                    case "gif":
                                        return "./Editor/ImageContainer.qml"
                                    case "qml":
                                    case "csv":
                                    case "html":
                                    case "txt":
                                    case "json":
                                    case "ts":
                                        return "./Editor/TextEditorContainer.qml"
                                    default:
                                        return "./Editor/UnsupportedFileType.qml"
                                }
                            }
                        }
                    }
                }

                NoActiveFile {
                    id: noActiveFile
                }
            }
        }
    }

    function closeFileTab(index, model) {
        if (model.unsavedChanges && !controlViewCreatorRoot.isConfirmCloseOpen) {
            confirmClosePopup.filename = model.filename
            confirmClosePopup.index = index
            confirmClosePopup.exists = model.exists
            confirmClosePopup.open()
            controlViewCreatorRoot.isConfirmCloseOpen = true
        } else {
            openFilesModel.closeTabAt(index);
        }
    }
}
