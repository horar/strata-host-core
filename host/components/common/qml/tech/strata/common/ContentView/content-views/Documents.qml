import QtQuick 2.9
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: root
    width: parent.width
    height: wrapper.height + 20

    property alias model: repeater.model
    property var documentCurrentIndex: 0

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
                bottomPadding: 2

                onCategorySelected: {
                    if (helpIcon.class_id != "help_docs_demo") {
                        documentCurrentIndex = index
                        categoryOpened = "platfrom documents"
                    }
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
                    if(categoryOpened === "platfrom documents") {
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

                contentSourceComponent: Item {
                    height: textItem.contentHeight + 20

                    SGWidgets.SGText {
                        id: textItem

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: chevronImage.width + chevronImage.anchors.rightMargin
                            right: parent.right
                            rightMargin: textItem.anchors.leftMargin
                        }

                        font.bold: delegate.checked ? false : true
                        horizontalAlignment: Text.AlignHCenter
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
                        alternativeColorEnabled: delegate.checked === false
                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        textFormat: Text.PlainText
                    }

                    Rectangle {
                        id: underline
                        width: textItem.contentWidth
                        height: 1
                        anchors {
                            top: textItem.bottom
                            topMargin: 2
                            horizontalCenter: textItem.horizontalCenter
                        }

                        color: "#33b13b"
                        visible: delegate.checked
                    }

                    SGWidgets.SGIcon {
                        id: chevronImage
                        height: 20
                        width: height
                        anchors {
                            right: parent.right
                            rightMargin: 2
                            verticalCenter: parent.verticalCenter
                        }

                        source: "qrc:/sgimages/chevron-right.svg"
                        visible: delegate.checked
                    }
                }
            }
        }
    }
}
