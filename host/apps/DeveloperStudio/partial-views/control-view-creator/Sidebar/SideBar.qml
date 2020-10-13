import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0
import QtQuick.Controls 1.4 as QtQC1
import QtQml.Models 2.12

import tech.strata.SGQrcTreeModel 1.0

Rectangle {
    id: sideBarRoot

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: treeViewContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"

            QtQC1.TreeView {
                id: treeView
                model: treeModel
                backgroundVisible: false
                alternatingRowColors: false
                width: treeViewContainer.width
                height: treeViewContainer.height

                selection: ItemSelectionModel {
                    model: treeModel
                }

                rowDelegate: Rectangle {
                    height: 25
                    color: styleData.selected ? "#CCCCCC" : "transparent"
                    focus: styleData.selected
                    onFocusChanged: {
                        forceActiveFocus()
                    }
                }

                itemDelegate: SideBarDelegate { }

                QtQC1.TableViewColumn {
                    title: treeModel.root ? treeModel.root.filename : "Project Files"
                    role: "filename"
                    width: 250
                }
            }

            Connections {
                target: treeModel

                // When a row is inserted, we want to focus on that row
                onRowsInserted: {
                    let index = treeModel.index(first, 0, parent);
                    treeView.selection.clearCurrentIndex();
                    treeView.selection.select(index, ItemSelectionModel.Rows);
                    treeView.selection.setCurrentIndex(index, ItemSelectionModel.Current);
                    // Only set editing to true if we have created a new file and the filename is empty
                    let node = treeModel.getNode(index);
                    if (node.filename === "") {
                        treeModel.setData(index, true, SGQrcTreeModel.EditingRole);
                    } else {
                        if (!node.isDir) {
                            if (treeView.isExpanded(parent)) {
                                openFilesModel.addTab(node.filename,
                                                      node.filepath,
                                                      node.filetype,
                                                      node.uid);
                            }
                        }
                    }
                }

                onFileAdded: {
                    if (parentPath === treeModel.projectDirectory) {
                        for (let i = 0; i < treeModel.root.childNodes.count; i++) {
                            if (treeModel.root.childNodes[i].filepath === path) {
                                // Don't add the file because it already exists
                                return;
                            }
                        }
                        treeModel.insertChild(path, -1, true, treeView.rootIndex);
                        treeModel.startSave();
                    }
                }
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
                    treeModel.insertChild(fileUrl, -1, true, callerIndex)
                    callerIndex = null;
                }
            }
        }
    }
}
