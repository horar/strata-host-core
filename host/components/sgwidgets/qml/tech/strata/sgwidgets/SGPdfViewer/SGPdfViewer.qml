import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.6
import QtGraphicalEffects 1.12

Item {
    id: root
    property string url: "datasheet-unavailable"

    signal error()

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

        Rectangle {
            id: barContainer
            color: "white"
            anchors {
                centerIn: webEngine
            }
            width: progressBar.width + 40
            height: progressBar.height + 60
            z: webEngine.z+1
            visible: progressBar.visible

            ProgressBar {
                id: progressBar
                anchors {
                    centerIn: barContainer
                    verticalCenterOffset: 10
                }
                height: 10
                width: webEngine.width/2
                z: webEngine.z + 2
                visible: value !== 100
                from: 0
                to: 100
                value: webEngine.loadProgress

                Text {
                    text: "Loading PDF Viewer..."
                    anchors {
                        bottom: progressBar.top
                        bottomMargin: 10
                        horizontalCenter: progressBar.horizontalCenter
                    }
                }
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
                z: -1
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
                root.error()
            }
        }

        Rectangle {
            id: disabledCoverUp
            color: "black"
            opacity: 0.6
            anchors {
                fill: parent
            }
            z: 20
            visible: !webEngine.enabled && !progressBar.visible && !notAvailableCoverUp.visible
        }

        Text {
            text: "No Document Loaded"
            color: "white"
            anchors {
                centerIn: disabledCoverUp
            }
            z: disabledCoverUp.z
            visible: disabledCoverUp.visible
        }

        Rectangle {
            id: notAvailableCoverUp
            color: "black"
            opacity: 0.6
            anchors {
                fill: parent
            }
            z: 20
            visible: root.url === "datasheet-unavailable"
        }

        Text {
            text: "Datasheet Unavailable<br><br>Please contact your local sales representative"
            color: "white"
            font {
                pixelSize: 20
            }
            wrapMode: Text.Wrap
            width: notAvailableCoverUp.width
            anchors {
                centerIn: notAvailableCoverUp
            }
            horizontalAlignment: Text.AlignHCenter
            z: notAvailableCoverUp.z
            visible: notAvailableCoverUp.visible
        }
    }
}
