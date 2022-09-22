/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1 as QtLabsSettings
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.theme 1.0
import tech.strata.logconf 1.0
import tech.strata.pluginLogger 1.0

GridLayout {
    id: logExportGrid

    property string appName
    property string defaultExportPath: CommonCpp.SGUtilsCpp.urlToLocalFile(
                                           QtLabsPlatform.StandardPaths.writableLocation(
                                               QtLabsPlatform.StandardPaths.DesktopLocation))
    property int innerSpacing: 5
    property int maximumWidth: 300
    property bool logExportInProgress: false

    columns: 3
    rows: 3
    columnSpacing: innerSpacing
    rowSpacing: innerSpacing
    enabled: appName !== ""

    QtLabsSettings.Settings {
        id: settings
        category: "LogExport"

        property alias exportPath: exportPathField.text
        property alias openFolder: openFolderCheckBox.checked
    }

    LogFilesCompress {
        id: logFilesCompress
    }

    SGWidgets.SGTextField {
        id: exportPathField
        Layout.fillWidth: true

        text: settings.value("exportPath",defaultExportPath)
        placeholderText: "Select export path..."

        onTextChanged: {
            warningText.visible = false
        }
    }

    SGWidgets.SGIconButton {
        icon.source: "qrc:/sgimages/folder-open.svg"
        hintText: "Select export path"
        onClicked: {
            if (exportPathField.text.length === 0) {
                fileDialog.folder = CommonCpp.SGUtilsCpp.pathToUrl(defaultExportPath)
            } else {
                fileDialog.folder = CommonCpp.SGUtilsCpp.pathToUrl(exportPathField.text)
            }

            fileDialog.open()
        }
    }

    SGWidgets.SGButton {
        id: logExportButton

        Layout.maximumWidth: height + 2
        text: "Export"
        enabled: logExportInProgress === false && exportPathField.text.length > 0

        onClicked: {
            exportLogs()
        }
    }

    SGWidgets.SGText {
        id: warningText
        Layout.columnSpan: 3
        Layout.maximumWidth: maximumWidth

        visible: false
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
    }

    SGWidgets.SGCheckBox {
        id: openFolderCheckBox
        Layout.columnSpan: 3

        text: "Open folder after saving"
        checked: settings.value("openFolder", false)
    }

    QtLabsPlatform.FolderDialog {
        id: fileDialog
        currentFolder: defaultExportPath
        title: qsTr("Please choose a file")
        onAccepted: {
            exportPathField.text = CommonCpp.SGUtilsCpp.urlToLocalFile(fileDialog.folder)
        }
    }

    Connections {
        target: logFilesCompress

        onShowExportMessage: {
            if (error) {
                warningText.color = Theme.palette.error
                console.warn(Logger.lcuCategory, msg)
            } else {
                warningText.color = Theme.palette.success
                console.info(Logger.lcuCategory, msg)
            }

            warningText.text = msg
            warningText.visible = true
        }

        onNonExistentDirectory: { //export path does not exist
            showCreateFolderDialog(exportPathField.text)
        }
    }

    function finishExport() {
        var fileNamesToZip  = [appName]
        if (Qt.application.name === "Strata Developer Studio") {
            fileNamesToZip.push("Host Controller Service")
        }
        if (logFilesCompress.logExport(exportPathField.text, fileNamesToZip) && openFolderCheckBox.checked) {
            Qt.openUrlExternally(CommonCpp.SGUtilsCpp.pathToUrl(exportPathField.text))
        }
    }

    function exportLogs() {
        logExportInProgress = true
        if(logFilesCompress.checkExportPath(exportPathField.text)) { //export path exists
            finishExport()
        }
        logExportInProgress = false
    }

    function showCreateFolderDialog(exportPath) {
        var dialog = SGDialogJS.createDialog(
                    ApplicationWindow.window,
                    "qrc:/CreateFolderDialog.qml", {
                        "filePath": exportPath
                    })

        dialog.accepted.connect(function() { //create new directory
            logExportInProgress = true
            if (logFilesCompress.createFolderForFile(exportPath)) {
                console.log(Logger.lcuCategory, "Created directory " + exportPath)
                finishExport()
            }
            dialog.destroy()
            logExportInProgress = false
        })

        dialog.rejected.connect(function() { //do not create new directory
            console.log(Logger.lcuCategory, "Directory " + exportPath + " not created")
            dialog.destroy()
        })
        dialog.open()
    }
}
