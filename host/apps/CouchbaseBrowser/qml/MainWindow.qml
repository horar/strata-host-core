import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import com.onsemi.couchbase 1.0
import "Popups"
import "Components"

Window {
    id: root
    visible: true
    minimumWidth: 800
    minimumHeight: 600
    width: 1280
    height: 720
    title: qsTr("Couchbase Browser") + ((filename !== "") ? " - " + filename : "")
    flags: Qt.WindowFullscreenButtonHint

    property string filename: ""
    property var allDocuments: "{}"
    property var jsonObj
    property alias openedFile: mainMenuView.openedFile
    property string openedDocumentID
    property string openedDocumentBody


    function updateOpenDocument() {
        if (documentSelectorDrawer.currentIndex !== 0) {
            mainMenuView.onSingleDocument = true
            openedDocumentID = documentSelectorDrawer.model[documentSelectorDrawer.currentIndex]
            openedDocumentBody = JSON.stringify(jsonObj[openedDocumentID],null, 4)
            bodyView.content = openedDocumentBody
        } else {
            mainMenuView.onSingleDocument = false
            openedDocumentID = documentSelectorDrawer.model[0]
            bodyView.content = JSON.stringify(jsonObj, null, 4)
        }
    }

    onFilenameChanged: openedFile = filename.length != 0
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
            documentSelectorDrawer.model = tempModel

            if (documentSelectorDrawer.currentIndex === newIndex) {
                updateOpenDocument()
            } else
                documentSelectorDrawer.currentIndex = newIndex
        } else {
            documentSelectorDrawer.model = []
            bodyView.content = ""
        }
    }

    Database {
        id:database
        onNewUpdate: {
            root.allDocuments = getJSONResponse();
            root.filename = getDBName();
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#b55400"
        ColumnLayout {
            id: gridview
            anchors.fill: parent
            spacing:0

            Rectangle {
                id: menuContainer
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 70
                color: "#222831"
                SystemMenu {
                    id: mainMenuView
                    anchors {
                        fill: parent
                    }
                    onOpenFileSignal: openFileDialog.visible = true
                    onNewDatabaseSignal: newDatabasesPopup.visible = true
                    onNewDocumentSignal: newDocPopup.visible = true
                    onDeleteDocumentSignal: deletePopup.visible = true
                    onEditDocumentSignal: editDocPopup.visible = true
                    onSaveAsSignal: saveAsPopup.visible = true
                    onCloseSignal: {
                        database.closeDB()
                        statusBar.message = "Closed file"
                    }
                    onStartListeningSignal: loginPopup.visible = true
                    onStopListeningSignal: {
                        database.stopListening()
                        statusBar.message = "Stopped listening"
                    }
                    onNewWindowSignal: {
//                        let component = Qt.createComponent("MainWindow.qml")
//                        if (component.status === Component.Ready) component.createObject();

                    }
                }
            }
            RowLayout {
                id: statusBarContainer
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width
                Button {
                    id: label
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: documentSelectorDrawer.width
                    text: "<b>Document Selector:</b>"
                    onClicked: documentSelectorDrawer.visible = !documentSelectorDrawer.visible
                }
                StatusBar {
                    id: statusBar
                    backgroundColor: "green"
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width - label.width
                }
            }

            RowLayout {
                id: bodyContainer
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height - menuContainer.height - statusBarContainer.height

                DocumentSelectorDrawer {
                    id: documentSelectorDrawer
                    parent: bodyContainer
                    Layout.preferredHeight: height
                    Layout.preferredWidth: width
                    height: parent.height
                    width: 160
                    color: "#222831"
                    visible: true

                    onCurrentIndexChanged: {
                        if (allDocuments !== "{}") {
                            updateOpenDocument()
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: height
                    Layout.fillWidth: true
                    height: parent.height
                    color: "transparent"
                    BodyDisplay {
                        id: bodyView
                    }
                }

//                Image {
//                    id: onLogo
//                    width: 50
//                    height: 50
//                    source: "Images/cbbrowserLogo.png"
//                    fillMode: Image.PreserveAspectCrop
//                    anchors {
//                        bottom: parent.bottom
//                        bottomMargin: 20
//                        horizontalCenter: parent.horizontalCenter
//                    }
//                }
            }
        }

        Item {
            id: popupWindow
            anchors.fill: parent

            FileDialog {
                id: openFileDialog
                title: "Please select a database"
                folder: shortcuts.home
                onAccepted: {
                    let message = database.openDB(fileUrls);
                    if (message.length === 0) {
                        statusBar.message = "Opened file"
                        mainMenuView.openedFile = true
                    } else
                        statusBar.message = message
                }
            }

            LoginPopup {
                id: loginPopup
                onStart: {
                    let message = database.startListening(url,username,password,rep_type);
                    if (message.length === 0) {
                        message = database.setChannels(channels)
                        statusBar.message = "Started listening successfully"
                        mainMenuView.startedListening = true
                        visible = false
                        if (message.length === 0)
                            statusBar.message = "Set channels successfully"
                        else
                            statusBar.message = message
                    } else
                        statusBar.message = message
                }
            }
            DocumentPopup {
                id: newDocPopup
                onSubmit: {
                    let message = database.creatNewDoc(docID,docBody);
                    if (message.length === 0)
                        statusBar.message = "Created new document successfully!"
                    else
                        statusBar.message = message
                }
            }
            DocumentPopup {
                id: editDocPopup
                docID: openedDocumentID
                docBody: openedDocumentBody
                onSubmit: {
                    let message = database.editDoc(openedDocumentID,docID,docBody)
                    if (message.length === 0) {
                        statusBar.message = "Edited document successfully"
                    } else
                        statusBar.message = message
                    visible = false
                }
            }
            DatabasePopup {
                id: newDatabasesPopup
                onSubmit: {
                    let message = database.createNewDatabase(folderPath,filename);
                    if (message.length === 0) {
                        statusBar.message = "Created new database successfully"
                    } else
                        statusBar.message = message
                    visible = false
                }
            }
            DatabasePopup {
                id: saveAsPopup
                onSubmit:  {
                    let message = database.saveAs(folderPath,filename);
                    if (message.length === 0) {
                        statusBar.message = "Saved database successfully";
                    }
                    else statusBar.message = message;
                    visible = false;
                }
            }
            WarningPopup {
                id: deletePopup
                messageToDisplay: "Are you sure that you want to permanently delete document \""
                                  + openedDocumentID + "\""
                onAllow: {
                    deletePopup.visible = false
                    database.deleteDoc(openedDocumentID)
                }
                onDeny: {
                    deletePopup.visible = false
                }
            }
        }
    }
}
