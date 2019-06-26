import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3

Item {
    id: root

    property int numberOfItems: 3

    RowLayout {
        id: row
        height: parent.height
        width: 100
        Rectangle {
            id: openIconBackground
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignLeft + Qt.AlignVCenter
            Layout.leftMargin: 5
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    openIconBackground.color = (containsMouse) ? "lightgrey" : "transparent"
                }
                onClicked: {
                    console.log("open file button clicked")
                    fileDialog.visible = true
                }
            }
            Label {
                id: openIconLabel
                text: "<b>Open</b>"
                color: "white"
                anchors {
                    top: openIconBackground.bottom
                    horizontalCenter: openIcon.horizontalCenter
                }
            }
            Image {
                id: openIcon
                source: "Images/openFolderIcon.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

            }
        }
        Rectangle {
            id: saveIconBackground
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignLeft + Qt.AlignVCenter
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    saveIconBackground.color = (containsMouse) ? "lightgrey" : "transparent"
                }
                onClicked: {
                    console.log("save icon clicked")
                }
            }
            Label {
                id: saveIconLabel
                text: "<b>Save</b>"
                color: "white"
                anchors {
                    top: saveIconBackground.bottom
                    horizontalCenter: saveIcon.horizontalCenter
                }
            }
            Image {
                id: saveIcon
                source: "Images/saveIcon.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

            }
        }
        Rectangle {
            id: closeIconBackground
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignLeft + Qt.AlignVCenter
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    closeIconBackground.color = (containsMouse) ? "lightgrey" : "transparent"
                }
                onClicked: {
                    console.log("close file button clicked")
                }
            }
            Label {
                id: closeIconLabel
                text: "<b>Close</b>"
                color: "white"
                anchors {
                    top: closeIconBackground.bottom
                    horizontalCenter: closeIcon.horizontalCenter
                }
            }
            Image {
                id: closeIcon
                source: "Images/closeIcon.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

            }
        }
        Rectangle {
            id: createIconBackground
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignLeft + Qt.AlignVCenter
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    createIconBackground.color = (containsMouse) ? "lightgrey" : "transparent"
                }
                onClicked: {
                    console.log("close file button clicked")
                }
            }
            Label {
                id: createIconLabel
                text: "<b>Create</b>"
                color: "white"
                anchors {
                    top: createIconBackground.bottom
                    horizontalCenter: createNewIcon.horizontalCenter
                }
            }
            Image {
                id: createNewIcon
                source: "Images/createDocumentIcon.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

            }
        }
        FileDialog {
            id: fileDialog
            visible: false
            title: "Please select a database"
            folder: shortcuts.home
            onAccepted: {
                qmlBridge.setFilePath(fileUrls.toString().replace("file://",""))
            }
        }

    }
}
