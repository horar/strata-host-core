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
import QtWebEngine 1.6
import QtGraphicalEffects 1.12
import tech.strata.commoncpp 1.0 as CommonCpp

Rectangle {
    id: root
    color: "#191919" // color of PDF.js background

    property string url: "datasheet-unavailable"
    property string remoteUrl: ""
    property string errorString: ""
    property string downloadStatus: ""

    onUrlChanged: {
        root.errorString = ""
        root.downloadStatus = ""
    }

    onRemoteUrlChanged: {
        root.errorString = ""
        root.downloadStatus = ""
        if (root.remoteUrl != "") {
            const class_id = (view.is_assisted && view.class_id.length === 0) ? view.controller_class_id : view.class_id
            sdsModel.fileDownloader.downloadDatasheetFile(root.remoteUrl, class_id)
        }
    }

    Text {
        id: loadProgress
        color: "#3f3f3f"
        anchors {
            centerIn: parent
        }
        text: "Loading PDF Viewer<br>" + webEngine.loadProgress + "%"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        visible: webEngine.loadProgress !== 100
    }

    WebEngineView {
        id: webEngine
        settings.localContentCanAccessRemoteUrls: true
        settings.localContentCanAccessFileUrls: true
        settings.localStorageEnabled: true
        anchors {
            fill: root
        }

        // Example url: "qrc:/minified/web/viewer.html?file=file://localhost/Users/zbgzzh/Desktop/layout.pdf"
        url: root.url === "datasheet-unavailable" ? "qrc:/tech/pdfjs/minified/web/viewer.html?file=" :"qrc:/tech/pdfjs/minified/web/viewer.html?file=" + root.url
        enabled: url != "qrc:/tech/pdfjs/minified/web/viewer.html?file="

        onNavigationRequested: {
            if (request.url.toString().startsWith("qrc:")) {
                // internal requests will always start with qrc:/tech/pdfjs/minified/web/viewer.html?file=...
                request.action = WebEngineNavigationRequest.AcceptRequest
            } else {
                // external request when user clicked on hyperlink should be opened in dedicated browser
                request.action = WebEngineNavigationRequest.IgnoreRequest
                Qt.openUrlExternally(request.url);
            }
        }

        profile: WebEngineProfile {
            onDownloadRequested: {
                download.accept()
                if (download.interruptReason === 0){
                    popupText.text = "Downloading to:" + download.path
                    popup.open()
                } else {
                    popupText.text = "Download failed:" + download.interruptReasonString
                }
            }
            onDownloadFinished: {
                console.log("download finished")
            }
        }

        Popup {
            id: popup
            x: webEngine.width/2 - this.width/2
            y: webEngine.height/2 - this.height/2
            modal: false
            closePolicy: Popup.CloseOnEscape

            DropShadow {
                width: popup.width
                height: popup.height
                horizontalOffset: 1
                verticalOffset: 3
                radius: 15.0
                samples: 30
                color: "#cc000000"
                source: popup.background
                cached: true
            }

            background: Rectangle {
                id: popupContainer
                implicitWidth: Math.min(popupText.width + 40, webEngine.width)
                implicitHeight: popupColumn.height + 40

                Column {
                    id: popupColumn
                    spacing: 10
                    anchors {
                        top: popupContainer.top
                        topMargin: 20
                        horizontalCenter: popupContainer.horizontalCenter
                    }

                    Text {
                        id: popupText
                    }

                    Button {
                        text: "Ok"
                        onClicked: {
                            popup.close()
                        }
                        anchors {
                            horizontalCenter: popupColumn.horizontalCenter
                        }
                    }
                }
            }
        }

        onJavaScriptConsoleMessage: {
            //        console.log("onJavaScriptConsoleMessage: " + " L:"+ level + " line: " + lineNumber + JSON.stringify(message))
            if (JSON.stringify(message) === "\"Uncaught (in promise) Error: An error occurred while loading the PDF.\"") {
                root.errorString = "Javascript Error: An error occurred while loading the PDF"
            }
        }
    }

    Rectangle {
        id: coverUp
        color: "black"
        opacity: 0.6
        anchors {
            fill: parent
        }
        visible: (root.url === "datasheet-unavailable") ||
                 (root.downloadStatus.length > 0) ||
                 (root.errorString.length > 0) ||
                 (!webEngine.enabled && !loadProgress.visible)
    }

    Text {
        text: {
            if (root.url === "datasheet-unavailable") {
                return "Datasheet Unavailable<br><br>Please contact your local sales representative"
            } else if (root.errorString.length > 0) {
                return root.errorString
            } else if (root.downloadStatus.length > 0) {
                return "Downloading PDF...<br>" + root.downloadStatus
            } else {
                return "No Document Loaded"
            }
        }
        color: "white"
        font.pixelSize: 20
        wrapMode: Text.Wrap
        width: coverUp.width
        anchors {
            centerIn: coverUp
        }
        horizontalAlignment: Text.AlignHCenter
        visible: coverUp.visible
    }

    Connections {
        target: sdsModel.fileDownloader

        onDownloadStatus: {
            if (root.url === "" && root.remoteUrl === fileUrl) {
                root.downloadStatus = downloadStatus
            }
        }

        onDownloadFinished: {
            if (root.url === "" && root.remoteUrl === fileUrl) {
                if (errorString) {
                    root.errorString = errorString
                } else {
                    root.url = "file://localhost/" + filePath
                    // keep the remoteUrl set so it can be used as index
                }
            }
        }
    }
}
