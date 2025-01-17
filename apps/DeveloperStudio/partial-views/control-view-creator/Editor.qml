/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0

import "editor/"
import "sidebar/"
import "qrc:/js/platform_selection.js" as PlatformSelection
import "../"

Item {
    id: editorRoot

    property alias editorToolBar: editorToolBar
    property alias openFilesModel: openFilesModel
    property alias fileTreeModel: treeModel
    property alias errorRectangle: parsingErrorRect
    property alias sideBar: sideBar
    property bool editQRCEnabled: true

    SGQrcTreeModel {
        id: treeModel

        onModelAboutToBeReset: {
            parsingErrorRect.errorMessage = ""
            parsingErrorRect.visible = false
        }

        onErrorParsing: {
            parsingErrorRect.errorMessage = error
            parsingErrorRect.visible = true
            openProjectContainer.url = ""
        }

        onUrlChanged: {
            debugMenuWindow = false
            isDebugMenuOpen = false
            openFilesModel.closeAll()
            editor.editQRCEnabled = true
        }
    }

    SGFileTabModel {
        id: openFilesModel

        onTabOpened: {
            treeModel.startWatchingPath(SGUtilsCpp.urlToLocalFile(filepath))
        }

        onTabClosed: {
            // always listen for debugMenuSource changes in order to update DebugMenu.qml
            if (filepath !== fileTreeModel.debugMenuSource) {
                treeModel.stopWatchingPath(SGUtilsCpp.urlToLocalFile(filepath))
            }
        }
    }

    SGSortFilterProxyModel {
        id: connectedPlatforms
        sourceModel: PlatformSelection.platformSelectorModel
        invokeCustomFilter: true

        function filterAcceptsRow(index) {
            return sourceModel.get(index).connected
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Shortcut {
            sequence: "Ctrl+R"
            enabled: editor.fileTreeModel.url.toString() !== ''
            onActivated: {
                recompileControlViewQrc()
                if (cvcUserSettings.openViewOnBuild && !confirmBuildClean.opened) {
                    viewStack.currentIndex = 2
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            Layout.maximumHeight: 26
            color:  "#777"

            TopBar {
                id: editorToolBar
                anchors.fill: parent
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            SGSplitView {
                anchors.fill: parent

                SideBar {
                    id: sideBar
                    Layout.fillHeight: true
                    implicitWidth: 200
                    Layout.minimumWidth: 25
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: parent.width * 0.5
                    spacing: 0

                    Rectangle {
                        id: fileTree
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
                                                return "./editor/ImageContainer.qml"
                                            case "qml":
                                            case "csv":
                                            case "html":
                                            case "txt":
                                            case "json":
                                            case "qrc":
                                            case "ts":
                                                return "./editor/TextEditorContainer.qml"
                                            default:
                                                return "./editor/UnsupportedFileType.qml"
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
            if (model.filepath === treeModel.url) {
                editQRCEnabled = true
            }
            openFilesModel.closeTabAt(index)
        }
    }
}
