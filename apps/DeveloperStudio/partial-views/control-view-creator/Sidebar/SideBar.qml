import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0
import QtQuick.Controls 1.4 as QtQC1
import QtQml.Models 2.12

import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0

Item {
    id: sideBarRoot

    QtQC1.TreeView {
        id: treeView

        anchors.fill: parent

        model: treeModel
        backgroundVisible: false
        alternatingRowColors: false

        onRootIndexChanged: {
            treeModel.rootIndex = rootIndex
        }

        onCollapsed: {
            treeModel.removeEmptyChildren(index);
        }

        function selectItem(index) {
            treeView.selection.clearCurrentIndex();
            treeView.selection.select(index, ItemSelectionModel.Rows);
            treeView.selection.setCurrentIndex(index, ItemSelectionModel.Current);
        }

        Connections {
            target: treeModel

            // When a row is inserted, we want to focus on that row
            onRowsInserted: {
                let index = treeModel.index(first, 0, parent);

                // Only set editing to true if we have created a new file and the filename is empty
                let node = treeModel.getNode(index);
                if (node.filename === "") {
                    if (!treeView.isExpanded(parent)) {
                        treeView.expand(parent)
                    }
                    Qt.callLater(treeView.selectItem, index)
                } else {
                    let idx = openFilesModel.findTabByFilepath(node.filepath);
                    if (idx >= 0) {
                        let modelIndex = openFilesModel.index(idx, 0);
                        openFilesModel.setData(modelIndex, node.uid, SGFileTabModel.UIdRole);
                        openFilesModel.setData(modelIndex, true, SGFileTabModel.ExistsRole);
                    }
                }
            }

            onFileDeleted: {
                // If the file is open, then set the `exists` property of the tab to false
                let idx = openFilesModel.findTabByFilepath(path);
                if (idx >= 0) {
                    openFilesModel.setData(openFilesModel.index(idx, 0), false, SGFileTabModel.ExistsRole)
                }
            }
        }

        selection: ItemSelectionModel {
            model: treeView.model
        }

        headerDelegate: Rectangle {
            height: 25
            color: "#777"

            Text {
                width: parent.width
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 5
                verticalAlignment: Text.AlignVCenter

                text: SGUtilsCpp.fileName(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
                font.pointSize: 12
                font.bold: true
                font.capitalization: Font.AllUppercase
                color: "white"
                elide: Text.ElideRight
            }
        }

        rowDelegate: Rectangle {
            height: 30
            color: styleData.selected && !model.editing ? "#CCCCCC" : "transparent"
        }

        itemDelegate: SideBarDelegate { }

        QtQC1.TableViewColumn {
            id: mainTreeColumn
            title: treeModel.root ? treeModel.root.filename : "Project Files"
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
                treeModel.insertChild(fileUrl, -1, true, callerIndex)
                callerIndex = null;
            }
        }
    }


    function openControlQML() {
        // Find the Control.qml file and select it
        for (let i = 0; i < treeModel.root.childCount(); i++) {
            if (treeModel.root.childNode(i).filename === "Control.qml") {
                let idx = treeModel.index(i);
                let node = treeModel.root.childNode(i);

                openFilesModel.addTab(node.filename, node.filepath, node.filetype, node.uid)
                // Need to use callLater here because the model indices haven't been set yet
                Qt.callLater(treeView.selectItem, idx);
                return;
            }
        }

        console.error("Project does not have Control.qml at the top level")
        missingControlQml.open();
    }
}
