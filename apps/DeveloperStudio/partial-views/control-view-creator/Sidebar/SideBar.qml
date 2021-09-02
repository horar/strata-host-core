import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0
import QtQuick.Controls 1.4 as QtQC1
import QtQml.Models 2.12

import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0
import tech.strata.theme 1.0
import QtQuick.Controls.Styles 1.4

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/partial-views"

Item {
    id: sideBarRoot

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            sideBarContextMenu.item.popup()
        }
    }

    QtQC1.TreeView {
        id: treeView

        anchors.fill: parent

        model: treeModel
        backgroundVisible: false
        frameVisible: false
        alternatingRowColors: false
        style: TreeViewStyle {
            branchDelegate: Item {
                width: 12
                height: 12
                SGIcon {
                    anchors.fill: parent
                    iconColor: expandIconMouseArea.containsMouse ? "green" : "grey"
                    source: styleData.isExpanded ? "qrc:/sgimages/chevron-down.svg" : "qrc:/sgimages/chevron-right.svg"

                    MouseArea {
                        id: expandIconMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onClicked: {
                            if (!treeView.isExpanded(styleData.index)) {
                                treeView.expand(styleData.index)
                            } else {
                                treeView.collapse(styleData.index)
                            }
                        }
                    }
                }
            }
        }

        onRootIndexChanged: {
            treeModel.rootIndex = rootIndex
        }

        onCollapsed: {
            treeModel.removeEmptyChildren(index)
        }

        function selectItem(index) {
            treeView.selection.clearCurrentIndex()
            treeView.selection.select(index, ItemSelectionModel.Rows)
            treeView.selection.setCurrentIndex(index, ItemSelectionModel.Current)
        }

        Connections {
            target: treeModel

            // When a row is inserted, we want to focus on that row
            onRowsInserted: {
                let index = treeModel.index(first, 0, parent)

                // Only set editing to true if we have created a new file and the filename is empty
                let node = treeModel.getNode(index)
                if (node.filename === "") {
                    if (!treeView.isExpanded(parent)) {
                        treeView.expand(parent)
                    }
                    Qt.callLater(treeView.selectItem, index)
                } else {
                    let idx = openFilesModel.findTabByFilepath(node.filepath)
                    if (idx >= 0) {
                        let modelIndex = openFilesModel.index(idx, 0)
                        openFilesModel.setData(modelIndex, node.uid, SGFileTabModel.UIdRole)
                        openFilesModel.setData(modelIndex, true, SGFileTabModel.ExistsRole)
                    }
                }
            }

            onFileDeleted: {
                // If the file is open, then set the `exists` property of the tab to false
                let idx = openFilesModel.findTabByFilepath(path)
                if (idx >= 0) {
                    openFilesModel.setData(openFilesModel.index(idx, 0), false, SGFileTabModel.ExistsRole)
                }
            }
        }

        selection: ItemSelectionModel {
            model: treeView.model
        }

        headerDelegate: Item { }

        rowDelegate: Rectangle {
            height: 30
            color: styleData.selected && !model.editing ? "#CCCCCC" : "transparent"
        }

        itemDelegate: SideBarDelegate { }

        QtQC1.TableViewColumn {
            id: mainTreeColumn
            role: "filename"
            width: treeView.width - 2
            resizable: false
        }
    }

    FileDialog {
        id: existingFileDialog

        nameFilters: ["Qrc Item (*.qml *.js *.png *.jpg *.jpeg *.svg *.json *.txt *.gif *.html *.csv)"]
        selectExisting: true
        selectMultiple: false
        folder: treeModel.projectDirectory

        property variant callerIndex: null

        onAccepted: {
            if (callerIndex) {
                if (callerIndex === -1) {
                    createFilePopup.fileAddRequested = true
                    treeModel.insertChild(fileUrl, -1, true, treeModel.index(callerIndex))
                    callerIndex = null
                } else {
                    createFilePopup.fileAddRequested = true
                    treeModel.insertChild(fileUrl, -1, true, callerIndex)
                    callerIndex = null
                }
            }
        }
    }

    Loader {
        id: sideBarContextMenu
        source: "./SideBarContextMenu.qml"
    }

    CreateFilePopup {
        id: createFilePopup
        visible: false
    }

    // TODO: add feature to move file to trash instead of permanently deleting it (requires Qt >= 5.15)
    // https://jira.onsemi.com/browse/CS-2055
    SGConfirmationPopup {
        id: confirmDeleteFile
        modal: true
        padding: 0
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: Overlay.overlay

        acceptButtonColor: Theme.palette.red
        acceptButtonHoverColor: Qt.darker(acceptButtonColor, 1.25)
        acceptButtonText: "Permanently delete"
        cancelButtonText: "Cancel"
        titleText: "Delete " + deleteType

        popupText: "Are you sure you want to delete " + deleteType.toLowerCase() + " <i>" + fileName + "</i>?<br><b>Warning: " + deleteType.toLowerCase() + " will be permanently deleted.</b>"

        property var deleteType: "File" // "File" or "Folder"
        property string fileName: ""
        property var uid
        property var row
        property var index

        onPopupClosed: {
            if (closeReason === acceptCloseReason) {
                openFilesModel.closeTab(uid)
                treeModel.deleteFile(row, index)
            }
        }
    }

    function openControlQML() {
        // Find the Control.qml file and select it
        for (let i = 0; i < treeModel.root.childCount(); i++) {
            if (treeModel.root.childNode(i).filename === "Control.qml") {
                let idx = treeModel.index(i)
                let node = treeModel.root.childNode(i)

                openFilesModel.addTab(node.filename, node.filepath, node.filetype, node.uid)
                // Need to use callLater here because the model indices haven't been set yet
                Qt.callLater(treeView.selectItem, idx)
                return
            }
        }

        console.error("Project does not have Control.qml at the top level")
        missingControlQml.open()
    }

    RenameFilePopup {
        id: renameFilePopup
        visible: false
    }
}
