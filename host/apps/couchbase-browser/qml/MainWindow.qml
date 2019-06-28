import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

Item {
    id: root
    anchors.fill: parent

    property var id
    property var content: ""
    property var jsonObj

    onContentChanged: {
        if (content !== "") {
            let tempModel = ["All documents"];
            jsonObj = JSON.parse(content);
            for (let i in jsonObj) tempModel.push(i);
            let prevID = tableSelectorView.model[tableSelectorView.currentIndex];
            let newIndex = tempModel.indexOf(prevID);
            if (newIndex === -1) newIndex = 0;
            tableSelectorView.model = tempModel;

            if (tableSelectorView.currentIndex === newIndex) {
                if (tableSelectorView.currentIndex !== 0)
                    bodyView.content = JSON.stringify(jsonObj[tableSelectorView.model[tableSelectorView.currentIndex]],null,4);
                else
                    bodyView.content = JSON.stringify(jsonObj,null,4);
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
                    onNewDocumentSignal: newDocPopup.visible = true
                    onNewDatabaseSignal: newDatabasesPopup.visible = true
                    //onSaveSignal:
                    onSaveAsSignal: saveAsPopup.visible = true
                    onCloseSignal: {
                        qmlBridge.closeFile(id)
                        bodyView.message = "Closed file"
                    }
                    onStartReplicatorSignal: loginPopup.visible = true
                    onStopReplicatorSignal: {
                        qmlBridge.stopReplicator(id)
                        bodyView.message = "Stopped replicator"
                    }
                    onNewWindowSignal: qmlBridge.createNewWindow()
                }
            }
            Rectangle {
                id: selectorContainer
                Layout.preferredWidth: 150
                Layout.preferredHeight: (parent.height - menuContainer.height)
                Layout.row: 1
                Layout.alignment: Qt.AlignTop
                color: "#222831"

                TableSelector {
                    id: tableSelectorView
                    onCurrentIndexChanged: {
                        if (content !== "") {
                            if (currentIndex !== 0)
                                bodyView.content = JSON.stringify(jsonObj[model[currentIndex]],null,4);
                            else
                                bodyView.content = JSON.stringify(jsonObj,null,4);
                        }
                    }
                }
                Image {
                    id: onLogo
                    width: 50
                    height: 50
                    source: "Images/OnLogo.png"
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
                color: "steelblue"
                BodyDisplay {
                    id: bodyView
                }
            }
            Item {
                id: popupWindow

                FileDialog {
                    id: openFileDialog
                    visible: false
                    title: "Please select a database"
                    folder: shortcuts.home
                    onAccepted: {
                        qmlBridge.setFilePath(id, fileUrls.toString().replace("file://",""));
                        bodyView.message = "Opened file";
                        mainMenuView.openedFile = true
                    }
                }

                LoginPopup {
                    id: loginPopup
                    onStart: {
                        let message = qmlBridge.startReplicator(id,hostName,username,password).length;
                        if (message === 0) {
                            bodyView.message = "Started replicator successfully";
                            mainMenuView.replicatorStarted = true;
                            visible = false;
                        }
                        else bodyView.message = message;
                    }
                }
                NewDocumentPopup {
                    id: newDocPopup
                    onSubmit: {
                        if (qmlBridge.createNewDocument(id,docID,docBody))
                            bodyView.message = "Created new document successfully!";
                        else
                            bodyView.message = "Cannot create new document";
                    }
                }
                NewDatabasePopup {
                    id: newDatabasesPopup

                }
                NewDatabasePopup {
                    id: saveAsPopup
                }
            }
        }
    }
}
