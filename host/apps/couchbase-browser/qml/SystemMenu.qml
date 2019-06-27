import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3

Item {
    id: root

    signal newWindowSignal();
    signal setFilePathSignal(string file_path);

    RowLayout {
        id: row
        height: parent.height
        width: implicitWidth
        spacing: 25
        CustomMenuItem {
            id: open
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/openFolderIcon"
            label: "<b>Open</b>"
            onButtonPress: fileDialog.visible = true
        }
        CustomMenuItem {
            id: newDocument
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/createDocumentIcon"
            label: "<b>New Doc</b>"
            onButtonPress: newDoc.visible = true
        }
        CustomMenuItem {
            id: newDB
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/newDatabase"
            label: "<b>New DB</b>"
            onButtonPress: fileDialog.visible = true
        }
        CustomMenuItem {
            id: save
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/saveIcon"
            label: "<b>Save</b>"
        }
        CustomMenuItem {
            id: saveAs
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/Save-as-icon"
            label: "<b>Save As</b>"
            onButtonPress: fileDialog.visible = true
        }
        CustomMenuItem {
            id: close
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/closeIcon"
            label: "<b>Close</b>"

        }


        FileDialog {
            id: fileDialog
            visible: false
            title: "Please select a database"
            folder: shortcuts.home
            onAccepted: {
                setFilePathSignal(fileUrls.toString().replace("file://",""));
                //qmlBridge.setFilePath(id,fileUrls.toString().replace("file://",""))
                hiddenMenuLayout.visible = true
            }
        }
    }
    Rectangle {
        id: hiddenMenuBackground
        width: 100
        height: parent.height
        color: "transparent"
        anchors {
            right: newTabContainer.left
        }
        RowLayout {
            id: hiddenMenuLayout
            anchors.fill: parent
            visible: false
            CustomMenuItem {
                id: startReplication
                Layout.preferredHeight: 50
                Layout.preferredWidth: 50
                Layout.alignment: Qt.AlignCenter
                label: "<b>Start Replication</b>"
                filename: "Images/replicateDatabase"
                onButtonPress: {
                    login.visible = true
                    startReplication.visible = false
                    stopReplication.visible = true
                }
            }
            CustomMenuItem {
                id: stopReplication
                visible: false
                Layout.preferredHeight: 50
                Layout.preferredWidth: 50
                Layout.alignment: Qt.AlignCenter
                label: "<b>Stop Replication</b>"
                filename: "Images/stopReplication"
                onButtonPress: {
                    startReplication.visible = true
                    stopReplication.visible = false
                }
            }
        }
    }
    Rectangle {
        id: newTabContainer
        width: 100
        height: parent.height
        color: "transparent"
        anchors {
            right: parent.right
        }
        RowLayout {
            id: newTabLayout
            anchors.fill: parent
            CustomMenuItem {
                id: newTab
                Layout.preferredHeight: 50
                Layout.preferredWidth: 50
                Layout.alignment: Qt.AlignCenter
                label: "<b>New Tab</b>"
                filename: "Images/newTabIcon"
                onButtonPress: {
                    newWindowSignal();
                }
            }
        }
    }
    PopupWindow {
        id: login
    }
    NewDocumentPopup {
        id: newDoc
    }
}

