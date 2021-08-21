import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0

Dialog {
    id: root
    height: 500
    width: 800
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: Overlay.overlay

    property alias folderPath: folderPath.text
    property color baseColor: "#fefefe"
    property alias headerTitle: title.text

    onClosed: {
        SGCSVTableUtils.clearBackingModel()
    }

    background: Rectangle {
        color: "#ddd"
        radius: 5
    }

    header: Rectangle {
        id: headerContainer
        implicitHeight: title.paintedHeight * 2
        color: "#ccc"
        radius: 5

        RowLayout{
            anchors.fill: parent

            SGWidgets.SGText {
                id: title
                text: "CSV File Utils Manager"
                Layout.leftMargin: 5
                font.bold: true
                fontSizeMultiplier: 1.2
                alternativeColorEnabled: true
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                id: closerBackground
                color: mouseClose.containsMouse ? Qt.darker(headerContainer.color, 1.1) : "transparent"
                radius: width/2
                Layout.preferredWidth: closer.height * 1.5
                Layout.preferredHeight: Layout.preferredWidth
                Layout.rightMargin: 5
                Layout.alignment: Qt.AlignRight
                Accessible.role: Accessible.Button
                Accessible.name: "ClosePopup"
                Accessible.onPressAction: pressAction()

                function pressAction() {
                    root.close()
                }

                SGIcon {
                    id: closer
                    anchors.centerIn: closerBackground
                    anchors.horizontalCenterOffset: .5
                    anchors.verticalCenterOffset: .5
                    source: "qrc:/sgimages/times.svg"
                    height: title.paintedHeight
                    width: height
                    iconColor: "white"
                }

                MouseArea {
                    id: mouseClose
                    anchors.fill: closerBackground
                    onClicked: closerBackground.pressAction()
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                }
            }
        }
    }

    contentItem: ColumnLayout {
        id: column
        width: root.width
        height: root.height

        TableView {
            id: csvView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: SGCSVTableUtils


            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            delegate: Rectangle {
                id: delRect
                implicitWidth: csvView.width / SGCSVTableUtils.getHeadersCount()
                implicitHeight: 35
                color: "#fefefe"
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
                id: folderPathRow
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    id: folderOpenRect
                    Layout.fillHeight: true
                    Layout.preferredWidth: 50
                    color: folderOpenMouse.containsMouse ? Qt.darker(baseColor, 1.2) : "transparent"
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
                        id: folderOpenMouse
                        anchors.fill: folderOpenRect
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            changeImportOrExport(false)
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
                color: exportButtonMouse.containsMouse ? Qt.darker(baseColor, 1.1) : "transparent"
                radius: 5
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
                    id: exportButtonMouse
                    anchors.fill: exportButtonRect
                    enabled: folderPath.text.length > 0
                    hoverEnabled: enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        SGCSVTableUtils.writeToPath()
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
                    color: folderImportMouse.containsMouse ? Qt.darker(baseColor, 1.2) : "transparent"
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
                        id: folderImportMouse
                        anchors.fill: folderImportOpenRect
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            changeImportOrExport(true)
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
                color: importButtonMouse.containsMouse ? Qt.darker(baseColor, 1.1) : "transparent"
                radius: 5
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
                    id: importButtonMouse
                    anchors.fill: importButtonRect
                    enabled: filePath.accepted
                    hoverEnabled: enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        importFile(importFolderPath.text)
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

        property bool isImport: false

        onAccepted: {
            if (!isImport) {
                folderPath.text = filePath.fileUrl
                SGCSVTableUtils.overrideFolderPath(folderPath.text)
            } else {
                importFolderPath.text = filePath.fileUrl
                const path = SGUtilsCpp.parentDirectoryPath(importFolderPath.text)
                SGCSVTableUtils.overrideFolderPath(path);
            }
            close()
        }
    }

    function updateTableFromView(data, exportOnAdd = true) {
        SGCSVTableUtils.updateTableFromControlView(data, exportOnAdd)
    }


    function importFile(filePath) {
        const path = SGUtilsCpp.urlToLocalFile(filePath)
        SGCSVTableUtils.importTableFromFile(path);
    }

    function changeImportOrExport(_import) {
        if (_import) {
            filePath.selectMultiple = false
            filePath.selectFolder = false
            filePath.nameFilters = ["*.csv"]
            filePath.isImport = true
        } else {
            filePath.selectMultiple = false
            filePath.selectFolder = true
            filePath.isImport = false
        }
        filePath.open()
    }
}
