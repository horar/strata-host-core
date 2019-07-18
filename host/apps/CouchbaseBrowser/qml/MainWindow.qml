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
    title: qsTr("Couchbase Browser") + ((dbName !== "") ? " - " + dbName : "")
    flags: Qt.WindowFullscreenButtonHint

    property string dbName: database.dbName
    property var allDocuments: database.jsonDBContents
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

    onMessageChanged: {
        messageJSONObj = JSON.parse(message)
        statusBar.message = messageJSONObj["msg"]
        statusBar.backgroundColor = messageJSONObj["status"] === "success" ? "green" : "darkred"
    }

    onConfigChanged: {
        configJSONObj = JSON.parse(config)
    }

    onOpenedFileChanged: {
        mainMenuView.openedFile = openedFile
        documentSelectorDrawer.visible = openedFile
    }
    onStartedListeningChanged: {
        mainMenuView.startedListening = startedListening
        channelSelectorDrawer.visible = startedListening
        if (!startedListening) {
            channelSelectorDrawer.channels = []
            channelSelectorDrawer.model.clear()
        }
    }

    function updateOpenDocument() {
        if (allDocuments === "{}") return;
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

            if (documentSelectorDrawer.currentIndex === newIndex) {
                updateOpenDocument()
            } else
                documentSelectorDrawer.currentIndex = newIndex
        } else {
            documentSelectorDrawer.model = []
            bodyView.text = ""
        }
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
                    openPopup.visible = true
                    updateOpenPopup()
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
                    database.closeDB()
                    documentSelectorDrawer.clearSearch()
                }
                onStartListeningSignal: {
                    statusBar.message = ""
                    loginPopup.visible = true
                    updateLoginPopup()
                }
                onStopListeningSignal: {
                    statusBar.message = ""
                    database.stopListening()
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
                        GradientStop { position: 0 ; color: channelDrawerBtn.hovered ? "#fff" : channelSelectorDrawer.visible ? "#ffd8a7" : "#eee" }
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
                onSearch: database.searchDocById(text)
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

            ChannelSelectorDrawer {
                id: channelSelectorDrawer
                Layout.fillHeight: true
                Layout.preferredWidth: 160
                visible: false
                onChanged: database.setChannels(channels)
                onSearch: database.searchDocById(text)
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
                database.openDB(fileUrl);
                if (messageJSONObj["status"] === "success")
                    mainMenuView.openedFile = true
                else
                    mainMenuView.openedFile = false
                close()
            }
            onRemove: {
                database.deleteConfigEntry(dbName)
                if (messageJSONObj["status"] === "success") {
                    updateOpenPopup()
                }
            }
            onClear: {
                database.clearConfig()
                if (messageJSONObj["status"] === "success") {
                    updateOpenPopup()
                }
            }
        }
        LoginPopup {
            id: loginPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onStart: {
                database.startListening(url,username,password,listenType,channels);
                if (messageJSONObj["status"] === "success") {
                    mainMenuView.startedListening = true
                    close()
                    channelSelectorDrawer.model.clear()
                    for (let i in channelList) channelSelectorDrawer.model.append({"checked":false,"channel":channelList[i]})
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
                database.createNewDoc(docID,docBody);
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
                database.editDoc(openedDocumentID,docID,docBody)
                if (messageJSONObj["status"] === "success") close();
            }
        }
        DatabasePopup {
            id: newDatabasesPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
            popupStatus.message: statusBar.message
            onSubmit: {
                database.createNewDB(folderPath,dbName);
                if (messageJSONObj["status"] === "success") {
                    folderPath = ""
                    dbName = ""
                    close();
                }
            }
        }
        DatabasePopup {
            id: saveAsPopup
            popupStatus.backgroundColor: statusBar.backgroundColor
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
                close()
                database.deleteDoc(openedDocumentID)
            }
            onDeny: close()
        }
    }
    Item {

        width: 200
        height: 200
        MouseArea {
            id: perimeter
            anchors.fill: parent
            hoverEnabled: true
            onEntered: fadeIn.start()
            onExited: fadeOut.start()
        }
        anchors {
            right: parent.right
            rightMargin: channelSelectorDrawer.visible ? channelSelectorDrawer.width : 0
            bottom: parent.bottom
        }
        Image {
            id: plusIcon
            width: 30
            height: 30
            source: "Images/plusIcon.png"
            opacity: 0.1
            MouseArea {
                id: plusButton
                anchors.fill: parent
                onEntered: plusIcon.opacity = 0.8
                onExited: plusIcon.opacity = 1
                onClicked: if(bodyView.font.pixelSize < 40) {
                               bodyView.font.pixelSize += 5
                           }
            }
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -20
                horizontalCenter: parent.horizontalCenter
            }
            fillMode: Image.PreserveAspectFit


        }
        Image {
            id: minusIcon
            width: 30
            height: 30
            source: "Images/minusIcon.png"
            opacity: 0.1
            MouseArea {
                id: minusButton
                anchors.fill: parent
                onEntered: minusIcon.opacity = 0.8
                onExited: minusIcon.opacity = 1
                onClicked: {
                    if(bodyView.font.pixelSize > 15 ){
                        bodyView.font.pixelSize -= 5
                    }
                }

            }
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 30
                horizontalCenter: parent.horizontalCenter
            }
            fillMode: Image.PreserveAspectFit

        }

    }
    NumberAnimation {
        id: fadeIn
        targets: [plusIcon, minusIcon]
        properties: "opacity"
        from: 0.1
        to: 1
        duration: 300
    }
    NumberAnimation {
        id: fadeOut
        targets: [plusIcon, minusIcon]
        properties: "opacity"
        from: 1
        to: 0.1
        duration: 300
    }
}
