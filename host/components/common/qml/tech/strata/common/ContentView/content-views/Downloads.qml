import QtQuick 2.9
import QtQuick.Controls 2.3
import Qt.labs.platform 1.1

import Qt.labs.settings 1.0 as QtLabsSettings
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.sgwidgets 1.0 as SGWidgets
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

    QtLabsSettings.Settings {
        category: "Strata.Download"

        property alias savePath: downloadSection.savePath
    }

    ButtonGroup {
        id: downloadButtonGroup
        exclusive: false
        checkState: selectAllRadioButton.checkState
    }

    Column {
        id: wrapper
        width: parent.width - 20
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        SGWidgets.SGText {
            text: "Select files for download:"
            font.bold: true
            fontSizeMultiplier: 1.2
            alternativeColorEnabled: true
        }

        DocumentCheckBox {
            id: selectAllRadioButton
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

                            DocumentCheckBox {
                                id: checkbox
                                anchors.centerIn: parent

                                fakeEnabled: delegate.pressable
                                enabled: false
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

                        SGWidgets.SGText {
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
                            alternativeColorEnabled: true
                            fontSizeMultiplier: delegate.enlarge ? 1.1 : 1.0
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideNone
                            textFormat: Text.PlainText
                            maximumLineCount: 2
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

                                color: Theme.palette.green
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

                        SGWidgets.SGText {
                            id: infoItem
                            anchors {
                                top: model.status === DownloadDocumentListModel.FinishedWithError ? textItem.bottom : progressBar.bottom
                                topMargin: spacing
                                left: progressBar.left
                                right: textItem.right
                            }

                            opacity: model.status === DownloadDocumentListModel.FinishedWithError ? 1 : 0.8
                            elide: Text.ElideRight
                            alternativeColorEnabled: true
                            font.family: "Monospace"
                            text: {
                                if (model.status === DownloadDocumentListModel.Waiting) {
                                    return "Preparing to download"
                                } else if (model.status === DownloadDocumentListModel.InProgress) {
                                    var received = CommonCpp.SGUtilsCpp.formattedDataSize(model.bytesReceived)
                                    var total = CommonCpp.SGUtilsCpp.formattedDataSize(model.bytesTotal)
                                    return received + " of " + total
                                } else if (model.status === DownloadDocumentListModel.Finished) {
                                    var total = CommonCpp.SGUtilsCpp.formattedDataSize(model.bytesTotal)
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
            height: 20
        }

        Item {
            id: savePathWrapper
            width: parent.width
            height: savePathField.y + savePathField.height

            enabled: repeater.model.downloadInProgress === false

            SGWidgets.SGText {
                id: savePathLabel
                anchors {
                    top: parent.top
                }

                text: "Save folder"
                color: "white"
            }

            SGWidgets.SGTextField {
                id: savePathField
                anchors {
                    top: savePathLabel.bottom
                    left: parent.left
                    right: savePathButton.left
                    rightMargin: 4
                }

                darkMode: true
                text: savePath
                onTextChanged: {
                    savePath = text
                }

                Binding {
                    target: savePathField
                    property: "text"
                    value: savePath
                }
            }

            Button {
                id: savePathButton
                height: savePathField.height - 2
                width: height
                anchors {
                    verticalCenter: savePathField.verticalCenter
                    right: parent.right
                }

                icon.source: "qrc:/sgimages/folder-open.svg"
                onClicked: {
                    if (savePath.length === 0) {
                        fileDialog.folder = CommonCpp.SGUtilsCpp.pathToUrl(defaultSavePath)
                    } else {
                        fileDialog.folder = CommonCpp.SGUtilsCpp.pathToUrl(savePath)
                    }

                    fileDialog.open()
                }

                MouseArea {
                    id: buttonCursor
                    anchors.fill: parent
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Item {
            width: 1
            height: 10
        }

        Button {
            anchors.horizontalCenter: wrapper.horizontalCenter
            opacity: enabled ? 1 : 0.2
            enabled: savePath !== ""

            contentItem: SGWidgets.SGText{
                text: "Open Selected Save Folder"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 40
                color: Theme.palette.lightGray
            }

            onClicked: {
                if(!fileDialog.visible){
                   Qt.openUrlExternally(CommonCpp.SGUtilsCpp.pathToUrl(savePath))
                }
            }

            MouseArea {
                id: buttonCursor2
                anchors.fill: parent
                onPressed:  mouse.accepted = false
                cursorShape: Qt.PointingHandCursor
            }
        }

        Item {
            width: 1
            height: 10
        }

        Button {
            anchors {
                horizontalCenter: wrapper.horizontalCenter
            }

            opacity: enabled ? 1 : 0.2
            enabled: {
                if (downloadButtonGroup.checkState === Qt.Unchecked
                        || repeater.model.downloadInProgress
                        || savePath.length === 0 )
                {
                    return false
                }

                return true
            }

            contentItem: SGWidgets.SGText {
                text: "Download"
                alternativeColorEnabled: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            background: Rectangle {
                color: "#33b13b"
                implicitWidth: 100
                implicitHeight: 40
            }

            onClicked: {
                var url = CommonCpp.SGUtilsCpp.pathToUrl(savePath)
                repeater.model.downloadSelectedFiles(url)
            }

            MouseArea {
                id: buttonCursor1
                anchors.fill: parent
                onPressed:  mouse.accepted = false
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    FolderDialog {
        id: fileDialog
        title: qsTr("Please choose a file")
        onAccepted: {
            savePath = CommonCpp.SGUtilsCpp.urlToLocalFile(fileDialog.folder)
        }
    }

    Component.onDestruction: {
        documentsHistory.markAllDocumentsAsSeen()
    }
}
