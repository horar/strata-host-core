import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0

Popup {
    id: root
    height: 400
    width: 800
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: Overlay.overlay

    property alias headers: csvModel.headers
    property alias cmdName: csvModel.cmdName
    property alias folderPath: folderPath.text

    contentItem: ColumnLayout {
        id: column
        width: root.width
        height: root.height

        SGWidgets.SGText {
            id: titleText
            text: "Export CSV"
            Layout.alignment: Qt.AlignHCenter
            font.bold: true
            fontSizeMultiplier: 1.5
        }

        TableView {
            id: csvView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: csvModel

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            delegate: Rectangle {
                id: delRect
                implicitWidth: csvView.width / headers.length
                implicitHeight: 35
                border {
                    color: "black"
                    width: 1
                }

                SGWidgets.SGText {
                    anchors.centerIn: delRect
                    text: model.display
                }
            }
        }

        RowLayout {
            id: row
            Layout.fillWidth: true
            Layout.maximumHeight: 50
            Layout.leftMargin: 5
            Layout.rightMargin: 5

            RowLayout {
                id: fileNameRow
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                Rectangle {
                    id: fileLabelrect
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    SGWidgets.SGText {
                        text: "Filename: "
                        anchors.centerIn: fileLabelrect
                    }
                }

                SGWidgets.SGTextField {
                    id: fileNameField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: csvModel.cmdName
                    Layout.alignment: Qt.AlignVCenter

                    onTextChanged: {
                        csvModel.cmdName = text
                    }
                }

                Rectangle {
                    id: fileTailRect
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 25
                    SGWidgets.SGText {
                        text: ".csv"
                        anchors.centerIn: fileTailRect
                    }
                }
            }

            RowLayout {
                id: folderPathRow
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    id: folderOpenRect
                    Layout.fillHeight: true
                    Layout.preferredWidth: 50
                    border {
                        color: "black"
                        width: 1
                    }

                    SGWidgets.SGIcon {
                        id: iconButton
                        height: 35
                        width: 35
                        anchors.centerIn: folderOpenRect
                        source: "qrc:/sgimages/folder-open-solid.svg"
                        iconColor: "black"
                    }

                    MouseArea {
                        anchors.fill: folderOpenRect

                        onClicked: {
                            filePath.open()
                        }
                    }
                }

                SGWidgets.SGTextField {
                    id: folderPath
                    Layout.preferredHeight: 50
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: filePath.shortcuts.home
                }
            }

            Rectangle {
                id: exportButtonRect
                width: 50
                height: 50
                border {
                    color: "black"
                    width: 1
                }

                SGWidgets.SGIcon {
                    id: exportButton
                    width: 35
                    height: 35
                    anchors.centerIn: exportButtonRect
                    source: "qrc:/sgimages/file-export.svg"
                }

                MouseArea {
                    anchors.fill: exportButtonRect
                    enabled: folderPath.text.length > 0
                    onClicked: {
                        csvModel.writeToPath(folderPath.text)
                        root.close()
                    }
                }
            }
        }

        RowLayout {
            id: rowForImport
            Layout.fillWidth: true
            Layout.maximumHeight: 50
            Layout.leftMargin: 5
            Layout.rightMargin: 5

            RowLayout {
                id: folderImportPathRow
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    id: folderImportOpenRect
                    Layout.fillHeight: true
                    Layout.preferredWidth: 50
                    border {
                        color: "black"
                        width: 1
                    }

                    SGWidgets.SGIcon {
                        id: importIconButton
                        height: 35
                        width: 35
                        anchors.centerIn: folderImportOpenRect
                        source: "qrc:/sgimages/folder-open-solid.svg"
                        iconColor: "black"
                    }

                    MouseArea {
                        anchors.fill: folderImportOpenRect

                        onClicked: {
                            importPath.open()
                        }
                    }
                }

                SGWidgets.SGTextField {
                    id: importFolderPath
                    Layout.preferredHeight: 50
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle {
                id: importButtonRect
                width: 50
                height: 50
                border {
                    color: "black"
                    width: 1
                }

                SGWidgets.SGIcon {
                    id: importButton
                    width: 35
                    height: 35
                    anchors.centerIn: importButtonRect
                    source: "qrc:/sgimages/file-import.svg"
                }

                MouseArea {
                    anchors.fill: importButtonRect
                    enabled: importPath.accepted
                    hoverEnabled: true;

                    onClicked: {
                        importFile(importPath.fileUrl)
                    }
                }
            }
        }
    }

    FileDialog {
        id: filePath
        selectMultiple: false
        selectFolder: true
        folder: filePath.shortcuts.home

        onAccepted: {
            folderPath.text = filePath.fileUrl
            csvModel.folderPath = folderPath.text
            close()
        }
    }

    FileDialog {
        id: importPath
        selectMultiple: false
        folder: filePath.folder

        onAccepted: {
            importFolderPath.text = importPath.fileUrl
        }
    }

    SGCSVTableUtils {
        id: csvModel
        folderPath: folderPath.text

       onClearBackingModel: {
           csvView.update();
       }
    }

    function updateTableFromView(data, exportOnAdd) {
        csvModel.updateTableFromControlView(data, exportOnAdd)
    }


    function importFile(filePath) {
        const path = SGUtilsCpp.urlToLocalFile(filePath)
        csvModel.importTableFromFile(path);
    }
}
