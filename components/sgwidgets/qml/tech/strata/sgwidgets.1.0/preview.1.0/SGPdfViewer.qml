/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

// LC: this component is not completed; read info bellow
import QtQuick 2.13
import QtQuick.Controls 2.13
import QtWebEngine 1.9
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

/*
  \qmltype SGPdfViewer

  \brief this is RS about migration from PDF.JS to Qt WebEngine PDF document viewer plugin

  Everything works smooth just one known issue stay at version Qt 5.13.2:
  https://bugreports.qt.io/browse/QTBUG-80159

  TODO:
  1. review/retest code with newer Qt release
  2. finalise UI/UX for find panel
*/
Item {
    id: root

    property string url: "datasheet-unavailable"

    signal error()

    Shortcut {
        sequence: StandardKey.Find

        onActivated: {
            findPanel.visible = true
        }
    }

    WebEngineView {
        id: webEngine

        settings.localContentCanAccessRemoteUrls: true
        settings.localContentCanAccessFileUrls: true
        settings.localStorageEnabled: true

        settings.errorPageEnabled: false
        settings.javascriptCanOpenWindows: false
        settings.javascriptEnabled: true
        settings.pluginsEnabled: true

        anchors.fill: parent

        url: root.url === "datasheet-unavailable" ? "" : root.url
        enabled: url !== ""

        onLoadingChanged: {
//            console.log(" ====> LCH " + JSON.stringify(loadRequest))
            if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
//                root.url = "datasheet-unavailable"

                console.error("loading request fails: " + loadRequest.errorString + "; domain: " + loadRequest.errorDomain)
//                var html = loadRequest.errorString;
                // TODO [lC]:implement our own error pages and load them qrc via 'loadHtml(html);'
            }
        }

        onJavaScriptConsoleMessage: {
        //            console.log("onJavaScriptConsoleMessage: " + " L:"+ level + " line: " + lineNumber + " " + JSON.stringify(message))
            if (JSON.stringify(message) === "\"Uncaught (in promise) undefined\"" || JSON.stringify(message) === "\"Uncaught Error: Assertion faile\"") {
                root.error()
            }
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
        visible: progressBar.visible

        ProgressBar {
            id: progressBar
            anchors {
                centerIn: barContainer
                verticalCenterOffset: 10
            }
            height: 10
            width: webEngine.width/2
            visible: value !== 100
            from: 0
            to: 100
            value: webEngine.loadProgress

            Text {
                text: qsTr("Loading PDF Viewer...")
                anchors {
                    bottom: progressBar.top
                    bottomMargin: 10
                    horizontalCenter: progressBar.horizontalCenter
                }
            }
        }
    }

    Rectangle {
        id: disabledCoverUp
        color: "black"
        opacity: 0.6
        anchors {
            fill: parent
        }
        visible: !webEngine.enabled && !progressBar.visible && !notAvailableCoverUp.visible

        Text {
            text: qsTr("No Document Loaded")
            color: "white"
            anchors {
                centerIn: disabledCoverUp
            }
            visible: disabledCoverUp.visible
        }
    }

    Rectangle {
        id: notAvailableCoverUp
        color: "black"
        opacity: 0.6
        anchors {
            fill: parent
        }
        visible: root.url === "datasheet-unavailable"

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
            visible: notAvailableCoverUp.visible
        }
    }

    // FIXME: [LC] move into standalone component and improve UI/UX this ugly rectangle
    Rectangle {
        id: findPanel

        visible: false
        color: "lightgray"
        opacity: 0.7
        height: 1.3 * inputField.height
        radius: height / 3

        anchors {
            bottom: parent.bottom
            bottomMargin: findRow.height // FIXME: [LC] debug bar height hack
            left: parent.left
            right: parent.right
            margins: 2 * inputField.height
        }


        Shortcut {
            sequence: StandardKey.Cancel

            onActivated: {
                findPanel.visible = false
                inputField.text = ""
            }
        }

        RowLayout {
            id: findRow

            property int findCounter: 0

            anchors.fill: parent
            anchors.margins: 5

            Label {
                id: findLabel

                text: qsTr("Find:")
            }

            TextField {
                id: inputField

                placeholderText: qsTr("Enter a text to find")

                Layout.fillWidth: true

                onAccepted: findNext.clicked()
                onTextChanged: findNext.clicked()

                Label {
                    id: findCounterLabel

                    visible: inputField.text !== ""
                    text: findRow.findCounter

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: parent.height / 2
                    }
                }
            }

            ToolButton {
                id: findPrev

                text: qsTr("<")
                enabled: inputField.text !== ""

                onClicked: {
                    webEngine.findText(inputField.text, WebEngineView.FindBackward | WebEngineView.FindCaseSensitively, function(matchCount) {
                        findRow.findCounter = matchCount
                    });
                }
            }

            ToolButton {
                id: findNext

                text: qsTr(">")
                enabled: inputField.text !== ""

                onClicked: {
                    webEngine.findText(inputField.text, WebEngineView.FindCaseSensitively, function(matchCount) {
                        findRow.findCounter = matchCount
                    });
                }
            }
        }
    }
}
