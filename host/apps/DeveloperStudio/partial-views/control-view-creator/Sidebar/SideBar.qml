import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0
import QtQuick.Controls 1.4 as QtQC1
import QtQml.Models 2.12

import tech.strata.SGQrcTreeModel 1.0

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
                    treeView.selectItem(index)
                    treeModel.setData(index, true, SGQrcTreeModel.EditingRole);
                }
            }

            onModelReset: {
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
                editor.errorRectangle.errorMessage = "Project does not have Control.qml at the top level. This means that the control view cannot be built or viewed."
                editor.errorRectangle.visible = true
            }

            onFileDeleted: {
                openFilesModel.closeTab(uid)
            }
        }

        selection: ItemSelectionModel {
            model: treeModel
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
            height: 25
            color: styleData.selected ? "#CCCCCC" : "transparent"
            focus: styleData.selected
            onFocusChanged: {
                forceActiveFocus()
            }
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
}
