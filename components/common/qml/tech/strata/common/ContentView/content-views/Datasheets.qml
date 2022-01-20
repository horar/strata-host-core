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
import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: datasheet
    height: wrapper.height + 20
    width: parent.width

    property alias model: sortModel.sourceModel
    property var datasheetCurrentIndex: 0

    Column {
        id: wrapper
        width: parent.width - 20
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        SGSortFilterProxyModel {
            id: sortModel

            sortEnabled: true
            invokeCustomLessThan: true

            function lessThan(index1, index2) {
                // sort list according to category
                var item1 = sourceModel.dirname(index1)
                var item2 = sourceModel.dirname(index2)

                return item1.toLowerCase().localeCompare(item2.toLowerCase()) < 0
            }

            function previousDirname(index) {
                if (index - 1 < 0)
                    return undefined;

                index = mapIndexToSource(index - 1);
                return sourceModel.dirname(index)
            }
        }

        Repeater {
            id: repeater
            model: sortModel

            delegate: BaseDocDelegate {
                id: delegate
                width: wrapper.width

                onCategorySelected: {
                    if(helpIcon.class_id != "help_docs_demo") {
                        datasheetCurrentIndex = index
                        categoryOpened = "platform datasheets"
                    }
                }

                property var currentDocumentCategory: view.currentDocumentCategory
                onCurrentDocumentCategoryChanged: {
                    if(categoryOpened === "platform datasheets") {
                        if(currentDocumentCategory) {
                            for (var i = 0; i < repeater.count ; ++i) {
                                if(i === datasheetCurrentIndex) {
                                    if(repeater.itemAt(datasheetCurrentIndex)) {
                                        repeater.itemAt(datasheetCurrentIndex).checked  = true
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
                    value: pdfViewer.url.toString() === model.uri
                }

                onCheckedChanged: {
                    if (checked) {
                        pdfViewer.url = model.uri
                    }
                }

                contentSourceComponent: Item {
                    height: textItem.contentHeight + 8

                    SGWidgets.SGText {
                        id: textItem
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left:  parent.left
                            leftMargin: 6
                            right: chevronImage.left
                        }
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
                            return model.prettyName.replace(htmlTags,"");
                        }
                    }

                    SGWidgets.SGIcon {
                        id: chevronImage
                        height: 12
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

                headerSourceComponent: {
                    if (model.dirname !== sortModel.previousDirname(model.index)) {
                        return sectionDelegateComponent
                    }

                    return undefined
                }

                Component {
                    id: sectionDelegateComponent

                    SectionDelegate {
                        text: model.dirname
                        isFirst: model.index === 0
                    }
                }
            }
        }
    }
}
