import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    height: wrapper.height + 20
    width: parent.width

    property alias model: repeater.model

    Column {
        id: wrapper
        width: parent.width - 20
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        Repeater {
            id: repeater

            delegate: BaseDocDelegate {
                id: delegate
                width: wrapper.width

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

                        text: model.filename
                        alternativeColorEnabled: delegate.checked === false
                        wrapMode: Text.Wrap
                        font.bold: delegate.checked ? false : true
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
                    if (model.dirname !== model.previousDirname) {

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
