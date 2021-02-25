import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: root
    width: parent.width
    height: wrapper.height + 20

    property alias model: repeater.model
    property var documentCurrentIndex: 0
    property bool historySeen: false

    Column {
        id: wrapper
        width: parent.width - 20
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        Repeater {
            id: repeater

            delegate: BaseDocDelegate {
                id: delegate
                width: wrapper.width

                onCategorySelected: {
                    if (helpIcon.class_id != "help_docs_demo") {
                        documentCurrentIndex = index
                        categoryOpened = "platform documents"
                    }
                    documentsHistory.markDocumentAsSeen(model.dirname + "_" + model.prettyName)
                    root.historySeen = true
                }

                property string effectiveUri: {
                    if(helpIcon.class_id === "help_docs_demo") {
                        return "qrc:/tech/strata/common/ContentView/images/" + model.uri
                    }
                    else {
                        return "file://localhost/" + model.uri
                    }
                }

                property var currentDocumentCategory: view.currentDocumentCategory
                onCurrentDocumentCategoryChanged: {
                    if(categoryOpened === "platform documents") {
                        if(currentDocumentCategory) {
                            for (var i = 0; i < repeater.count ; ++i) {
                                if(i === documentCurrentIndex) {
                                    if(repeater.itemAt(documentCurrentIndex)) {
                                        repeater.itemAt(documentCurrentIndex).checked  = true
                                    }
                                    return
                                }
                            }
                        }
                    }
                }

                Binding {
                    target: delegate
                    property: "checked"
                    value: {
                        pdfViewer.url.toString() === effectiveUri
                    }
                }

                onCheckedChanged: {
                    if (checked) {
                        pdfViewer.url = effectiveUri
                    }
                }

                contentSourceComponent: RowLayout {
                    height: textItem.contentHeight + 8
                    spacing: 0

                    SGWidgets.SGText {
                        id: textItem
                        Layout.leftMargin: 6
                        Layout.rightMargin: 2
                        Layout.fillWidth: true
                        font.bold: delegate.checked
                        alternativeColorEnabled: delegate.checked === false
                        wrapMode: Text.Wrap
                        textFormat: Text.PlainText
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        text: {
                            /*
                                 the first regexp is looking for HTML RichText
                                 the second regexp is looking for spaces after string
                                 the third regexp is looking for spaces before string
                                 the fourth regexp is looking for tabs throughout the string
                             */
                            const htmlTags = /(<([^>]+)>)|\s*$|^\s*|\t/ig;
                            return model.dirname.replace(htmlTags,"");
                        }
                    }

                    HistoryStatus {
                        id: historyUpdate
                        Layout.rightMargin: 2
                    }

                    SGWidgets.SGIcon {
                        id: chevronImage
                        height: 12
                        width: height
                        Layout.rightMargin: 2
                        source: "qrc:/sgimages/chevron-right.svg"
                        visible: delegate.checked
                    }
                }
            }
        }
    }

    Component.onDestruction: {
        if (platformStack.documentsHistoryDisplayed || root.historySeen) {
            documentsHistory.markAllDocumentsAsSeen()
        }
    }
}
