import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

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
            mainMenuView.onSingleDocument = true;
            openedDocumentID = tableSelectorView.model[tableSelectorView.currentIndex];
            openedDocumentBody = JSON.stringify(jsonObj[openedDocumentID],null,4);
            bodyView.content = openedDocumentBody;
        }
        else {
            mainMenuView.onSingleDocument = false;
            openedDocumentID = tableSelectorView.model[0];
            bodyView.content = JSON.stringify(jsonObj,null,4);
        }
    }

    onAllDocumentsChanged: {
        if (allDocuments !== "{}") {
            let tempModel = ["All documents"];
            jsonObj = JSON.parse(allDocuments);
            for (let i in jsonObj) tempModel.push(i);
            let prevID = openedDocumentID;
            let newIndex = tempModel.indexOf(prevID);
            if (newIndex === -1) newIndex = 0;
            tableSelectorView.model = tempModel;

            if (tableSelectorView.currentIndex === newIndex) {
                update();
            }
            else
                tableSelectorView.currentIndex = newIndex;
        }
        else {
            tableSelectorView.model = [];
            bodyView.content = "";
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
                        qmlBridge.closeFile(id)
                        bodyView.message = "Closed file"
                    }
                    onStartReplicatorSignal: {
                        loginPopup.visible = true


                    }
                    onStopReplicatorSignal: {
                        qmlBridge.stopReplicator(id)
                        bodyView.message = "Stopped replicator"
                    }
                    onNewWindowSignal: qmlBridge.createNewWindow()

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
                    Component.onCompleted: console.log(height, root.height);
                    onCurrentIndexChanged: {
                        if (allDocuments !== "{}") {
                            updateOpenDocument();
                        }
                    }
                }
                Image {
                    id: onLogo
                    width: 50
                    height: 50
                    source: "Images/CBBrowserLogo.png"
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
                    let message = qmlBridge.setFilePath(id, fileUrls.toString().replace("file://",""));
                    if (message.length === 0) {
                        bodyView.message = "Opened file";
                        mainMenuView.openedFile = true
                    }
                    else bodyView.message = message;
                }
            }

            LoginPopup {
                id: loginPopup
                onStart: {
                    let message = qmlBridge.startReplicator(id,url,username,password,rep_type);
                    if (message.length === 0) {
                        bodyView.message = "Started replicator successfully";
                        mainMenuView.replicatorStarted = true;
                        visible = false;
                    }
                    else bodyView.message = message;
                }
            }
            NewDocumentPopup {
                id: newDocPopup
                changed: true
                onSubmit: {
                    let message = qmlBridge.createNewDocument(id,docID,docBody);
                    if (message.length === 0)
                        bodyView.message = "Created new document successfully!";
                    else
                        bodyView.message = message;
                }
            }
            NewDocumentPopup {
                id: editDocPopup
                docID: openedDocumentID
                docBody: openedDocumentBody
                onDocIDChanged: {
                    if (docID !== openedDocumentID || docBody !== openedDocumentBody) {
                        changed = true
                    }
                    else changed = false
                }
                onDocBodyChanged: {
                    if (docID !== openedDocumentID || docBody !== openedDocumentBody) {
                        changed = true
                    }
                    else changed = false
                }

                onSubmit:  {
                    let message = ""
                    if (docID !== openedDocumentID) {
                        message = qmlBridge.createNewDocument(id,docID,docBody)
                        if (message.length === 0) {
                            message = qmlBridge.deleteDoc(id,openedDocumentID)
                            if (message.length === 0) {
                                bodyView.message = "Edited document successfully"
                                tableSelectorView.currentIndex = tableSelectorView.model.indexOf(docID)
                            }
                            else bodyView.message = message + " | " + qmlBridge.deleteDoc(id,docID,docBody)
                        }
                        else bodyView.message = message
                    }
                    else {
                        message = qmlBridge.editDoc(id,docID,docBody)
                        if (message.length === 0) {
                            bodyView.message = "Edited document successfully"
                        }
                        else bodyView.message = message;
                    }
                    visible = false
                }
            }
            NewDatabasePopup {
                id: newDatabasesPopup
                anchors.centerIn: parent
                onSubmit: {
                    let message = qmlBridge.createNewDatabase(id,mainMenuView.openedFile,folderPath.toString().replace("file://",""), filename);
                    if (message.length === 0) {
                        bodyView.message = "Created new database successfully";
                    }
                    else bodyView.message = message;
                    visible = false;
                }

            }
            NewDatabasePopup {
                id: saveAsPopup
                anchors.centerIn: parent
                onSubmit:  {
                    visible = false;
                }
            }
            WarningPopup {
                id: deletePopup
                messageToDisplay: "Are you sure that you want to permanently delete document \""+openedDocumentID+"\"";
                onAllow: {
                    deletePopup.visible = false
                    qmlBridge.deleteDoc(id,openedDocumentID)
                }
                onDeny: {
                    deletePopup.visible = false
                }
            }
        }
    }
}

