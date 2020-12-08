import QtQuick 2.9
import QtQuick.Controls 2.3
import "content-views"

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 0.9

import tech.strata.common 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

Rectangle {
    id: view
    anchors {
        fill: parent
    }

    property string class_id: ""
    property var classDocuments: null

    property int totalDocuments: classDocuments.pdfListModel.count + classDocuments.datasheetListModel.count + classDocuments.downloadDocumentListModel.count
    onTotalDocumentsChanged: {
        if (classDocuments.pdfListModel.count > 0) {
            pdfViewer.url = "file://localhost/" + classDocuments.pdfListModel.getFirstUri()
        } else if (classDocuments.datasheetListModel.count > 0) {
            pdfViewer.url = classDocuments.datasheetListModel.getFirstUri()
        } else {
            pdfViewer.url = ""
        }

        if (classDocuments.downloadDocumentListModel.count > 0){
            empty.hasDownloads = true
        }

        if (totalDocuments > 0) {
            navigationSidebar.state = "open"
        } else {
            navigationSidebar.state = "close"
        }
    }

    Component.onCompleted: {
        classDocuments = sdsModel.documentManager.getClassDocuments(view.class_id)
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
            // Read existing 'documents-history' file
            let previousDocHistory = documentHistory.loadSettings()

            // Downloads
            let downloadDocumentsData = classDocuments.downloadDocumentListModel.getMD5()
            downloadDocumentsData = JSON.parse(downloadDocumentsData)

            // Views
            let pdfData = classDocuments.pdfListModel.getMD5()
            pdfData = JSON.parse(pdfData)

            var newDocHistory = {}
            for (var _obj in downloadDocumentsData) {
                newDocHistory[_obj] = downloadDocumentsData[_obj]
            }
            for (var _obj in pdfData) {
                newDocHistory[_obj] = pdfData[_obj]
            }

            Object.keys(newDocHistory).forEach(function(key) {
                if (Object.keys(previousDocHistory).length > 0 && !previousDocHistory.hasOwnProperty(key)) {

                    // Key did not exist in old documents-history
                    console.error("Key '" + key + "' did not exist in old documents-history!!")

                } else if (previousDocHistory[key] != newDocHistory[key]) {

                    // Key has changed from old documents-history
                    console.error("Key '" + key + "' has changed from old documents-history!!")

                }
            })

            documentHistory.saveSettings(newDocHistory)
        }
    }

    Rectangle {
        id: divider
        height: 1
        anchors {
            bottom: contentContainer.top
            left: contentContainer.left
            right: contentContainer.right
        }

        color: "#888"
    }

    Item {
        id: contentContainer
        anchors {
            top: divider.bottom
            right: view.right
            left: view.left
            bottom: view.bottom
        }

        Rectangle {
            id: navigationSidebar
            color: Qt.darker("#666")
            anchors {
                left: contentContainer.left
                top: contentContainer.top
                bottom: contentContainer.bottom
            }
            width: 0
            visible: false

            states: [
                // default state is "", width:0, visible:false
                State {
                    name: "open"
                    PropertyChanges {
                        target: navigationSidebar
                        visible: true
                        width: 300
                    }
                },
                State {
                    name: "close"
                    PropertyChanges {
                        target: navigationSidebar
                        visible: false
                    }
                }
            ]

            SGAccordion {
                id: accordion
                anchors {
                    fill: parent
                }

                // Optional Configuration:
                openCloseTime: 80           // Default: 80 (how fast the sliders pop open)
                statusIcon: "\u25B2"        // Default: "\u25B2" (triangle char)
                contentsColor: Qt.darker("#555")
                textOpenColor: "#fff"
                textClosedColor: "#ccc"
                headerOpenColor: "#666"
                headerClosedColor: "#484848"
                dividerColor: "grey"
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

                        onOpenChanged: {
                            if(open){
                                pdfAccordion.openContent.start();
                            } else {
                                pdfAccordion.closeContent.start();
                            }
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
                    }
                }
            }
        }

        Rectangle {
            id: sidebarControl
            width: 20 + rightDivider.width
            anchors {
                left: navigationSidebar.right
                top: contentContainer.top
                bottom: contentContainer.bottom
            }
            color: controlMouse.containsMouse ? "#444" : "#333"

            Rectangle {
                id: rightDivider
                width: 1
                anchors {
                    top: sidebarControl.top
                    bottom: sidebarControl.bottom
                    right: sidebarControl.right
                }
                color: "#33b13b"
            }

            SGIcon {
                id: control
                anchors {
                    centerIn: sidebarControl
                }
                iconColor: "white"
                source: "images/angle-right-solid.svg"
                height: 30
                width: 30
                rotation: navigationSidebar.visible ? 180 : 0
            }

            MouseArea {
                id: controlMouse
                anchors {
                    fill: sidebarControl
                }
                onClicked: {
                    if (navigationSidebar.state === "open") {
                        navigationSidebar.state = "close"
                    } else {
                        navigationSidebar.state = "open"
                    }
                }

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        SGPdfViewer {
            id: pdfViewer
            anchors {
                left: sidebarControl.right
                right: contentContainer.right
                top: contentContainer.top
                bottom: contentContainer.bottom
            }

            url: ""
        }

        EmptyDocuments {
            id: empty
            visible: pdfViewer.url === "" && loading.visible === false
            anchors {
                left: sidebarControl.right
                right: contentContainer.right
                top: contentContainer.top
                bottom: contentContainer.bottom
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

    SGUserSettings {
        id: documentHistory
        classId: view.class_id + "-documents-history"
        user: NavigationControl.context.user_id

        function loadSettings() {
            const settings = readFile("documents-history.json")
            return settings
        }

        function saveSettings(settings) {
            documentHistory.writeFile("documents-history.json", settings)
        }
    }
}
