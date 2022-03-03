/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQml 2.12
import tech.strata.commoncpp 1.0
import "qrc:/js/navigation_control.js" as NavigationControl

QtObject {
    id: documentsHistory
    property bool displayPdfUnseenAlert: false
    property bool displayDownloadUnseenAlert: false

    property SGUserSettings documentsHistorySettings: SGUserSettings {
        classId: "documents-history"
        user: NavigationControl.context.user_id

        property var documentsHistoryFilename: view.class_id + ".json"

        function loadDocumentsHistory() {
            const settings = readFile(documentsHistoryFilename)
            return settings
        }

        function saveDocumentsHistory(documentsHistory) {
            if (Object.keys(documentsHistory).length != 0) {
                writeFile(documentsHistoryFilename, documentsHistory)
            }
        }
    }

    function processDocumentsHistory() {
        // Read existing 'documents-history' file
        let previousDocHistory = documentsHistorySettings.loadDocumentsHistory()

        // Downloads
        let downloadDocumentsData = classDocuments.downloadDocumentListModel.getMD5()
        downloadDocumentsData = JSON.parse(downloadDocumentsData)

        // Views
        let pdfData = classDocuments.pdfListModel.getMD5()
        pdfData = JSON.parse(pdfData)

        var newDownloadsHistory = {}
        Object.keys(downloadDocumentsData).forEach(function(key) {
            var insideObj = {"md5": downloadDocumentsData[key], "state": "seen"}
            newDownloadsHistory[key] = insideObj
        })

        var newViewsHistory = {}
        Object.keys(pdfData).forEach(function(key) {
            var insideObj = {"md5": pdfData[key], "state": "seen"}
            newViewsHistory[key] = insideObj
        })

        var documentChanges = {}
        if (Object.keys(previousDocHistory).length > 0) {
            Object.keys(newDownloadsHistory).forEach(function(key) {
                if (!previousDocHistory.hasOwnProperty(key)) {
                    // Key did not exist in old documents-history
                    newDownloadsHistory[key]["state"] = "new_document"
                    classDocuments.downloadDocumentListModel.setHistoryState(key, "new_document")
                } else if (previousDocHistory[key]["md5"] != newDownloadsHistory[key]["md5"]) {
                    // Key has changed from old documents-history
                    newDownloadsHistory[key]["state"] = "different_md5"
                    classDocuments.downloadDocumentListModel.setHistoryState(key, "different_md5")
                } else if (previousDocHistory[key]["state"] == "new_document") {
                    newDownloadsHistory[key]["state"] = "new_document"
                    classDocuments.downloadDocumentListModel.setHistoryState(key, "new_document")
                } else if (previousDocHistory[key]["state"] == "different_md5") {
                    newDownloadsHistory[key]["state"] = "different_md5"
                    classDocuments.downloadDocumentListModel.setHistoryState(key, "different_md5")
                }
            })

            Object.keys(newViewsHistory).forEach(function(key) {
                if (!previousDocHistory.hasOwnProperty(key)) {
                    // Key did not exist in old documents-history
                    newViewsHistory[key]["state"] = "new_document"
                    classDocuments.pdfListModel.setHistoryState(key, "new_document")
                } else if (previousDocHistory[key]["md5"] != newViewsHistory[key]["md5"]) {
                    // Key has changed from old documents-history
                    newViewsHistory[key]["state"] = "different_md5"
                    classDocuments.pdfListModel.setHistoryState(key, "different_md5")
                } else if (previousDocHistory[key]["state"] == "new_document") {
                    newViewsHistory[key]["state"] = "new_document"
                    classDocuments.pdfListModel.setHistoryState(key, "new_document")
                } else if (previousDocHistory[key]["state"] == "different_md5") {
                    newViewsHistory[key]["state"] = "different_md5"
                    classDocuments.pdfListModel.setHistoryState(key, "different_md5")
                }
            })
        }

        var newDocHistory = {};
        Object.keys(newDownloadsHistory).forEach(key => newDocHistory[key] = newDownloadsHistory[key]);
        Object.keys(newViewsHistory).forEach(key => newDocHistory[key] = newViewsHistory[key]);
        documentsHistorySettings.saveDocumentsHistory(newDocHistory)

        displayPdfUnseenAlert = classDocuments.pdfListModel.anyItemsUnseen()
        displayDownloadUnseenAlert = classDocuments.downloadDocumentListModel.anyItemsUnseen()
        if (displayPdfUnseenAlert || displayDownloadUnseenAlert) {
            var unseenPdfItems = classDocuments.pdfListModel.getItemsUnseen()
            var unseenDownloadItems = classDocuments.downloadDocumentListModel.getItemsUnseen()
            collateralContainer.launchDocumentsHistoryNotification(unseenPdfItems, unseenDownloadItems)
        }
    }

    function markDocumentAsSeen(documentName) {
        let history = documentsHistorySettings.loadDocumentsHistory()
        if (!history.hasOwnProperty(documentName)) {
            console.debug("Documents history: Failed to mark document as seen, '" + documentName + "' not found")
            return
        }

        if (history[documentName]["state"] == "seen") {
            return
        }

        history[documentName]["state"] = "seen"
        documentsHistorySettings.saveDocumentsHistory(history)
        classDocuments.pdfListModel.setHistoryState(documentName, "seen")
        classDocuments.downloadDocumentListModel.setHistoryState(documentName, "seen")

        displayPdfUnseenAlert = classDocuments.pdfListModel.anyItemsUnseen()
        displayDownloadUnseenAlert = classDocuments.downloadDocumentListModel.anyItemsUnseen()
    }

    function markAllDocumentsAsSeen() {
        let history = documentsHistorySettings.loadDocumentsHistory()
        Object.keys(history).forEach(function(key) {
            history[key]["state"] = "seen"
        })
        documentsHistorySettings.saveDocumentsHistory(history)

        classDocuments.pdfListModel.setAllHistoryStateToSeen()
        classDocuments.downloadDocumentListModel.setAllHistoryStateToSeen()

        displayPdfUnseenAlert = false
        displayDownloadUnseenAlert = false
    }
}
