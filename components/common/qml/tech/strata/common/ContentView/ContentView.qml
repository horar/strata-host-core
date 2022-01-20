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
import QtQuick.Layouts 1.12

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as SGWidgets1
import tech.strata.common 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/navigation_control.js" as NavigationControl

import "content-views"

Item {
    id: view
    anchors {
        fill: parent
    }

    property string class_id: ""
    property string controller_class_id: ""
    property bool is_assisted: false
    property string help_tour_id: ""
    property var classDocuments: null
    property var fakeHelpDocuments: null
    property bool pdfAccordionState: false
    property bool datasheetAccordionState: false
    property bool downloadAccordionState: false
    property var currentDocumentCategory : false
    property string categoryOpened: "platform documents"
    signal finished()

    property int totalDocuments: classDocuments.pdfListModel.count + classDocuments.datasheetListModel.count + classDocuments.downloadDocumentListModel.count

    onTotalDocumentsChanged: {
        if(helpIcon.class_id === "help_docs_demo" ) {
            pdfViewer.url = "qrc:/tech/strata/common/ContentView/images/" + classDocuments.pdfListModel.getFirstUri()
        }
        else {
            if (classDocuments.pdfListModel.count > 0) {
                pdfViewer.url = "file://localhost/" + classDocuments.pdfListModel.getFirstUri()
            } else if (classDocuments.datasheetListModel.count > 0) {
                pdfViewer.url = classDocuments.datasheetListModel.getFirstUri()
            } else {
                pdfViewer.url = ""
            }
        }

        if (classDocuments.downloadDocumentListModel.count > 0){
            empty.hasDownloads = true
        }

        if (totalDocuments > 0) {
            navigationSidebar.visible = true
        } else {
            navigationSidebar.visible = false
        }
    }

    HelpButton {
        id: helpIcon
        height: 30
        width: 30
        anchors {
            right: view.right
            bottom: view.bottom
            margins: 40
        }
        z: 2

        Rectangle {
            // white icon backround fill
            anchors {
                centerIn: parent
            }
            width: parent.width + 2
            height: width
            radius: width/2
            z:-1
        }
    }

    Connections {
        target: Help.utility
        onTour_runningChanged: {
            if(tour_running === false && visible) {
                helpIcon.class_id = view.class_id
                accordion.contentItem.children[0].open = pdfAccordionState
                accordion.contentItem.children[1].open = datasheetAccordionState
                accordion.contentItem.children[2].open = downloadAccordionState
                currentDocumentCategory = true
                const class_id = (view.is_assisted && view.class_id.length === 0) ? view.controller_class_id : view.class_id
                classDocuments = sdsModel.documentManager.getClassDocuments(class_id)
            }
        }
    }

    Component.onCompleted: {
        const class_id = (view.is_assisted && view.class_id.length === 0) ? view.controller_class_id : view.class_id
        classDocuments = sdsModel.documentManager.getClassDocuments(class_id)
        helpIcon.class_id = class_id
        let previousDeviceId = Help.current_device_id
        // generate a uuidv4
        help_tour_id = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        })
        Help.setDeviceId(help_tour_id)
        Help.registerTarget(accordion.contentItem.children[0],"Use this menu to select platform-specific documents for viewing.",0,"contentViewHelp")
        Help.registerTarget(accordion.contentItem.children[1],"This menu includes part-specific datasheets for viewing.",1,"contentViewHelp")
        Help.registerTarget(accordion.contentItem.children[2],"Select and download files related to this platform here.",2,"contentViewHelp")
        Help.registerTarget(pdfViewerContainer,"This pane displays the documents selected from the left menu.",3,"contentViewHelp")
        Help.current_device_id = previousDeviceId
    }

    Connections {
        target: classDocuments
        onErrorStringChanged: {
            if (classDocuments.errorString.length > 0) {
                pdfViewer.url = ""
                loadingImage.currentFrame = 0
            }
        }

        onMd5Ready: {
            documentsHistory.processDocumentsHistory()
        }
    }

    Connections {
        target: Help.utility
        onInternal_tour_indexChanged: {
            if (helpIcon.class_id === "help_docs_demo") {
                accordion.contentItem.children[0].open = (Help.current_tour_targets[index]["target"] === accordion.contentItem.children[0])
                accordion.contentItem.children[1].open = (Help.current_tour_targets[index]["target"] === accordion.contentItem.children[1])
                accordion.contentItem.children[2].open = (Help.current_tour_targets[index]["target"] === accordion.contentItem.children[2])
            }
        }
    }

    SGWidgets1.SGSplitView {
        id: contentContainer
        anchors {
            fill: parent
        }

        Rectangle {
            id: navigationSidebar
            color: Qt.darker("#666")
            Layout.fillHeight: true
            Layout.minimumWidth: 100
            implicitWidth: 300
            visible: false

            SGAccordion {
                id: accordion
                anchors {
                    fill: parent
                }

                contentsColor: Qt.darker("#555")
                textClosedColor: "#ccc"
                headerClosedColor: "#484848"
                dividerColor: contentsColor
                exclusive: false

                accordionItems: Column {
                    SGAccordionItem {
                        id: pdfAccordion
                        title: "Platform Documents"
                        contents: Documents {
                            model: classDocuments.pdfListModel
                        }
                        open: pdfAccordion.visible
                        visible: classDocuments.pdfListModel.count > 0

                        Accessible.role: Accessible.Button
                        Accessible.name: title

                        onOpenChanged: {
                            if (open){
                                pdfAccordion.openContent.start();
                            } else {
                                pdfAccordion.closeContent.start();
                            }
                        }

                        HistoryStatus {
                            visible: documentsHistory.displayPdfUnseenAlert && !parent.open
                            anchors {
                                right: parent.right
                                rightMargin: 2 + titleBarHeight
                                top: parent.top
                                topMargin: (titleBarHeight - height) / 2
                            }
                            text: "UPDATED"

                            property real titleBarHeight: parent.children[0].height
                        }
                    }

                    SGAccordionItem {
                        id: datasheetAccordion
                        title: "Part Datasheets"
                        contents: Datasheets {
                            model: classDocuments.datasheetListModel
                        }
                        open: !pdfAccordion.visible && datasheetAccordion.visible
                        visible: classDocuments.datasheetListModel.count > 0

                        onOpenChanged: {
                            if(open){
                                datasheetAccordion.openContent.start();
                            } else {
                                datasheetAccordion.closeContent.start();
                            }
                        }
                    }

                    SGAccordionItem {
                        id: downloadAccordion
                        title: "Downloads"
                        contents: Downloads {
                            model: classDocuments.downloadDocumentListModel

                        }
                        open: !pdfAccordion.visible && !datasheetAccordion.visible && downloadAccordion.visible
                        visible: classDocuments.downloadDocumentListModel.count > 0

                        onOpenChanged: {
                            if(open){
                                downloadAccordion.openContent.start();
                            } else {
                                downloadAccordion.closeContent.start();
                            }
                        }

                        HistoryStatus {
                            visible: documentsHistory.displayPdfUnseenAlert && !parent.open
                            anchors {
                                right: parent.right
                                rightMargin: 2 + titleBarHeight
                                top: parent.top
                                topMargin: (titleBarHeight - height) / 2
                            }
                            text: "UPDATED"

                            property real titleBarHeight: parent.children[0].height
                        }
                    }
                }
            }
        }

        SGPdfViewer {
            id: pdfViewer
            Layout.fillHeight: true
            Layout.fillWidth: true

            url: ""

            Item {
                id: pdfViewerContainer
                width: parent.width
                height: parent.height - 250
                anchors {
                    top: pdfViewer.top
                    topMargin: 10
                }
            }

            EmptyDocuments {
                id: empty
                visible: pdfViewer.url === "" && loading.visible === false
                anchors {
                    fill: parent
                }
            }
        }
    }

    Item {
        id: loading
        anchors {
            fill: view
        }

        visible: loadingText.text.length

        Rectangle {
            color: "#222"
            opacity: .5
            anchors {
                fill: parent
            }
        }

        AnimatedImage {
            id: loadingImage
            source: "images/docLoading.gif"
            anchors {
                centerIn: loading
                verticalCenterOffset: -height/4
            }
            playing: classDocuments.loading
            height: 200
            width: 200
        }

        Text {
            id: loadingText
            color: "#fff"
            anchors {
                top: loadingImage.bottom
                horizontalCenter: loading.horizontalCenter
            }
            font {
                pixelSize: 30
                family:  Fonts.franklinGothicBold
            }
            text: {
                if (classDocuments.errorString.length > 0) {
                    return "Error: " + classDocuments.errorString
                }

                if (classDocuments.loading) {
                    return "Downloading\n" + classDocuments.loadingProgressPercentage + "% completed"
                }

                return ""
            }

            width: 500
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            anchors { fill: loading }
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }
    }

    DocumentsHistory {
        id: documentsHistory
    }
}
