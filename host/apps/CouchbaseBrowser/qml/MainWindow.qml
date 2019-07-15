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
    property string message
    property var messageJSONObj

    onMessageChanged: {
        messageJSONObj = JSON.parse(message)
        statusBar.message = messageJSONObj["msg"]
        statusBar.backgroundColor = messageJSONObj["status"] === "success" ? "green" : "darkred"
    }

    function updateOpenDocument() {
        if (allDocuments === "{}") return;
        if (documentSelectorDrawer.currentIndex !== 0) {
            mainMenuView.onSingleDocument = true
            openedDocumentID = documentSelectorDrawer.model[documentSelectorDrawer.currentIndex]
            openedDocumentBody = JSON.stringify(jsonObj[openedDocumentID],null, 4)
            bodyView.text = openedDocumentBody
        } else {
            mainMenuView.onSingleDocument = false
            openedDocumentID = documentSelectorDrawer.model[0]
            bodyView.text = JSON.stringify(jsonObj, null, 4)
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
            bodyView.text = ""
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
        color: "#222831"
        GridLayout {
            id: gridview
            anchors.fill: parent
            rows: 3
            columns: 3
            rowSpacing:0
            columnSpacing: 0

            SystemMenu {
                id: mainMenuView
                Layout.row: 0
                Layout.columnSpan: 3
                Layout.preferredHeight: 70
                Layout.fillWidth: true
                onOpenFileSignal: openFileDialog.open()
                onNewDatabaseSignal: newDatabasesPopup.visible = true
                onNewDocumentSignal: newDocPopup.visible = true
                onDeleteDocumentSignal: deletePopup.visible = true
                onEditDocumentSignal: editDocPopup.visible = true
                onSaveAsSignal: saveAsPopup.visible = true
                onCloseSignal: root.message = database.closeDB()
                onStartListeningSignal: loginPopup.visible = true
                onStopListeningSignal: root.message = database.stopListening()
                onNewWindowSignal: manage.createNewWindow
            }

            Rectangle {
                id: docDrawerBtnContainer
                Layout.row:1
                Layout.column: 0
                Layout.preferredHeight: 30
                Layout.preferredWidth: 160
                color: statusBar.backgroundColor
                Button {
                    id: docDrawerBtn
                    height: parent.height - 10
                    width: parent.width - 20
                    anchors.centerIn: parent
                    text: "<b>Document Selector</b>"
                    onClicked: documentSelectorDrawer.visible = !documentSelectorDrawer.visible
                }
            }

            StatusBar {
                id: statusBar
                Layout.row:1
                Layout.column: 1
                Layout.preferredHeight: 30
                Layout.fillWidth: true
                message: ""
                backgroundColor: "green"
            }

            Rectangle {
                id: channelDrawerBtnContainer
                Layout.row:1
                Layout.column: 2
                Layout.preferredHeight: 30
                Layout.preferredWidth: 160
                color: statusBar.backgroundColor
                Button {
                    id: channelDrawerBtn
                    height: parent.height - 10
                    width: parent.width - 20
                    anchors.centerIn: parent
                    text: "<b>Channel Selector</b>"
                    onClicked: channelSelectorDrawer.visible = !channelSelectorDrawer.visible
                }
            }

            DocumentSelectorDrawer {
                id: documentSelectorDrawer
                Layout.fillHeight: true
                Layout.preferredWidth: 160
                visible: true
                onCurrentIndexChanged: updateOpenDocument()
                onSearch: root.message = database.searchDocById(text)
            }

            ScrollView {
                id: bodyViewContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 1 + (documentSelectorDrawer.visible ? 0 : 1) + (channelSelectorDrawer.visible ? 0 : 1)
                clip: true
                TextArea {
                    id: bodyView
                    wrapMode: "Wrap"
                    selectByMouse: true
                    text: ""
                    color: "#eeeeee"
                    readOnly: true
                    background: Rectangle {
                        anchors.fill:parent
                        color: "#393e46"
                    }
                }
            }

            Rectangle {
                id: channelSelectorDrawer
                Layout.fillHeight: true
                Layout.preferredWidth: 160
                color: "#222831"
                visible: true
            }
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
                root.message = database.openDB(fileUrls);
                if (messageJSONObj["status"] === "success")
                    mainMenuView.openedFile = true
                else
                    mainMenuView.openedFile = false
                close()
            }
            onRejected: close()
        }

        LoginPopup {
            id: loginPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onStart: {
                root.message = database.startListening(url,username,password,listenType,channels);
                if (messageJSONObj["status"] === "success") {
                    mainMenuView.startedListening = true
                    close()
                }
                else
                    mainMenuView.startedListening = false
            }
        }
        DocumentPopup {
            id: newDocPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                root.message = database.createNewDoc(docID,docBody);
                if (messageJSONObj["status"] === "success") close();
            }
        }
        DocumentPopup {
            id: editDocPopup
            docID: openedDocumentID
            docBody: openedDocumentBody
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                root.message = database.editDoc(openedDocumentID,docID,docBody)
                if (messageJSONObj["status"] === "success") close();
            }
        }
        DatabasePopup {
            id: newDatabasesPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                root.message = database.createNewDB(folderPath,filename);
                if (messageJSONObj["status"] === "success") {
                    folderPath = ""
                    filename = ""
                    close();
                }
            }
        }
        DatabasePopup {
            id: saveAsPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onSubmit:  {
                root.message = database.saveAs(folderPath,filename);
                if (messageJSONObj["status"] === "success") close();
            }
        }
        WarningPopup {
            id: deletePopup
            messageToDisplay: "Are you sure that you want to permanently delete document \""+ openedDocumentID + "\""
            onAllow: {
                close()
                root.message = database.deleteDoc(openedDocumentID)
            }
            onDeny: close()
        }
    }
}
