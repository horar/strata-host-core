/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.3

import Qt.labs.settings 1.0 as QtLabsSettings
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sgwidgets 2.0 as SGWidgets2
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.DownloadDocumentListModel 1.0
import tech.strata.theme 1.0

Item {
    id: downloadSection

    height: wrapper.y + wrapper.height + 20
    width: parent.width

    property alias model: repeater.model
    property string savePath: defaultSavePath
    property string defaultSavePath: CommonCpp.SGUtilsCpp.urlToLocalFile(
                                         QtLabsPlatform.StandardPaths.writableLocation(
                                             QtLabsPlatform.StandardPaths.DocumentsLocation))

    property bool historySeen: false

    QtLabsSettings.Settings {
        category: "Strata.Download"

        property alias savePath: downloadSection.savePath
    }

    ButtonGroup {
        id: downloadButtonGroup
        exclusive: false
        checkState: selectAllCheckBox.checkState
    }

    Column {
        id: wrapper
        width: parent.width - 20
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 10

        SGWidgets2.SGText {
            text: "Select files for download:"
            font.bold: true
            fontSizeMultiplier: 1.2
        }

        SGWidgets2.SGCheckBox {
            id: selectAllCheckBox
            text: "Select All"
            checkState: downloadButtonGroup.checkState
            enabled: repeater.model.downloadInProgress === false
            leftPadding: 0
        }

        Column {
            width: parent.width

            Repeater {
                id: repeater

                delegate: BaseDocDelegate {
                    id: delegate
                    width: wrapper.width

                    pressable: repeater.model.downloadInProgress === false
                    uncheckable: true
                    whiteBgWhenSelected: false
                    headerSourceComponent: {
                        if (model.dirname !== model.previousDirname) {
                            return sectionDelegateComponent
                        }

                        return undefined
                    }

                    onCheckedChanged: {
                        repeater.model.setSelected(index, checked)
                        documentsHistory.markDocumentAsSeen(model.dirname + "_" + model.prettyName)
                        downloadSection.historySeen = true
                    }

                    Binding {
                        target: delegate
                        property: "checked"
                        value: model.status === DownloadDocumentListModel.Selected
                               || model.status === DownloadDocumentListModel.Waiting
                               || model.status === DownloadDocumentListModel.InProgress
                    }

                    contentSourceComponent: Item {
                        id: contentComponent
                        height: Math.ceil(textMetrics.boundingRect.height) + progressBar.height + infoItem.contentHeight + 4*spacing

                        property int spacing: 2

                        TextMetrics {
                            id: textMetrics
                            font: textItem.font
                            text: "The One"
                        }

                        Item {
                            id: checkboxWrapper
                            width: checkbox.width + 6
                            anchors {
                                left: parent.left
                                leftMargin: 4
                                top: parent.top
                                bottom: parent.bottom
                            }

                            SGWidgets2.SGCheckBox {
                                id: checkbox
                                anchors.centerIn: parent

                                enabled: delegate.pressable
                                padding: 0
                                onCheckedChanged: {
                                    delegate.checked = checked
                                }

                                Binding {
                                    target: checkbox
                                    property: "checked"
                                    value: delegate.checked
                                }

                                ButtonGroup.group: downloadButtonGroup
                            }
                        }

                        states: State {

                            AnchorChanges {
                                target: textItem
                                anchors.top: contentComponent.top
                                anchors.verticalCenter: undefined
                            }

                            PropertyChanges {
                                target: textItem
                                wrapMode: Text.NoWrap
                                elide: Text.ElideMiddle
                            }

                            when: model.status === DownloadDocumentListModel.Waiting
                                  || model.status === DownloadDocumentListModel.InProgress
                                  || model.status === DownloadDocumentListModel.Finished
                                  || model.status === DownloadDocumentListModel.FinishedWithError
                        }

                        SGWidgets2.SGText {
                            id: textItem

                            anchors {
                                verticalCenter: parent.verticalCenter
                                topMargin: spacing
                                left: checkboxWrapper.right
                                leftMargin: 6
                                right: parent.right
                                rightMargin: 4
                            }

                            text: {
                                /*
                                    the first regexp is looking for HTML RichText
                                    the second regexp is looking for spaces after string
                                    the third regexp is looking for spaces before string
                                    the fourth regexp is looking for tabs throughout the string
                                */
                                const htmlTags = /(<([^>]+)>)|\s*$|^\s*|\t/ig;
                                if (model.status === DownloadDocumentListModel.Selected
                                        || model.status === DownloadDocumentListModel.NotSelected)
                                {
                                    return model.prettyName.replace(htmlTags, "");
                                }

                                return model.downloadFilename.replace(htmlTags, "");
                            }
                            fontSizeMultiplier: delegate.enlarge ? 1.1 : 1.0
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideNone
                            textFormat: Text.PlainText
                            maximumLineCount: 2
                        }

                        HistoryStatus {
                            id: historyUpdate
                            anchors {
                                right: textItem.right
                                rightMargin: 2
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            id: progressBar
                            height: 6
                            anchors {
                                top: textItem.bottom
                                topMargin: spacing
                                left: textItem.left
                                right: textItem.right
                            }

                            visible: model.status === DownloadDocumentListModel.Waiting
                                     || model.status === DownloadDocumentListModel.InProgress
                                     || model.status === DownloadDocumentListModel.Finished

                            color: "#44ffffff"

                            Rectangle {
                                width: Math.floor((parent.width - 0) * model.progress)
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }

                                color: Theme.palette.onsemiOrange
                            }
                        }

                        Rectangle {
                            anchors {
                                verticalCenter: infoItem.verticalCenter
                                left: infoItem.left
                                margins: -1
                            }

                            width: infoItem.contentWidth + 2
                            height: infoItem.contentHeight + 2

                            radius: 2
                            color: Theme.palette.error
                            visible: model.status === DownloadDocumentListModel.FinishedWithError
                        }

                        SGWidgets2.SGText {
                            id: infoItem
                            anchors {
                                top: model.status === DownloadDocumentListModel.FinishedWithError ? textItem.bottom : progressBar.bottom
                                topMargin: spacing
                                left: progressBar.left
                                right: textItem.right
                            }

                            opacity: model.status === DownloadDocumentListModel.FinishedWithError ? 1 : 0.8
                            elide: Text.ElideRight
                            font.family: "Monospace"
                            text: {
                                if (model.status === DownloadDocumentListModel.Waiting) {
                                    return "Preparing to download"
                                } else if (model.status === DownloadDocumentListModel.InProgress) {
                                    let received = CommonCpp.SGUtilsCpp.formattedDataSize(model.bytesReceived)
                                    let total = CommonCpp.SGUtilsCpp.formattedDataSize(model.bytesTotal)
                                    return received + " of " + total
                                } else if (model.status === DownloadDocumentListModel.Finished) {
                                    let total = CommonCpp.SGUtilsCpp.formattedDataSize(model.bytesTotal)
                                    return "Done " + total
                                } else if (model.status === DownloadDocumentListModel.FinishedWithError) {
                                    return model.errorString
                                }
                                return ""
                            }
                        }
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

        Item {
            width: 1
            height: 10
        }

        Column {
            id: savePathWrapper

            spacing: 5
            width: parent.width
            enabled: repeater.model.downloadInProgress === false

            SGWidgets2.SGText {
                id: savePathLabel

                text: "Save folder"
            }

            SGWidgets.SGTextField {
                id: savePathField

                width: savePathWrapper.width
                contextMenuEnabled: true
                text: savePath
                onTextChanged: {
                    savePath = text
                }
                palette.highlight: Theme.palette.onsemiOrange

                Binding {
                    target: savePathField
                    property: "text"
                    value: savePath
                }
            }

            Row {
                spacing: 5

                SGWidgets2.SGButton {
                    id: savePathButton
                    text: "Select"

                     onClicked: {
                        if (savePath.length === 0) {
                            fileDialog.folder = CommonCpp.SGUtilsCpp.pathToUrl(defaultSavePath)
                        } else {
                            fileDialog.folder = CommonCpp.SGUtilsCpp.pathToUrl(savePath)
                        }

                        fileDialog.open()
                     }
                }

                SGWidgets2.SGButton {
                    enabled: savePath !== ""
                    text: "Open"

                    onClicked: {
                        if(!fileDialog.visible) {
                            Qt.openUrlExternally(CommonCpp.SGUtilsCpp.pathToUrl(savePath))
                        }
                    }
                }
            }
        }

       Item {
            width: 1
            height: 20
        }

        SGWidgets2.SGButton {
            anchors.horizontalCenter: wrapper.horizontalCenter

            enabled: {
                if (downloadButtonGroup.checkState === Qt.Unchecked
                        || repeater.model.downloadInProgress
                        || savePath.length === 0 )
                {
                    return false
                }

                return true
            }
            text: "Download"
            buttonSize: SGWidgets2.SGButton.Large
            icon.source: "qrc:/sgimages/download.svg"

            onClicked: {
                var url = CommonCpp.SGUtilsCpp.pathToUrl(savePath)
                repeater.model.downloadSelectedFiles(url)
            }
        }
    }

    QtLabsPlatform.FolderDialog {
        id: fileDialog
        title: qsTr("Please choose a file")
        onAccepted: {
            savePath = CommonCpp.SGUtilsCpp.urlToLocalFile(fileDialog.folder)
        }
    }

    Component.onDestruction: {
        if (platformStack.documentsHistoryDisplayed || downloadSection.historySeen) {
            documentsHistory.markAllDocumentsAsSeen()
        }
    }
}
