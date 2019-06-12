import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
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
                    pdfTestDocument.url = "qrc:/minified/web/viewer.html?file=file://localhost/Users/zbgzzh/Desktop/layout.pdf"
                }
            }

            ToolSeparator {
            }

            ToolButton {
                id: buttonLoadEmptyPdfview
                text: "Clear view"
                onClicked: {
                    pdfTestDocument.url = "qrc:/minified/web/viewer.html"
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
