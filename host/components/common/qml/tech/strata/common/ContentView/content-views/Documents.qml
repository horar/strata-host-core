import QtQuick 2.9
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: root
    width: parent.width
    height: wrapper.height + 20

    property alias model: repeater.model

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

                property string effectiveUri: "file://localhost/" + model.uri

                Binding {
                    target: delegate
                    property: "checked"
                    value: pdfViewer.url.toString() === effectiveUri
                }

                onCheckedChanged: {
                    if (checked) {
                        pdfViewer.url = effectiveUri
                        documentsHistory.markDocumentAsSeen(model.dirname + "_" + model.prettyName)
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

                    Rectangle {
                        id: historyUpdate
                        width: model.historyState == "new_document" ? 50 : 80
                        height: 20
                        radius: width/2
                        color: "green"
                        visible: model.historyState != "seen"
                        anchors {
                            right: textItem.right
                            rightMargin: 2
                            verticalCenter: parent.verticalCenter
                        }

                        Label {
                            anchors.centerIn: parent
                            text: {
                                if (model.historyState == "new_document") {
                                    return "NEW"
                                }
                                if (model.historyState == "different_md5") {
                                    return "UPDATED"
                                }
                                return ""
                            }
                            color: "white"
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
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

    Component.onDestruction: {
        documentsHistory.markAllDocumentsAsSeen()
    }
}
