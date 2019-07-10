import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import "Popups"
import "Components"

Item {
    id: root
    anchors.fill: parent

    property var id
    property var allDocuments: "{}"
    property var jsonObj
    property alias openedFile: mainMenuView.openedFile
    property string openedDocumentID
    property string openedDocumentBody

    function updateOpenDocument() {
        if (tableSelectorView.currentIndex !== 0) {
            mainMenuView.onSingleDocument = true
            openedDocumentID = tableSelectorView.model[tableSelectorView.currentIndex]
            openedDocumentBody = JSON.stringify(jsonObj[openedDocumentID],
                                                null, 4)
            bodyView.content = openedDocumentBody
        } else {
            mainMenuView.onSingleDocument = false
            openedDocumentID = tableSelectorView.model[0]
            bodyView.content = JSON.stringify(jsonObj, null, 4)
        }
    }

    onAllDocumentsChanged: {
        if (allDocuments !== "{}") {
            let tempModel = ["All documents"]
            jsonObj = JSON.parse(allDocuments)
            for (let i in jsonObj)
                tempModel.push(i)
            let prevID = openedDocumentID
            let newIndex = tempModel.indexOf(prevID)
            if (newIndex === -1)
                newIndex = 0
            tableSelectorView.model = tempModel

            if (tableSelectorView.currentIndex === newIndex) {
                updateOpenDocument()
            } else
                tableSelectorView.currentIndex = newIndex
        } else {
            tableSelectorView.model = []
            bodyView.content = ""
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#b55400"
        GridLayout {
            id: gridview
            anchors.fill: parent
            rows: 2
            columns: 2
            columnSpacing: 2
            rowSpacing: 2

            Rectangle {
                id: menuContainer
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 82
                Layout.row: 0
                Layout.columnSpan: 2
                color: "#222831"
                SystemMenu {
                    id: mainMenuView
                    anchors {
                        fill: parent
                        bottomMargin: 10
                    }
                    onOpenFileSignal: openFileDialog.visible = true
                    onNewDatabaseSignal: newDatabasesPopup.visible = true
                    onNewDocumentSignal: newDocPopup.visible = true
                    onDeleteDocumentSignal: deletePopup.visible = true
                    onEditDocumentSignal: editDocPopup.visible = true
                    onSaveAsSignal: saveAsPopup.visible = true
                    onCloseSignal: {
                        database.close(id)
                        bodyView.message = "Closed file"
                    }
                    onStartListeningSignal: {
                        loginPopup.visible = true
                    }
                    onStopListeningSignal: {
                        database.stopListening(id)
                        bodyView.message = "Stopped listening"
                    }
                    onNewWindowSignal: database.newWindow()
                }
            }
            Rectangle {
                id: selectorContainer
                Layout.preferredWidth: 160
                Layout.preferredHeight: (parent.height - menuContainer.height)
                Layout.row: 1
                Layout.alignment: Qt.AlignTop
                color: "#222831"

                TableSelector {
                    id: tableSelectorView
                    height: parent.height
                    onCurrentIndexChanged: {
                        if (allDocuments !== "{}") {
                            updateOpenDocument()
                        }
                    }
                }
                Image {
                    id: onLogo
                    width: 50
                    height: 50
                    source: "Images/cbbrowserLogo.png"
                    fillMode: Image.PreserveAspectCrop
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            Rectangle {
                id: bodyContainer
                Layout.preferredWidth: (parent.width - selectorContainer.width)
                Layout.preferredHeight: (parent.height - menuContainer.height)
                Layout.alignment: Qt.AlignTop
                color: "transparent"
                BodyDisplay {
                    id: bodyView
                }
            }
        }

        Item {
            id: popupWindow
            anchors.fill: parent

            FileDialog {
                id: openFileDialog
                visible: false
                title: "Please select a database"
                folder: shortcuts.home
                onAccepted: {
                    let message = database.open(id, fileUrls);
                    if (message.length === 0) {
                        bodyView.message = "Opened file"
                        mainMenuView.openedFile = true
                    } else
                        bodyView.message = message
                }
            }

            LoginPopup {
                id: loginPopup
                onStart: {
                    let message = database.startListening(id,url,username,password,rep_type,channels);
                    if (message.length === 0) {
                        bodyView.message = "Started listening successfully"
                        mainMenuView.startedListening = true
                        visible = false
                    } else
                        bodyView.message = message
                }
            }
            DocumentPopup {
                id: newDocPopup
                onSubmit: {
                    let message = database.newDocument(id,docID,docBody);
                    if (message.length === 0)
                        bodyView.message = "Created new document successfully!"
                    else
                        bodyView.message = message
                }
            }
            DocumentPopup {
                id: editDocPopup
                docID: openedDocumentID
                docBody: openedDocumentBody
                onSubmit: {
                    let message = database.editDocument(id,openedDocumentID,docID,docBody)
                    if (message.length === 0) {
                        bodyView.message = "Edited document successfully"
                    } else
                        bodyView.message = message
                    visible = false
                }
            }
            DatabasePopup {
                id: newDatabasesPopup
                onSubmit: {
                    let message = database.newDatabase(id,folderPath,filename);
                    if (message.length === 0) {
                        bodyView.message = "Created new database successfully"
                    } else
                        bodyView.message = message
                    visible = false
                }
            }
            DatabasePopup {
                id: saveAsPopup
                onSubmit:  {
                    let message = database.saveAs(id,folderPath,filename);
                    if (message.length === 0) {
                        bodyView.message = "Saved database successfully";
                    }
                    else bodyView.message = message;
                    visible = false;
                }
            }
            WarningPopup {
                id: deletePopup
                messageToDisplay: "Are you sure that you want to permanently delete document \""
                                  + openedDocumentID + "\""
                onAllow: {
                    deletePopup.visible = false
                    database.deleteDocument(id,openedDocumentID)
                }
                onDeny: {
                    deletePopup.visible = false
                }
            }
        }
    }
}
