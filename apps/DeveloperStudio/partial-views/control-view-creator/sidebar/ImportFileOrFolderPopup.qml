/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0

import "qrc:/partial-views"

SGStrataPopup {
    id: importFileOrFolderPopup
    modal: true
    headerText: "Import File(s) Or Folder"
    closePolicy: Popup.CloseOnEscape
    focus: true
    width: 300
    height: 280
    anchors.centerIn: Overlay.overlay

    property var callerIndex: null
    property var viewState: "File" // "File" or "Folder"
    property var importPaths: []

    onClosed: {
        callerIndex = null
        viewState = "File"
        filenameInfobox.text = ""
        importPaths = []
        addToQrcCheckbox.checked = false
    }

    onViewStateChanged: {
        filenameInfobox.text = ""
        importPaths = []
    }

    contentItem: ColumnLayout {
        id: column
        width: parent.width

        SGText {
            text: "Select to Import:"
        }

        RowLayout {
            SGButton {
                id: importFileButton
                text: "File(s)"
                checkable: true
                checked: importFileOrFolderPopup.viewState == "File"

                onClicked: {
                    importFileOrFolderPopup.viewState = "File"
                }
            }

            SGButton {
                id: importFolderButton
                text: "Folder"
                checkable: true
                checked: importFileOrFolderPopup.viewState == "Folder"

                onClicked: {
                    importFileOrFolderPopup.viewState = "Folder"
                }
            }
        }

        ColumnLayout {
            implicitWidth: parent.width
            Layout.preferredHeight: 200

            RowLayout {
                id: filenameRow
                spacing: 5
                Layout.fillWidth: true

                SGButton {
                    id: browseButton
                    text: "Browse"

                    onClicked: {
                        importFileDialog.open()
                    }
                }

                SGInfoBox {
                    id: filenameInfobox
                    text: ""
                    implicitWidth: 175
                    readOnly: true
                    enabled: true
                    contextMenuEnabled: true
                    placeholderText: importFileOrFolderPopup.viewState + " Name"

                    onAccepted: {
                        if (importButton.enabled) {
                            importButton.clicked()
                        }
                    }
                }
            }

            CheckBox {
                id: addToQrcCheckbox
                text: qsTr("Add selected " + (importFileOrFolderPopup.viewState == "File" ? "file(s)" : "folder") + " to project QRC")
                checked: false
            }

            SGText {
                text: (importFileOrFolderPopup.viewState === "File" ? "File(s)" : "Folder") + " will be " + (addToQrcCheckbox.checked ? "copied and added to project QRC" : "copied to project directory")
            }

            SGButton {
                id: importButton
                text: "Import " + (importFileOrFolderPopup.viewState == "File" ? "File(s)" : "Folder")
                enabled: importFileOrFolderPopup.importPaths.length > 0

                onClicked: {
                    if (callerIndex == null) {
                        return
                    }

                    for (var fileItr = 0; fileItr < importFileDialog.fileUrls.length; ++fileItr) {
                        let success
                        if (callerIndex === -1) {
                            success = treeModel.insertChild(importFileDialog.fileUrls[fileItr], -1, addToQrcCheckbox.checked, treeModel.index(callerIndex))
                        } else {
                            success = treeModel.insertChild(importFileDialog.fileUrls[fileItr], -1, addToQrcCheckbox.checked, callerIndex)
                        }

                        if (!success) {
                            console.error("Failed to insert:", importFileDialog.fileUrls[fileItr])
                        }
                    }

                    treeModel.startSave()
                    callerIndex = null
                    importFileOrFolderPopup.close()
                }
            }
        }
    }

    FileDialog {
        id: importFileDialog

        nameFilters: ["Qrc Item (*.qml *.js *.png *.jpg *.jpeg *.svg *.json *.txt *.gif *.html *.csv)"]
        selectExisting: true
        selectMultiple: importFileOrFolderPopup.viewState === "File"
        selectFolder: importFileOrFolderPopup.viewState === "Folder"
        folder: treeModel.projectDirectory

        onAccepted: {
            if (importFileDialog.fileUrls.length == 1) {
                filenameInfobox.text = importFileDialog.fileUrl
                importFileOrFolderPopup.importPaths = [importFileDialog.fileUrl]
            } else {
                filenameInfobox.text = importFileDialog.fileUrls.length + " files selected"
                importFileOrFolderPopup.importPaths = importFileDialog.fileUrls
            }
        }
    }
}
