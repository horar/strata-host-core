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
    title: qsTr("Couchbase Browser") + (openedFile ? " - " + dbName : "")
    flags: Qt.WindowFullscreenButtonHint

    property string dbName: database.dbName
    property string allDocuments: database.jsonDBContents
    property var documentsJSONObj
    property alias openedFile: database.dbStatus
    property alias startedListening: database.listenStatus
    property string openedDocumentID
    property string openedDocumentBody
    property var channelList: database.channels
    property string message: database.message
    property var messageJSONObj
    property string config: database.jsonConfig
    property var configJSONObj
    property string activityLevel: database.activityLevel

    property bool waitingForStartListening: false
    property bool waitingForStopListening: false

    onMessageChanged: {
        messageJSONObj = JSON.parse(message)
        statusBar.message = messageJSONObj["msg"]
        statusBar.messageBackgroundColor = messageJSONObj["status"] === "success" ? "green" : "darkred"
    }

    function updateOpenPopup() {
        openPopup.model.clear()
        for (let i in configJSONObj) openPopup.model.append({"name":i,"path":configJSONObj[i]["file_path"]})
    }
    function updateLoginPopup() {
        loginPopup.url = configJSONObj[dbName]["url"]
        loginPopup.username = configJSONObj[dbName]["username"]
        loginPopup.listenType = configJSONObj[dbName]["rep_type"]
        if (loginPopup.listenType === "") loginPopup.listenType = "pull"
    }
    onConfigChanged: {
        configJSONObj = JSON.parse(config)
        updateOpenPopup()
        if (openedFile && !startedListening) updateLoginPopup()
    }

    onOpenedFileChanged: {
        mainMenuView.openedFile = openedFile
        documentSelectorDrawer.visible = openedFile
        if (openedFile && !startedListening) updateLoginPopup()
    }
    onStartedListeningChanged: {
        if (waitingForStartListening) {
            if (startedListening) {
                loginPopup.close()
                channelSelectorDrawer.model.clear()
                channelSelectorDrawer.channels = []
                for (let i in channelList) channelSelectorDrawer.model.append({"checked":false,"channel":channelList[i]})
                waitingForStartListening = false;
            }
        }

        if (waitingForStopListening) {
            if (!startedListening) waitingForStopListening = false;
        }

        mainMenuView.startedListening = startedListening
        channelSelectorDrawer.visible = startedListening

        if (!startedListening) {
            channelSelectorDrawer.model.clear()
            channelSelectorDrawer.channels = []
            loginPopup.model.clear()
            loginPopup.channels = []
        }
    }

    function updateOpenDocument() {
        if (allDocuments === "{}") {
            openedDocumentID = ""
            openedDocumentBody = ""
            return;
        }
        if (documentSelectorDrawer.currentIndex !== 0) {
            mainMenuView.onSingleDocument = true
            openedDocumentID = documentSelectorDrawer.model[documentSelectorDrawer.currentIndex]
            openedDocumentBody = JSON.stringify(documentsJSONObj[openedDocumentID],null, 4)
            bodyView.text = openedDocumentBody
        } else {
            mainMenuView.onSingleDocument = false
            openedDocumentID = documentSelectorDrawer.model[0]
            bodyView.text = JSON.stringify(documentsJSONObj, null, 4)
        }
    }
    onAllDocumentsChanged: {
        if (allDocuments !== "{}") {
            let tempModel = ["All documents"]
            documentsJSONObj = JSON.parse(allDocuments)
            for (let i in documentsJSONObj)
                tempModel.push(i)
            let prevID = openedDocumentID
            let newIndex = tempModel.indexOf(prevID)
            if (newIndex === -1)
                newIndex = 0
            documentSelectorDrawer.model = tempModel
            documentSelectorDrawer.currentIndex = newIndex
        } else {
            documentSelectorDrawer.model = []
            documentSelectorDrawer.currentIndex = 0
            mainMenuView.onSingleDocument = false
            bodyView.text = ""
        }
        updateOpenDocument()
    }

    function updateSuggestionModel() {
        loginPopup.model.clear()
        let suggestionChannels = database.getChannelSuggestions()
        for (let i in suggestionChannels) loginPopup.model.append({"channel":suggestionChannels[i],"selected":false,"removable":"false"})
    }

    Database {
        id:database
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
                    openPopup.show()
                }
                onNewDatabaseSignal: {
                    statusBar.message = ""
                    newDatabasesPopup.show()
                }
                onNewDocumentSignal: {
                    statusBar.message = ""
                    newDocPopup.show()
                }
                onDeleteDocumentSignal: {
                    statusBar.message = ""
                    deletePopup.show()
                }
                onEditDocumentSignal: {
                    editDocPopup.docID = openedDocumentID
                    editDocPopup.docBody = openedDocumentBody
                    statusBar.message = ""
                    editDocPopup.show()
                }
                onSaveAsSignal: {
                    statusBar.message = ""
                    saveAsPopup.show()
                }
                onCloseSignal: {
                    statusBar.message = ""
                    database.closeDB()
                    documentSelectorDrawer.clearSearch()
                }
                onStartListeningSignal: {
                    updateSuggestionModel()
                    statusBar.message = ""
                    loginPopup.show()
                }
                onStopListeningSignal: {
                    statusBar.message = ""
                    database.stopListening()
                    waitingForStopListening = true;
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
                enabled: openedFile
            }

            StatusBar {
                id: statusBar
                Layout.row:1
                Layout.column: 1
                Layout.maximumHeight: 30
                Layout.preferredHeight: 30
                Layout.fillWidth: true
                message: ""
                messageBackgroundColor: "green"

                displayActivityLevel: startedListening
                activityLevel: root.activityLevel
                activityLevelColor: (["Busy","Idle"].includes(root.activityLevel)) ? "green" : "yellow"
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
                        GradientStop { position: 0 ; color: channelDrawerBtn.hovered ? "#fff" : channelSelectorDrawer.visible ? "#ffd8a7" : "#eee" }
                        GradientStop { position: 1 ; color: channelDrawerBtn.hovered ? "#aaa" : "#999" }
                    }
                }
                enabled: startedListening
            }

            DocumentSelectorDrawer {
                id: documentSelectorDrawer
                Layout.fillHeight: true
                Layout.preferredWidth: 160
                visible: false
                onCurrentIndexChanged: updateOpenDocument()
                onSearch: database.searchDocById(text)
            }

            BodyDisplay {
                id: bodyView
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 1 + (documentSelectorDrawer.visible ? 0 : 1) + (channelSelectorDrawer.visible ? 0 : 1)
            }

            ChannelSelectorDrawer {
                id: channelSelectorDrawer
                Layout.fillHeight: true
                Layout.preferredWidth: 160
                visible: false
                onChanged: database.setChannels(channels)
            }
        }
    }

    Item {
        id: popupWindow
        anchors.fill: parent

        OpenPopup {
            id: openPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.openDB(fileUrl);
                close()
            }
            onRemove: database.deleteConfigEntry(dbName)
            onClear: database.clearConfig()
        }
        LoginPopup {
            id: loginPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onStart: {
                database.startListening(url,username,password,listenType,channels);
                waitingForStartListening = true;
            }
        }
        DocumentPopup {
            id: newDocPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.createNewDoc(docID,docBody);
                if (messageJSONObj["status"] === "success") close();
            }
        }
        DocumentPopup {
            id: editDocPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.editDoc(openedDocumentID,docID,docBody)
                if (messageJSONObj["status"] === "success") close();
            }
        }
        DatabasePopup {
            id: newDatabasesPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.createNewDB(folderPath,dbName);
                if (messageJSONObj["status"] === "success") close();
            }
        }
        DatabasePopup {
            id: saveAsPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit:  {
                database.saveAs(folderPath,dbName);
                if (messageJSONObj["status"] === "success") close();
            }
        }
        WarningPopup {
            id: deletePopup
            messageToDisplay: "Are you sure that you want to permanently delete document \""+ openedDocumentID + "\""
            onAllow: {
                database.deleteDoc(openedDocumentID)
                close()
            }
            onDeny: close()
        }
    }
}
