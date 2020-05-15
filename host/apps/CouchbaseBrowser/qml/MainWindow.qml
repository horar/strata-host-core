import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import com.onsemi.couchbase 1.0
import "Popups"
import "Components"

Window {
    id: root
    width: 1280
    height: 720
    minimumWidth: 800
    minimumHeight: 600

    title: qsTr("Couchbase Browser") + (openedFile ? " - " + dbName : "")
    flags: Qt.Window | Qt.WindowFullscreenButtonHint
    visible: true

    property alias openedFile: database.dbStatus
    property alias startedListening: database.listenStatus
    property string openedDocumentID
    property string openedDocumentBody
    property string channels: database.channels
    property string dbName: database.dbName
    property string allDocuments: database.jsonDBContents
    property string message
    property string config: database.jsonConfig
    property string activityLevel: database.activityLevel
    property var documentsJSONObj: ({})
    property var channelsJSONObj: ({})
    property var messageJSONObj: ({})
    property var configJSONObj: ({})    
    property bool waitingForStartListening: false
    property bool waitingForStopListening: false
    property real documentsDrawerWidth: 160
    property real channelsDrawerWidth: 160
    property int windowId

    function isEmpty(obj) {
        for(var key in obj) {
            if(obj.hasOwnProperty(key)) {
                return false;
            }
        }
        return true;
    }
    function updateOpenPopup() {
        openPopup.model.clear()
        for (let i in configJSONObj) {
            openPopup.model.append({"name":i,"path":configJSONObj[i]["file_path"]})
        }
    }
    function updateLoginPopup() {
        if (dbName in configJSONObj) {
            loginPopup.url = configJSONObj[dbName]["url"]
            loginPopup.username = configJSONObj[dbName]["username"]
            loginPopup.listenType = configJSONObj[dbName]["rep_type"]
            if (loginPopup.listenType === "") {
                loginPopup.listenType = "pull"
            }
        }
    }
    function updateDocumentsDrawer() {
        if (!isEmpty(documentsJSONObj)) {
            let tempModel = ["All documents"]
            for (let i in documentsJSONObj) {
                tempModel.push(i)
            }
            let prevID = openedDocumentID
            let newIndex = tempModel.indexOf(prevID)
            if (newIndex === -1) {
                newIndex = 0
            }
            documentSelectorDrawer.model = tempModel
            documentSelectorDrawer.currentIndex = newIndex
        }
        else {
            documentSelectorDrawer.model = []
            documentSelectorDrawer.currentIndex = -1
            mainMenuView.onSingleDocument = false
            bodyView.text = ""
        }
    }
    function updateChannelsDrawer() {
        channelSelectorDrawer.model.clear()
        channelSelectorDrawer.channels = []
        channelSelectorDrawer.channelsLength = 0
        let labelAdded = false
        for (let i in channelsJSONObj) {
            if (channelsJSONObj[i] === "active") {
                if (!labelAdded) {
                    labelAdded = true
                    channelSelectorDrawer.model.append({"checked":false,"channel":"Listened Channels:","isLabel":true})
                }
                channelSelectorDrawer.model.append({"checked":false,"channel":i,"isLabel":false})
            }
        }
        labelAdded = false
        for (let i in channelsJSONObj) {
            if (channelsJSONObj[i] !== "active") {
                if (!labelAdded) {
                    labelAdded = true
                    channelSelectorDrawer.model.append({"checked":false,"channel":"Other Channels:","isLabel":true})
                }
                channelSelectorDrawer.model.append({"checked":false,"channel":i,"isLabel":false})
            }
        }
    }
    function updateSuggestionModel() {
        loginPopup.model.clear()
        loginPopup.channels = []
        let suggestionChannels = database.getChannelSuggestions()
        for (let i in suggestionChannels) {
            loginPopup.model.append({"text":suggestionChannels[i],"selected":false})
        }
    }
    function updateOpenDocument() {
        if (isEmpty(documentsJSONObj) || documentSelectorDrawer.currentIndex === -1) {
            openedDocumentID = ""
            openedDocumentBody = ""
            return;
        }
        if (documentSelectorDrawer.currentIndex !== 0) {
            mainMenuView.onSingleDocument = true
            openedDocumentID = documentSelectorDrawer.model[documentSelectorDrawer.currentIndex]
            openedDocumentBody = JSON.stringify(documentsJSONObj[openedDocumentID],null, 4)
            bodyView.text = openedDocumentBody
        }
        else {
            mainMenuView.onSingleDocument = false
            openedDocumentID = documentSelectorDrawer.model[0]
            bodyView.text = JSON.stringify(documentsJSONObj, null, 4)
        }
    }
    onClosing: {
        manage.closeWindow(windowId)
    }
    onConfigChanged: {
        configJSONObj = JSON.parse(config)
        updateOpenPopup()
        if (openedFile && !startedListening) {
            updateLoginPopup()
        }
    }
    onChannelsChanged: {
        channelsJSONObj = JSON.parse(channels)
        updateChannelsDrawer()
    }
    onAllDocumentsChanged: {
        documentsJSONObj = JSON.parse(allDocuments)
        updateDocumentsDrawer()
        updateOpenDocument()
    }
    onOpenedFileChanged: {
        mainMenuView.openedFile = openedFile
        documentSelectorDrawer.visible = openedFile
        documentSelectorDrawer.clearSearch()
        if (openedFile && !startedListening) {
            updateLoginPopup()
        }
    }
    onStartedListeningChanged: {
        if (waitingForStartListening) {
            if (startedListening) {
                loginPopup.close()
                waitingForStartListening = false;
            }
            else {
                loginPopup.submit()
            }
        }

        if (waitingForStopListening) {
            if (!startedListening) {
                waitingForStopListening = false;
            }
        }

        mainMenuView.startedListening = startedListening
    }

    Database {
        id:database
        onMessageChanged: {
            message = getMessage()
            messageJSONObj = JSON.parse(message)
            statusBar.message = messageJSONObj["msg"]
            if(messageJSONObj["status"] === "success") {
                statusBar.messageBackgroundColor = "green"
            } else if(messageJSONObj["status"] === "error") {
                statusBar.messageBackgroundColor = "darkred"
            } else {
                statusBar.messageBackgroundColor = "#b55400"
            }
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
                    openPopup.open()
                }
                onNewDatabaseSignal: {
                    statusBar.message = ""
                    newDatabasesPopup.open()
                }
                onNewDocumentSignal: {
                    statusBar.message = ""
                    newDocPopup.open()
                }
                onDeleteDocumentSignal: {
                    statusBar.message = ""
                    deletePopup.open()
                }
                onEditDocumentSignal: {
                    editDocPopup.docID = openedDocumentID
                    editDocPopup.docBody = openedDocumentBody
                    statusBar.message = ""
                    editDocPopup.open()
                }
                onSaveAsSignal: {
                    statusBar.message = ""
                    saveAsPopup.open()
                }
                onCloseSignal: {
                    statusBar.message = ""
                    database.closeDB()
                    documentSelectorDrawer.clearSearch()
                }
                onStartListeningSignal: {
                    updateSuggestionModel()
                    statusBar.message = ""
                    loginPopup.open()
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

            CustomButton {
                id: docDrawerBtn
                Layout.preferredHeight: 30
                Layout.preferredWidth: documentsDrawerWidth
                Layout.row:1
                Layout.column: 0

                text: "<b>Document Selector</b>"
                radius: 0
                enabled: openedFile
                onClicked: documentSelectorDrawer.visible = !documentSelectorDrawer.visible
            }

            StatusBar {
                id: statusBar
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.maximumHeight: 30
                Layout.row:1
                Layout.column: 1

                message: ""
                messageBackgroundColor: "green"
                displayActivityLevel: startedListening
                activityLevel: root.activityLevel
                activityLevelColor: (["Busy","Idle"].includes(root.activityLevel)) ? "green" : "#b55400"
            }

            CustomButton {
                id: channelDrawerBtn
                Layout.preferredHeight: 30
                Layout.preferredWidth: channelsDrawerWidth
                Layout.row:1
                Layout.column: 2

                text: "<b>Channel Selector</b>"
                radius: 0
                enabled: openedFile && (channels !== "{}")
                onEnabledChanged: channelSelectorDrawer.visible = enabled
                onClicked: channelSelectorDrawer.visible = !channelSelectorDrawer.visible
            }

            DocumentSelectorDrawer {
                id: documentSelectorDrawer
                Layout.fillHeight: true
                Layout.preferredWidth: documentsDrawerWidth

                visible: false
                onCurrentIndexChanged: updateOpenDocument()
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
                Layout.preferredWidth: channelsDrawerWidth

                visible: false
                onChanged: database.searchDocByChannel(channels)
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
            onSubmit: {
                waitingForStartListening = true;
                database.startListening(url,username,password,listenType,channels);
            }
            onClearFailedMessage: {
                statusBar.message = ""
                statusBar.messageBackgroundColor = "green"
            }
        }
        DocumentPopup {
            id: newDocPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.createNewDoc(docID,docBody);
                if (messageJSONObj["status"] === "success") {
                    close();
                }
            }
            onClearFailedMessage: {
                statusBar.message = ""
                statusBar.messageBackgroundColor = "green"
            }
        }
        DocumentPopup {
            id: editDocPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.editDoc(openedDocumentID,docID,docBody)
                if (messageJSONObj["status"] === "success") {
                    close();
                }
            }
            onClearFailedMessage: {
                statusBar.message = ""
                statusBar.messageBackgroundColor = "green"
            }
        }
        DatabasePopup {
            id: newDatabasesPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.createNewDB(folderPath,dbName);
                if (messageJSONObj["status"] === "success") {
                    close();
                }
            }
            onClearFailedMessage: {
                statusBar.message = ""
                statusBar.messageBackgroundColor = "green"
            }
        }
        DatabasePopup {
            id: saveAsPopup
            popupStatus.messageBackgroundColor: statusBar.messageBackgroundColor
            popupStatus.message: statusBar.message
            onSubmit:  {
                database.saveAs(folderPath,dbName);
                if (messageJSONObj["status"] === "success") {
                    close();
                }
            }
            onClearFailedMessage: {
                statusBar.message = ""
                statusBar.messageBackgroundColor = "green"
            }
        }
        WarningPopup {
            id: deletePopup
            messageToDisplay: "Are you sure that you want to permanently delete document \""+ openedDocumentID + "\"?"
            onAllow: {
                database.deleteDoc(openedDocumentID)
                close()
            }
            onDeny: close()
        }
    }
}
