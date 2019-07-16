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
    property alias startedListening: mainMenuView.startedListening
    property string openedDocumentID
    property string openedDocumentBody
    property string message
    property var messageJSONObj

    onMessageChanged: {
        messageJSONObj = JSON.parse(message)
        statusBar.message = messageJSONObj["msg"]
        statusBar.backgroundColor = messageJSONObj["status"] === "success" ? "green" : "darkred"
    }

    onOpenedFileChanged: documentSelectorDrawer.visible = openedFile
    onStartedListeningChanged: channelSelectorDrawer.visible = startedListening

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

    function updateConfig() {
        let config = database.getConfigJson()
        let jsonObj = JSON.parse(config)
        console.log(config)
        openPopup.model.clear()
        for (let i in jsonObj) openPopup.model.append({"name":"","path":jsonObj[i]["file_path"]})
    }

    Component.onCompleted: {
        updateConfig();
    }

    Database {
        id:database
        onNewUpdate: {
            root.allDocuments = getJSONResponse();
            root.filename = getDBName();
            root.openedFile = getDBstatus();
            root.startedListening = getRepstatus();
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
                onOpenFileSignal: {
                    statusBar.message = ""
                    openPopup.visible = true
                    updateConfig()
                }
                onNewDatabaseSignal: {
                    statusBar.message = ""
                    newDatabasesPopup.visible = true
                }
                onNewDocumentSignal: {
                    statusBar.message = ""
                    newDocPopup.visible = true
                }
                onDeleteDocumentSignal: {
                    statusBar.message = ""
                    deletePopup.visible = true
                }
                onEditDocumentSignal: {
                    statusBar.message = ""
                    editDocPopup.visible = true
                }
                onSaveAsSignal: {
                    statusBar.message = ""
                    saveAsPopup.visible = true
                }
                onCloseSignal: {
                    statusBar.message = ""
                    root.message = database.closeDB()
                }
                onStartListeningSignal: {
                    statusBar.message = ""
                    loginPopup.visible = true
                }
                onStopListeningSignal: {
                    statusBar.message = ""
                    root.message = database.stopListening()
                }
                onNewWindowSignal: {
                    statusBar.message = ""
                    manage.createNewWindow()
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    height: 1
                    width: parent.width
                    color: "black"
                }
            }

            Button {
                id: docDrawerBtn
                Layout.row:1
                Layout.column: 0
                Layout.preferredHeight: 30
                Layout.preferredWidth: 160
                text: "<b>Document Selector</b>"
                onClicked: documentSelectorDrawer.visible = !documentSelectorDrawer.visible
                background: Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0 ; color: docDrawerBtn.hovered ? "#fff" : documentSelectorDrawer.visible ? "#ffd8a7" : "#eee" }
                        GradientStop { position: 1 ; color: docDrawerBtn.hovered ? "#aaa" : "#999" }
                    }
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

            Button {
                id: channelDrawerBtn
                Layout.row:1
                Layout.column: 2
                Layout.preferredHeight: 30
                Layout.preferredWidth: 160
                text: "<b>Channel Selector</b>"
                onClicked: channelSelectorDrawer.visible = !channelSelectorDrawer.visible
                background: Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0 ; color: channelDrawerBtn.hovered ? "#fff" : documentSelectorDrawer.visible ? "#ffd8a7" : "#eee" }
                        GradientStop { position: 1 ; color: channelDrawerBtn.hovered ? "#aaa" : "#999" }
                    }
                }
            }

            DocumentSelectorDrawer {
                id: documentSelectorDrawer
                Layout.fillHeight: true
                Layout.preferredWidth: 160
                visible: false
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
                visible: false
            }
        }
    }

    Item {
        id: popupWindow
        anchors.fill: parent

        OpenPopup {
            id: openPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                root.message = database.openDB(fileUrl);
                if (messageJSONObj["status"] === "success")
                    mainMenuView.openedFile = true
                else
                    mainMenuView.openedFile = false
                close()
            }
            onRemove: {
                root.message = database.deleteConfigEntry(dbName)
                if (messageJSONObj["status"] === "success") {
                    updateConfig()
                }
            }
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
                root.message = database.createNewDB(folderPath,dbName);
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
                root.message = database.saveAs(folderPath,dbName);
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
