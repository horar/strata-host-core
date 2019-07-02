import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

Item {
    id: root

    signal openFileSignal()
    signal newDocumentSignal()
    signal newDatabaseSignal()
    signal saveSignal()
    signal saveAsSignal()
    signal closeSignal()
    signal startReplicatorSignal()
    signal stopReplicatorSignal()
    signal newWindowSignal()
    signal editDocumentSignal()
    signal deleteDocumentSignal()

    property bool replicatorStarted: false
    property bool openedFile: false

    RowLayout {
        id: row
        height: parent.height
        width: implicitWidth
        spacing: 25
        CustomMenuItem {
            id: openFile
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/openFolderIcon"
            label: "<b>Open</b>"
            onButtonPress: openFileSignal()
        }
        CustomMenuItem {
            id: newDB
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/newDatabase"
            label: "<b>New DB</b>"
            onButtonPress: newDatabaseSignal()
        }
        CustomMenuItem {
            id: newDocument
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/createDocumentIcon"
            label: "<b>New Doc</b>"
            onButtonPress: newDocumentSignal()
            disable: !openedFile || replicatorStarted
        }
        CustomMenuItem {
            id: deleteDocument
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/deleteDocumentIcon"
            label: "<b>Delete Doc</b>"
            onButtonPress: deleteDocumentSignal
            disable: !openedFile || replicatorStarted
        }
        CustomMenuItem {
            id: editDocument
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/editIcon"
            label: "<b>Edit Doc</b>"
            onButtonPress: editDocumentSignal()
            disable: !openedFile || replicatorStarted
        }
        CustomMenuItem {
            id: save
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/saveIcon"
            label: "<b>Save</b>"
            onButtonPress: saveSignal()
            disable: !openedFile || replicatorStarted
        }
        CustomMenuItem {
            id: saveAs
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/Save-as-icon"
            label: "<b>Save As</b>"
            onButtonPress: saveAsSignal()
            disable: !openedFile
        }
        CustomMenuItem {
            id: close
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.leftMargin: 5
            filename: "Images/closeIcon"
            label: "<b>Close</b>"
            onButtonPress: {
                if (replicatorStarted) {
                    stopReplicatorSignal()
                    replicatorStarted = false
                }
                closeSignal()
                openedFile = false
            }
            visible: openedFile
        }
    }

    RowLayout {
        id: newWindowLayout
        height: parent.height
        width: implicitWidth
        spacing: 50
        anchors {
            right: parent.right
            rightMargin: 25
            top: parent.top
        }
        CustomMenuItem {
            id: startReplication
            visible: !replicatorStarted
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            label: "<b>Replicate</b>"
            filename: "Images/replicateDatabase"
            onButtonPress: startReplicatorSignal()
            disable: !openedFile
        }
        CustomMenuItem {
            id: stopReplication
            visible: replicatorStarted
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            label: "<b>Stop Replication</b>"
            filename: "Images/stopReplication"
            onButtonPress: {
                stopReplicatorSignal()
                replicatorStarted = false
            }
        }
        CustomMenuItem {
            id: newWindow
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignCenter
            label: "<b>New Window</b>"
            filename: "Images/newTabIcon"
            onButtonPress: newWindowSignal()
        }
    }
}

