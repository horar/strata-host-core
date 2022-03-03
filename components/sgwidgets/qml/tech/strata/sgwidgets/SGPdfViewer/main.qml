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

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

ApplicationWindow {
    id: window
    visible: true
    minimumWidth: 640
    minimumHeight: 480
    width: 800
    height: 600
    title: qsTr("SGpdfTestDocument Demo")


    SGPdfViewer {
        id: pdfTestDocument
        anchors {
            fill: parent
        }
    }


    // Testing and Debug:
    footer: ToolBar {
        RowLayout {
            id: row
            anchors.fill: parent

            ToolButton {
                id: buttonLoadPdf
                text: "Load file"
                onClicked: {
                    pdfTestDocument.url = "qrc:/tech/pdfjs/minified/web/viewer.html?file=file://localhost/Users/zbgvzx/Documents/cpumemory.pdf"
                }
            }

            ToolSeparator {
            }

            ToolButton {
                id: buttonLoadEmptyPdfview
                text: "Clear view"
                onClicked: {
                    pdfTestDocument.url = "qrc:/tech/pdfjs/minified/web/viewer.html"
                }
            }

            ToolSeparator {
            }

            ToolButton {
                id: buttonReloadPage
                text: "Reload webview"
                onClicked: {
                    pdfTestDocument.reload()
                }
            }
        }
    }
}
