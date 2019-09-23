import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.commoncpp 1.0 as CommonCPP

SGWidgets.SGMainWindow {
    id: root

    visible: true
    height: 600
    width: 800
    minimumHeight: 600
    minimumWidth: 800

    property var exitWarningDialog: null

    title: {
        if (docCreator.currentFilePath.length > 0) {
            var text = CommonCPP.SGUtilsCpp.fileName(docCreator.currentFilePath)
        } else {
            text = docCreator.tempFileName
        }

        if (docCreator.fileEdited) {
            text += "*"
        }

        if (docCreator.currentFilePath.length > 0) {
            text += " \u2022 "
            text += CommonCPP.SGUtilsCpp.fileAbsolutePath(docCreator.currentFilePath)
        }

        if (Qt.platform.os === "windows") {
            text += " \u2022 "
            text += Qt.application.name
        }

        return text
    }

    onClosing: {
        close.accepted = false
        if (exitWarningDialog !== null) {
            return
        }

        if (docCreator.fileEdited) {
            exitWarningDialog = SGWidgets.SGDialogJS.showConfirmationDialog(
                        root,
                        "Want to save your changes first?",
                        "Your changes will be lost if you don't save them.",
                        "Save",
                        function() {
                            exitWarningDialog.destroy()
                            docCreator.saveCurrentState(
                                        undefined,
                                        function() { Qt.quit() })
                        },
                        "Don't Save",
                        function() {
                            exitWarningDialog.destroy()
                            Qt.quit()
                        })
        } else {
            Qt.quit()
        }
    }

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            title: "File"

            QtLabsPlatform.MenuItem {
                text: qsTr("&New")
                shortcut: StandardKey.New
                onTriggered:  {
                    docCreator.newFileHandler()
                }
            }

            QtLabsPlatform.MenuItem {
                text: qsTr("&Open")
                shortcut: StandardKey.Open
                onTriggered:  {
                    docCreator.openFileHandler()
                }
            }

            QtLabsPlatform.MenuSeparator {}

            QtLabsPlatform.MenuItem {
                text: qsTr("&Save")
                shortcut: StandardKey.Save
                onTriggered:  {
                    docCreator.saveFileHandler()
                }
            }

            QtLabsPlatform.MenuItem {
                text: qsTr("&Save As...")
                shortcut: StandardKey.SaveAs
                onTriggered:  {
                    docCreator.saveAsFileHandler()
                }
            }

            QtLabsPlatform.MenuSeparator {}

            QtLabsPlatform.MenuItem {
                text: qsTr("&Exit")
                shortcut: StandardKey.Quit
                onTriggered:  {
                    root.close()
                }
            }
        }

        QtLabsPlatform.Menu {
            title: "Help"
            QtLabsPlatform.MenuItem {
                text: qsTr("&About")
                onTriggered:  {
                    aboutWindowLoader.source = "qrc:/CdcAboutWindow.qml"
                }
            }
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    CdcMain {
        id: docCreator
        anchors.fill: parent
    }

    Loader {
        id: aboutWindowLoader

        Connections {
            target: aboutWindowLoader.item
            onClosing: {
                close.accepted = false
                aboutWindowLoader.source = ""
            }
        }
    }
}
