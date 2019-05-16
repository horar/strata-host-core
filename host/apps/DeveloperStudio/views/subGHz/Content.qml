import QtQuick 2.9
import QtQuick.Controls 2.3
import "content-views"
import "content-views/content-widgets"
import "qrc:/views/SGPdfViewer/"
import tech.strata.fonts 1.0

Rectangle {
    id: view
    anchors { fill: parent }

    Rectangle {
        id: divider
        color: "#888"
        anchors {
            bottom: contentContainer.top
            left: contentContainer.left
            right: contentContainer.right
        }
        height: contentContainer.anchors.topMargin
    }

    Item {
        id: contentContainer
        anchors {
            top: view.top
            right: view.right
            left: view.left
            bottom: view.bottom
            topMargin: 1
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

                accordionItems: Column {

                    SGAccordionItem {
                        id: pdfAccordion
                        title: "Platform Documents"
                        contents: Documents { }
                        open: true
                        visible: false
                        exclusive: false
                    }

                    SGAccordionItem {
                        id: datasheetAccordion
                        title: "Part Datasheets"
                        contents: Datasheets { }
                        visible: false
                        exclusive: false
                    }

                    SGAccordionItem {
                        id: downloadAccordion
                        title: "Downloads"
                        contents: Downloads { }
                        visible: false
                        exclusive: false
                    }

                    Connections {
                        target: documentManager
                        onDocumentsUpdated: {
                            updateDocState()
                        }
                    }

                    Component.onCompleted: {
                        updateDocState()
                    }

                    function updateDocState() {
                        if (documentManager.pdfDocuments.length > 0 ||
                            documentManager.datasheetDocuments.length > 0 ||
                            documentManager.downloadDocuments.length > 0) {
                            loading.visible = false
                        }

                        // set initially visible document to first pdf or first datasheet if no pdfs
                        if (documentManager.pdfDocuments.length > 0) {
                            pdfViewer.url = "file://localhost/" + documentManager.pdfDocuments[0].uri
                        } else if (documentManager.datasheetDocuments.length > 0) {
                            pdfViewer.url = documentManager.datasheetDocuments[0].uri
                        } else {
                            pdfViewer.url = ""
                        }

                        // update accordion section visibility
                        pdfAccordion.visible = documentManager.pdfDocuments.length > 0
                        datasheetAccordion.visible = documentManager.datasheetDocuments.length > 0
                        downloadAccordion.visible = documentManager.downloadDocuments.length > 0

                        // update list models
                        pdfAccordion.contentItem.model = documentManager.pdfDocuments
                        datasheetAccordion.contentItem.model = documentManager.datasheetDocuments
                        downloadAccordion.contentItem.resetModel(documentManager.downloadDocuments)
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

            Text {
                id: control
                text: "\ue811"
                font {
                    family: Fonts.sgicons
                    pixelSize: 20
                }
                color: "white"
                anchors {
                    centerIn: sidebarControl
                }
                rotation: navigationSidebar.visible ? 0 : 180
            }

            MouseArea {
                id: controlMouse
                anchors {
                    fill: sidebarControl
                }
                onClicked: {
                    if (navigationSidebar.state === "open") {
                        navigationSidebar.state = "" // "" is default closed state
                    } else {
                        navigationSidebar.state = "open"
                    }
                }
                hoverEnabled: true
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
        }
    }

    Item {
        id: loading
        anchors {
            fill: view
        }

        onVisibleChanged: {
            if (!visible) {
                navigationSidebar.state = "open"
                loadingTimer1.stop()
                loadingTimer2.stop()
                loadingText.text = "Downloading Documents..."
            } else {
                navigationSidebar.state = "" // "" is default closed state
            }
        }

        Rectangle {
            color: "#222"
            opacity: .5
            anchors {
                fill: parent
            }
        }

         AnimatedImage {
            id: loadingImage
            source: "content-views/content-widgets/docLoading.gif"
            anchors {
                centerIn: loading
                verticalCenterOffset: -height/4
            }
            playing: loading.visible
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
            text: "Downloading Documents..."
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

        Timer {
            id: loadingTimer1
            interval: 10000
            running: true
            onTriggered: {
                loadingText.text = "Downloading documents taking longer than normal..."
                loadingTimer2.start()
            }
        }

        Timer {
            id: loadingTimer2
            interval: 20000
            onTriggered: {
                loadingText.text = "Still waiting for downloads, there may be a problem with your internet connection..."
            }
        }
    }
}
